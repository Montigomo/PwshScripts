


$ScriptPath = $MyInvocation.MyCommand.Path
# this worked
$items = Get-ChildItem -Path $PSScriptRoot -Recurse | Where-Object {$_.FullName -ne $ScriptPath}
$items.count

# this not
$items = Get-ChildItem -Path $PSScriptRoot -Recurse | Where-Object {$_.FullName -ne $MyInvocation.MyCommand.Path}
$items.count
