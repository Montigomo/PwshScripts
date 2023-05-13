function Unpair-Bluetooth
{
    # take a UInt64 either directly or as part of an object with a property
    # named "DeviceAddress" or "Address"
    param
    (
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('Address')]
        [UInt64]
        $DeviceAddress
    )
 
    # tell PowerShell the location of the internal Windows API
    # and define a static helper function named "Unpair" that takes care
    # of creating the needed arguments:
    begin
    {
        Add-Type -Namespace "Devices" -Name 'Bluetooth' -MemberDefinition '
[DllImport("BluetoothAPIs.dll", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
[return: MarshalAs(UnmanagedType.U4)]
static extern UInt32 BluetoothRemoveDevice(IntPtr pAddress);
public static UInt32 Unpair(UInt64 BTAddress) {
    GCHandle pinnedAddr = GCHandle.Alloc(BTAddress, GCHandleType.Pinned);
    IntPtr pAddress     = pinnedAddr.AddrOfPinnedObject();
    UInt32 result       = BluetoothRemoveDevice(pAddress);
    pinnedAddr.Free();
    return result;
}'
    }
 
    # do this for every object that was piped into this function:
    process
    {
        $result = [Devices.Bluetooth]::Unpair( $DeviceAddress)
        [PSCustomObject]@{
            Success = $result -eq 0
            ReturnValue = $result
        }
    }
} 


# $Address =     @{
#     Name='Address'
#     Expression={$_.HardwareID | ForEach-Object { [uInt64]('0x' + $_.Substring(12))}}
# }

# Get-PnpDevice -Class Bluetooth |
#    Where-Object HardwareID -match 'DEV_' |
#    Select-Object FriendlyName, $Address |
#    Where-Object Address |
#    Out-GridView -Title 'Select Bluetooth Device to Remove' -OutputMode Single 


$Address =     @{
    Name='Address'
    Expression={$_.HardwareID |  ForEach-Object { [uInt64]('0x' + $_.Substring(12))}}
}
 
Get-PnpDevice -Class Bluetooth |
    Where-Object HardwareID -match 'DEV_' |
    Select-Object FriendlyName, $Address |
    Where-Object Address |
    Out-GridView -Title 'Select Bluetooth Device to Unpair' -OutputMode Single |
    Unpair-Bluetooth