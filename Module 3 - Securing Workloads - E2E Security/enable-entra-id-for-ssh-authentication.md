# Use Entra ID and OpenSSH to sign-in to Linux VMs

To improve the security of Linux virtual machines (VMs) in Azure, you can integrate with Microsoft Entra authentication and use Entra ID as a core authentication platform and a certificate authority, instead of relying on locally stored private keys, or password-based authentication.

## Key benefits

There are several benefits to this method for authentication, including:

* Reduce the security risks of traditional password-based authentication.
* Remove the need to manage your own keys, and reduce the risk of use of SSH keys by unauthorized individuals.
* The ability to use Azure RBAC to managed user access.
* An easy way to restrict/remove user access, for instance if an individual leaves the organization.
* Ability to leverage Conditional Access to restrict access to compliant devices, users, and locations for instance.
* In-built auditing.
* Integration with Active Directory Federation Services (ADFS).

## Prerequisites

* Client must have SSH support for OpenSSH-based certificates for authentication - one option is to use Azure CLI >= 2.21.1, or Azure Cloud Shell.
* Azure CLI with SSH extension installed (`az extension add --name ssh`).
* Network connectivity (TCP) from client to public/private IP address of destination VM.
* Entra Login enabled for the Linux VM via either Azure Portal or Azure CLI/Cloud Shell.
* Role assignments configured for the respective users who should be able to login:
  * **Virtual Machine Administrator Login** for administrative users
  * **Virtual Machine User Login** for regular users
* VM must be configured with a system-assigned Managed Identity

## Use case

Customers using SSH access to manage/administer Linux VMs, who don't want to have to manage and distribute SSH keys manually.

## Alternatives

* Store SSH keys within Key Vault
* Store SSH keys locally and distribute/manage manually

## Lab

In this lab, we will configure an Azure VM to use Entra ID for authentication via SSH, and then use this method to connect to the VM for management.

### Task 1: Verify Azure CLI installation and install the SSH extension (or use Cloud Shell)

Note: these steps are only required if you are not using Cloud Shell.

1. Check if Azure CLI is installed: `which az`
   * If you do not see a path to the location of the Azure CLI executable, use the steps from [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) to install the Azure CLI.
2. Verify that the **ssh** extension is installed: `az extension list --query "[?name=='ssh']" -o table`
   * If the extension is not installed, use the command `az extension add -n ssh` to install it.

### Task 2: Confirm the VM has a system-assigned Managed Identity

1. Access the VM's **Identity** blade, from within the **Security** section
2. Confirm that the status is set to **On**, otherwise change this and click **Save**

### Task 2: Enable the AADSSHLoginForLinux extension on an existing Linux VM

1. Access the **Extensions + applications** blade from the VM's **Settings** section
2. Click **Add**, and install the extension named **Azure AD based SSH Login**

### Task 3. Configure RBAC role assignments for the VM

1. Access the VM's **Access control (IAM)** blade
2. Click **Add** to add a role assignment, and select **Virtual Machine Administrator Login** from the list of available roles
3. Click **Next**, then **Select members**, find your Entra user account and finally click **Review + assign**

### Task 4. Use Entra ID to sign-in to your Linux VM

Note: if you are using JIT then you will need to ensure you have requested JIT access to your VM prior to trying to connect via SSH.

Now that your VM and and RBAC role assignments are configured, you should be able to use the following command via Azure CLI/Cloud Shell to connect to your VM using SSH and your Entra ID user account:

`az ssh vm --resource-group <yourResourceGroupName> --name <yourVmName>`

## Further information

[Sign in to a Linux virtual machine in Azure by using Microsoft Entra ID and OpenSSH](https://learn.microsoft.com/en-us/entra/identity/devices/howto-vm-sign-in-azure-ad-linux)
