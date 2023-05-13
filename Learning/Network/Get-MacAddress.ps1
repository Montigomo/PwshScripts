function Get-MacAddress
{
    [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
      ForEach-Object {
          $nic = $_
      
          [PSCustomObject]@{
              Name = $_.Name
              Status = $_.OperationalStatus
              Mac   = [System.BitConverter]::ToString($nic. GetPhysicalAddress().GetAddressBytes())
              Type = $_.NetworkInterfaceType
              SpeedGb = $(if ($_.Speed -ge 0) { $_.Speed/1000000000 } )
              Description  = $_.Description
          }
      }
} 