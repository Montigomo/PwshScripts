Param (
    $LogFile = 'C:\testlog.txt',
    $Throttle = 20,
    $Count = 100,
    [switch]$NoMutex
)
 
$Parameters = @{
    LogFile = $LogFile
    NoMutex = $NoMutex
}
 
$DebugPreference = 'Continue'
 
$RunspacePool = [runspacefactory]::CreateRunspacePool(
    1, #Min Runspaces
    10, #Max Runspaces
    [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault(), #Initial Session State; defines available commands and Language availability
    $host #PowerShell host
)
 
$RunspacePool.Open()
 
$jobs = New-Object System.Collections.ArrayList
 
1..$Count | ForEach {
    $PowerShell = [powershell]::Create()
     
    $PowerShell.RunspacePool = $RunspacePool
     
    [void]$PowerShell.AddScript({
        Param(
            $LogFile,
            $NoMutex
        )
        If (-Not $NoMutex) {
            $mtx = New-Object System.Threading.Mutex($false, "LogMutex")
            Write-Verbose "[$(Get-Date)][PID: $($PID)][TID: $([System.Threading.Thread]::CurrentThread.ManagedThreadId)] Requesting mutex!" -Verbose
            $mtx.WaitOne()
            Write-Verbose "[$(Get-Date)][PID: $($PID)][TID: $([System.Threading.Thread]::CurrentThread.ManagedThreadId)] Recieved mutex!" -Verbose       
        }
        Try {
            Write-Verbose "[$(Get-Date)][PID: $($PID)][TID: $([System.Threading.Thread]::CurrentThread.ManagedThreadId)] Writing data $($_) to $LogFile" -Verbose
            "[$(Get-Date)] | ThreadID: $([System.Threading.Thread]::CurrentThread.ManagedThreadId) | ProcessID $($PID) | Data: $($_)" | Out-File $LogFile -Append
        } Catch {
            Write-Warning $_
        }
        If (-Not $NoMutex) {
            Write-Verbose "[$(Get-Date)][PID: $($PID)][TID: $([System.Threading.Thread]::CurrentThread.ManagedThreadId)] Releasing mutex" -Verbose
            [void]$mtx.ReleaseMutex()
        }
    })
 
    [void]$PowerShell.AddParameters($Parameters)
 
    $Handle = $PowerShell.BeginInvoke()
    $temp = '' | Select PowerShell,Handle
    $temp.PowerShell = $PowerShell
    $temp.handle = $Handle
    [void]$jobs.Add($Temp)
     
    Write-Debug ("Available Runspaces in RunspacePool: {0}" -f $RunspacePool.GetAvailableRunspaces()) 
    Write-Debug ("Remaining Jobs: {0}" -f @($jobs | Where {
        $_.handle.iscompleted -ne 'Completed'
    }).Count)
}
 
#Verify completed
Write-Debug ("Available Runspaces in RunspacePool: {0}" -f $RunspacePool.GetAvailableRunspaces()) 
Write-Debug ("Remaining Jobs: {0}" -f @($jobs | Where {
    $_.handle.iscompleted -ne 'Completed'
}).Count)
 
$return = $jobs | ForEach {
    $_.powershell.EndInvoke($_.handle);$_.PowerShell.Dispose()
}
$jobs.clear()