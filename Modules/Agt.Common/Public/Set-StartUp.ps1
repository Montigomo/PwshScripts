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
        [hashtable]$ProgrammPath
    )
    
    # Biltin/administrators   S-1-5-32-544
    
    $taskName = "AtStartup"
    $taskPath = "T1000"

    $Actions = @()

    # $existTask = Get-ScheduledTask -TaskName $taskName

    # if($existTask){
    #     $Actions = $existTask.Actions
    # }

    # foreach ($item in $Actions){
    #     if($item.CimClass.CimClassName -eq "MSFT_TaskExecAction"){
    #         if(-not $ProgrammPath.Contains($item.Execute)){
    #             #$ProgrammPath += $item.Execute
    #             $ProgrammPath.Add($item.Execute, $item.Arguments)
    #         }
    #     }
    # }

    $Actions = $ProgrammPath.Keys | ForEach-Object {if($ProgrammPath[$_]) { New-ScheduledTaskAction -Execute $_ -Argument $ProgrammPath[$_]} else {New-ScheduledTaskAction -Execute $_}}
    
    $index = 0;
    foreach($item in $Actions){
        $Trigers = New-ScheduledTaskTrigger -AtLogon
        $Principal = New-ScheduledTaskPrincipal -GroupId "S-1-5-32-544" -RunLevel Highest
        $Settings = New-ScheduledTaskSettingsSet

        $Task = New-ScheduledTask -Action $item -Principal $Principal -Trigger $Trigers -Settings $Settings

        $itemName = "$taskName{0:000}" -f $index

        $existTask = Get-ScheduledTask -TaskName $itemName

        if($existTask){
            Unregister-ScheduledTask -TaskName $itemName -Confirm:$false
        }
        Register-ScheduledTask -TaskPath $taskPath -InputObject $Task -TaskName $itemName | Out-Null
        $index++;
    }
}