# Check if the script is running with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an administrator."
    Exit 1
}

# Define variables
$folderPath = "C:\\LinuxLab"
$logFilePath = "C:\\LinuxLab\\LinuxLabBuilder.txt"
$VHDPath = "C:\\LinuxLab\\VMFiles\\"
$isoFolder = "C:\\LinuxLab\\"

function Write-Log {
    param (
        [string]$EventTimeStamp,
        [string]$Comment
    )
    
    # Get the current date and time
    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fffffff"
    
    # Format the log entry
    $logEntry = "$currentDateTime - $Comment"
    
    # Write the log entry to the log file
    Add-Content -Path $EventTimeStamp -Value $logEntry
    
    # Ensure the log file is updated immediately
    [System.IO.File]::WriteAllText($EventTimeStamp, [System.IO.File]::ReadAllText($EventTimeStamp) + "`r`n")
}

# Verify the existence of the LinuxLab folder and the LinuxLabBuilder.txt file

if (-Not (Test-Path $folderPath)) {
    Write-Host "LinuxLab folder does not exist. Creating the folder..."
    New-Item -Path $folderPath -ItemType Directory
}

if (-Not (Test-Path $logFilePath)) {
    Write-Host "LinuxLabBuilder.txt file does not exist. Creating the file..."
    New-Item -Path $logFilePath -ItemType File
}

if (-Not (Test-Path $VHDPath)) {    # Check if the VMFiles folder exists
    Write-Host "VMFiles folder does not exist. Creating the folder..."
    New-Item -Path $VHDPath -ItemType Directory    <# Action to perform if the condition is true #>
}

# Example usage
$Comment = "Script started"
Write-Log -EventTimeStamp $logFilePath -Comment $Comment

# Define the Hyper-V feature name
$featureName = "Microsoft-Hyper-V-All"

# Function to check if Hyper-V is installed
function Confirm-HyperV {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName
    return $feature.State -eq "Enabled"
}

# Function to install Hyper-V
function Install-HyperV {
    Enable-WindowsOptionalFeature -Online -FeatureName $featureName -All -NoRestart
    Write-Host "Hyper-V has been installed. Please restart your computer to complete the installation."
    $Comment= "Hyper-V has been installed. Restart will be needed"
    Write-Log -EventTimeStamp $logFilePath -Comment $Comment
}

# Check if Hyper-V is installed
if (Confirm-HyperV) {
    Write-Host "Hyper-V is already installed."
    $Comment= "Hyper-V is already installed"
    Write-Log -EventTimeStamp $logFilePath -Comment $Comment
} else {
    Write-Host "Hyper-V is not installed. Installing now..."
    $Comment= "Hyper-V is not installed. Installing now"
    Write-Log -EventTimeStamp $logFilePath -Comment $Comment
    Install-HyperV
}




# Function to check if ISO exists
function Confirm-ISOExists {
    param (
        [string]$folder,
        [string]$fileName
    )

    $filePath = Join-Path -Path $folder -ChildPath $fileName
    return Test-Path -Path $filePath
}

# Function to start BITS job
function Start-BITSJob {
    param (
        [string]$jobName,
        [string]$sourceUrl,
        [string]$destinationPath
    )

    Write-Output "Starting BITS job: $jobName"
    Start-BitsTransfer -Source $sourceUrl -Destination $destinationPath -DisplayName $jobName -Asynchronous
   
}

# Function to create a virtual machine
function Create-VM {
    param (
        [string]$vmName,
        [string]$isoPath
    )

    Write-Output "Creating VM: $vmName"

    New-VM -Name $vmName -MemoryStartupBytes 1GB -Generation 1 -SwitchName "Default Switch" -NewVHDPath "C:\LinuxLab\VMFiles\$vmName.vhdx" -NewVHDSizeBytes 60GB
    Set-VMProcessor -VMName $vmName -Count 2
    Add-VMDvdDrive -VMName $vmName -Path $isoPath
    Set-VMDvdDrive -VMName $vmName -ControllerNumber 0 -ControllerLocation 1
    
    Start-VM -Name $vmName

    Write-Output "VM $vmName created and started."
}

