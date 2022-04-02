

$DeskTopFolder = [Environment]::GetFolderPath("Desktop");
$RiconFolderName = "RiconScan"
$RiconScanFolder = "$DeskTopFolder\$RiconFolderName"

$Acl = Get-Acl $RiconScanFolder 

$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("RiconUser", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$Acl.SetAccessRule($Ar)
Set-Acl $RiconScanFolder $Acl

exit





$Password = Read-Host -AsSecureString
$UserAccount = Get-LocalUser -Name "12345"
$UserAccount | Set-LocalUser -Password $Password



$c = get-credential -UserName 12345
$SecurePassword = $c.Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)