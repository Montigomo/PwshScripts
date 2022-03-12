
function Set-AtStartup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProgrammPath
    )
    

    $A = New-ScheduledTaskAction -Execute "Taskmgr.exe"
    $T = New-ScheduledTaskTrigger -AtLogon
    $P = New-ScheduledTaskPrincipal "Contoso\Administrator"
    $S = New-ScheduledTaskSettingsSet
    $D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
    Register-ScheduledTask T1 -InputObject $D



    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30

    Register-ScheduledJob -Trigger $trigger -FilePath C:\fso\Get-BatteryStatus.ps1 -Name GetBatteryStatus

}

Set-AtStartup -ProgrammPath "D:\tools\network\Virtual Here\vhui64.exe"