# BITS job details
$bitsJobs = @(
    
@{ JobName = "Job1"; SourceUrl = "https://vault.centos.org/7.7.1908/isos/x86_64/CentOS-7-x86_64-Everything-1908.iso"; DestinationPath = "C:\\LinuxLab\\CentOS-7-Everything.iso" },
@{ JobName = "Job2"; SourceUrl = "https://vault.centos.org/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso"; DestinationPath = "C:\\LinuxLab\\CentOS-7-Minimal.iso" },
@{ JobName = "Job3"; SourceUrl = "https://vault.centos.org/7.7.1908/isos/x86_64/CentOS-7-x86_64-LiveGNOME-1908.iso"; DestinationPath = "C:\\LinuxLab\\CentOS-7-LiveGNOME.iso" }
    

    
    # Add more jobs as needed
)

# Main routine to build out base VMs
foreach ($bitsJob in $bitsJobs) {
    $jobName = $bitsJob.JobName
    $sourceUrl = $bitsJob.SourceUrl
    $destinationPath = $bitsJob.DestinationPath
    $isoFileName = [System.IO.Path]::GetFileName($destinationPath)
    $vmName = "LinuxLabVM-" + [System.IO.Path]::GetFileNameWithoutExtension($isoFileName)
    $retryCount = 0
    $maxRetries = 3
    $isoExists = $false

    while (-not $isoExists -and $retryCount -lt $maxRetries) {
        # Start the BITS job
        Start-BITSJob -jobName $jobName -sourceUrl $sourceUrl -destinationPath $destinationPath
        $Comment = "Starting $sourceUrl download"
        Write-Log -EventTimeStamp $logFilePath -Comment $Comment

                
        # Wait for the BITS job to complete
        $job = Get-BitsTransfer -Name $jobName
        while ($job.JobState -ne 'Transferred' -and $job.JobState -ne 'Suspended' -and $job.JobState -ne 'Error') {
            Start-Sleep -Seconds 5
            $job = Get-BitsTransfer -Name $jobName
        }

        if ($job.JobState -eq 'Transferred') {
            Complete-BitsTransfer -BitsJob $job
        } elseif ($job.JobState -eq 'Error') {
            Write-Host "BITS job failed: $($job | Select-Object -ExpandProperty ErrorDescription)"
            Write-Log -EventTimeStamp $logFilePath -Comment "BITS job failed: $($job | Select-Object -ExpandProperty ErrorDescription)"
        }

        # Check if the ISO exists
        $isoExists = Confirm-ISOExists -folder $isoFolder -fileName $isoFileName
        if ($isoExists) {
            Write-Output "ISO exists: $isoFileName"
        } else {
            $retryCount++
            Write-Output "ISO not found, repeating BITS job... Attempt $retryCount of $maxRetries"
            Write-Log -EventTimeStamp $logFilePath -Comment "ISO not found: $isoFileName, Attempt $retryCount of $maxRetries"
        }
    }

    if (-not $isoExists) {
        Write-Host "Failed to download $isoFileName after $maxRetries attempts. Please download manually."
        Write-Log -EventTimeStamp $logFilePath -Comment "Failed to download $isoFileName after $maxRetries attempts. Please download manually."
        Add-Content -Path $failedLogFilePath -Value "$isoFileName`n"
    }

        # Create a virtual machine using the downloaded ISO
        Create-VM -vmName $vmName -isoPath $destinationPath
        $Comment = $vmName + " created"
        Write-Log -EventTimeStamp $logFilePath -Comment $Comment
}

# Additional VM creation to meet lab output requirements
# Create additional VMs as needed

