
function Get-HardwareHash {
    
    function GetIdentifier {
        [CmdletBinding()]
        param (
            [Parameter()][string]$ClassName,
            [Parameter()][string[]]$Properties
        )
        $result = [System.String]::Empty
        $items = Get-CimInstance -Class $ClassName;
        foreach ($item in $items) {
            foreach ($property in $Properties) {
                $result += $item | Select-Object -ExpandProperty $property -ErrorAction SilentlyContinue
            }
        }
        return $result
    }

    $hstr = GetIdentifier -ClassName "Win32_Processor" -Properties "UniqueId"
    
    if ([System.String]::IsNullOrWhiteSpace($hstr)) {
        $hstr = GetIdentifier -ClassName "Win32_Processor" -Properties "ProcessorId"
        if ([System.String]::IsNullOrWhiteSpace($hstr)) {
            $hstr = GetIdentifier -ClassName "Win32_Processor" -Properties "Name"
            if ([System.String]::IsNullOrWhiteSpace($hstr)) {
                $hstr = GetIdentifier -ClassName "Win32_Processor" -Properties "Manufacturer"
            }
            $hstr += GetIdentifier -ClassName "Win32_Processor" -Properties "MaxClockSpeed"
        }
    }
    $hstr += GetIdentifier -ClassName "Win32_BIOS" -Properties @("Manufacturer", "SMBIOSBIOSVersion", "IdentificationCode", "SerialNumber", "ReleaseDate", "Version")
    $hstr += GetIdentifier -ClassName "Win32_BaseBoard" -Properties @("Model", "Manufacturer", "Name", "SerialNumber")
    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    $utf8 = New-Object -TypeName System.Text.UTF8Encoding
    $hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($hstr))) -replace "-", ""
    return $hash
}