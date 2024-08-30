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
  --resource-group myRGNetwork \
  --vnet-name myVNet \
  --name myBackendSubnet \
  --address-prefix 10.0.2.0/24
```

At this point, a network has been created and segmented into two subnets, one for front-end services, and another for back-end services. In the next section, virtual machines are created and connected to these subnets.