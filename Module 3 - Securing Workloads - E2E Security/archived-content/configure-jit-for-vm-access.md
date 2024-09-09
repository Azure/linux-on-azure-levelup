# Enable Just-in-Time (JIT) access for your Linux VMs

## Introduction

Just-in-Time access uses NSGs to allow temporary SSH access to a Linux VM, and automatically manages the creation and expiration of the required NSG rules.

## Key benefits

There are several benefits to this approach, including:

* No requirement to keep ports closed since they are locked-down by default and only accessible when a JIT request is made and approved.
* Allowed users can easily request temporary access to protected ports.
* You can create your own JIT approval policies.

## Use case

JIT is particularly useful for customers/scenarios where public connectivity is required and/or private connectivity is not available, specifically to protect management ports.

## Alternatives

* Manual NSG configuration
* Azure Bastion
* Manually configured jumpboxes/bastions
* SSH connections via public internet
* Serial console
* Run-command (to execute commands ad-hoc)

## Prerequisites

* JIT is a feature of Defender for Cloud and therefore requires Microsoft Defender for Servers Plan 2 to be enabled on your subscription.
* JIT can be configured for AWS VMs, however this requires some extra configuration steps detailed [here](https://learn.microsoft.com/en-us/azure/defender-for-cloud/quickstart-onboard-aws).

## Lab

During our lab session, we will enable Defender for Cloud and enable JIT access for an existing Linux VM.

### Task 1: Enable Defender for Cloud on your subscription (if not already enabled)

Follow the steps [here](https://learn.microsoft.com/en-us/azure/defender-for-cloud/tutorial-enable-servers-plan#deploy-defender-for-servers)

Essentially you need to select your subscription within the **Environment settings** blade beneath **Management** from within Defender for Cloud, and then if not already switch the **Servers** plan to **On**.

### Task 2: Enable JIT for your Linux VM

1. Access your VM's **Configuration** blade from within **Settings** on the Azure Portal.
2. Click **Enable just-in-time**.

### Task 3. Request JIT access and connect to your VM

1. Find your VM within the Azure portal and access the **Connect** blade within section **Connect**.
2. Click the link **Request access** and then the button **Request access** to grant your public IP address temporary JIT access to the VM's SSH port TCP/22.

You should now be able to connect to the VM using the SSH client on your local machine.

## Further information

[JIT documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-overview)
