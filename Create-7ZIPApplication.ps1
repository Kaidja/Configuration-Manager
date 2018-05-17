#STEP 0 - Import the Module
# Import Module
Import-Module $env:SMS_ADMIN_UI_PATH.Replace("\bin\i386","\bin\configurationmanager.psd1")
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location "$($SiteCode.Name):\"

#STEP 1 - Download the content
$7ZIPURL = 'https://www.7-zip.org/a/7z1805-x64.exe'
$SourceFolder = 'E:\Sources\Software\7-ZIP\18.05\X64\EXE\7z1805-x64.exe'
Invoke-WebRequest -Uri $7ZIPURL -OutFile $SourceFolder

#STEP 2 - Get the file information
$FileInfo = Get-Item -Path $SourceFolder
$FileInfo.VersionInfo.ProductVersion
$FileInfo.BaseName

#STEP 3 - Create the Application
    $AppProperties = @{
        Name = $FileInfo.BaseName;
        SoftwareVersion = $FileInfo.VersionInfo.ProductVersion
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
        Existence = $True
    }

$7ZIPFolder = New-CMDetectionClauseDirectory @7ZIPFolderProperties
$7ZIPFile = New-CMDetectionClauseFile @7ZIPFileProperties

#STEP 5 - Create the Deployment Type with detection methods
$DeploymentTypeProperties = @{
    InstallCommand = "$($FileInfo.Name) /S"
    DeploymentTypeName = 'Install - 7-ZIP'
    ApplicationName = $FileInfo.BaseName
    ContentLocation = '\\cm01\sources\Software\7-ZIP\18.05\X64\EXE'
    AddDetectionClause = $7ZIPFolder,$7ZIPFile
}
Add-CMScriptDeploymentType @DeploymentTypeProperties

#STEP 6 - Distribute the Content
    $ContentProperties = @{
        ApplicationName = $FileInfo.BaseName
        DistributionPointGroupName = 'All Content'
    }
Start-CMContentDistribution @ContentProperties

#STEP 7 - Create the Collection
    $CollectionProperties = @{
        Name = "SWD - $($FileInfo.BaseName) $($FileInfo.VersionInfo.ProductVersion)";
        LimitingCollectionName = 'All Systems';
        CollectionType = 'Device'
    }
New-CMCollection @CollectionProperties | Move-CMObject -FolderPath PS1:\DeviceCollection\Software

#STEP 8 - Create the Deployment
    $DeploymentProperties = @{
        Name = $FileInfo.BaseName;
        DeployAction = 'Install';
        DeployPurpose = 'Required';
        CollectionName = "SWD - $($FileInfo.BaseName) $($FileInfo.VersionInfo.ProductVersion)"
    }
New-CMApplicationDeployment @DeploymentProperties

