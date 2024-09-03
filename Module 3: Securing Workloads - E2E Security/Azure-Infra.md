# Create Secure Azure Resources for Linux VM

## Variables

Set the following variables to create the Azure resources.

```bash
export SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
export LOCAL_NAME="linux"
export TAGS="owner=user"
export RESOURCE_GROUP_NAME="rg-${LOCAL_NAME}-${SUFFIX}"
export REGION="westus3"
```

## Create Azure Resource Group

This will create a resource group in the primary region.

```bash
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --tags $TAGS \
    --output tsv
```

## Create Azure VNET

This will create a private VNET with no internet access and encryption enabled for certain VM SKUs.

```bash
export VNET_NAME="vnet-${LOCAL_NAME}-${SUFFIX}"
export VNET_CIDR="10.240.0.0/16"

az network vnet create \
    --name "$VNET_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --address-prefixes $VNET_CIDR \
    --tags $TAGS \
    --enable-encryption true \
    --encryption-enforcement-policy allowUnencrypted \
    --output tsv
```

### Create Azure Bastion Subnet

This will create a subnet for Azure Bastion.

```bash
export BASTION_SUBNET_NAME="AzureBastionSubnet"
export BASTION_SUBNET_CIDR="10.240.0.0/26"

az network vnet subnet create \
    --name $BASTION_SUBNET_NAME \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --vnet-name "$VNET_NAME" \
    --address-prefix $BASTION_SUBNET_CIDR \
    --query 'properties.provisioningState' \
    --output tsv
```

### Create VM Subnet

```bash
export VM_SUBNET_NAME="subnet-vm-${LOCAL_NAME}-${SUFFIX}"
export VM_SUBNET_CIDR="10.240.0.64/26"

az network vnet subnet create \
    --name "$VM_SUBNET_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --vnet-name "$VNET_NAME" \
    --address-prefix $VM_SUBNET_CIDR \
    --query 'properties.provisioningState' \
    --output tsv
```

### Create public IP address for Azure NAT Gateway

```bash
export NAT_PUBLIC_IP_NAME="nat-ip-${LOCAL_NAME}-${SUFFIX}"

az network public-ip create \
    --name "$NAT_PUBLIC_IP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --allocation-method Static \
    --sku Standard \
    --tags $TAGS \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3 \
    --allocation-method Static \
    --output tsv
```

### Create NAT gateway resource

```bash
export NAT_GW_NAME="nat-${LOCAL_NAME}-${SUFFIX}"

az network nat gateway create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $NAT_GW_NAME \
    --public-ip-addresses $NAT_PUBLIC_IP_NAME \
    --idle-timeout 10 \
    --location $REGION \
    --output tsv
```
### Add Tag to NAT gateway resource

```bash
export NAT_GATEWAY_ID=$(az network nat gateway show \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $NAT_GW_NAME \
  --query id -o tsv)

az tag create \
  --resource-id $NAT_GATEWAY_ID \
  --tags owner=user

```

### Configure NAT gateway for the VM subnet

```bash
az network vnet subnet update \
    --name $VM_SUBNET_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --vnet-name $VNET_NAME \
    --nat-gateway $NAT_GW_NAME
```

## Create Azure Bastion Host

### Create Azure Public IP for Bastion Host

```bash
export BASTION_NAME="bastion-${LOCAL_NAME}-${SUFFIX}"
export BASTION_PUBLIC_IP_NAME="bastion-ip-${LOCAL_NAME}-${SUFFIX}"

az network public-ip create \
    --name "$BASTION_PUBLIC_IP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --allocation-method Static \
    --sku Standard \
    --tags $TAGS \
    --dns-name "$BASTION_NAME" \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3 \
    --allocation-method Static \
    --output tsv
```

### Create Azure Bastion Host with native client support and IP-based connections

```bash
az network bastion create \
    --name "$BASTION_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --vnet-name "$VNET_NAME" \
    --location "$REGION" \
    --public-ip-address "$BASTION_PUBLIC_IP_NAME" \
    --enable-ip-connect true \
    --enable-tunneling true \
    --sku Standard \
    --tags $TAGS \
    --query 'properties.provisioningState' \
    --output tsv
```

## Create Azure VM in the VM Subnet using Ubuntu 24.04 and NO public IP using SKU that supports VNET encryption

You must enable the feature for your subscription before you use the EncryptionAtHost property for your VM/VMSS. Use the following steps to enable the feature for your subscription:

Execute the following command to register the feature for your subscription

```bash
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
```

### Create cloud-init file

```bash
cat << EOF > cloud-init.txt
#cloud-config
# Install, update, and upgrade packages
package_upgrade: true
package_update: true
package_reboot_if_require: true
# Install packages
packages:
  - vim
  - ufw
  - curl
  - bash-completion
  - nginx
  - pwgen
  - libpam-pwquality
  - haveged rng-tools5
  - wget 
  - apt-transport-https 
  - gnupg
  - apparmor 
  - apparmor-utils 
  - apparmor-profiles
EOF
```

### Generate SSH key pair using ED25519 encryption

The following command creates an SSH key pair using ED25519 encryption with a fixed length of 256 bits:

```bash
ssh-keygen -m PEM -t ed25519 -f $HOME/id_ed25519_levelup_key.pem.pub -C "LevelUp Linux VM SSH Key"
```

