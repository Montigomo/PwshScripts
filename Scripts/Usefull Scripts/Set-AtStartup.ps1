
function Set-AtStartup {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProgrammPath
    )
    # Biltin/administrators   S-1-5-32-544  
    $A = New-ScheduledTaskAction -Execute $ProgrammPath
    $T = New-ScheduledTaskTrigger -AtLogon
    #$P = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $P = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-544" -RunLevel Highest
    $S = New-ScheduledTaskSettingsSet
    $D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S -
    Register-ScheduledTask -TaskPath "T1" -InputObject $D -TaskName "AtStartup"

    # $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
    # Register-ScheduledJob -Trigger $trigger -FilePath C:\fso\Get-BatteryStatus.ps1 -Name GetBatteryStatus
}

Set-AtStartup -ProgrammPath "D:\tools\network\Virtual Here\vhui64.exe"