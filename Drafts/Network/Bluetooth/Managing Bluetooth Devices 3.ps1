$Address =     @{
    Name='Address'
Expression={$_.HardwareID | 
ForEach-Object { [uInt64]('0x' + $_.Substring(12))}}
}
 
Get-PnpDevice -Class Bluetooth |
    Where-Object HardwareID -match 'DEV_' |
    Select-Object FriendlyName, $Address |
    Where-Object Address |
    Out-GridView -Title 'Select Bluetooth Device to Unpair' -OutputMode Single #|
    #Unpair-Bluetooth