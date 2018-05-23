<#
.Synopsis
   This script allows you to import Configuration Manager Device Collection Maintenance Windows from a CSV file
.DESCRIPTION
   
.EXAMPLE
   Import-CMMaintenanceWindows.ps1 -MWsInputFile 'D:\Scripts\SUPMWs.csv' -Preview
   Preview the Device Collection Maintenance Windows before the real production import.
.EXAMPLE
   Import-CMMaintenanceWindows.ps1 -MWsInputFile 'D:\Scripts\SUPMWs.csv' -Production
   Import Configuration Manager Maintenance Windows to Configuration Manager.
#>
[CmdLetBinding(DefaultParameterSetName = "none")]
Param(
    [Parameter(Mandatory=$True,
               HelpMessage="Please specify Maintenance Windows CSV file location",
               ParameterSetName='Preview')]
    [Parameter(Mandatory=$True,
               HelpMessage="Please specify Maintenance Windows CSV file location",
               ParameterSetName='Production')]
               [ValidateScript({Test-Path -Path $PSItem})]
               [String]
               $MWsInputFile,
    [Parameter(Mandatory=$True,
               ParameterSetName='Production')]
               [Switch]
               $Production,
    [Parameter(Mandatory=$True,
               ParameterSetName='Production')]
    [Parameter(Mandatory=$True,
               ParameterSetName='Preview')]
               [String]
               $Delimiter,
    [Parameter(Mandatory=$True,
               ParameterSetName='Preview')]
               [Switch]
               $Preview
)

$CurrentLocation = Get-Location

#Import Configuration Manager Module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

#Import CSV file
$MWInfo = Import-Csv -Path $MWsInputFile -Delimiter $Delimiter

If($Preview){

    $PreviewMWs = @()
    foreach($MW in $MWInfo){
       $Collection = Get-CMDeviceCollection -Name $MW.'Collection Name'
       $MaintenanceWindowDate = Get-Date -Hour ($MW.'Start Time').Split(":")[0] -Minute 00  -Date (Get-Date $MW.'Patch Tuesday').AddDays($MW.OffSet)
       
       #Build new MW
       $Schedule = New-CMSchedule -Start $MaintenanceWindowDate -End $MaintenanceWindowDate.AddHours($MW.Duration) -Nonrecurring
       $Schedule | Add-Member -MemberType NoteProperty -Name 'Collection' -Value $Collection.Name
       $Schedule | Add-Member -MemberType NoteProperty -Name 'CollectionID' -Value $Collection.CollectionID
       $Schedule | Add-Member -MemberType NoteProperty -Name 'Patch Tuesday' -Value $MW.'Patch Tuesday'
       $Schedule | Add-Member -MemberType NoteProperty -Name 'Off Set (Days)' -Value $MW.OffSet
       $Schedule | Add-Member -MemberType NoteProperty -Name 'Maintenance Window Date' -Value $Schedule.StartTime
       $Schedule | Add-Member -MemberType NoteProperty -Name 'MW Type' -Value $MW.'Maintenance Window Type'
       $Schedule | Add-Member -MemberType NoteProperty -Name 'MW Name' -Value $MW.'MW Name'

       #Save the object for later report
       $PreviewMWs += $Schedule
    }
    $PreviewMWs | Out-GridView -Title "Maintenance Windows Preview - $(Get-Date) by Kaido Järvemets - KaidoJarvemets.com"

}

If($Production){

    foreach($MW in $MWInfo){

       $Collection = Get-CMDeviceCollection -Name $MW.'Collection Name'
       $MaintenanceWindowDate = Get-Date -Hour ($MW.'Start Time').Split(":")[0] -Minute 00  -Date (Get-Date $MW.'Patch Tuesday').AddDays($MW.OffSet)
       
       #Build new MW
       $Schedule = New-CMSchedule -Start $MaintenanceWindowDate -End $MaintenanceWindowDate.AddHours($MW.Duration) -Nonrecurring
       $Schedule | Add-Member -MemberType NoteProperty -Name 'Collection' -Value $Collection.Name
       $Schedule | Add-Member -MemberType NoteProperty -Name 'CollectionID' -Value $Collection.CollectionID
       
       New-CMMaintenanceWindow -Name $MW.'MW Name' -CollectionID $Collection.CollectionID -ApplyTo $MW.'Maintenance Window Type' -Schedule $Schedule
    }

    
}

#Back to file system
Set-Location $CurrentLocation
