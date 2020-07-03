

@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%Install.Powershell.ps1

rem PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'"

powershell.exe "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File %PowerShellScriptPath%' -Verb RunAs"