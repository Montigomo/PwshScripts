

function Irfhs {
    param ([Parameter()] [string] $Regstr)
    $tmp = New-TemporaryFile
    $Regstr | Out-File $tmp
    reg import $tmp.FullName
}

$regstr1 = @"
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag]
"ThisPCPolicy"="Hide"
"@

$regstr2 = @"
Windows Registry Editor Version 5.00

#Desctop folder
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag]
"ThisPCPolicy"="Show"
"@

Irfhs -Regstr $regstr2