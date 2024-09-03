
# WIP - Not ready for testing
# Lab 1: Create Linux VMs in a Secure Environment 

In this Lab we are going to deploy two virtual machines and configure Azure networking for these VMs.  Assume that the VMs are hosting a web application with a database back-end, however an application is not deployed in the Lab. You learn how to:

> * Create a virtual network and subnet
> * Create Bastion Host
> * Create a public IP address
> * Create a front-end(webapp) VM
> * Secure network traffic with NSGs
> * Create a back-end(DB) VM


## VM networking overview

In this Lab We'll create 2 subnets for traffic segmentation, one for front-end VM and one for backend-vm  
At the end of the Lab the following virtual network resources are created:

- *myVNet* - The virtual network that the VMs use to communicate with each other and the internet.
- *myFrontendSubnet* - The subnet in *myVNet* used by the front-end resources.
- *myPublicIPAddress* - The public IP address used to access *myFrontendVM* from the internet.
- *myFrontentNic* - The network interface used by *myFrontendVM* to communicate with *myBackendVM*.
- *myFrontendVM* - The VM used to communicate between the internet and *myBackendVM*.
- *myBackendNSG* - The network security group that controls communication between the *myFrontendVM* and *myBackendVM*.
- *myBackendSubnet* - The subnet associated with *myBackendNSG* and used by the back-end resources.
- *myBackendNic* - The network interface used by *myBackendVM* to communicate with *myFrontendVM*.
- *myBackendVM* - The VM that uses port 22 and 3306 to communicate with *myFrontendVM*.

## Create a virtual network and subnet

For this tutorial, a single virtual network is created with two subnets. A front-end subnet for hosting a web application, and a back-end subnet for hosting a database server.

Before you can create a virtual network, create a resource group with [az group create](/cli/azure/group). The following example creates a resource group named *myRGNetwork* in the eastus location.
## Variables

Set the following variables to create the Azure resources.

```bash
export SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
export RESOURCE_GROUP_NAME="rg-levelup-${SUFFIX}"
export VNET_NAME="mvVNet-${SUFFIX}"
export VM_ADMIN_USER="azureuser"
export VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
export REGION="swedencentral"
```

```azurecli-interactive 
az group create --name $RESOURCE_GROUP_NAME --location $REGION
```

### Create virtual network

Use the [az network vnet create](/cli/azure/network/vnet) command to create a virtual network. In this example the network is named *mvVNet-${SUFFIX}* and is given an address prefix of *10.0.0.0/16*. A subnet is also created with a name of *myFrontendSubnet* and a prefix of *10.0.1.0/24*. Later in this tutorial a front-end VM is connected to this subnet. 

In this step we re going to create the VNET named *mvVNet-${SUFFIX}* and a subnet named *myFrontendSubnet* and a prefix of *10.0.1.0/24*. We'll put a front-end VM in the *myFrontendSubnet* later in this lab. 
See the below important features that we used while creating the VNET : 
- Outbound Internet connection is disabled with  *--default-outbound false* flag.  By default outbound internet connection is open for the VNETs. A breaking change will be happen to disable default outbound internet connection as of on xyz date. 
- VNET Encrytion is set with *--enable-encryption true* . This mean the VM traffic within the VNET will be encrypted. Virtual Network encryption is supported on general-purpose and memory optimized virtual machine instance sizes. The *--encryption-enforcement-policy * flag is for controlling if the VM ithout encryption is allowed in encrypted Virtual Network or not.

```azurecli-interactive 
az network vnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --enable-encryption true \
  --encryption-enforcement-policy allowUnencrypted 
```

```azurecli-interactive 
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name myFrontendSubnet \
  --address-prefix 10.0.1.0/24
```

### Create backend and bastion subnets
 
A new subnet is added to the virtual network using the [az network vnet subnet create](/cli/azure/network/vnet/subnet) command. In this example, the subnet is named *myBackendSubnet* and is given an address prefix of *10.0.2.0/24*. This subnet is used with all back-end services. We need to create this subnet seperatley since you can create only 1 subnet while you are creating the VNET. 

```azurecli-interactive 
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name myBackendSubnet \
  --default-outbound false \
  --address-prefix 10.0.2.0/24
```

This will create a subnet for Azure Bastion.

```bash
export BASTION_SUBNET_NAME="AzureBastionSubnet"
export BASTION_SUBNET_CIDR="10.0.3.0/26"

az network vnet subnet create \
    --name $BASTION_SUBNET_NAME \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --vnet-name "$VNET_NAME" \
    --address-prefix $BASTION_SUBNET_CIDR \
    --query 'properties.provisioningState' \
    --output tsv
```


At this point, a network has been created and segmented into three subnets, one for front-end services, one for back-end services and the last one is for bastion host. In the next section, virtual machines are created and connected to these subnets.


### Extra settings 
We're going to use EncryptionAtHost feature while creating our VMs. This settings is for using the Host Based Encryption to encrypt the disks on your VM. 
You must enable the feature for your subscription before you use the EncryptionAtHost property for your VM/VMSS. Use the following steps to enable the feature for your subscription:

Execute the following command to register the feature for your subscription

