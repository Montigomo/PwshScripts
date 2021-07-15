


Add-Host -HostIp "163.172.167.207" -HostName "bt.t-ru.test.org"

FIND /C /I "www.easeus.com" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	www.easeus.com>>%WINDIR%\system32\drivers\etc\hosts

FIND /C /I "activation.easeus.com" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	activation.easeus.com>>%WINDIR%\system32\drivers\etc\hosts

FIND /C /I "track.easeus.com" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	track.easeus.com>>%WINDIR%\system32\drivers\etc\hosts

FIND /C /I "66.39.112.91" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	66.39.112.91>>%WINDIR%\system32\drivers\etc\hosts

FIND /C /I "216.92.151.227" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	216.92.151.227>>%WINDIR%\system32\drivers\etc\hosts

FIND /C /I "216.92.61.7" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	216.92.61.7>>%WINDIR%\system32\drivers\etc\hosts

FIND /C /I "update.easeus.com" %WINDIR%\system32\drivers\etc\hosts
IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^127.0.0.1	update.easeus.com>>%WINDIR%\system32\drivers\etc\hosts