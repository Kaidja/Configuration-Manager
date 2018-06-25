#Import Module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

$CollectionFolderRoot = "$($SiteCode.Name):\DeviceCollection\Client Health\By Hardware Model"
$Query = "select Manufacturer,Model from SMS_G_System_COMPUTER_SYSTEM where Manufacturer <>'Lenovo'"
$LimitingCollectionName = 'All Systems'

$OtherModels = Get-CimInstance -Namespace "Root\SMS\Site_$($SiteCode.Name)" -Query $Query | Select-Object -Property Model,Manufacturer -Unique
foreach($Model in $OtherModels){

    Write-Output -InputObject "Create - All $($Model.Manufacturer) $($Model.Model) - Collection"
    
    $CollectionName = "All $($Model.Manufacturer) $($Model.Model)"
    $HWQuery = "select *  from  SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM on SMS_G_System_COMPUTER_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM.Model = '$($Model.Model)'"
    
    New-CMCollection -CollectionType Device -Name $CollectionName -LimitingCollectionName $LimitingCollectionName | 
        Move-CMObject -FolderPath $CollectionFolderRoot

    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -RuleName $CollectionName -QueryExpression $HWQuery
}
