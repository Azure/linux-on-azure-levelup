# Module 1 - CentOS EOL conversion methods

Overview

In this workshop you will convert a Centos 7 system into a Red Hat Enterprise Linux 7 system.
You can also convert CentOS 7 systems to Alma Linux or Rocky distros, you can find the links to the instructions below in the Notes from the Field.

The CentOS_Lab_Hyper-V_Buildout.ps1 file is used to download the CentOS iso's and build the VM's that then can be configured  for the addtional steps in both Module 1 and Module 2.

## Run Powershell script to build out a local Hyper-V lab on a Windows 11 client.

**NOTE** The Powershell script uses 1GB of RAM per VM it builds. This can be adjusted manually within the scipt prior to running if your system does not have enough of RAM to support all the VM's. You will need at least 10GB of free RAM.

1. Download the CentOS_Lab_Hyper-V_Buildout.ps1 and run with elevated privelages from the Powershell command. Alternalety you can copy the script content into Windows PowerShell ISE and execute the scipt.

2. Once the Script has completed, you should have six new VM's as seen in the picture below:

![Linux Lab centOS EOL](images/Hyper-V-Manager-CentOS-EOL-Lab-v2.png "Linux Lab CentOS EOL")

## Install CentOS on Hyper-V VM's via the GUI

There are six VM's deployed in this lab, three of them will be used for Rehost, Redploy and Modernize sections to follow. The other three are deployed so that at any time you can explore using the different versions of distro's which include Minimal, Everything and Live ISO's to deploy and or interact with the OS.

For the three VM's that will be used for Module 1 and Module 2, you will follow the same steps to install the OS via the GUI and then update via the command line using Putty or similar program.

The three VM's we will use are:

+ LinuxLabVM-CentOS-7-EOL-2-RHEL
+ LinuxLabVM-CentOS-7-PostGreSQL
+ LinuxLabVM-CentOS-7-Apache

Follow the steps below for all three VM's listed above (EOL-2-RHEL, PostGreSQL, Apache)
1. Configure Language preference for OS install

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_1.png" alt="Language Preference" width="50%" />
</div>

2. Configure Installation Destination

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_2.png" alt="Destination" width="50%" />
</div>

3. Choose 60 GiB Virtaul Disk to install to

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_3.png" alt="Install Disk" width="50%" />
</div>

4. Configure Network (Toggle Network interface to "ON")

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_4.png" alt="Network" width="50%" />
</div>

5. Begin Installation

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_5.png" alt="Begin Install" width="50%" />
</div>

6. Set Root password to something you can remember for the lab

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_6.png" alt="Root Password" width="50%" />
</div>

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_7.png" alt="Root Password" width="50%" />
</div>

7. Let installation continue to complete (about five minutes)

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_8.png" alt="Root Password" width="50%" />
</div>

8. Reboot system

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_9.png" alt="Reboot system" width="50%" />
</div>

9. Log into VM from the console

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_10.png" alt="First time login" width="50%" />
</div>

10. Find the IP address of the VM by typing "ip addr" at the command line

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_11.png" alt="IP Address" width="50%" />
</div>

11. Using Putty log into the VM using Putty or other SSH client

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_12.png" alt="Putty" width="50%" />
</div>

12. Accept the key fingerprint

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_13.png" alt="Fingerprint" width="50%" />
</div>

13. Log into VM via SSH client

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_14.png" alt="SSH Client" width="50%" />
</div>

14. Switch to the root directory of the VM by typing "cd /" at the command line

```bash
cd /
```

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_15.png" alt="SSH Client" width="50%" />
</div>

15. Since CentOS is End of Life we need to use archived repos to update the system, so first back up the exsisting repo file by typing "sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak" at the command line

```bash
sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
```

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_16.png" alt="Back up old repo" width="50%" />
</div>

16. Using curl command lets pull down a copy of active repo's by typing the folliwing at the comamnd line "curl -o /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/AtlasGondal/centos7-eol-repo-fix/main/CentOS-Base.repo"

```bash
curl -o /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/AtlasGondal/centos7-eol-repo-fix/main/CentOS-Base.repo
```

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_18.png" alt="New repo file" width="50%" />
</div>


