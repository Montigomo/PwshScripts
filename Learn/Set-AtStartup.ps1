

$A = New-ScheduledTaskAction -Execute "Taskmgr.exe"
$T = New-ScheduledTaskTrigger -AtLogon
$P = New-ScheduledTaskPrincipal "Contoso\Administrator"
$S = New-ScheduledTaskSettingsSet
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask T1 -InputObject $D