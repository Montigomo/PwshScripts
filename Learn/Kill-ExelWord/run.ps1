

#$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
#add-type -name win -member $t -namespace native

#[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)


@("WINWORD", "EXCEL") | foreach{ if((Get-Process $_ -ErrorAction SilentlyContinue) -ne $null) { Stop-Process -Name $_ -Force} }


#$processName = @("WINWORD", "EXCEL")
#foreach($item in $processName)
#{
#    $ProcessActive = Get-Process $item -ErrorAction SilentlyContinue
#    if($ProcessActive -eq $null)
#    {
#        #Write-host "Do X"
#    }
#    else
#    {
#        Stop-Process -Name $item -Force
#    }
#}

#$p = Get-Process -Name "WINWORD"
#Stop-Process -InputObject $p -Force -Confirm
#Get-Process | Where-Object {$_.HasExited}