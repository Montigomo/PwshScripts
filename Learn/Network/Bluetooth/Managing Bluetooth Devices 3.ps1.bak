[CmdletBinding()] Param (
    [Parameter(Mandatory=$true)][ValidateSet('Off', 'On')][string]$BluetoothStatus
)
If ((Get-Service bthserv).Status -eq 'Stopped') { Start-Service bthserv }
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { 
        $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' 
    })[0]
    
Function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}
[Windows.Devices.Radios.Radio,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
[Windows.Devices.Radios.RadioAccessStatus,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
Await ([Windows.Devices.Radios.Radio]::RequestAccessAsync()) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null
$radios = Await ([Windows.Devices.Radios.Radio]::GetRadiosAsync()) ([System.Collections.Generic.IReadOnlyList[Windows.Devices.Radios.Radio]])
$bluetooth = $radios | ? { $_.Kind -eq 'Bluetooth' }
[Windows.Devices.Radios.RadioState,Windows.System.Devices,ContentType=WindowsRuntime] | Out-Null
Await ($bluetooth.SetStateAsync($BluetoothStatus)) ([Windows.Devices.Radios.RadioAccessStatus]) | Out-Null



$device = Get-PnpDevice | Where-Object {$_.Class -eq "Bluetooth" -and $_.FriendlyName -eq "FriendlyDeviceName"}
Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
Start-Sleep -Seconds 10
Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false



$Source = @"
   [DllImport("BluetoothAPIs.dll", SetLastError = true, CallingConvention = CallingConvention.StdCall)]
   [return: MarshalAs(UnmanagedType.U4)]
   static extern UInt32 BluetoothRemoveDevice(IntPtr pAddress);
   public static UInt32 Unpair(UInt64 BTAddress) {
      GCHandle pinnedAddr = GCHandle.Alloc(BTAddress, GCHandleType.Pinned);
      IntPtr pAddress     = pinnedAddr.AddrOfPinnedObject();
      UInt32 result       = BluetoothRemoveDevice(pAddress);
      pinnedAddr.Free();
      return result;
   }
"@
Function Get-BTDevice {
    Get-PnpDevice -class Bluetooth |
      ?{$_.HardwareID -match 'DEV_'} |
         select Status, Class, FriendlyName, HardwareID,
            # Extract device address from HardwareID
            @{N='Address';E={[uInt64]('0x{0}' -f $_.HardwareID[0].Substring(12))}}
}
################## Execution Begins Here ################
$BTDevices = @(Get-BTDevice) # Force array if null or single item
$BTR = Add-Type -MemberDefinition $Source -Name "BTRemover"  -Namespace "BStuff" -PassThru
Do {
   If ($BTDevices.Count) {
      "`n******** Bluetooth Devices ********`n" | Write-Host
      For ($i=0; $i -lt $BTDevices.Count; $i++) {
         ('{0,5} - {1}' -f ($i+1), $BTDevices[$i].FriendlyName) | Write-Host
      }
      $selected = Read-Host "`nSelect a device to remove (0 to Exit)"
      If ([int]$selected -in 1..$BTDevices.Count) {
         'Removing device: {0}' -f $BTDevices[$Selected-1].FriendlyName | Write-Host
         $Result = $BTR::Unpair($BTDevices[$Selected-1].Address)
         If (!$Result) {"Device removed successfully." | Write-Host}
         Else {"Sorry, an error occured." | Write-Host}
      }
   }
   Else {
      "`n********* No devices foundd ********" | Write-Host
   }
} While (($BTDevices = @(Get-BTDevice)) -and [int]$selected)