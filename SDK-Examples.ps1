# Example PowerShell code, scripts, and functions for the Pure Storage PowerShell SDK v1
<#
  This file contains the example script that follows along with the Quick Start Guide (https://support.purestorage.com/Solutions/Microsoft_Platform_Guide/a_Windows_PowerShell) as well as some further examples to help you create your own scripts using the SDK.

These examples are presented AS-IS. These examples are not meant to be implemented as-is in a production environment. No warranties expressed or implied by Pure Storage or the contributors.

: REVISION HISTORY
:: 01.05.2022 - Added examples and clarified code.
:: 03.10.2021 - Added extended script and altered text for clarity.

: CONTRIBUTORS
:: Barkz, Mike Nelson, Julian Cates, Robert Quimbey --  @purestorage
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
$fa = New-PfaArray -EndPoint 192.0.0.1 -Credentials $Creds -IgnoreCertificateError
Get-PfaControllers -Array $fa
$Controllers = Get-PfaControllers -Array $fa
$Controllers

## Working with Volumes
#######################
New-PfaVolume -Array $fa -VolumeName "sdk-vol" -Unit "TB" -Size 2
ForEach ($i in 2..10) { New-PfaVolume -Array $fa -VolumeName “sdk-vol$i” -Unit TB -Size 2 }
Get-PfaVolume -Array $fa -Name "sdk-vol" | Format-Table -Autosize
Rename-PfaVolumeOrSnapshot -Array $fa -NewName "sdk-vol1" -Name "sdk-vol"

## Volume and Host Connections
##############################
$wwn=@('10:00:00:00:00:00:11:11','10:00:00:00:00:00:12:12')
New-PfaHost -Array $fa -Name "sdk-host1" -WwnList $wwn
New-PfaHostGroup -Array $fa -Hosts "sdk-host1" -Name "sdk-hostgroup"
New-PfaHostVolumeConnection -Array $fa -VolumeName "sdk-vol1" -HostName "sdk-host1"
New-PfaHostGroupVolumeConnection -Array $fa -VolumeName "sdk-vol2" -HostGroupName "sdk-hostgroup"

## FlashRecover Snapshots
#########################
New-PfaVolumeSnapshots -Array $fa -Sources "sdk-vol1","sdk-vol2" -Suffix "EXAMPLE"
New-PfaVolume -Array $fa -Source "sdk-vol1.EXAMPLE" -VolumeName "new-sdk-vol1"
New-PfaVolume -Array $fa -Source "sdk-vol2.EXAMPLE" -VolumeName "sdk-vol2" -Overwrite

## Protection Groups
####################
New-PfaProtectionGroup -Array $fa -Name "sdk-pgroup"
$Volumes = @()
ForEach($i in 1..10) { $Volumes += @("sdk-vol$i") }
$Volumes
Add-PfaVolumesToProtectionGroup -Array $fa -VolumesToAdd $Volumes -Name "sdk-pgroup"
New-PfaProtectionGroupSnapshot -Array $fa -Protectiongroupname "sdk-pgroup" -Suffix "EXAMPLE"
Get-PfaProtectionGroupSnapshots -Array $fa -Name "sdk-pgroup"
Get-PfaProtectionGroupSchedule -Array $fa -ProtectionGroupName "sdk-pgroup"
Set-PfaProtectionGroupSchedule -Array $fa -SnapshotFrequencyInSeconds 21600 -GroupName "sdk-pgroup"
Enable-PfaSnapshotSchedule -Array $fa -Name "sdk-pgroup"

$Volumes = @()
ForEach($i in 1..10) { $Volumes += @("sdk-vol$i") }
$Volumes
Remove-PfaVolumesFromProtectionGroup -Array $fa -VolumesToRemove $Volumes -Name "sdk-pgroup"

Add-PfaHostsToProtectionGroup -Array $fa -Name "sdk-pgroup" -HostsToAdd "sdk-host1"
New-PfaProtectionGroupSnapshot -Array $fa -Protectiongroupname "sdk-pgroup"
Remove-PfaHostsFromProtectionGroup -Array $fa -HostsToRemove "sdk-host1" -Name "sdk-pgroup"

Add-PfaHostGroupsToProtectionGroup -Array $fa -HostGroupsToAdd "sdk-hostgroup" -Name "sdk-pgroup"
New-PfaProtectionGroupSnapshot -Array $fa -Protectiongroupname "sdk-pgroup"

## Monitor Metrics
##################
Get-Command -Module PureStoragePowerShellSDK *Metric
Get-PfaVolumeIOMetrics -Array $fa -VolumeName "sdk-vol1" -TimeRange 1h | Format-Table -AutoSize
Get-PfaVolumeIOMetrics -Array $fa -VolumeName "sdk-vol1" -TimeRange 1h | Export-Csv -Path "C:\temp\test.csv"

## END QUICK START EXAMPLES

## Miscellaneous
################

## EXAMPLE
# Run a Purity CLI command via SSH using a plaintext password converted to a SecureString
$CommandText = "purevol create --size 10G volume-name-1"
$Username = "pureuser"
$Password = "pureuser"
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
New-PfaCliCommand -EndPoint 192.0.0.1 -UserName $Username -Password $SecurePassword -CommandText $CommandText

## EXAMPLE
# Alternative using Get-Credentials in-line
$CommandText = "purepgroup snap --replicate-now sdk-pgroup"
New-PfaCliCommand -EndPoint 192.0.0.1 -Credential (Get-Credential) -CommandText $CommandText

## EXAMPLE
# Create a PowerShell array of authenticated FlashArray objects and perform a command against all of the objects in series
$fa @()
$fa += New-PfaArray -EndPoint 192.0.0.1 -Credentials (Get-Credential) -IgnoreCertificateError
$fa += New-PfaArray -EndPoint 192.0.0.2 -Credentials (Get-Credential) -IgnoreCertificateError
$fa += New-PfaArray -EndPoint 192.0.0.3 -Credentials (Get-Credential) -IgnoreCertificateError
$fa += New-PfaArray -EndPoint 192.0.0.4 -Credentials (Get-Credential) -IgnoreCertificateError
Get-PfaVolumes -Array $fa

## EXAMPLE
# Get volumes created within the last 30 days
$a = (Get-Date).AddDays(-30)
Get-PfaVolumes -Array $Array | Where-Object { ($_.name -like "Volume0*") -and ($_.created -ge $a) }

## EXAMPLE
# Destroy (not eradicate) snapshots older than "x" Days for all volumes
$targetDate = (Get-Date).AddDays(-1 * $Days)
$snaps = Get-PfaVolumeSnapshot -Array $fa -SnapshotName * | Where-Object source -EQ $Volume
foreach ($snap in $snaps) {
    $snapDate = Get-Date($snap.created)
    if ($snapDate -lt $targetDate) {
        Remove-PfaVolumeOrSnapshot -Array $fa -Name $snap.name
    }
}

## EXAMPLE
# The previous example code put into a Function with command line parameters
Function Remove-SnapshotsByTime {
Param (
        [Parameter(Mandatory = $true)][PSCredential]$Credential,
        [Parameter(Mandatory = $true)][String]$Array,
        [Parameter(Mandatory = $true)][String]$Volume,
        [Parameter(Mandatory = $true)][Int]$Days
    )
    $fa = New-PfaArray -Credentials $Credential -Endpoint 192.0.0.1 -IgnoreCertificateError
    $targetDate = (Get-Date).AddDays(-1 * $Days)
    $snaps = Get-PfaVolumeSnapshot -Array $fa -SnapshotName * | Where-Object source -EQ $Volume
    foreach ($snap in $snaps) {
        $snapDate = Get-Date($snap.created)
        if ($snapDate -lt $targetDate) {
            Remove-PfaVolumeOrSnapshot -Array $fa -Name $snap.name
        }
    }
}

## EXAMPLE
# Alternative method for destroy (not eradicate) snapshots older than "x" days for volume "vol1"
$fa = New-PfaArray -EndPoint 192.0.0.1 -Username pureuser -IgnoreCertificateError
    $purevolume = "vol1"
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

## EXAMPLE
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

## EXAMPLE
# Retrieve all Protection Group snapshot information
$pgs = Get-PfaProtectionGroups -Array $fa | Select-Object name
foreach ($pg in $pgs) {
    Get-PfaProtectionGroupSnapshots -Array $fa -Name $pg.name | Select-Object Name, created | Format-Table -AutoSize
}

## EXAMPLE
# Invoke REST API command to retrieve volumes
Invoke-PfaRestCommand -EndPoint 192.0.0.1 -Method GET -Command "https://pure01.example.com/api/1.19/volume"

## EXAMPLE
# Invoke REST API command create a volume 10G in size on Array $array
$command = "volume/sdk-vol1"
$body = ' { "size": "10G" } '
Invoke-PfaRestCommand -Array $fa -Method POST -Command $command -Body $body

## EXAMPLE
# Delete the volume created in the previous example
$command = "volume/sdk-vol1"
Invoke-PfaRestCommand -Array $fa -Method DELETE -Command $command

## EXAMPLE
# Eradicate the volume from the previous example
$command = "volume/sdk-vol1?eradicate=true"
Invoke-PfaRestCommand -Array $fa -Method DELETE -Command $command

## EXAMPLE
# Configure syslog server on multiple arrays
$cred = Get-Credential
$arrays = "192.0.0.1,192.0.0.2,192.0.0.3"
$SysLogServer = "tcp://192.0.0.100:514"
Foreach ($array in $arrays) {
    $array = New-PfaArray -EndPoint $array -Credentials $cred -IgnoreCertificateError | Set-PfaSyslogServer -Array $array -SyslogServer $SyslogServer | Format-List
}
## EXAMPLE
# Create an array-to-array replication connection
$sourceArray = New-PfaArray -EndPoint 192.0.0.1 -IgnoreCertificateError -Credentials (Get-Credential)
$targetArray = New-PfaArray -EndPoint 192.0.0.2 -IgnoreCertificateError -Credentials (Get-Credential)
$connectionKey = Get-PfaConnectionKey -Array $targetArray
# -ManagementAddress is the Target Array IP, -ReplicationAddress is the Target Array Replbond or Replication IP
New-PfaReplicationConnection -Array $sourceArray -ManagementAddress 192.0.0.1 -replicationAddress 192.0.0.2 -connectionKey $connectionKey.connection_key -Types "replication"

## EXAMPLE
# This is an example script to change a user password on a FlashArray
    Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    <# The "$OldPassword" and "$Newpassword" strings should not be changed to a SecureString unless the logic for the Invoke-WebRequest is also altered. #>
    function Update-UserFaPassword {
        Param (
            [Parameter(Mandatory = $true)][String]$User,
            [Parameter(Mandatory = $true)][String]$OldPassword,
            [Parameter(Mandatory = $true)][String]$NewPassword,
            [Parameter(Mandatory = $True)][Object[]]$Array
        )
    <# This function expects a connection to have already been made to the target array using the Pure PowerShell SDK v1. That array object must be passed to this function, as we use that to obtain endpoint and API token information. The api version could be 1.19 if present on the array. #>
        $baseURI = "https://" + $fa + "/api/1.17"
    <# Establish Connection Using API Token from SDK1 Array Variable. #>
        $connectURI = $baseURI + "/auth/session"
        $connectBody = @{
            api_token = $fa.ApiToken
        }
        $result = Invoke-WebRequest -Uri $connectURI -Method Post -Body $connectBody -SessionVariable pure -UseBasicParsing
    <# Update Password #>
        $adminURI = $baseURI + "/admin/" + $User
        $body = @{
            password     = $NewPassword;
            old_password = $OldPassword;
        }
        $body = $body | ConvertTo-Json
        $result = Invoke-WebRequest -Uri $adminURI -WebSession $pure -Method Put -Body $body -ContentType "application/json" -UseBasicParsing
    <# Get and Return Updated User #>
        $user = Invoke-WebRequest -Uri $adminURI -Method Get -WebSession $pure -UseBasicParsing
        return ConvertFrom-Json($user)
        }
    <# Example Usage of the Update-UserFaPassword Function #>
        $fa = New-PfaArray -EndPoint 192.0.0.1 -Credentials (Get-Credential) -IgnoreCertificateError
        Update-UserFaPassword -Array $fa -User "user1" -OldPassword "myoldpassword" -NewPassword "mynewpassword"


### END EXAMPLES FILE