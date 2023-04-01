<#
.SYNOPSIS
    Short description
.PARAMETER ProgrammPath
    Array of file pathes.
#>
function Set-StartUp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $false)]
        [string]$Argument

    )
    
    $taskNamePattern = "AtStartup"
    $taskPath = "T1000"
    $taskName = "${taskNamePattern}_{0}" -f $Name

    $existTask = Get-ScheduledTask -TaskPath "\$taskPath\" -ErrorAction SilentlyContinue

    foreach ($task in $existTask) {
        if ($task.Actions -and $task.Actions[0].Execute -eq $Action) {
            Write-Output "Task with action $Action already exist."
            Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
            #return;
        }
    }

    $Trigers = New-ScheduledTaskTrigger -AtLogon
    $Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-544" -RunLevel Highest
    $Settings = New-ScheduledTaskSettingsSet
    $Action = if ($Parameter) { New-ScheduledTaskAction -Execute $Path -Argument $Argument } else { New-ScheduledTaskAction -Execute $Path } 

    $Task = New-ScheduledTask -Action $Action -Principal $Principal -Trigger $Trigers -Settings $Settings


    $existTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    Write-Output "Trying to register task $Name ..."
    Register-ScheduledTask -TaskPath $taskPath -InputObject $Task -TaskName $taskName | Out-Null
    Write-Output "Task $Name registered successefully."

}