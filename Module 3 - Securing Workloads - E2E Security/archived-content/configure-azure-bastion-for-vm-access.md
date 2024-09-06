# Create an Azure Bastion to securely access your VM through a private network

## Introduction

Use Azure Bastion to provide fully managed and secure connectivity to your VMs, without any requirements for internet access.
For Linux VMs, you can use Bastion to provide secure SSH connectivity via either the Azure Portal, or your native SSH client installed on your local machine.

## Key benefits

Some of the key benefits of Azure Bastion include:

* Easy SSH access via Portal
* Easier firewall configuration since Bastion uses TCP port 443
* No public IP required for target VM(s)
* No need to manually manage NSGs to restrict access for administrative ports
* Since it's a PaaS solution, you don't need to manage the Bastion infrastructure
* Since the target VM doesn't require internet connectivity and/or open ports for SSH, the risk of port scanning and/or attack is minimized
* Bastion is inside your VNet therefore you can leverage it to access multiple different VMs
* Azure manages the Bastion infrastructure and protects you from exploits

## Use case

* Customers who want to ensure that connectivity to their VMs is fully private, and who don't have access to the VM's VNet/subnet
* Customers who create VMs with no public connectivity

## Alternatives

* Deploy your own manually configured jump host or bastion
* JIT access via public IP

## Lab

In this lab, we will configure Azure Bastion within a VNet that hosts an Azure VM, and then use Bastion to securely connect to that VM via SSH.

### Task 1: Create an Azure Bastion in an existing VNet

1. Search for **Bastions** within the Azure Portal and access the Bastions blade
2. Click **create** and then populate the following fields:
   * Resource Group - select the resource group of your VM
   * Name - Choose a suitable name for the Bastion resource
   * Region - Choose the same region as that of your VM and its VNet
   * Tier - choose the _basic_ SKU
   * Subnet - let the portal create a new subnet _AzureBastionSubnet_
   * Public IP address/name - leave as default
3. Click **Review + create**

### Task 2: Create a Key Vault and upload your SSH private key as a secret within that vault

1. Search for **Key Vault** within the portal, access the blade and create a new vault:
2. Populate the following fields (and leave the others as default)
   * Resource Group - select the resource group of your VM
   * Key vault name - choose a unique name
   * Region - select your preferred region
3. Click **Review + create**
4. Once the Key Vault is created, find it in the Azure Portal and give your Entra user **Key Vault Administrator** privileges via **Access control (IAM)**
5. Use the Azure CLI to create a secret, using your SSH private key (this needs to be done via CLI to preserve formatting): `az keyvault secret set --name <yourKeyName> --value @~/.ssh/id_rsa --vault-name <yourVaultName>`

### Task 3: Use the newly created Bastion instance to connect to your VM

Note: you will need to disable pop-up blocking for the Azure Portal in order to allow the Bastion window to be shown.

1. Find your VM within the Azure Portal, and select the **Bastion** blade beneath the **Connect** section.
2. Select **SSH Private Key from Azure Key Vault** from the **Authentication Type** field.
3. Enter your username in the respective field and then for the **Azure Key Vault Secret**, select your Key Vault and the name of the secret which you created in task 2.
4. Click on **Connect** and you should be automatically connected and signed-in to your Linux VM via a new browser tab/window.

## Further information

[Bastion documentation](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview)
