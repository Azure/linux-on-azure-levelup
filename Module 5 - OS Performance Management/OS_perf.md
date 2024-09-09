# This module will describe how Obtaining Performance metrics from a Linux system and test network performance using iperf3

It will cover the following LAB topics:

1. Obtaining Performance metrics from a Linux system
1. Test network performance using iperf3

All of the commands below are meant to be run on a Ubuntu 24.04 LTS machine previously installed in the Azure-Infra Lab, using sudo or root privileges. The below commands have been tested on WSL2 installation and the latest azure-cli version.

## LAB 1: Obtaining Performance metrics from a Linux system

**Intro:**
There are several commands that can be used to obtain performance counters on Linux. Commands such as vmstat and uptime, provide general system metrics such as CPU usage, System Memory, and System load. Most of the commands are already installed by default with others being readily available in default repositories. The commands can be separated into:

- CPU
- Memory
- Disk I/O
- Processes
- Network

**TASK:**

1. Run the following commands to obtain performance metrics from a Linux system
   - CPU
     - mpstat
     - vmstat
     - uptime
   - Memory
     - free
   - I/O
     - iostat

### Step 1: CPU

#### sysstat

Some commands are part of the sysstat package which might not be installed by default. The package can be easily installed with:

```bash
sudo apt install -y sysstat
```

The mpstat utility is part of the sysstat package. It displays per CPU utilization and averages, which is helpful to quickly identify CPU usage. mpstat provides an overview of CPU utilization across the available CPUs, helping identify usage balance and if a single CPU is heavily loaded.

```bash
mpstat -P ALL 1
```

The options and arguments are:

- -P: Indicates the processor to display statistics, the ALL argument indicates to display statistics for all the online CPUs in the system.
- 1: The first numeric argument indicates how often to refresh the display in seconds.
- 2: The second numeric argument indicates how many times the data refreshes.

The number of times the mpstat command displays data can be changed by increasing the second numeric argument to accommodate for longer data collection times. Ideally 3 or 5 seconds should suffice, for systems with increased core counts 2 seconds can be used to reduce the amount of data displayed. From the output:

```text
Linux 6.8.0-1013-azure (linux001)       08/29/24        _x86_64_        (1 CPU)

17:00:08     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
17:00:09     all    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00
17:00:09       0    1.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.00

17:00:09     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
17:00:10     all    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
17:00:10       0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00

Average:     CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
Average:     all    0.50    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.50
Average:       0    0.50    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00   99.50
```

Things to look out for
Some details to keep in mind when reviewing the output for mpstat:

Verify that all CPUs are properly loaded and not a single CPU is serving all the load. This information could indicate a single threaded application.
Look for a healthy balance between %usr and %sys as the opposite would indicate more time spent on the actual workload than serving kernel processes.
Look for %iowait percentages as high values could indicate a system that is constantly waiting for I/O requests.
High %soft usage could indicate high network traffic.

#### vmstat

The vmstat utility is widely available in most Linux distributions, it provides high level overview for CPU, Memory, and Disk I/O utilization in a single pane. The command for vmstat is:

```bash
vmstat -w 1 5
```

The options and arguments are:

- -w: Use wide printing to keep consistent columns.
- 1: The first numeric argument indicates how often to refresh the display in seconds.
- 5: The second numeric argument indicates how many times the data refreshes.

The output:

```text
--procs-- -----------------------memory---------------------- ---swap-- -----io---- -system-- ----------cpu----------
   r    b         swpd         free         buff        cache   si   so    bi    bo   in   cs  us  sy  id  wa  st  gu
   2    0            0       642036        85644      2287696    0    0    69   584  101    1   2   0  97   1   0   0
   0    0            0       642036        85644      2287712    0    0     0     0  137  175   0   0 100   0   0   0
   0    0            0       642036        85644      2287712    0    0     0     0   53   79   0   0 100   0   0   0
   0    0            0       642036        85644      2287712    0    0     0     0   29   57   0   0 100   0   0   0
   0    0            0       642036        85644      2287712    0    0     0     0   23   46   0   0 100   0   0   0
```

Things to look out for
Some details to keep in mind when reviewing the output for vmstat:

