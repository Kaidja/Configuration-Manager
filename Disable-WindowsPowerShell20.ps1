#Discovery Script
Get-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2Root" -Online | Select-Object -ExpandProperty State

#Remediation Script
Disable-WindowsOptionalFeature -FeatureName "MicrosoftWindowsPowerShellV2Root" -Online 
