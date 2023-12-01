# Powershell scripts

- **Modules**
  - Install
    - _Get-GitReleaseInfo_ - get latest github project release url
    - _Install-7zip_ - install latest 7zip from \[https://7-zip.org\]
    - _Install-Far_ - install latest far release from \[https://github.com/FarGroup/FarManager\]
    - _Install-OpenSsh_ - install latest release from \[https://github.com/powershell/Win32-OpenSSH\]
    - _Install-Powershell_ - install latest powershell release from \[https://github.com/powershell/powershell/\]
    - _Install-WinRar_ - install latest WinRar from \[[WinRar site](https://www.rarlab.com/download.htm)\]
    - _Set-OpenSsh_ - config Win32-OpenSSH,
      write changes to $env:ProgramData/ssh/sshd_config (PubkeyAuthentication=yes, StrictModes=no, PasswordAuthentication=no, Subsystem (add "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile" value)) and can used to add any other changes. Check and set correct ssh services startup state. Add public key to "$env:USERPROFILE.ssh\\authorized_keys".
    - _Install-NvDriver_ - install latest Nvidia driver
  - Network
    - _Get-Hosts_ - list "$env:windir\\System32\\drivers\\etc\\hosts" content
    - _Add-Host_ - add record to "$env:windir\\System32\\drivers\\etc\\hosts".
      example: Add-Host -HostIp "83.243.40.67 " -HostName "wiki.bash-hackers.org"
    - _Remove-Host_ - remove record from "$env:windir\\System32\\drivers\\etc\\hosts"
    - _New-IpRange_ - generate string array of ip.
      example: New-IpRange -From 192.168.1.1 -To 192.168.1.255
    - _Test-Ping_ - try ping to host  using \[Net.NetworkInformation.Ping\].
      example:  Test-Ping -ComputerName "192.168.1.25" -TimeoutMillisec 5000
    - _Test-RemotePort_ - try conect to remote host port using \[Net.Sockets.TcpClient\].
      example: Test-RemotePort -ComputerName "192.168.1.10" -Port 22 -TimeoutMilliSec 2500
    - _Get-PrinterInfo_ - get connected to network printer SMNP info.
      example: Get-PrinterInfo -ComputerName "RNP5838790BA9A6"
- **Scripts**
  - _Get-VSStudioAdv.ps1_ - assistant for downloading visual studio workloads and components. Requires powershell core above 6.0 and admin priviledge.