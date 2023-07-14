

$Logfile = "$PSScriptRoot\log.log"

function WriteLog {
  Param ([string]$LogString)
  $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
  $LogMessage = "$Stamp $LogString"
  Write-Output $LogString
  Add-content $LogFile -value $LogMessage
}

WriteLog "Runned $($GetDate)"