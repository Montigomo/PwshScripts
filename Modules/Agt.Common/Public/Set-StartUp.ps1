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
        [array]$ProgrammPath
    )
    
    # Biltin/administrators   S-1-5-32-544
    
    $taskName = "AtStartup"
    $taskPath = "T1000"

    $Actions = @()

    $existTask = Get-ScheduledTask -TaskName $taskName

    if($existTask){
        $Actions = $existTask.Actions
    }

    foreach ($item in $Actions){
        if($item.CimClass.CimClassName -eq "MSFT_TaskExecAction"){
            if(-not $ProgrammPath.Contains($item.Execute)){
                $ProgrammPath += $item.Execute
            }
        }
    }
    $Actions = $ProgrammPath | ForEach-Object {New-ScheduledTaskAction -Execute $_}
    $Trigers = New-ScheduledTaskTrigger -AtLogon
    $Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-544" -RunLevel Highest
    $Settings = New-ScheduledTaskSettingsSet

    $Task = New-ScheduledTask -Action $Actions -Principal $Principal -Trigger $Trigers -Settings $Settings

    if($existTask){
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
    Register-ScheduledTask -TaskPath $taskPath -InputObject $Task -TaskName $taskName | Out-Null
}