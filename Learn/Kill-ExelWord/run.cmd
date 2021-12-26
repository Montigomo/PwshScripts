@ECHO OFF
SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%run.ps1
PowerShell -windowstyle hidden -NoProfile -ExecutionPolicy Bypass -Command "& '%PowerShellScriptPath%'"