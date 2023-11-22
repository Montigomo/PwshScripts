# Powershell scripts
+ **Modules**
  + Install
    + *Get-GitReleaseInfo* - get latest github project release url
    + *Install-7zip* - install latest 7zip from [https://7-zip.org]
    + *Install-Far* - install latest far release from [https://github.com/FarGroup/FarManager]
    + *Install-OpenSsh* - install latest release from [https://github.com/powershell/Win32-OpenSSH]
    + *Install-Powershell* - install latest powershell release from [https://github.com/powershell/powershell/]
    + *Install-WinRar* - install latest WinRar from [[WinRar site](https://www.rarlab.com/download.htm)]
    + *Set-OpenSsh* - config Win32-OpenSSH, write changes to $env:ProgramData/ssh/sshd_config (PubkeyAuthentication=yes, StrictModes=no, PasswordAuthentication=no, Subsystem (add "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile" value)) and can used to add any other changes. Check and set correct ssh services startup state. Add public key to "$env:USERPROFILE\.ssh\authorized_keys".
+ **Scripts**  
  + *Get-VSStudioAdv.ps1* - assistant for downloading visual studio workloads and components. Requires powershell core above 6.0 and admin priviledge.
