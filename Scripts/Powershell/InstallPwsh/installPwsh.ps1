

Import-Module $PSScriptRoot\Get-IsAdmin.psm1
Import-Module $PSScriptRoot\Install-Powershell.psm1

Install-Powershell -IsWait

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
