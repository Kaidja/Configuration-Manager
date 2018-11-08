Function Convert-BitLockerEncryptionMethod
{
    Param(
        $EncryptionMethodCode
    )

    Switch($EncryptionMethodCode){

    #Source - https://docs.microsoft.com/en-us/windows/desktop/secprov/getencryptionmethod-win32-encryptablevolume

    0 { $EncryptionMethod = "The volume is not encrypted";Break}
    1 { $EncryptionMethod = "AES_128_WITH_DIFFUSER";Break}
    2 { $EncryptionMethod = "AES_256_WITH_DIFFUSER";Break}
    3 { $EncryptionMethod = "AES_128";Break}
    4 { $EncryptionMethod = "AES_256";Break}
    5 { $EncryptionMethod = "HARDWARE_ENCRYPTION";Break}
    6 { $EncryptionMethod = "XTS_AES_128";Break}
    7 { $EncryptionMethod = "XTS_AES_256";Break}
    Default { $EncryptionMethod = "Unknown";Break}

    }

    Return $EncryptionMethod
}
$BitLockerInfo = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftVolumeEncryption" -Class Win32_EncryptableVolume -Filter "DriveLetter='C:'"
Convert-BitLockerEncryptionMethod -EncryptionMethodCode $BitLockerInfo.GetEncryptionMethod().EncryptionMethod
