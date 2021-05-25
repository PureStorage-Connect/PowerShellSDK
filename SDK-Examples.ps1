<#
Example PowerShell scripts for the Pure Storage PowerShell SDK
  This contains the step-by-step example script that follows along with the Quick Start Guide (https://support.purestorage.com/Solutions/Microsoft_Platform_Guide/a_Windows_PowerShell) as well as some further examples to help you create your own scripts using the SDK.

This script is AS-IS. No warranties expressed or implied by Pure Storage or the creator.

: REVISION HISTORY
:: 03.10.2021 - Added extended script and altered text for clarity. [mnelson]
::

: CONTRIBUTING AUTHORS
:: Barkz, Mike Nelson, Julian Cates, Robert Quimbey --  @purestorage.com
#>

###START

## Getting Started
##################
Get-Module -ListAvailable
$env:PSModulePath
Get-Command -Module PureStoragePowerShellSDK
(Get-Command -Module PureStoragePowerShellSDK).Count
Update-Help -Module PureStoragePowerShellSDK # Requires Run as Administrator
Get-Help New-PfaArray
Get-Help New-PfaArray -Full
Get-Help New-PfaArray -Detailed
Get-Help New-PfaArray -Examples

## Connecting to the FlashArray
###############################
$Creds = Get-Credential
$FlashArray = New-PfaArray -EndPoint <IP/DNS> -Credentials $Creds -IgnoreCertificateError
Get-PfaControllers -Array $FlashArray
$Controllers = Get-PfaControllers –Array $FlashArray
$Controllers

## Working with Volumes
#######################
New-PfaVolume –Array $FlashArray –VolumeName 'TEST-VOL' –Unit 'TB' –Size 2
ForEach ($i in 2..10) { New-PfaVolume –Array $FlashArray –VolumeName “TEST-VOL$i” –Unit TB –Size 2 }
Get-PfaVolume –Array $FlashArray –Name ‘TEST-VOL’ | Format-Table –Autosize
Rename-PfaVolumeOrSnapshot –Array $FlashArray –NewName ‘TEST-VOL1’ –Name ‘TEST-VOL’

## Volume and Host Connections
##############################
$wwn=@('10:00:00:00:00:00:11:11','10:00:00:00:00:00:12:12')
New-PfaHost –Array $FlashArray –Name ‘TEST-HOST1’ –WwnList $wwn
New-PfaHostGroup -Array $FlashArray -Hosts 'TEST-HOST1' -Name 'TEST-HOSTGROUP'
New-PfaHostVolumeConnection -Array $FlashArray -VolumeName 'TEST-VOL1' -HostName 'TEST-HOST1'
New-PfaHostGroupVolumeConnection -Array $FlashArray -VolumeName 'TEST-VOL2' -HostGroupName 'TEST-HOSTGROUP'

## FlashRecover Snapshots
#########################
New-PfaVolumeSnapshots -Array $FlashArray -Sources 'TEST-VOL1','TEST-VOL2' -Suffix 'EXAMPLE'
New-PfaVolume -Array $FlashArray -Source 'TEST-VOL1.EXAMPLE' -VolumeName 'NEW-TEST-VOL1'
New-PfaVolume -Array $FlashArray -Source 'TEST-VOL2.EXAMPLE' -VolumeName 'TEST-VOL2' –Overwrite

## Protection Groups
####################
New-PfaProtectionGroup -Array $FlashArray -Name ‘TEST-PGROUP’
$Volumes = @()
ForEach($i in 1..10) { $Volumes += @("TEST-VOL$i") }
$Volumes
Add-PfaVolumesToProtectionGroup -Array $FlashArray -VolumesToAdd $Volumes -Name 'TEST-PGROUP'
New-PfaProtectionGroupSnapshot -Array $FlashArray -Protectiongroupname 'TEST-PGROUP' -Suffix 'EXAMPLE'
Get-PfaProtectionGroupSnapshots -Array $FlashArray -Name 'TEST-PGROUP'
Get-PfaProtectionGroupSchedule -Array $FlashArray -ProtectionGroupName 'TEST-PGROUP'
Set-PfaProtectionGroupSchedule -Array $FlashArray -SnapshotFrequencyInSeconds 21600 -GroupName 'TEST-PGROUP'
Enable-PfaSnapshotSchedule -Array $FlashArray -Name 'TEST-PGROUP'

$Volumes = @()
ForEach($i in 1..10) { $Volumes += @("TEST-VOL$i") }
$Volumes
Remove-PfaVolumesFromProtectionGroup -Array $FlashArray -VolumesToRemove $Volumes -Name 'TEST-PGROUP'

Add-PfaHostsToProtectionGroup -Array $FlashArray -Name 'TEST-PGROUP' -HostsToAdd 'TEST-HOST1'
New-PfaProtectionGroupSnapshot -Array $FlashArray -Protectiongroupname 'TEST-PGROUP'
Remove-PfaHostsFromProtectionGroup -Array $FlashArray -HostsToRemove 'TEST-HOST1' -Name 'TEST-PGROUP'

Add-PfaHostGroupsToProtectionGroup -Array $FlashArray -HostGroupsToAdd 'TEST-HOSTGROUP' -Name 'TEST-PGROUP'
New-PfaProtectionGroupSnapshot -Array $FlashArray -Protectiongroupname 'TEST-PGROUP'

## Monitor Metrics
##################
Get-Command -Module PureStoragePowerShellSDK *Metric
Get-PfaVolumeIOMetrics -Array $FlashArray -VolumeName ‘TEST-VOL1’ –TimeRange 1h | Format-Table –AutoSize
Get-PfaVolumeIOMetrics -Array $FlashArray -VolumeName ‘TEST-VOL1’ –TimeRange 1h | Export-Csv -Path ‘C:\temp\test.csv’

## END QUICK START EXAMPLES

## Miscellaneous
################

# Use an Invoke method to run a Purity CLI command
$CommandText = "purevol create --size 10G volume-name-1"
New-PfaCLICommand -EndPoint $array -Username $ArrayUsername -Password $ArrayPassword -CommandText $CommandText

# Get volumes created within the last 30 days
$a = (Get-Date).AddDays(-30)
Get-PfaVolumes -Array $Array | Where-Object { ($_.name -like 'Volume0*') -and ($_.created -ge $a) }

# Destroy (not eradicate) snapshots older than "x" Days
$targetDate = (Get-Date).AddDays(-1 * $Days)
$snaps = Get-PfaVolumeSnapshot -Array $FlashArray -SnapshotName * | Where-Object source -EQ $Volume
foreach ($snap in $snaps) {
    $snapDate = Get-Date($snap.created)
    if ($snapDate -lt $targetDate) {
        Remove-PfaVolumeOrSnapshot -Array $FlashArray -Name $snap.name
    }
}

# The above code put into a Function with command line parameters
Function Remove-SnapshotsByTime {
Param (
        [Parameter(Mandatory = $true)][PSCredential]$Credential,
        [Parameter(Mandatory = $true)][String]$Array,
        [Parameter(Mandatory = $true)][String]$Volume,
        [Parameter(Mandatory = $true)][Int]$Days
    )
    $fa = New-PfaArray -Credentials $Credential -Endpoint $Array -IgnoreCertificateError
    $targetDate = (Get-Date).AddDays(-1 * $Days)
    $snaps = Get-PfaVolumeSnapshot -Array $fa -SnapshotName * | Where-Object source -EQ $Volume
    foreach ($snap in $snaps) {
        $snapDate = Get-Date($snap.created)
        if ($snapDate -lt $targetDate) {
            Remove-PfaVolumeOrSnapshot -Array $fa -Name $snap.name
        }
    }
}

# Alternative method for destroy (not eradicate) snapshots older than "x" days
$fa = new-pfaarray -endpoint x.x.x.x -username pureuser -ignorecertificateerror
    $purevolume = "nameofvolume"
    # Set number of days from today to retain
    $retention = (Get-Date).adddays(-10)
    $ListAllSnap = Get-PfaVolumeSnapshots -VolumeName $purevolume -Array $fa
    $ListAllSnap | ForEach-Object {
        if ($_.created -lt $retention) {
            Write-Host $_.created "deleted"
            Remove-PfaVolumeOrSnapshot -array $fa -name $_.name
        }
        else {
            Write-Host $_.created "saved"
        }
    }

# Protection Group information
    $allVols = Get-PfaVolumes -Array $fa
    $volProtection = @()
    foreach ($pfaVol in $allVols) {
        $Result = $null
        $Result = "" | Select-Object Name, ProtectionGroups, Serial, Size
        $Result.Name = $pfaVol.Name
        $Result.Serial = $pfaVol.Serial
        $Result.Size = $pfaVol.Size
        $Result.ProtectionGroups = ((Get-PfaVolumeProtectionGroups -Array $fa -VolumeName $pfaVol.name).Protection_group)
        $volProtection += $Result
    }
    return $volProtection

# Retrieve Protection Group snapshot information
$pgs = Get-Pfaprotectiongroups -array $fa | Select-Object name
foreach ($pg in $pgs) {
    Get-PfaProtectionGroupSnapshots -array $fa -Name $pg.name | Select-Object Name, created | Format-Table -AutoSize
}

# Configure syslog on multiple arrays
$cred = Get-Credential
$arrays = "x.x.x.x,x.x.x.x,x.x.x.x"
$SysLogServer = "tcp://x.x.x.x:514"
Foreach ($array in $arrays) {
    $array = New-PfaArray -EndPoint $array -Credentials $cred -IgnoreCertificateError | Set-PfaSyslogServer -Array $array -SyslogServer $SyslogServer | Format-List
}

# Create a array-to-array replication connection
$sourceArray = New-PfaArray -EndPoint "x.x.x.x" -IgnoreCertificateError -Credentials (Get-Credential)
$targetArray = New-PfaArray -EndPoint "x.x.x.x" -IgnoreCertificateError -Credentials (Get-Credential)
$connectionKey = Get-PfaConnectionKey -Array $targetArray
# -ManagementAddress is the Target Array IP, -ReplicationAddress is the Target Array Replbond or Replication IP
New-PfaReplicationConnection -Array $sourceArray -ManagementAddress "x.x.x.x" -replicationAddress "x.x.x.x" -connectionKey $connectionKey.connection_key -Types "replication"

### END