17. Now we need to clean the current yum cache by typing the following at the command line "sudo yum clean all"

```bash
sudo yum clean all
```

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_19.png" alt="New repo file" width="50%" />
</div>

18. Now we need to make a new yum cache by typing the following at the command line "sudo yum makecache"

```bash
sudo yum makecache
```

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_20.png" alt="New repo file" width="50%" />
</div>


19. To update the system type the follwoing at the command line "sudo yum update -y"

```bash
sudo yum update -y
```

20. Reboot the system

```bash
reboot
```

<div style="text-align: center; margin-top: 50px; margin-bottom: 50px;">
<img src="images/PostgreSQL_21.png" alt="New repo file" width="50%" />
</div>

21. Run steps 1 through 20 for all the VM's in the lab and also explority VM's

## Run the Convert2RHEL Commands on the LinuxLabVM-CentOS-7-EOL-2-RHEL VM

Now we'll actually perform the Centos to RHEL conversion. Keep in mind to use elevated privileges.

1. Via putty log into the VM as the root user.

2. Switch to the root directory

At the command type "cd /"

```bash
cd /
```


## Enabling the Convert2RHEL Repository on LinuxLabVM-CentOS-7-EOL-2-RHEL VM

The Convert2RHEL RPM is an offical Red Hat package.
Therefore it is readily availble from the Red Hat software repository (CDN).
As your CentOS server is not subscribed to the Red Hat CDN, you will need to enable the Convert2RHEL repository.

1. Get the GPG signing key by 

At the command type "curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release <https://www.redhat.com/security/data/fd431d51.txt>"

```bash
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release <https://www.redhat.com/security/data/fd431d51.txt>
```

2. Download the SSL certificate

At the command type "curl --create-dirs -o /etc/rhsm/ca/redhat-uep.pem https://ftp.redhat.com/redhat/convert2rhel/redhat-uep.pem"

```bash
curl --create-dirs -o /etc/rhsm/ca/redhat-uep.pem https://ftp.redhat.com/redhat/convert2rhel/redhat-uep.pem
```

3. Download the convert2rhel repository file

At the command type "curl -o /etc/yum.repos.d/convert2rhel.repo <https://ftp.redhat.com/redhat/convert2rhel/7/convert2rhel.repo>"

```bash
curl -o /etc/yum.repos.d/convert2rhel.repo https://ftp.redhat.com/redhat/convert2rhel/7/convert2rhel.repo
```

## Installing the Convert2RHEL Utility on LinuxLabVM-CentOS-7-EOL-2-RHEL VM

Now that the requisite repository is enabled on your CentOS Linux system, it is time to install the Convert2RHEL utility and prepare the system for conversion.

1. Before you begin the installation process, verify that you are running CentOS Linux and on the latest minor version.

At the command type "cat /etc/centos-release"

```bash
cat /etc/centos-release
```


2. Verify that the Convert2RHEL repo is enabled.

At the command type "yum repolist"

```bash
yum repolist
```

3. Install the convert2rhel utility.

At the command type "yum install -y convert2rhel"

```bash
yum install -y convert2rhel
```

## Run the Convert2RHEL Utility on LinuxLabVM-CentOS-7-EOL-2-RHEL VM

Before running the Convert2RHEL utility for this lab, you need to tell it to ignore the unknown or incompatible kernel modules.
The Microsoft kernel modules are not known to the conversion system.
Execute the following to put the override flag into your environment permanently.
Once again ensure you are on the correct server and have elevated privileges.

The below varaibles are not recommnded for converting production systems. The recommendation would be to remidiate any issues that you may have with 3rd party software prior to converting the system.

1. Allow unknown Modules varaible

At the command type "echo "export CONVERT2RHEL_ALLOW_UNAVAILABLE_KMODS=1" >> ~/.bashrc"

```bash
echo "export CONVERT2RHEL_ALLOW_UNAVAILABLE_KMODS=1" >> ~/.bashrc
```

2. Skip Tainted Kernel Modules varaible

At the command type "echo "export CONVERT2RHEL_TAINTED_KERNEL_MODULE_CHECK_SKIP=1" >> ~/.bashrc"

