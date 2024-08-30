# Linux on Azure value proposition

In this article we will discuss the value proposition for running Linux workloads on the Azure platform.

## Azure-specific values

[Marketing slides]

Built-in support for some distro options (e.g., SUSE & Red Hat, Ubuntu): <https://learn.microsoft.com/en-gb/troubleshoot/azure/virtual-machines/linux/support-linux-open-source-technology>

* MS distributions:
  * Azure Linux Container Host
  * Flatcar
* MS one of largest contributors to OSS community:
  * Kubernetes
  * Systemd
  * Kernel releases
  * CIFS
  * Linux optimised hypervisor
* Can bring custom images to Azure
* Huge number of distros available in Azure Portal/marketplace
* Partnerships (useful for support interactions):
  * Red Hat: <https://www.redhat.com/en/partners/microsoft>
  * Canonical: <https://ubuntu.com/azure>
  * SUSE: <https://www.suse.com/partners/alliance/microsoft/>

## Azure Hybrid Benefit (AHB)

* Can convert existing VMs to BYO license (no need for rebuild).
* Cost savings by bringing own license/subscription to Azure.

## Security

* Defender for Cloud:<https://azure.microsoft.com/en-gb/products/defender-for-cloud/?azure-portal=true#overview>
* ATP
* Realtime monitoring
* Security recommendations
* FIPS

Sentinel integration (SIEM) Security information and event management (SIEM) is a security solution that helps organizations detect threats before they disrupt business.

* Entra ID integration
* Confidential Computing
* Intune
* JIT SSH
* Gen2 VMs: <https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2>

## Scalability

* Regions: >60 worldwide
* AZs

## Performance

* Ephemeral OS Disk
* Accelerated Networking
* InfiniBand
* Ultra Disk

## Governance

* Policy
* Azure Backup/ASR
* Azure Monitor

## Cost

* AMD, ARM VM SKUs
* Cost Management
* Reservations
* BYO RHEL/SUSE subs w/ HUB: <https://go.microsoft.com/fwlink/?linkid=2238438>
* Azure savings plan: <https://azure.microsoft.com/en-gb/pricing/offers/savings-plan-compute/>

## Logging/monitoring

## Migration

* Azure Migrate to assess & discover VMs
* Can also use to create business case

## Other

* Bicep/Terraform Landing Zones: <https://learn.microsoft.com/en-gb/azure/architecture/landing-zones/bicep/landing-zone-bicep>
* Use Azure Arc to manage on-prem & Azure Linux VMs together
* Azure Verified Modules (AVM)
