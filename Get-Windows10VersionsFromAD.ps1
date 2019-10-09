Function Convert-Windows10BuildVersion
{
    Param(
        $BuilVersion
    )

    Switch($BuilVersion){
        "10.0 (10586)" {"Windows 10 1511"}
        "10.0 (14393)" {"Windows 10 1607"}
        "10.0 (15063)" {"Windows 10 1703"}
        "10.0 (16299)" {"Windows 10 1709"}
        "10.0 (17134)" {"Windows 10 1803"}
        "10.0 (17763)" {"Windows 10 1809"}
        "10.0 (18362)" {"Windows 10 1903"}
        "10.0 (18895)" {"Windows 10 Insider Preview"}
        Default {"$BuilVersion - We dont know this version"}
    }
}
$ProcessedMachines = @()
$ADComputers = Get-ADComputer -Filter {OperatingSystem -like "*Windows 10*"} -Properties OperatingSystem,operatingSystemVersion
foreach($Computer in $ADComputers){

    $CompProperties = @{
        "Name" = $Computer.Name
        "Windows10Version" = Convert-Windows10BuildVersion -BuilVersion $Computer.OperatingSystemVersion
    }

    $Object = New-Object -TypeName PSObject -Property $CompProperties
    $ProcessedMachines += $Object
}

$ProcessedMachines | Group-Object -Property Windows10Version
