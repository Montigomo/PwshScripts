# Скрипт для созданя папки для Ricon

#New-localUser -Name "RiconUser" -Description "RiconUser" -NoPassword
<# Список служб
fdPHost
#>

# Инициалbзация переменых
$users = @(@{ UserName = "LibraryReader"; Password = "fubntx1791"; Description = "LibraryReader"},
            @{ UserName = "SmbAgitech"; Password = "fubntx17cfv,f91"; Description = "SmbAgitech"});
foreach($user in $users)
{
    # $DeskTopFolder = [Environment]::GetFolderPath("Desktop");
    # $RiconFolderName = "RiconScan"
    # $RiconScanFolder = "$DeskTopFolder\$RiconFolderName"
    $Password = $user["Password"]; $UserName = $user["UserName"]; $Description = $user["Description"];

    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Проверка наличия и моздание в случае отсутствия папки C:\Users\[CurrentUser]\Desctop\RiconScan
    # if(!(Test-Path $RiconScanFolder))
    # {
    #     New-Item -Path $RiconScanFolder -ItemType Directory -Force
    # }

    # Проверка наличия учетной записи
    if(!(Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue))
    {
        New-LocalUser -Name $UserName -Description $Description -Password $SecurePassword
    }
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    Set-LocalUser -Name $UserName -Password $SecurePassword
}

exit


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

# Настройка параметров общего доступа к сети




# Внесение учетной записи пользователя в адресную книгу Ricon



# Проверка наличия, режима запуска и включие необходимых служб
# If none of those work, make sure all networking services are running. The following services should all be set to Automatic and be currently running:
# DNS Client
# Function Discovery Provider Host
# Function Discovery Resource Publication
# HomeGroup Provider
# HomeGroup Listener
# Peer Networking Grouping
# SSDP Discovery
# UPnP Device Host

$items = @("dnscache", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
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