```bash
echo "export CONVERT2RHEL_TAINTED_KERNEL_MODULE_CHECK_SKIP=1" >> ~/.bashrc
```

3. Skip Kernel Currencey Check varaible

At the command type "echo "export CONVERT2RHEL_SKIP_KERNEL_CURRENCY_CHECK=1" >> ~/.bashrc"

```bash
echo "export CONVERT2RHEL_SKIP_KERNEL_CURRENCY_CHECK=1" >> ~/.bashrc
```

4. Skip Outdated Package Check varaible

At the command type "echo "export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1" >> ~/.bashrc"

```bash
echo "export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1" >> ~/.bashrc
```

5. Now Load the variable(s) into the active shell

At the command type "source ~/.bashrc"

```bash
source ~/.bashrc
```

6. In order to automate this process, you need to use activation key in the conversion command.

At the command type "convert2rhel --org 12451665 --activationkey convert2rhel -y"

```bash
convert2rhel --org 12451665 --activationkey convert2rhel -y
```

**NOTE**

This process takes some time!
The above process ask to confirm at several steps.
Adding a `-y` as an argument will automate the input.

Now that the conversion has been deployed successfully, you will need to reboot the system in order to put the changes into effect.
Reboot is required because the system is now running a Red Hat Enterprise Linux Kernel `kernel-3.10.0-1160.118.1.el7.x86_64`

7. Reboot the system load the new kernel.

At the command type "reboot"

```bash
reboot
```

8. Verify the system is running on Red Hat Enterprise Linux.

At the command type "cat /etc/redhat-release"

```bash
cat /etc/redhat-release
```

9. Verify that the necessary Red Hat repositories are enabled. Also, note that none of the old CentOS repos are available.

At the command type "yum repolist"

```bash
yum repolist
```

10. Now you can review the logs from the conversion itself.

At the command type "less /var/log/convert2rhel/convert2rhel.log"

```bash
less /var/log/convert2rhel/convert2rhel.log
```

Use the down arrow key or page down key to view more of the log.
To close the log, simply press the "q" key for quit.

## Congratulations

You have converted from Centos to RHEL for both VM's. Following the optional lab below you can gain access to the Azure portal and view and manage the Arc enabled VMs from this lab.

## Notes from the Field

Convert2Rhel can fail to complete for a varity of reasons, such as 3rd party packages which are not offically supported by Red Hat. In some cases there will be just a simple warning that a specfic package will not be replaced during the conversion process and the converion process will still complete. It is recommneded to check to see if the package that was skipped to ensure proper operation after the conversion and the kernel is updated and loaded.

In other cases the conversion process will initiate a roll back to the state it was before running the conversion. In these cases, you will need to either remidiate the issue such as removing the package, unloading the module from starting or changing enviromental variables that will skip the process in the conversion process.

The most common enviromental variables (Note not recommended for production systems):

Solution 1: `echo "export CONVERT2RHEL_ALLOW_UNAVAILABLE_KMODS=1" >> ~/.bashrc; source ~/.bashrc`
Solution 2: `echo "export CONVERT2RHEL_TAINTED_KERNEL_MODULE_CHECK_SKIP=1" >> ~/.bashrc; source ~/.bashrc`
Solution 3: `echo "export CONVERT2RHEL_SKIP_KERNEL_CURRENCY_CHECK=1" >> ~/.bashrc; source ~/.bashrc`
Solution 4: `echo "export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1" >> ~/.bashrc; source ~/.bashrc`

### Other supported distros to convert to from CentOS

+ AlmaLinux https://wiki.almalinux.org/elevate/ELevating-CentOS7-to-AlmaLinux-9.html
+ Rocky Linux https://docs.rockylinux.org/guides/migrate2rocky/

## Prepare RHEL VM LinuxLabVM-CentOS-7-EOL-2-RHEL VM to migrate into Azure

Current supported method for migrating a Hyper-V VM can be found here:

+ Hyper-V Host requirements 

https://learn.microsoft.com/en-us/azure/migrate/migrate-support-matrix-hyper-v-migration#hyper-v-host-requirements
+ Migrate Hyper-V VM's

https://learn.microsoft.com/en-us/azure/migrate/tutorial-migrate-hyper-v?tabs=UI

