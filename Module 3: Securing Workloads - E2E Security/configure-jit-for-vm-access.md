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

### Task 2: Enable JIT for your Linux VM

### Task 3. Request JIT access and connect to your VM

## Further information

[JIT documentation](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-overview)
