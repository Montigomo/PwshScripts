

# 

if((Test-Path variable:global:TASK_TRIGGER_EVENT) -eq $false)
{
# typedef enum  {
New-Variable -Name TASK_TRIGGER_EVENT                 -Value 0 -Option constant
New-Variable -Name TASK_TRIGGER_TIME                  -Value 1 -Option constant
New-Variable -Name TASK_TRIGGER_DAILY                 -Value 2 -Option constant
New-Variable -Name TASK_TRIGGER_WEEKLY                -Value 3 -Option constant
New-Variable -Name TASK_TRIGGER_MONTHLY               -Value 4 -Option constant
New-Variable -Name TASK_TRIGGER_MONTHLYDOW            -Value 5 -Option constant
New-Variable -Name TASK_TRIGGER_IDLE                  -Value 6 -Option constant
New-Variable -Name TASK_TRIGGER_REGISTRATION          -Value 7 -Option constant
New-Variable -Name TASK_TRIGGER_BOOT                  -Value 8 -Option constant
New-Variable -Name TASK_TRIGGER_LOGON                 -Value 9 -Option constant
New-Variable -Name TASK_TRIGGER_SESSION_STATE_CHANGE  -Value 11 -Option constant
# }   TASK_TRIGGER_TYPE2;
}


if((Test-Path variable:global:TASK_ACTION_EXEC) -eq $false)
{
# typedef enum  { 
New-Variable -Name TASK_ACTION_EXEC          -Value 0 -Option constant
New-Variable -Name TASK_ACTION_COM_HANDLER   -Value 5 -Option constant
New-Variable -Name TASK_ACTION_SEND_EMAIL    -Value 6 -Option constant
New-Variable -Name TASK_ACTION_SHOW_MESSAGE  -Value 7 -Option constant
# } TASK_ACTION_TYPE;
}
if((Test-Path variable:global:TASK_VALIDATE_ONLY) -eq $false)
{
# typedef enum  {
New-Variable -Name TASK_VALIDATE_ONLY                -Value 0 -Option constant
New-Variable -Name TASK_CREATE                       -Value 2 -Option constant
New-Variable -Name TASK_UPDATE                       -Value 4 -Option constant
New-Variable -Name TASK_CREATE_OR_UPDATE             -Value 6 -Option constant
New-Variable -Name TASK_DISABLE                      -Value 8 -Option constant
New-Variable -Name TASK_DONT_ADD_PRINCIPAL_ACE       -Value 10 -Option constant
New-Variable -Name TASK_IGNORE_REGISTRATION_TRIGGERS -Value 20 -Option constant
# } TASK_CREATION;
}
if((Test-Path variable:global:TASK_LOGON_NONE) -eq $false)
{
# typedef enum  {
New-Variable -Name TASK_LOGON_NONE                          -Value 0 -Option constant
New-Variable -Name TASK_LOGON_PASSWORD                      -Value 1 -Option constant
New-Variable -Name TASK_LOGON_S4U                           -Value 2 -Option constant
New-Variable -Name TASK_LOGON_INTERACTIVE_TOKEN             -Value 3 -Option constant
New-Variable -Name TASK_LOGON_GROUP                         -Value 4 -Option constant
New-Variable -Name TASK_LOGON_SERVICE_ACCOUNT               -Value 5 -Option constant
New-Variable -Name TASK_LOGON_INTERACTIVE_TOKEN_OR_PASSWORD -Value 6 -Option constant
# } TASK_LOGON_TYPE;
}

$TaskName = "aaa"

$service = New-Object -ComObject("Schedule.Service")
$service.Connect()
$rootFolder = $service.GetFolder("")

$taskdef = $service.NewTask(0)

# Creating task settings with some default properties plus
# the task’s idle settings; requiring 15 minutes idle time
$sets = $taskdef.Settings
$sets.AllowDemandStart = $true
$sets.Compatibility = 2
$sets.Enabled = $true
$sets.RunOnlyIfIdle = $true
$sets.IdleSettings.IdleDuration = "PT01M"
$sets.IdleSettings.WaitTimeout = "PT00M"
$sets.IdleSettings.StopOnIdleEnd = $true
$sets.StopIfGoingOnBatteries = $false
$sets.DisallowStartIfOnBatteries = $false
$sets.StartWhenAvailable = $true
$sets.RunOnlyIfNetworkAvailable = $false
$sets.WakeToRun = $true

# Creating an reoccurring daily trigger, limited to execute
# once per 40-minutes.
$trg = $taskdef.Triggers.Create($TASK_TRIGGER_IDLE)
# $trg.StartBoundary = ([datetime]::Now).ToString("yyyy-MM-dd'T'HH:mm:ss")
# $trg.Enabled = $true
# $trg.DaysInterval = 1
# $trg.Repetition.Duration = "P1D"
# $trg.Repetition.Interval = "PT40M"
# $trg.Repetition.StopAtDurationEnd = $true

# The command and command arguments to execute
$act = $taskdef.Actions.Create(0)
$act.Path = 'D:\temp\awatcher\xmrig\xmrig.exe'
$act.Arguments = ""

#
$principal = $taskdef.Principal
#$principal.GroupId
$test = $principal.Id
$principal.Id ='NT AUTHORITY\SYSTEM'
$principal.LogonType = $TASK_LOGON_SERVICE_ACCOUNT
$principal.RunLevel = 1
#$principal.UserId
$test = $principal.Id

$user = "SYSTEM"
$password = $null
$sddl = $null

# Register the task under the current Windows user
#$user = [environment]::UserDomainName + "\" + [environment]::UserName
#$rootFolder.RegisterTaskDefinition($TaskName, $taskdef, 6, $user, $null, 3)
$res = $rootFolder.RegisterTaskDefinition($TaskName,$taskdef,$TASK_CREATE_OR_UPDATE, $user,$password,$TASK_LOGON_SERVICE_ACCOUNT,$sddl)