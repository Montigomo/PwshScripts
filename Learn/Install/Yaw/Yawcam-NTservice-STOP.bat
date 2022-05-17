NET STOP "Yawcam"
@echo off
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
echo ***********************
echo ** Service Stopped ! **
echo ***********************
echo.
pause