```bash
az feature register --namespace Microsoft.Compute --name EncryptionAtHost
```
Once the feature 'EncryptionAtHost' is registered, invoking 'az provider register -n Microsoft.Compute' is required to get the change propagated



### Create cloud-init file
We're going ti use the front-end VM at our next Lab. Installing some prerequisetes like firewall(ufw) , apparmor* etc. 

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

ED25519 ssh keys are public preview now. You can use ED25519 or RSA keys. ED25519 ssh keys provides better security and performance. The following command creates an SSH key pair using ED25519 encryption with a fixed length of 256 bits:

```bash
ssh-keygen -m PEM -t ed25519 -f $HOME/id_ed25519_levelup_key.pem -C "LevelUp Linux VM SSH Key"
```
## Create a public IP address for frontend VM

```azurecli-interactive
az network public-ip create --resource-group $RESOURCE_GROUP_NAME --name myPublicIPAddress
```


## Create a front-end VM

Use the [az vm create](/cli/azure/vm) command to create the VM named *myFrontendVM* using *myPublicIPAddress*.

```azurecli-interactive 
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name myFrontendVM \
  --vnet-name $VNET_NAME \
  --subnet myFrontendSubnet \
  --nsg myFrontendNSG \
  --public-ip-address myPublicIPAddress \
  --image $VM_IMAGE \
  --assign-identity \
  --accelerated-networking true \
  --storage-sku os=Premium_LRS \
  --encryption-at-host true \
  --os-disk-caching ReadWrite \
  --os-disk-delete-option Delete \
  --os-disk-size-gb 30 \
  --admin-username $VM_ADMIN_USER \
  --authentication-type ssh \
  --ssh-key-value "$HOME/id_ed25519_levelup_key.pem.pub" \
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
    --vm-name myFrontendVM \
    --output tsv
```


## Secure network traffic

### Create network security groups

A network security group can be created at the same time as a VM using the [az vm create](/cli/azure/vm) command. When doing so, the NSG is associated with the VMs network interface and an NSG rule is auto created to allow traffic on port *22* from any source. Earlier in this lab the front-end NSG was auto-created with the front-end VM. An NSG rule was also auto created for port 22. 

In some cases, it may be helpful to pre-create an NSG, such as when default SSH rules should not be created, or when the NSG should be attached to a subnet. 

Use the [az network nsg create](/cli/azure/network/nsg) command to create a network security group.

```azurecli-interactive 
az network nsg create --resource-group $RESOURCE_GROUP_NAME --name myBackendNSG
```

Instead of associating the NSG to a network interface, it is associated with a subnet. In this configuration, any VM that is attached to the subnet inherits the NSG rules.

Update the existing subnet named *myBackendSubnet* with the new NSG.

```azurecli-interactive 
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name myBackendSubnet \
  --network-security-group myBackendNSG
```

### Secure incoming traffic

When the front-end VM was created, an NSG rule was created to allow incoming traffic on port 22. This rule allows SSH connections to the VM. For this example, traffic should also be allowed on ports *80* and *443*. This configuration allows a web application to be accessed on the VM.

Use the [az network nsg rule create](/cli/azure/network/nsg/rule) command to create a rule for port *80*.

```azurecli-interactive 
az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name myFrontendNSG \
  --name httpandhttps \
  --access allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 200 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-ranges 80 443
```

The front-end VM is only accessible on port *22*, port *80* and port *443*. All other incoming traffic is blocked at the network security group. It may be helpful to visualize the NSG rule configurations. Return the NSG rule configuration with the [az network rule list](/cli/azure/network/nsg/rule) command. 

```azurecli-interactive 
az network nsg rule list --resource-group $RESOURCE_GROUP_NAME --nsg-name myFrontendNSG --output table
```

### Configure role assignments for the VM

The following example uses az role assignment create to assign the Virtual Machine Administrator Login role to the VM for your current Azure user. You obtain the username of your current Azure account by using az account show, and you set the scope to the VM created in a previous step by using az vm show.

You can also assign the scope at a resource group or subscription level. Normal Azure RBAC inheritance permissions apply.

```bash
USERNAME=$(az account show --query user.name --output tsv)

az role assignment create --role "Virtual Machine Administrator Login" --assignee $USERNAME --scope $RESOURCE_GROUP_NAME
```

### Install the SSH extension for the Azure CLI

Run the following command to add the SSH extension for the Azure CLI:

```bash
az extension add --name ssh
```

### Log in by using a Microsoft Entra user account to SSH into the Linux VM

```bash
az ssh vm --name $VM_NAME --resource-group $RESOURCE_GROUP_NAME
```

### Export the SSH configuration for use with SSH clients that support OpenSSH

Sign in to Azure Linux VMs with Microsoft Entra ID supports exporting the OpenSSH certificate and configuration. That means you can use any SSH clients that support OpenSSH-based certificates to sign in through Microsoft Entra ID. The following example exports the configuration for all IP addresses assigned to the VM:

```bash
az ssh config --file ~/.ssh/config --name $VM_NAME --resource-group $RESOURCE_GROUP_NAME
```

### Secure VM to VM traffic

