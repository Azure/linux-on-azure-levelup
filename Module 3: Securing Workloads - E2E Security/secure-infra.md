
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
export REGION="westus3"
```

```azurecli-interactive 
az group create --name $RESOURCE_GROUP_NAME --location $REGION
```

### Create virtual network

Use the [az network vnet create](/cli/azure/network/vnet) command to create a virtual network. In this example, the network is named *mvVNet-${SUFFIX}* and is given an address prefix of *10.0.0.0/16*. A subnet is also created with a name of *myFrontendSubnet* and a prefix of *10.0.1.0/24*. Later in this tutorial a front-end VM is connected to this subnet. 

```azurecli-interactive 
az network vnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name myFrontendSubnet \
  --subnet-prefix 10.0.1.0/24
```

### Create subnet

A new subnet is added to the virtual network using the [az network vnet subnet create](/cli/azure/network/vnet/subnet) command. In this example, the subnet is named *myBackendSubnet* and is given an address prefix of *10.0.2.0/24*. This subnet is used with all back-end services.

```azurecli-interactive 
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name myBackendSubnet \
  --address-prefix 10.0.2.0/24
```

At this point, a network has been created and segmented into two subnets, one for front-end services, and another for back-end services. In the next section, virtual machines are created and connected to these subnets.

## Create a public IP address

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
  --image Ubuntu2404 \
  --generate-ssh-keys
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
  --destination-port-ranges 80 443 22
```

The front-end VM is only accessible on port *22*, port *80* and port *443*. All other incoming traffic is blocked at the network security group. It may be helpful to visualize the NSG rule configurations. Return the NSG rule configuration with the [az network rule list](/cli/azure/network/nsg/rule) command. 

```azurecli-interactive 
az network nsg rule list --resource-group $RESOURCE_GROUP_NAME --nsg-name myFrontendNSG --output table
```

### Secure VM to VM traffic

Network security group rules can also apply between VMs. For this example, the front-end VM needs to communicate with the back-end VM on port *22* and *3306*. This configuration allows SSH connections from the front-end VM, and also allow an application on the front-end VM to communicate with a back-end MySQL database. All other traffic should be blocked between the front-end and back-end virtual machines.

Use the [az network nsg rule create](/cli/azure/network/nsg/rule) command to create a rule for port 22. Notice that the `--source-address-prefix` argument specifies a value of *10.0.1.0/24*. This configuration ensures that only traffic from the front-end subnet is allowed through the NSG.

```azurecli-interactive 
az network nsg rule create \
  --resource-group $RESOURCE_GROUP_NAME \
  --nsg-name myBackendNSG \
  --name SSH \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix 10.0.1.0/24 \
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

## Create back-end VM

Now create a virtual machine, which is attached to the *myBackendSubnet*. Notice that the `--nsg` argument has a value of empty double quotes. An NSG does not need to be created with the VM. The VM is attached to the back-end subnet, which is protected with the pre-created back-end NSG. This NSG applies to the VM. Also, notice here that the `--public-ip-address` argument has a value of empty double quotes. This configuration creates a VM without a public IP address. 

```azurecli-interactive 
az vm create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name myBackendVM \
  --vnet-name $VNET_NAME \
  --subnet myBackendSubnet \
  --public-ip-address "" \
  --nsg "" \
  --image Ubuntu2404 \
  --generate-ssh-keys
```

The back-end VM is only accessible on port *22* and port *3306* from the front-end subnet. All other incoming traffic is blocked at the network security group. It may be helpful to visualize the NSG rule configurations. Return the NSG rule configuration with the [az network rule list](/cli/azure/network/nsg/rule) command. 

```azurecli-interactive 
az network nsg rule list --resource-group $RESOURCE_GROUP_NAME --nsg-name myBackendNSG --output table
```
