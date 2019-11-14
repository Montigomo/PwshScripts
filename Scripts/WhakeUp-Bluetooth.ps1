

$device = Get-PnpDevice | Where-Object {$_.Class -eq "Bluetooth" -and $_.FriendlyName -eq "Samsung U Flex (40BB)"}

Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false

Start-Sleep -Seconds 10

Enable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
