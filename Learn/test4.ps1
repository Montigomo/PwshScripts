

# # investigate Get-Process (replace Get-Process by cmdlet of choice)
# $cmdlet = { Get-Process }
 
# # find out the data type returned by a cmdlet (this example uses only the first emitted data type)
# $typename = & $cmdlet | Get-Member | Select-Object -ExpandProperty TypeName -First 1 
 
# # find this line in the formatting files:
# $searchtext = "<TypeName>$typename</TypeName>"
 
# # find all formatting files
# Get-ChildItem -Path "$pshome\*format.ps1xml" |
#   # return the content that starts with the line above, and add 20 more lines
#   Select-String -Pattern $searchtext -Context 0 ,20 | 
#   # select the text that Select-String found
#   Select-Object -ExpandProperty Context |
#   # select the 20 additional lines found in DisplayPostContext
#   Select-Object -ExpandProperty DisplayPostContext

<# 
function foo {
  [cmdletbinding()]
  Param([parameter(ValueFromPipeline)]$a)
  Begin   {1}
  Process {2}
  End     {3}
}
Write-Host -ForegroundColor Green 'Expected:'
1..3|foo|%{$_} -pv x -ov y |select {$x},{$_},{$y}|out-host

Write-Host -ForegroundColor Green 'Actual:'
1..3|foo       -pv x -ov y |select {$x},{$_},{$y}|out-host


Get-Service | Where DependentServices | Foreach {($s=$_)}| Select -Exp DependentServices  | Select @{n="RootService";e={$s.Name}},Name

Get-Service | Where DependentServices


function Enable-ProcessCreationEvent
{
   $Query = New-Object System.Management.WqlEventQuery "__InstanceCreationEvent", (New-Object TimeSpan 0,0,1), "TargetInstance isa 'Win32_Process'"
   $ProcessWatcher = New-Object System.Management.ManagementEventWatcher $Query
   $Identifier = "WMI.ProcessCreated"
   Register-ObjectEvent $ProcessWatcher "EventArrived" -SupportEvent $Identifier -Action { [void] (New-Event -SourceID "PowerShell.ProcessCreated" -Sender $Args[0] -EventArguments $Args[1].SourceEventArgs.NewEvent.TargetInstance)  }
}
 #>


# $Path = "$env:userprofile\Downloads"
 
# Get-ChildItem -Path $Path -file | Where-Object { @(Get-Item -Path $_.FullName -Stream * ).Stream -contains 'Zone.Identifier' } | ForEach-Object {   Get-Content -Path $_.FullName -Stream Zone.Identifier }6

$token = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$xy = 'S-1-5-64-36'
if ($token.Groups -contains $xy)
{
"You're in this group."
}