- The r column indicates the number of processes waiting for CPU time, a high value could indicate a CPU bottleneck.
- The b column indicates the number of processes in uninterruptible sleep, a high value could indicate a disk I/O bottleneck.
- The wa column indicates the percentage of time the CPU is waiting for I/O operations to complete, a high value could indicate a disk I/O bottleneck.
- The si and so columns indicate the amount of data swapped in and out of memory, a high value could indicate a memory bottleneck.
- The us and sy columns indicate the percentage of time the CPU is spending on user and system processes, respectively.
- The id column indicates the percentage of time the CPU is idle.
- The gu column indicates the percentage of time the CPU is guest time.
- The st column indicates the percentage of time the CPU is stolen time.
- The in and cs columns indicate the number of interrupts and context switches per second, respectively.
- The bi and bo columns indicate the number of blocks received and sent to block devices per second, respectively.
- The free column indicates the amount of free memory available.
- The buff column indicates the amount of memory used as buffers.
- The cache column indicates the amount of memory used as cache.
- The swpd column indicates the amount of memory swapped to disk.

#### uptime

For CPU related metrics, the uptime utility provides a broad overview of the system load with the load average values.

```bash
uptime
```

The output:

```text
 17:00:08 up  1:00,  1 user,  load average: 0.00, 0.00, 0.00
```

The load average displays three numbers. These numbers are for 1, 5 and 15 minute intervals of system load.

To interpret these values, it's important to know the number of available CPUs in the system, obtained from the mpstat output before. The value depends on the total CPUs, so as an example of the mpstat output the system has 8 CPUs, a load average of 8 would mean that ALL cores are loaded to a 100%.

A value of 4 would mean that half of the CPUs were loaded at 100% (or a total of 50% load on ALL CPUs). In the previous output, the load average is 9.26, which means the CPU is loaded at about 115%.
The 1m, 5m, 15m intervals help identify if load is increasing or decreasing over time.

### Step 2: Memory

#### free

The free utility provides a high level overview of the system memory usage.

```bash
free -m
```

The -m option displays the output in megabytes.

The output:

```text
              total        used        free      shared  buff/cache   available
Mem:           7826        1044        5864         104        917        6544
Swap:          2047           0        2047
```

Things to look out for
Some details to keep in mind when reviewing the output for free:

- The total column indicates the total amount of memory available.
- The used column indicates the amount of memory used.
- The free4 column indicates the amount of memory available for use.
- The shared column indicates the amount of memory shared between processes.
- The buff/cache column indicates the amount of memory used as buffers and cache.
- The available column indicates the amount of memory available for use by applications.
- The swap column indicates the amount of swap space available.

### Step 3: I/O

#### iostat

The iostat utility provides an overview of disk I/O utilization.

```bash
iostat -dxtm 1 5
```

The options and arguments are:

- -d: Per device usage report.
- -x: Extended statistics.
- -t: Display the timestamp for each report.
- -m: Display in MB/s.
- 1: The first numeric argument indicates how often to refresh the display in seconds.
- 2: The second numeric argument indicates how many times the data refreshes.

## LAB 2: Using two Azure VMs to test network performance using iperf3

**Intro:**
iperf3 is a tool used to measure network performance. It can be used to test the maximum achievable bandwidth on IP networks. It is particularly useful when troubleshooting network issues or when comparing network performance between different VMs cross Azure Regions.

**TASK:**
Create two Azure VMs in different regions, peer the VNets, and test network performance using iperf3.

### Step 1: Create iperf3 server Azure VM

To set up an Azure VM for an iperf3 server in the East US region, create a resource group named "$RESOURCE_GROUP_NAME" and a VNet named "iperf3-server-vnet" with a subnet "iperf3-server-subnet." Configure a network security group "iperf3-server-nsg" with a rule to allow SSH traffic. Create a public IP "iperf3-server-pip" and a NIC "iperf3-server-nic." Deploy a VM named "iperf3-server-vm" using the Ubuntu 24.04 LTS image and Standard D2s v5 size. Bastion Host is also created for secure access to the VM.

1. Set the following variables to create the Azure resources.

```bash
export SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
export LOCAL_NAME="iperf3-server"
export TAGS="Environment=iperf3"
export IPERF_SERVER_RESOURCE_GROUP_NAME="rg-${LOCAL_NAME}-${SUFFIX}"
export REGION="eastus2"
```

