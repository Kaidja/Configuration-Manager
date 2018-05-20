#STEP 0 - Import the Module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

#STEP 1 - Download the content
$7ZIPURL = 'https://www.7-zip.org/a/7z1805-x64.exe'
$SourceFolder = 'E:\Sources\Software\7-ZIP\18.05\X64\EXE\7z1805-x64.exe'
Invoke-WebRequest -Uri $7ZIPURL -OutFile $SourceFolder

#STEP 2 - Get the file information
$FileInfo = Get-Item -Path $SourceFolder
$Version = $FileInfo.VersionInfo.ProductVersion
$FileName = $FileInfo.BaseName

#Define additional variables for 7-ZIP Application
$ApplicationName = '7-ZIP'
$CommandLine = "$($FileInfo.Name) /S"
$DeploymentTypeName = "Install - $FileName"
$ContentLocation = '\\cm01\sources\Software\7-ZIP\18.05\X64\EXE'
$DistributionPointGroupName = 'All Content'
$InstallCollectionName = "SWD - $ApplicationName - $Version"
$LimitingCollectionName = 'All Systems'
$SoftwareAPPRootFolder = "$($SiteCode.Name):\DeviceCollection\Software"

#STEP 3 - Create the Application
    $AppProperties = @{
        Name = $ApplicationName;
        SoftwareVersion = $Version
    }

New-CMApplication @AppProperties

#STEP 4 - Create the Detection Methods
    $7ZIPFolderProperties = @{
        DirectoryName = '7-Zip';
        Path = 'C:\Program Files\';
        Is64Bit = $True;
        Existence = $True
    }
    $7ZIPFileProperties = @{
        FileName = '7zFM.exe';
        Path = 'C:\Program Files\7-Zip';
        Is64Bit = $True;
        PropertyType = 'Version';
        ExpectedValue = $Version;
        ExpressionOperator = 'IsEquals'
        Value = $True
    }

$7ZIPFolder = New-CMDetectionClauseDirectory @7ZIPFolderProperties
$7ZIPFile = New-CMDetectionClauseFile @7ZIPFileProperties

#STEP 5 - Create the Deployment Type with detection methods
$DeploymentTypeProperties = @{
    InstallCommand = $CommandLine
    DeploymentTypeName = $DeploymentTypeName
    ApplicationName = $ApplicationName
    ContentLocation = $ContentLocation
    AddDetectionClause = $7ZIPFolder,$7ZIPFile
}
Add-CMScriptDeploymentType @DeploymentTypeProperties

#STEP 6 - Distribute the Content
    $ContentProperties = @{
        ApplicationName = $ApplicationName
        DistributionPointGroupName = $DistributionPointGroupName
    }
Start-CMContentDistribution @ContentProperties

#STEP 7 - Create the Collection
    $CollectionProperties = @{
        Name = $InstallCollectionName;
        LimitingCollectionName = $LimitingCollectionName;
        CollectionType = 'Device'
    }
New-CMCollection @CollectionProperties | Move-CMObject -FolderPath $SoftwareAPPRootFolder

#STEP 8 - Create the Deployment
    $DeploymentProperties = @{
        Name = $ApplicationName;
        DeployAction = 'Install';
        DeployPurpose = 'Required';
        CollectionName = $InstallCollectionName
    }
New-CMApplicationDeployment @DeploymentProperties
