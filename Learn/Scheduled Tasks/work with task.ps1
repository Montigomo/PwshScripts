


# $taskPrincipal = New-ScheduledTaskPrincipal -UserId 'NTAuthority\SYSTEM' -RunLevel Highest


# write0output 'ooo'




# $action = New-ScheduledTaskAction -Execute foo.exe -Argument "bar baz"
# $trigger = New-ScheduledTaskTrigger -Once -At $startTime -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([Timespan]::MaxValue)
# $principal = New-ScheduledTaskPrincipal -UserId "$($env:USERDOMAIN)\$($env:USERNAME)" -LogonType ServiceAccount
# $settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel

# Register-ScheduledTask -TaskName $taskName -TaskPath "\my\path" -Action $action -Trigger $trigger -Settings $settings -Principal $principal




# $TaskName = "FileSync"
# $Description = "This task will run periodically to sync .fin files from a specified source directory to a specified destination directory"
# $ScriptPath = "C:\Users\my_userDesktop\file_sync.ps1"
# $UserAccount = "COMP1\my_user"
# $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $ScriptPath"
# $Principal = New-ScheduledTaskPrincipal -UserID $UserAccount -LogonType ServiceAccount
# $Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration ([System.TimeSpan]::MaxValue)
# Register-ScheduledTask -TaskName $TaskName -Action $Action -Description $Description -Trigger $Trigger -Principal $Principal



# $ErrorActionPreference = 'Stop'


# Clear-Host

# $taskName = "it3xl_dummy_PowerShell_job"
# # Unregister-ScheduledJob it3xl_dummy_PowerShell_job -Confirm:$false

# $task = Get-ScheduledJob -Name $taskName  -ErrorAction SilentlyContinue
# if ($task -ne $null)
# {
#     Unregister-ScheduledJob $task  -Confirm:$false
#     Write-Host "Old $taskName job has been unregistered"; Write-Host;
# }


$trigger = New-JobTrigger -AtStartup;

$options = New-ScheduledJobOption -StartIfOnBattery  -RunElevated;

Write-Host "Registering new $taskName job";
Register-ScheduledJob -Name $taskName  -Trigger $trigger  -ScheduledJobOption $options `
    -ScriptBlock {
    Write-Host In our PowerShell job we say - oppa!;
}


$accountId = "NT AUTHORITY\SYSTEM";
#$accountId = "NT AUTHORITY\LOCAL SERVICE";
$principal = New-ScheduledTaskPrincipal -UserID $accountId `
    -LogonType ServiceAccount  -RunLevel Highest;

$psSobsSchedulerPath = "\Microsoft\Windows\PowerShell\ScheduledJobs";
$someResult = Set-ScheduledTask -TaskPath $psSobsSchedulerPath `
    -TaskName $taskName  -Principal $principal


Write-Host;
Write-Host "Let's show proofs that our PowerShell job will be running under the LocalSytem account"
$task = Get-ScheduledTask -TaskName $taskName
$task.Principal

Write-Host "Let's start $taskName"
Start-Job -DefinitionName $taskName | Format-Table

Write-Host "Let's proof that our PowerShell job was ran"
Start-Sleep -Seconds 3
Receive-Job -Name $taskName