2. Create a resource group in the primary region.

```bash
az group create --name $IPERF_SERVER_RESOURCE_GROUP_NAME --location $REGION --tags $TAGS --output tsv
```

3. Create a VNET and subnet in the primary region.

```bash
export IPERF_SERVER_VNET_NAME="iperf3-server-vnet"
export VNET_CIDR="10.230.0.0/23"
export IPERF_SERVER_SUBNET_NAME="iperf3-server-subnet"
export IPERF_SERVER_SUBNET_CIDR="10.230.0.0/24"

az network vnet create \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --name $IPERF_SERVER_VNET_NAME \
   --location $REGION \
   --tags $TAGS \
   --address-prefix $VNET_CIDR \
   --output tsv

az network vnet subnet create \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --vnet-name $IPERF_SERVER_VNET_NAME \
   --name $IPERF_SERVER_SUBNET_NAME \
   --address-prefix $IPERF_SERVER_SUBNET_CIDR \
   --output tsv
```

4. Create a subnet for Azure Bastion.

```bash
export BASTION_SUBNET_NAME="AzureBastionSubnet"
export BASTION_SUBNET_CIDR="10.230.1.0/26"

az network vnet subnet create \
   --name $BASTION_SUBNET_NAME \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --vnet-name $IPERF_SERVER_VNET_NAME \
   --address-prefix $BASTION_SUBNET_CIDR \
   --output tsv
```

5. Create Azure Public IP for Bastion Host

```bash
export BASTION_NAME="bastion-${SUFFIX}"
export BASTION_PUBLIC_IP_NAME="bastion-pip-${SUFFIX}"

az network public-ip create \
   --name "$BASTION_PUBLIC_IP_NAME" \
   --resource-group "$IPERF_SERVER_RESOURCE_GROUP_NAME" \
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

6. Create Azure Bastion Host with native client support and IP-based connections

```bash
az network bastion create \
   --name "$BASTION_NAME" \
   --resource-group "$IPERF_SERVER_RESOURCE_GROUP_NAME" \
   --vnet-name "$IPERF_SERVER_VNET_NAME" \
   --location "$REGION" \
   --public-ip-address "$BASTION_PUBLIC_IP_NAME" \
   --enable-ip-connect true \
   --enable-tunneling true \
   --sku Standard \
   --tags $TAGS \
   --output tsv \
   --no-wait
```

7. Create Azure VM in the VM Subnet using Ubuntu 24.04 and without a Public IP

```bash
cat << EOF > cloud-init-os-perf.txt
#cloud-config
# Install, update, and upgrade packages
package_upgrade: true
package_update: true
package_reboot_if_require: false
# Install packages
packages:
  - iperf3
  - sysstat
EOF
```

8. The following command creates an SSH key pair using ED25519 encryption with a fixed length of 256 bits:

```bash
ssh-keygen -m PEM -t ed25519 -f $HOME/id_ed25519_levelup_key.pem -C "LevelUp Linux VM SSH Key"
```

9. Create a network security group (NSG) to allow SSH and iperf3 traffic.

```bash
export NSG_NAME="NSG-${SUFFIX}"
export NSG_RULE_NAME="Allow-Access-${SUFFIX}"
export VM_NIC_SERVER_NAME="VMNic-${SUFFIX}"

az network nsg create \
   --name $NSG_NAME \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --location $REGION \
   --tags $TAGS \
   --output tsv
```

10. Create a rule to allow connections to the virtual machine on port 22 for SSH and ports 9000 for iperf3.

```bash
az network nsg rule create \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --nsg-name $NSG_NAME \
   --name $NSG_RULE_NAME \
   --access Allow \
   --protocol '*' \
   --direction Inbound \
   --priority 100 \
   --source-address-prefix '*' \
   --source-port-range '*' \
   --destination-address-prefix '*' \
   --destination-port-range 22 9000 \
   --output tsv
```

11. Use az network nic create to create the network interface for the virtual machine.

```bash
az network nic create \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --name $VM_NIC_SERVER_NAME \
   --location $REGION \
   --accelerated-networking true \
   --ip-forwarding false \
   --subnet $IPERF_SERVER_SUBNET_NAME \
   --vnet-name $IPERF_SERVER_VNET_NAME \
   --network-security-group $NSG_NAME \
   --tags $TAGS \
   --output tsv
