# Create Secure Azure Resources for Linux VM

## Variables

Set the following variables to create the Azure resources.

```bash
export SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
export LOCAL_NAME="linux"
export TAGS="owner=user"
export RESOURCE_GROUP_NAME="rg-${LOCAL_NAME}-${SUFFIX}"
export PRIMARY_CLUSTER_REGION="westus3"
```

## Create Azure Resource Group

This will create a resource group in the primary region.

```bash
az group create \
    --name "$RESOURCE_GROUP_NAME" \
    --location $PRIMARY_CLUSTER_REGION \
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
    --location $PRIMARY_CLUSTER_REGION \
    --address-prefixes $VNET_CIDR \
    --tags $TAGS \
    --enable-encryption true \
    --encryption-enforcement-policy allowUnencrypted \
    --default-outbound false \
    --output tsv
```

## Create Azure Bastion Subnet

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

## Create VM Subnet

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

## Create Azure Bastion Host

```bash
export BASTION_NAME="bastion-${LOCAL_NAME}-${SUFFIX}"
export BASTION_PUBLIC_IP_NAME="bastion-ip-${LOCAL_NAME}-${SUFFIX}"

az network public-ip create \
    --name "$BASTION_PUBLIC_IP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $PRIMARY_CLUSTER_REGION \
    --allocation-method Static \
    --sku Standard \
    --tags $TAGS \
    --dns-name "$BASTION_NAME" \
    --sku Standard \
    --version IPv4 \
    --zone 1 2 3 \
    --allocation-method Static \
    --query 'properties.provisioningState' \
    --output tsv
```

### Create Azure Bastion Host with native client support and IP-based connections

```bash
az network bastion create \
    --name "$BASTION_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --vnet-name "$VNET_NAME" \
    --location "$PRIMARY_CLUSTER_REGION" \
    --public-ip-address "$BASTION_PUBLIC_IP_NAME" \
    --enable-ip-connect true \
    --enable-tunneling true \
    --sku Standard \
    --tags $TAGS \
    --query 'properties.provisioningState' \
    --output tsv
```

## Create Azure VM in the VM Subnet using Ubuntu 24.04 and NO public IP using SKU that supports VNET encryption

```bash
export VM_NAME="vm-${LOCAL_NAME}-${SUFFIX}"
export VM_SIZE="Standard_DS1_v2"
export VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
export VM_ADMIN_USER="azureuser"

az vm create \
    --name "$VM_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location $PRIMARY_CLUSTER_REGION \
    --size $VM_SIZE \
    --image $VM_IMAGE \
    --admin-username $VM_ADMIN_USER \
    --vnet-name "$VNET_NAME" \
    --subnet "$VM_SUBNET_NAME" \
    --nic-delete-option Delete \
    --accelerated-networking true \
    --storage-sku os=Premium_LRS \
    --os-disk-caching ReadWrite \
    --os-disk-delete-option Delete \
    --os-disk-size-gb 30 \
    --ssh-key-value "$HOME/.ssh/id_rsa.pub" \
    --public-ip-address "" \
    --nsg "" \
    --tags $TAGS \
    --query 'provisioningState' \
    --output tsv
```
