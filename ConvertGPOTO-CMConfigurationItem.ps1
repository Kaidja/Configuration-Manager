Function Get-GPSettings {

    Param( 
        [string]$Key, 
        [string]$GPOName 
    )

        $CurrentRegKey = Get-GPRegistryValue -Name $GPOName -Key $Key

        If($CurrentRegKey -eq $null){ 
             
        } 
        Foreach ($RegKey in $CurrentRegKey) { 
            If ($RegKey.ValueName -ne $null){
                Write-Output $RegKey
                [ARRAY]$ReturnKey += $RegKey 
            } 
            Else{
                Get-GPSettings -Key $RegKey.FullKeyPath -GPOName $GPOName
            } 
        }
            
}
################# SCRIPT ENTRY POINT ##################
$GPOName = 'Credential Guard'
#$GPOName = 'Windows Update'
#$GPOName = 'Microsoft LAPS'

$Key = 'HKLM\Software\Policies'
$Settings = Get-GPSettings -Key $Key -GPOName $GPOName

#Import Configuration Manager PowerShell Module
Import-Module 'E:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Set-Location PS1:\

foreach($GPSetting in $Settings){
    Switch($GPSetting.Value.GetType().Name){
            'Int32'{$DataType = 'Integer'; Break}
            'String'{$DataType = 'String'; Break}
    }

    $CIProperties = @{
        SettingName = $GPSetting.ValueName;
        RuleName = $GPSetting.ValueName + " must be " + $GPSetting.Value;
        DataType = $DataType;
        Hive = 'LocalMachine';
        KeyName = $GPSetting.KeyPath;
        ValueName = $GPSetting.ValueName;
        ValueRule = $True;
        ExpressionOperator = 'IsEqual';
        ExpectedValue = $GPSetting.Value
    }

    New-CMConfigurationItem -Name "CI WRK - $GPOName - $($GPSetting.ValueName)" -CreationType WindowsOS | 
    Add-CMComplianceSettingRegistryKeyValue @CIProperties
}