```

12. Create the Azure VM using the Ubuntu 24.04 LTS image and the Standard_D2s_v5 size.

```bash
export IPERF_SERVER_VM_NAME="vm-${LOCAL_NAME}-${SUFFIX}"
export VM_SIZE="Standard_D2s_v5"
export VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
export VM_ADMIN_USER="azureuser"

az vm create \
   --name "$IPERF_SERVER_VM_NAME" \
   --resource-group "$IPERF_SERVER_RESOURCE_GROUP_NAME" \
   --location $REGION \
   --size $VM_SIZE \
   --image $VM_IMAGE \
   --nics $VM_NIC_SERVER_NAME \
   --nic-delete-option Delete \
   --storage-sku os=Premium_LRS \
   --os-disk-caching ReadWrite \
   --os-disk-delete-option Delete \
   --os-disk-size-gb 30 \
   --admin-username $VM_ADMIN_USER \
   --authentication-type ssh \
   --ssh-key-values "$HOME/id_ed25519_levelup_key.pem.pub" \
   --custom-data cloud-init-os-perf.txt \
   --tags $TAGS \
   --output tsv
```

### Step 2: Create iperf3 client Azure VM

To set up an Azure VM for an iperf3 client in the West US region, create a resource group named "$RESOURCE_GROUP_NAME" and a VNet named "iperf3-client-vnet" with a subnet "iperf3-client-subnet." Configure a network security group "iperf3-client-nsg" with a rule to allow SSH traffic. Create a public IP "iperf3-client-pip" and a NIC "iperf3-client-nic." Deploy a VM named "iperf3-client-vm" using the Ubuntu 24.04 LTS image and Standard D2s v5 size.

1. Set the following variables to create the Azure resources.

```bash
export SUFFIX=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
export LOCAL_NAME="iperf3-client"
export TAGS="Environment=iperf3"
export IPERF_CLIENT_RESOURCE_GROUP_NAME="rg-${LOCAL_NAME}-${SUFFIX}"
export IPERF_CLIENT_REGION="swedencentral"
```

2. Create a resource group in the primary region.

```bash
az group create --name $IPERF_CLIENT_RESOURCE_GROUP_NAME --location $IPERF_CLIENT_REGION --tags $TAGS --output tsv
```

3. Create a VNET and subnet in the primary region.

```bash
export IPERF_CLIENT_VNET_NAME="iperf3-client-vnet"
export VNET_CIDR="10.220.0.0/23"
export IPERF_CLIENT_SUBNET_NAME="iperf3-client-subnet"
export IPERF_CLIENT_SUBNET_CIDR="10.220.0.0/24"

az network vnet create \
   --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME \
   --name $IPERF_CLIENT_VNET_NAME \
   --location $IPERF_CLIENT_REGION \
   --tags $TAGS \
   --address-prefix $VNET_CIDR \
   --output tsv

az network vnet subnet create \
   --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME \
   --vnet-name $IPERF_CLIENT_VNET_NAME \
   --name $IPERF_CLIENT_SUBNET_NAME \
   --address-prefix $IPERF_CLIENT_SUBNET_CIDR \
   --output tsv
```

4. Create a network security group (NSG) to allow SSH and iperf3 traffic.

```bash
export NSG_NAME="NSG-${SUFFIX}"
export NSG_RULE_NAME="Allow-Access-${SUFFIX}"
export VM_NIC_CLIENT_NAME="VMNic-${SUFFIX}"

az network nsg create \
   --name $NSG_NAME \
   --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME \
   --location $IPERF_CLIENT_REGION \
   --tags $TAGS \
   --output tsv
```

5. Create a rule to allow connections to the virtual machine on port 22 for SSH and ports 9000 for iperf3.

```bash
az network nsg rule create \
   --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME \
   --nsg-name $NSG_NAME \
   --name $NSG_RULE_NAME \
   --access Allow \
   --protocol '*' \
   --direction Inbound \
   --priority 100 \
   --source-address-prefix '*' \
   --source-port-range '*' \
   --destination-address-prefix '*' \
   --destination-port-range 22 9000 \
   --output tsv
