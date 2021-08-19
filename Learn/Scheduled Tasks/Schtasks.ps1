



# $taskname = "Restart My Service"
# $taskdescription = "Restart My Service after startup"
# $action = New-ScheduledTaskAction -Execute 'D:\temp\awatcher\xmrig\xmrig.exe' -Argument ''
# #$trigger =  New-ScheduledTaskTrigger - -RandomDelay (New-TimeSpan -minutes 3)
# $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 2) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
# Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -Description $taskdescription -Settings $settings -User "System"

#schtasks /create /tn "My App" /tr c:\idle.cmd /sc onidle /i 30 /ru system


$xmlDef = New-Object -TypeName System.Xml.XmlDocument;
$xmlContent = Get-Content "D:\work\powershell\Tasks\aaaaaaa.xml"
$xmlDef.LoadXml($xmlContent)

Register-ScheduledTask -Xml $xmlDef.OuterXml -TaskName "aaaaaaa"
