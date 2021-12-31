

$Password = Read-Host -AsSecureString
$UserAccount = Get-LocalUser -Name "12345"
$UserAccount | Set-LocalUser -Password $Password



$c = get-credential -UserName 12345
$SecurePassword = $c.Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)