NET START "Yawcam"
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
echo ** Service Started ! **
echo ***********************
echo.
pause