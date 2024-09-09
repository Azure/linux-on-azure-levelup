# Module 1 - CentOS EOL conversion methods

Overview

In this workshop you will convert a Centos 7 system into a Red Hat Enterprise Linux 7 system.
You will also convert CentOS 7 systems to Alma Linux, CentOS Stream and Rocky distros.

The CentOS_Lab_Hyper-V_Buildout.ps1 file is used to download the CentOS iso's and build the VM's that then can be configured  for the addtional steps in both Module 1 and Module 2.

## Run Powershell script to build out a local Hyper-V lab on a Windows 11 client.

**NOTE** The Powershell script uses 1GB of RAM per VM it builds. This can be adjusted manually within the scipt prior to running if your system does not have enough of RAM to support all the VM's. You will need at least 10GB of free RAM.

1. Download the CentOS_Lab_Hyper-V_Buildout.ps1 and run with elevated privelages from the Powershell command. Alternalety you can copy the script content into Windows PowerShell ISE and execute the scipt.

2. Once the Script has completed, you should have six new VM's as seen in the picture below:

![Linux Lab centOS EOL](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Linux Lab CentOS EOL")

## Lab Access Web Server

NOTE: Accept the fingerprint when connecting by typing yes and pressing enter. You may see the message "Failed to add the host to the list of known hosts". This message can be ignored, proceed to enter the password below to connect to the server as the user devops.

Enter `devops` user password

{web_host_ssh_password}

=# Run Azure Arc Setup Commands on Web Server/Bastion

Azure Arc enables the managment and monitoring of infrastrucutre such as RHEL Servers and OpenShift deployemnts that are deployed on-premsies or in mulit-cloud enviroments.
For this lab we pre-created the installation script using a service principal that will connect the AWS VM to Azure Arc.
Once the script is executed, the connected VM will display in the Azure portal.

Connect your VM to Azure Arc

Switch to root user.
sudo -i

Change into the home directory of root

cd /root

Execute the Arc connection sript named deploy_arc.sh

./deploy_arc.sh

The azcmagent-1.39.02628-1431.x86_64 will be installed and the VM Arc resource will be associated with the resource group called RedHatSummmit2024.
You can verify the agent and its dependencies are installed in the /opt/azcmagent/bin folder.

Verify the Web App is Running After Arc Installation

Browse to {web_app}[Sample Web App^] to verify the web app is running.

Web App is Running
Northwind_Sample_Data.jpg

## Run the Convert2RHEL Commands on Web Server/Bastion

Now we'll actually do the Centos to RHEL conversion. Keep in mind to use elevated privileges.

NOTE: Verify that you are still on the bastion server as root, you can use the `whoami` and `hostname` commands to ensure you are on the correct server and user.
If not use the steps below.

Access your *httpd server VM- with the following command.

{web_host_ssh_command}

Enter `devops` user password

{web_host_ssh_password}

Switch to root user.

sudo -i

## Enabling the Convert2RHEL Repository on The Web Server/Bastion

The Convert2RHEL RPM is an offical Red Hat package.
Therefore it is readily availble from the Red Hat software repository (CDN).
As your CentOS server is not subscribed to the Red Hat CDN, you will need to enable the Convert2RHEL repository.

Get the GPG signing key

curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release <https://www.redhat.com/security/data/fd431d51.txt>

Download the SSL certificate

curl --create-dirs -o /etc/rhsm/ca/redhat-uep.pem <https://ftp.redhat.com/redhat/convert2rhel/redhat-uep.pem>

Download the convert2rhel repository file
curl -o /etc/yum.repos.d/convert2rhel.repo <https://ftp.redhat.com/redhat/convert2rhel/7/convert2rhel.repo>

## Installing the Convert2RHEL Utility

Now that the requisite repository is enabled on your CentOS Linux system, it is time to install the Convert2RHEL utility and prepare the system for conversion.

Before you begin the installation process, verify that you are running CentOS Linux and on the latest minor version.

cat /etc/centos-release

Verify that the Convert2RHEL repo is enabled.
yum repolist

Install the convert2rhel utility.

yum install -y convert2rhel

## Run the Convert2RHEL Utility

Verify that you are still on the bastion server as root, you can use the `whoami` and `hostname` commands to ensure you are on the correct server and user.
If not use the steps below.

Access your *httpd server VM- with the following command.

web_host_ssh_command

Enter `devops` user password

source,bash,subs="attributes",role=execute

web_host_ssh_password

Switch to root user.

sudo -i

Before running the Convert2RHEL utility for this lab, you need to tell it to ignore the unknown or incompatible kernel modules.
The Microsoft kernel modules are not known to the conversion system.
Execute the following to put the override flag into your environment permanently.
Once again ensure you are on the correct server and have elevated privileges.

The below varaibles are not recommnded for converting production systems. The recommendation would be to remidiate any issues that you may have with 3rd party software prior to converting the system.

Allow unknown Modules varaible

echo "export CONVERT2RHEL_ALLOW_UNAVAILABLE_KMODS=1" >> ~/.bashrc

Skip Tainted Kernel Modules varaible

echo "export CONVERT2RHEL_TAINTED_KERNEL_MODULE_CHECK_SKIP=1" >> ~/.bashrc

Skip Kernel Currencey Check varaible

echo "export CONVERT2RHEL_SKIP_KERNEL_CURRENCY_CHECK=1" >> ~/.bashrc

Skip Outdated Package Check varaible

echo "export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1" >> ~/.bashrc

Now Load the variable(s) into the active shell

source ~/.bashrc

In order to automate this process, you need to use activation key in the conversion command.

convert2rhel --org 12451665 --activationkey convert2rhel -y

This process takes some time!
The above process ask to confirm at several steps.
Adding a `-y` as an argument will automate the input.

Now that the conversion has been deployed successfully, you will need to reboot the system in order to put the changes into effect.
Reboot is required because the system is now running a Red Hat Enterprise Linux Kernel `kernel-3.10.0-1160.118.1.el7.x86_64`

reboot

Your connection to the bastion will drop.
After a few minutes, the VM should be up again.
Try to connect again.

Access your *httpd server/bastion VM- with the following command.

web_host_ssh_command

devops user password

web_host_ssh_password

Verify the system is running on Red Hat Enterprise Linux.

cat /etc/redhat-release
Verify that the necessary Red Hat repositories are enabled.
Also, note that none of the old CentOS repos are available.

yum repolist

Now you can review the logs from the conversion itself.

less /var/log/convert2rhel/convert2rhel.log

Use the down arrow key or page down key to view more of the log.
To close the log, simply press the "q" key for quit.

Verify the Web Application still functions by browsing to {web_app}[Sample Web App^] to verify the web app is running.

Sample App still running after convert2rhel

Northwind_Sample_Data.jpg

## Remote Convert to RHEL: Convert the MySQL Host

In the previous section of the lab, you excuted the conversion process effectily in a manual fashion from the command line. Using an automation tool like Ansible, we can reduce the 20 plus commands down to two commands. To start we need to install Ansible on the Web server so we can target the MySQL server.

Verify that you are still on the bastion server as root, you can use the `whoami` and `hostname` commands to ensure you are on the correct server and user.
If not use the steps below.

Access your *httpd server VM- with the following command.

web_host_ssh_command

Enter `devops` user password

web_host_ssh_password

Switch to root user.

sudo -i

Install EPEL and Ansible on Web Server/Bastion

yum install <https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm> -y

Install Ansible and TMUX on Web Server/Bastion

yum install -y ansible tmux

Start `tmux` so your session doesn't detach

tmux

Run the playbook to set up Arc on the Mysql host

ansible-playbook -v deploy_arc.yaml

Run the playbook to convert the Mysql host to RHEL.

ansible-playbook -v convert_to_rhel.yaml

This takes just over 15 mintues.
Keep aware of the job, and make sure that the terminal doesn't disconnect.
It shouldn't, but you never know.

Now that the conversion has been deployed successfully, you will need to reboot the system in order to put the changes into effect.
Reboot is required because the system is now running a Red Hat Enterprise Linux Kernel `kernel-3.10.0-1160.118.1.el7.x86_64`

reboot

## Congratulations

You have converted from Centos to RHEL for both VM's. Following the optional lab below you can gain access to the Azure portal and view and manage the Arc enabled VMs from this lab.

Optional Lab: Log into Azure portal.

In order to log into the Azure portal, you will need user credentials which you can obtain from lab instructors.
Logging into the Azure portal requires the use of MFA which for this lab requires a mobile device that can receive a SMS message.

Via a web browser navigate to <https://portal.azure.com>
Login in with the username and password given to you by the lab instructors. The username should be <redhatsummitlabXXX@MngEnvMCAP768372.onmicrosoft.com>
If you provided your phone number to one of the lab instructors, you will be prompted to use MFA and enter a code that will be sent via SMS.

Once logged into the Azure portal you can navigate to a few key areas (keep in mind your user has Read only rights)

Arc resource blade and find the Infrastructure section and click on Machines to find your VM's connected via Azure Arc

Azure_Arc_Portal_A.png

Once you have chosen a specfic VM from the Mahcines list, you can deploy additional extentions sush as Custom Script Extenstion for Linux, assign polices to the VM, or enable Monitor insights which will allow you to view and create reports such as VM performance and workload network mapping.

Azure_Arc_Portal_B.png

## Notes from the Field

Convert2Rhel can fail to complete for a varity of reasons, such as 3rd party packages which are not offically supported by Red Hat. In some cases there will be just a simple warning that a specfic package will not be replaced during the conversion process and the converion process will still complete. It is recommneded to check to see if the package that was skipped to ensure proper operation after the conversion and the kernel is updated and loaded.

In other cases the conversion process will initiate a roll back to the state it was before running the conversion. In these cases, you will need to either remidiate the issue such as removing the package, unloading the module from starting or changing enviromental variables that will skip the process in the conversion process.

The most common enviromental variables (Note not recommended for production systems):

Solution 1: `echo "export CONVERT2RHEL_ALLOW_UNAVAILABLE_KMODS=1" >> ~/.bashrc; source ~/.bashrc`
Solution 2: `echo "export CONVERT2RHEL_TAINTED_KERNEL_MODULE_CHECK_SKIP=1" >> ~/.bashrc; source ~/.bashrc`
Solution 3: `echo "export CONVERT2RHEL_SKIP_KERNEL_CURRENCY_CHECK=1" >> ~/.bashrc; source ~/.bashrc`
Solution 4: `echo "export CONVERT2RHEL_OUTDATED_PACKAGE_CHECK_SKIP=1" >> ~/.bashrc; source ~/.bashrc`