Write-Output "Creating VM: LinuxLabVM-CentOS-7-EOL-2-RHEL"
New-VM -Name "LinuxLabVM-CentOS-7-EOL-2-RHEL" -MemoryStartupBytes 1GB -Generation 1 -SwitchName "Default Switch" -NewVHDPath "C:\LinuxLab\VMFiles\LinuxLabVM-CentOS-7-EOL-2-RHEL.vhdx" -NewVHDSizeBytes 60GB
Set-VMProcessor -VMName "LinuxLabVM-CentOS-7-EOL-2-RHEL" -Count 2
Add-VMDvdDrive -VMName "LinuxLabVM-CentOS-7-EOL-2-RHEL" -Path "C:\\LinuxLab\\CentOS-7-Everything.iso"
Set-VMDvdDrive -VMName "LinuxLabVM-CentOS-7-EOL-2-RHEL" -ControllerNumber 0 -ControllerLocation 1
Start-VM -Name "LinuxLabVM-CentOS-7-EOL-2-RHEL"

Write-Output "VM LinuxLabVM-CentOS-7-EOL-2-RHEL created and started."
$Comment = "VM LinuxLabVM-CentOS-7-EOL-2-RHEL created and started."
Write-Log -EventTimeStamp $logFilePath -Comment $Comment

Write-Output "Creating VM: LinuxLabVM-CentOS-7-PostGreSQL"
New-VM -Name "LinuxLabVM-CentOS-7-PostGreSQL" -MemoryStartupBytes 1GB -Generation 1 -SwitchName "Default Switch" -NewVHDPath "C:\LinuxLab\VMFiles\LinuxLabVM-CentOS-7-PostGreSQL.vhdx" -NewVHDSizeBytes 60GB
Set-VMProcessor -VMName "LinuxLabVM-CentOS-7-PostGreSQL" -Count 2
Add-VMDvdDrive -VMName "LinuxLabVM-CentOS-7-PostGreSQL" -Path "C:\\LinuxLab\\CentOS-7-Everything.iso"
Set-VMDvdDrive -VMName "LinuxLabVM-CentOS-7-PostGreSQL" -ControllerNumber 0 -ControllerLocation 1
Start-VM -Name "LinuxLabVM-CentOS-7-PostGreSQL"

Write-Output "VM LinuxLabVM-CentOS-7-Apache created and started."
$Comment = "LinuxLabVM-CentOS-7-Apache created and started."
Write-Log -EventTimeStamp $logFilePath -Comment $Comment

Write-Output "Creating VM: LinuxLabVM-CentOS-7-Apache"
New-VM -Name "LinuxLabVM-CentOS-7-Apache" -MemoryStartupBytes 1GB -Generation 1 -SwitchName "Default Switch" -NewVHDPath "C:\LinuxLab\VMFiles\LinuxLabVM-CentOS-7-Apache.vhdx" -NewVHDSizeBytes 60GB
Set-VMProcessor -VMName "LinuxLabVM-CentOS-7-Apache" -Count 2
Add-VMDvdDrive -VMName "LinuxLabVM-CentOS-7-Apache" -Path "C:\\LinuxLab\\CentOS-7-Everything.iso"
Set-VMDvdDrive -VMName "LinuxLabVM-CentOS-7-Apache" -ControllerNumber 0 -ControllerLocation 1
Start-VM -Name "LinuxLabVM-CentOS-7-Apache"

Write-Output "VM LinuxLabVM-CentOS-7-Apache created and started."
$Comment = "LinuxLabVM-CentOS-7-Apache created and started."
Write-Log -EventTimeStamp $logFilePath -Comment $Comment

# VM creation complete
Write-Output "All BITS jobs completed, ISOs validated, and VMs created."
$Comment = "All BITS jobs completed, ISOs validated, and VMs created."
Write-Log -EventTimeStamp $logFilePath -Comment $Comment

#Post installation setup of VM's


# Script completion message
$Comment = "Script has completed"
Write-Log -EventTimeStamp $logFilePath -Comment $Comment