### Create an Azure Network Security Group (NSG) for the VM

Security rules in network security groups enable you to filter the type of network traffic that can flow in and out of virtual network subnets and network interfaces. To learn more about network security groups.

```bash
export NSG_NAME="NSG-${SUFFIX}"
export NSG_RULE_NAME="Allow-Access-${SUFFIX}"
export VM_NIC_NAME="VMNic-${SUFFIX}"

az network nsg create \
    --name $NSG_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $REGION \
    --output tsv
```

#### Create Azure Network Security Group rules

Create a rule to allow connections to the virtual machine on port 22 for SSH and ports 80, 443 for HTTP and HTTPS. An extra rule is created to allow all ports for outbound connections. Use az network nsg rule create to create a network security group rule.

```bash
az network nsg rule create \
    --resource-group $RESOURCE_GROUP_NAME \
    --nsg-name $NSG_NAME \
    --name $NSG_RULE_NAME \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --priority 100 \
    --source-address-prefix '*' \
    --source-port-range '*' \
    --destination-address-prefix '*' \
    --destination-port-range 22 80 443 \
    --output tsv
```

### Create an Azure Network Interface

Use az network nic create to create the network interface for the virtual machine. The public IP addresses and the NSG created previously are associated with the NIC. The network interface is attached to the virtual network you created previously.

```bash
az network nic create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NIC_NAME \
    --location $REGION \
    --ip-forwarding false \
    --subnet $VM_SUBNET_NAME \
    --vnet-name $VNET_NAME \
    --network-security-group $NSG_NAME \
    --output tsv
```

### Create the Ubuntu Linux Azure VM

```bash
export VM_NAME="vm-${LOCAL_NAME}-${SUFFIX}"
export VM_SIZE="Standard_D2s_v4"
export VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
export VM_ADMIN_USER="azureuser"

az vm create \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --size $VM_SIZE \
    --assign-identity \
    --image $VM_IMAGE \
    --nics $VM_NIC_NAME \
    --nic-delete-option Delete \
    --storage-sku os=Premium_LRS \
    --encryption-at-host true \
    --os-disk-caching ReadWrite \
    --os-disk-delete-option Delete \
    --os-disk-size-gb 30 \
    --admin-username $VM_ADMIN_USER \
    --authentication-type ssh \
    --ssh-key-value "$HOME/id_ed25519_levelup_key.pem.pub.pub" \
    --tags $TAGS \
    --custom-data cloud-init.txt \
    --output tsv
```

### Enable Azure AD Login for a Linux virtual machine in Azure

The following code example deploys a Linux VM and then installs the extension to enable an Azure AD Login for a Linux VM. VM extensions are small applications that provide post-deployment configuration and automation tasks on Azure virtual machines.

```bash
az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory \
    --name AADSSHLoginForLinux \
    --resource-group $RESOURCE_GROUP_NAME \
    --vm-name $VM_NAME \
    --output tsv
```

### Configure role assignments for the VM

The following example uses az role assignment create to assign the Virtual Machine Administrator Login role to the VM for your current Azure user. You obtain the username of your current Azure account by using az account show, and you set the scope to the VM created in a previous step by using az vm show.

You can also assign the scope at a resource group or subscription level. Normal Azure RBAC inheritance permissions apply.

```bash
USERNAME=$(az account show --query user.name --output tsv)
RESOURCE_GROUP_ID=$(az group show --name $RESOURCE_GROUP_NAME --query id 
--output tsv)
VM_RESOURCE_ID=$(az vm show --name $VM_NAME --resource-group $RESOURCE_GROUP_NAME --query id --output tsv)

az role assignment create --role "Virtual Machine Administrator Login" --assignee $USERNAME --scope $RESOURCE_GROUP_ID
```

### Install the SSH extension for the Azure CLI

Run the following command to add the SSH extension for the Azure CLI:

```bash
az extension add --name ssh
```

### Log in by using a Microsoft Entra user account to SSH via Bastion into the Linux VM with Azure CLI

This requires Bastion extension, you will be prompted to install if missing.

```bash
az network bastion ssh --name $BASTION_NAME --resource-group $RESOURCE_GROUP_NAME --target-resource-id $VM_RESOURCE_ID --auth-type "AAD" --username $USERNAME
```

### Log in  by using a Microsoft Entra user account to SSH via Bastion using Bastion tunnel and local SSH client

Create Bastion tunnel using AZ CLI

```
az network bastion tunnel --name $BASTION_NAME --resource-group $RESOURCE_GROUP_NAME --target-resource-id $VM_RESOURCE_ID --auth-type "AAD" --username $USERNAME

```

Use local SSH client to connect to VM

```
ssh user@127.0.0.1

```

### Export the SSH configuration for use with SSH clients that support OpenSSH

Sign in to Azure Linux VMs with Microsoft Entra ID supports exporting the OpenSSH certificate and configuration. That means you can use any SSH clients that support OpenSSH-based certificates to sign in through Microsoft Entra ID. The following example exports the configuration for all IP addresses assigned to the VM:

```bash
az ssh config --file ~/.ssh/config --name $VM_NAME --resource-group $RESOURCE_GROUP_NAME
```
