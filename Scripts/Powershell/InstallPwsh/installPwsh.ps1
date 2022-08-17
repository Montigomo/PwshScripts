

Import-Module $PSScriptRoot\Get-IsAdmin.ps1
Import-Module $PSScriptRoot\Install-Powershell.ps1

Install-Powershell -IsWait

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