```

6. Use az network nic create to create the network interface for the virtual machine.

```bash
az network nic create \
   --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME \
   --name $VM_NIC_CLIENT_NAME \
   --location $IPERF_CLIENT_REGION \
   --accelerated-networking true \
   --ip-forwarding false \
   --subnet $IPERF_CLIENT_SUBNET_NAME \
   --vnet-name $IPERF_CLIENT_VNET_NAME \
   --network-security-group $NSG_NAME \
   --tags $TAGS \
   --output tsv
```

7. Create the Azure VM using the Ubuntu 24.04 LTS image and the Standard_D2s_v5 size.

```bash
export IPERF_CLIENT_VM_NAME="vm-${LOCAL_NAME}-${SUFFIX}"
export VM_SIZE="Standard_D2s_v5"
export VM_IMAGE="Canonical:ubuntu-24_04-lts:server:latest"
export VM_ADMIN_USER="azureuser"

az vm create \
   --name "$IPERF_CLIENT_VM_NAME" \
   --resource-group "$IPERF_CLIENT_RESOURCE_GROUP_NAME" \
   --location $IPERF_CLIENT_REGION \
   --size $VM_SIZE \
   --image $VM_IMAGE \
   --nics $VM_NIC_CLIENT_NAME \
   --nic-delete-option Delete \
   --storage-sku os=Premium_LRS \
   --os-disk-caching ReadWrite \
   --os-disk-delete-option Delete \
   --os-disk-size-gb 30 \
   --admin-username $VM_ADMIN_USER \
   --authentication-type ssh \
   --ssh-key-values "$HOME/id_ed25519_levelup_key.pem.pub" \
   --custom-data cloud-init-os-perf.txt \
   --tags $TAGS \
   --output tsv
```

### Step 3: Configure Azure VNet Peering

To allow communication between the two Azure VMs, configure VNet peering between the two VNets.

1. Set the following variables to configure VNet peering.

```bash
export IPERF_SERVER_VNET_ID=$(az network vnet show --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME --name $IPERF_SERVER_VNET_NAME --query id --output tsv)
export IPERF_CLIENT_VNET_ID=$(az network vnet show --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME --name $IPERF_CLIENT_VNET_NAME --query id --output tsv)
```

2. Create a VNet peering connection from the iperf3-server-vnet to the iperf3-client-vnet.

```bash
az network vnet peering create \
   --name iperf3-server-to-client \
   --resource-group $IPERF_SERVER_RESOURCE_GROUP_NAME \
   --vnet-name $IPERF_SERVER_VNET_NAME \
   --remote-vnet $IPERF_CLIENT_VNET_ID \
   --allow-vnet-access \
   --allow-forwarded-traffic \
   --output tsv
```

3. Create a VNet peering connection from the iperf3-client-vnet to the iperf3-server-vnet.

```bash
az network vnet peering create \
   --name iperf3-client-to-server \
   --resource-group $IPERF_CLIENT_RESOURCE_GROUP_NAME \
   --vnet-name $IPERF_CLIENT_VNET_NAME \
   --remote-vnet $IPERF_SERVER_VNET_ID \
   --allow-vnet-access \
   --allow-forwarded-traffic \
   --output tsv
```

### Step 3: Test network performance using iperf3

1. SSH into the iperf3-server-vm via the Azure Bastion Host

> [!CAUTION]
> Run the following commands in a separate terminal window to establish an SSH tunnel to the Azure VM. For those running in Azure Shell please use any terminal mulitplexor like tmux or screen to run the following commands.

```bash
export IPERF_SERVER_RESOURCE_GROUP_NAME="rg-iperf3-server-<SUFFIX>" #replace <SUFFIX> with the actual value
export IPERF_SERVER_NAME="vm-iperf3-server-<SUFFIX>" #replace <SUFFIX> with the actual value

export IPERF_SEVER_VM_ID="$(az vm show -g "$IPERF_SERVER_RESOURCE_GROUP_NAME" -n "$IPERF_SERVER_NAME" --query id -o tsv)"

az network bastion tunnel -n $BASTION_NAME -g "$IPERF_SERVER_RESOURCE_GROUP_NAME" \
   --target-resource-id $IPERF_SEVER_VM_ID --resource-port 22 --port 2022
