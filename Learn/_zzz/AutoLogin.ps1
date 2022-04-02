






# ask for logon credentials:
$cred = Get-Credential -Message 'Logon automatically'
$password = $cred.GetNetworkCredential().Password
$username = $cred.UserName
 
# save logon credentials to registry (WARNING: clear text password used):
$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $path -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path $path -Name DefaultPassword -Value $password
Set-ItemProperty -Path $path -Name DefaultUserName -Value $username
 
# restart machine and automatically log on: (remove -WhatIf to test-drive)
Restart-Computer -WhatIf 