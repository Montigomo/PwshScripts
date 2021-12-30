# Скрипт для созданя папки куда сканер Ricon будет отправлять файлы

#New-localUser -Name "RiconUser" -Description "RiconUser" -NoPassword
<# Список служб
fdPHost
#>

# Инициалтзация переменых
$UserName = "12345"
$Password = "12345"
$Description = "RiconUser"
$DeskTopFolder = [Environment]::GetFolderPath("Desktop");
$RiconScanFolder = "$DeskTopFolder\RiconScan"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Проверка наличия и моздание в случае отсутствия папки C:\Users\[CurrentUser]\Desctop\RiconScan
if(!(Test-Path $RiconScanFolder))
{
    New-Item -Path $RiconScanFolder -ItemType Directory -Force
}

#Set-LocalUser -Name "12345" -Password $SecurePassword
#Exit

#$Password = "riconuser"


#$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

exit
$c = get-credential -UserName 12345
$SecurePassword = $c.Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

New-LocalUser -Name $UserName -Description $Description -Password $SecurePassword