

$Password = Read-Host -AsSecureString
$UserAccount = Get-LocalUser -Name "12345"
$UserAccount | Set-LocalUser -Password $Password