```

```bash
ssh azureuser@localhost -p 2022 -i $HOME/id_ed25519_levelup_key.pem
```

Start the iperf3 server on the iperf3-server-vm.

```bash
iperf3 --server --port 9000 --format m
```

> [!TIP]
> An alternative way of running the iperf3 server is to run it in the background using the nohup command via the Azure CLI run-command extension.

   ```bash
   az vm run-command invoke -g $IPERF_SERVER_RESOURCE_GROUP_NAME -n $IPERF_SERVER_VM_NAME --command-id RunShellScript --scripts "nohup iperf3 --server --port 9000 --format m > /var/log/iperf3.log 2>&1 &"
   ```

2. Start the iperf3 client on the iperf3-client-vm.

```bash
export IPERF_SERVER_VM_IP=$(az network nic show -g $IPERF_SERVER_RESOURCE_GROUP_NAME -n $VM_NIC_SERVER_NAME --query "ipConfigurations[0].privateIPAddress" -o tsv)

az vm run-command invoke -g $IPERF_CLIENT_RESOURCE_GROUP_NAME -n $IPERF_CLIENT_VM_NAME --command-id RunShellScript --scripts "nohup iperf3 --client $IPERF_SERVER_VM_IP --port 9000 --format m --time 60 --parallel 1 --omit 1 > /var/log/iperf3-client.log 2>&1 &" 
```

> [!IMPORTANT]
> As we can observer with the default settings the network performance is not optimal and we are not close to the advised line speed of the Azure VMs.

```text
Connecting to host 10.230.0.4, port 9000
[ 5] local 10.220.0.4 port 34018 connected to 10.230.0.4 port 9000
[ ID] Interval Transfer Bitrate Retr Cwnd
[ 5] 0.00-1.00 sec 9.38 MBytes 78.6 Mbits/sec 0 5.75 MBytes (omitted)
[ 5] 0.00-1.00 sec 35.5 MBytes 297 Mbits/sec 0 8.01 MBytes
[ 5] 1.00-2.00 sec 35.6 MBytes 299 Mbits/sec 0 8.01 MBytes
[ 5] 2.00-3.00 sec 39.4 MBytes 330 Mbits/sec 0 8.01 MBytes
[ 5] 3.00-4.00 sec 35.5 MBytes 298 Mbits/sec 0 8.01 MBytes
[ 5] 4.00-5.00 sec 35.5 MBytes 298 Mbits/sec 0 8.01 MBytes
[ 5] 5.00-6.00 sec 32.5 MBytes 273 Mbits/sec 15 5.62 MBytes
[ 5] 6.00-7.00 sec 34.6 MBytes 290 Mbits/sec 0 5.62 MBytes
[ 5] 7.00-8.00 sec 38.2 MBytes 321 Mbits/sec 0 5.62 MBytes
[ 5] 8.00-9.00 sec 33.2 MBytes 279 Mbits/sec 8 3.95 MBytes
```

### Step 4: Tuning the sysctl parameters

By increasing the kernel buffers and changing the congestion control algorithm to BBR we can improve the network performance.

Modify the sysctl parameters on **BOTH** Azure VMs to improve network performance.

```bash
sudo cat << EOF > /etc/sysctl.d/99-azure-network-buffers.conf  
net.core.rmem_max = 2147483647  
net.core.wmem_max = 2147483647  
net.ipv4.tcp_rmem = 4096 67108864 1073741824  
net.ipv4.tcp_wmem = 4096 67108864 1073741824  
EOF 
```

Apply the changes to the sysctl parameters on **BOTH** Azure VMs.

```bash
sudo sysctl -p /etc/sysctl.d/99-azure-network-buffers.conf
```

### Step 5: Repeat the iperf3 test

> [!TIP]
> If not already loaded please use the modprobe command to enable the TCP BBR congestion control algorithm.

On the client side Azure VM please repeat the iperf3 test to measure the network performance after tuning the sysctl parameters.

```bash
sudo modprobe tcp_bbr
```

```bash
iperf3 --client $IPERF_SERVER_VM_IP --port 9000 --format m --time 60 --parallel 1 --omit 1 --congestion bbr
```
