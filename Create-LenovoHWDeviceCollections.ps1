#Import Module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

$CollectionFolderRoot = "$($SiteCode.Name):\DeviceCollection\Client Health\By Hardware Model"
$Query = "select Vendor,Version from SMS_G_System_COMPUTER_SYSTEM_PRODUCT where Vendor = 'Lenovo'"
$LimitingCollectionName = 'All Systems'

$LenovoModels = Get-CimInstance -Namespace "Root\SMS\Site_$($SiteCode.Name)" -Query $Query | Select-Object -Property Vendor,Version -Unique
foreach($Model in $LenovoModels){

    Write-Output -InputObject "Create - All Lenovo $($Model.Version) - Collection"
    
    $CollectionName = "All Lenovo $($Model.Version)"
    $LenovoQuery = "select *  from  SMS_R_System inner join SMS_G_System_COMPUTER_SYSTEM_PRODUCT on SMS_G_System_COMPUTER_SYSTEM_PRODUCT.ResourceId = SMS_R_System.ResourceId where SMS_G_System_COMPUTER_SYSTEM_PRODUCT.Version = '$($Model.Version)'"
    
    New-CMCollection -CollectionType Device -Name $CollectionName -LimitingCollectionName $LimitingCollectionName | 
        Move-CMObject -FolderPath $CollectionFolderRoot

    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName -RuleName $CollectionName -QueryExpression $LenovoQuery
}
