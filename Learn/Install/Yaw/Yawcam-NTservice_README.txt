
Run Yawcam as a Service - README

Info
****
It is possible to run Yawcam as a service. This means that Yawcam is running silent in the background as soon as Windows starts. A service is running even before a user has logged in to the system and is still running if all users have logged off. (More info here: https://en.wikipedia.org/wiki/Windows_service) 
When Yawcam is running as a service you will not see the Graphical User Interface. This is why it is important to start Yawcam as usual first and change the settings as preferred. You probably want to enable for example the HTTP output at startup. (Settings -> Edit Settings... -> Startup)
When Yawcam is running as a service it will use the same settings as for the user who installed Yawcam on the computer.

How to:
1) Start Yawcam as usual.
2) Change the settings as you like.
3) Enable wanted output type at startup.
4) Exit Yawcam.
5) Install the service.
6) Start the service.


Note
****
Install, start/stop and uninstall of the service must be run as an administrator in windows vista and above. Do this by right clicking and use: "Run as administrator".
If you don't see the option "Run as administrator", you will have to click on "More -> Open file location" first.


Install the service
*******************
From Windows start menu click: 
"Start -> All programs -> Yawcam -> Service -> Service Install"

The service is now installed but not started. It will automatically start next time you start the computer. However you can manually start it right away without restarting the computer. More info below...


Start/stop the service
**********************
Start or stop the service manually from Windows start menu. Click:
"Start -> All programs -> Yawcam -> Service -> Service START"
or
"Start -> All programs -> Yawcam -> Service -> Service STOP"


Uninstall the service
*********************
You can manually uninstall the service from Windows start menu.  Click:
"Start -> All programs -> Yawcam -> Service -> Service Uninstall"

(The service will also be uninstalled if you uninstall Yawcam.)

