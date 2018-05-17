# Import Module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")

# Import Boundaries from CSV file
$Boundaries = Import-Csv `
    -Path 'E:\Scripts\Boundaries\DummyBoundaries.csv' -UseCulture

$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

foreach($Boundary in $Boundaries){

    Write-Output -InputObject "Creating $($Boundary.Name)"
    
    #Create the Boundary
    New-CMBoundary `
        -Name $Boundary.Name `
        -Type IPRange `
        -Value "$($Boundary.'Iprange start')-$($Boundary.'IP range End')"
}
