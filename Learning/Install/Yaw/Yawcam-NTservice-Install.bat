@echo off
setlocal
set SCRIPTPATH=%~dp0
"%SCRIPTPATH%"Yawcam_Service.exe -install
if not errorlevel 1 goto :success
echo.
echo *********************
echo ***     ERROR     ***
echo *********************
echo.
pause
goto :eof
:success
echo.
echo **************************************
echo ** Service successfully installed ! **
echo **************************************
echo.
pause
