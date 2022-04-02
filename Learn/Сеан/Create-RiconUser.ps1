# Скрипт для созданя папки для Ricon

#New-localUser -Name "RiconUser" -Description "RiconUser" -NoPassword
<# Список служб
fdPHost
#>

# Инициалтзация переменых
$UserName = "RiconUser"
$Password = "riconuser"
$Description = "RiconUser"
$DeskTopFolder = [Environment]::GetFolderPath("Desktop");
$RiconFolderName = "RiconScan"
$RiconScanFolder = "$DeskTopFolder\$RiconFolderName"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Проверка наличия и создание в случае отсутствия папки C:\Users\[CurrentUser]\Desctop\RiconScan
if(!(Test-Path $RiconScanFolder))
{
    New-Item -Path $RiconScanFolder -ItemType Directory -Force
}

# Проверка наличия учетной записи
if(!(Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue))
{
    New-LocalUser -Name $UserName -Description $Description -Password $SecurePassword
}
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
Set-LocalUser -Name $UserName -Password $SecurePassword

# Предоставление общего доступа к папке
if(!(Get-SmbShare $RiconFolderName -ErrorAction SilentlyContinue))
{
    New-SmbShare -Name $RiconFolderName -Path $RiconScanFolder -FullAccess "RiconUser"
}

$acim = Get-SmbShareAccess $RiconFolderName
$flag = $true
foreach($item in $acim)
{
    $accounName = $item.CimInstanceProperties["AccountName"].Value
    # 2 - read, 0 - full
    $accessRights = $item.CimInstanceProperties["AccessRight"].Value
    if($accounName.EndsWith($UserName) -and $accessRights -eq 0)
    {
        $flag = $false
        break
    }
}

if($flag)
{
    Grant-SmbShareAccess -Name $RiconFolderName -AccountName "RiconUser" -AccessRight Full -Force
}

# Предоставление полного доступа к папке для поьзователя
$Acl = Get-Acl $RiconScanFolder 
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("RiconUser", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl $RiconScanFolder $Acl

# Настройка параметров общего доступа к сети




# Внесение учетной записи пользователя в адресную книгу Ricon



# Проверка наличия, режима запуска и включие необходимых служб
# SSDP Discovery
# UPnP Device Host
# Список служб
$items = @("ssdpsrv")
foreach($item in $items)
{
    if(($service = Get-Service -Name $item -ErrorAction SilentlyContinue))
    {
        # ($service.StartType) -eq [System.ServiceProcess.ServiceStartMode]::Manual 
        if($service.StartType -ne [System.ServiceProcess.ServiceStartMode]::Automatic)
        {
            $service | Set-Service -StartupType ([System.ServiceProcess.ServiceStartMode]::Automatic)
        }
        if($service.Status -ne "Running")
        {
            $service | Start-Service
        }
    }
}


#вывод информации
"\\$env:COMPUTERNAME\$RiconFolderName"
