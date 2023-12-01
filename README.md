# Powershell scripts
+ **Modules**
  + Install
    + *Get-GitReleaseInfo* - get latest github project release url
    + *Install-7zip* - install latest 7zip from [https://7-zip.org]
    + *Install-Far* - install latest far release from [https://github.com/FarGroup/FarManager]
    + *Install-OpenSsh* - install latest release from [https://github.com/powershell/Win32-OpenSSH]
    + *Install-Powershell* - install latest powershell release from [https://github.com/powershell/powershell/]
    + *Install-WinRar* - install latest WinRar from [[WinRar site](https://www.rarlab.com/download.htm)]
    + *Set-OpenSsh* - config Win32-OpenSSH,
	    write changes to $env:ProgramData/ssh/sshd_config (PubkeyAuthentication=yes, StrictModes=no, PasswordAuthentication=no, Subsystem (add "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile" value)) and can used to add any other changes. Check and set correct ssh services startup state. Add public key to "$env:USERPROFILE\.ssh\authorized_keys".
    + *Install-NvDriver* - install latest Nvidia driver
   + Network
	   + *Get-Hosts* - list "$env:windir\System32\drivers\etc\hosts" content
	   + *Add-Host* - add record to "$env:windir\System32\drivers\etc\hosts". 
			example: Add-Host -HostIp "83.243.40.67 " -HostName "wiki.bash-hackers.org"
	   + *Remove-Host* - remove record from "$env:windir\System32\drivers\etc\hosts"
	   + *New-IpRange* - generate string array of ip.
		   example: New-IpRange -From 192.168.1.1 -To 192.168.1.255
	   + *Test-Ping* - try ping to host  using [Net.NetworkInformation.Ping].
		   example:  Test-Ping -ComputerName "192.168.1.25" -TimeoutMillisec 5000
	   + *Test-RemotePort* - try conect to remote host port using [Net.Sockets.TcpClient].
		   example: Test-RemotePort -ComputerName "192.168.1.10" -Port 22 -TimeoutMilliSec 2500
	   + *Get-PrinterInfo* - get connected to network printer SMNP info.
		   example: Get-PrinterInfo -ComputerName "RNP5838790BA9A6"
+ **Scripts**  
  + *Get-VSStudioAdv.ps1* - assistant for downloading visual studio workloads and components. Requires powershell core above 6.0 and admin priviledge.