Network security group rules can also apply between VMs. For this example, the front-end VM needs to communicate with the back-end VM on port *22* and *3306*. This configuration allows SSH connections from the front-end VM, and also allow an application on the front-end VM to communicate with a back-end MySQL database. All other traffic should be blocked between the front-end and back-end virtual machines.

Use the [az network nsg rule create](/cli/azure/network/nsg/rule) command to create a rule for port 22. Notice that the `--source-address-prefix` argument specifies a value of *10.0.1.0/24*. This configuration ensures that only traffic from the front-end subnet is allowed through the NSG.

NSG rule for Bastion subnet 

```azurecli-interactive 
az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name myBackendNSG \
  --name SSH \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix 10.0.3.0/26 \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "22"
```

Now add a rule for MySQL traffic on port 3306.

```azurecli-interactive 
az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name myBackendNSG \
  --name MySQL \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 200 \
  --source-address-prefix 10.0.1.0/24 \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "3306"
```

Finally, because NSGs have a default rule allowing all traffic between VMs in the same VNet, a rule can be created for the back-end NSGs to block all traffic. Notice here that the `--priority` is given a value of *300*, which is lower that both the NSG and MySQL rules. This configuration ensures that SSH and MySQL traffic is still allowed through the NSG.

```azurecli-interactive 
az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name myBackendNSG \
  --name denyAll \
  --access Deny \
  --protocol Tcp \
  --direction Inbound \
  --priority 300 \
  --source-address-prefix "*" \
  --source-port-range "*" \
  --destination-address-prefix "*" \
  --destination-port-range "*"
```


### Create public IP address for Azure NAT Gateway

The backend VM does not need a public IP, we are going to add a NAT Gateway for Outbound Internet connection. We're adding this just for LAB purposes to show how you can use NAT GW to allow outbound internet connection implicitly. 

```bash
export NAT_PUBLIC_IP_NAME="nat-ip-levelup-${SUFFIX}"

az network public-ip create \
    --name "$NAT_PUBLIC_IP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --allocation-method Static \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3 \
    --output tsv
```

### Create NAT gateway resource

```bash
export NAT_GW_NAME="nat-levelup-${SUFFIX}"

az network nat gateway create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $NAT_GW_NAME \
    --public-ip-addresses $NAT_PUBLIC_IP_NAME \
    --idle-timeout 10 \
    --location $REGION \
    --output tsv
```

### Configure NAT gateway for the backend subnet

```bash
az network vnet subnet update \
    --name myBackendSubnet \
    --resource-group $RESOURCE_GROUP_NAME \
    --vnet-name $VNET_NAME \
    --nat-gateway $NAT_GW_NAME
```

## Create Azure Bastion Host

### Create Azure Public IP for Bastion Host

```bash
export BASTION_NAME="bastion-levelup-${SUFFIX}"
export BASTION_PUBLIC_IP_NAME="bastion-ip-levelup-${SUFFIX}"

az network public-ip create \
    --name "$BASTION_PUBLIC_IP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $REGION \
    --allocation-method Static \
    --sku Standard \
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
    --query 'properties.provisioningState' \
    --output tsv
  ```  
## Create back-end VM

Now create a virtual machine, which is attached to the *myBackendSubnet*. Notice that the `--nsg` argument has a value of empty double quotes. An NSG does not need to be created with the VM. The VM is attached to the back-end subnet, which is protected with the pre-created back-end NSG. This NSG applies to the VM. Also, notice here that the `--public-ip-address` argument has a value of empty double quotes. This configuration creates a VM without a public IP address. 

```azurecli-interactive 
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name myBackendVM \
  --vnet-name $VNET_NAME \
  --subnet myBackendSubnet \
  --public-ip-address "" \
  --assign-identity \
  --nsg "" \
  --image $VM_IMAGE \
  --assign-identity \
  --accelerated-networking true \
  --storage-sku os=Premium_LRS \
  --encryption-at-host true \
  --os-disk-caching ReadWrite \
  --os-disk-delete-option Delete \
  --os-disk-size-gb 30 \
  --admin-username $VM_ADMIN_USER \
  --authentication-type ssh \
  --generate-ssh-keys
```

The back-end VM is only accessible on port *22* and port *3306* from the front-end subnet. All other incoming traffic is blocked at the network security group. It may be helpful to visualize the NSG rule configurations. Return the NSG rule configuration with the [az network rule list](/cli/azure/network/nsg/rule) command. 

```azurecli-interactive 
az network nsg rule list --resource-group $RESOURCE_GROUP_NAME --nsg-name myBackendNSG --output table
```
Connect to myBackendVM with your AD account through the Bastion Host we created above .

Get the Resource ID for the VM to which you want to connect. The Resource ID can be easily located in the Azure portal. Go to the Overview page for your VM and select the JSON View link to open the Resource JSON. Copy the Resource ID at the top of the page to your clipboard to use later when connecting to your VM.

```azurecli-interactive 
az network bastion ssh --name $BASTION_NAME --resource-group $RESOURCE_GROUP_NAME --target-resource-id "<VMResourceId or VMSSInstanceResourceId>" --auth-type "AAD"
```