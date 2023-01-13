[CmdletBinding()]
param (
    [Parameter()][string]$UserProfilesFolder = $env:USERPROFILE
)

$userFolders = @{
    "Documents" = @{Handle = $false; FolderName = "Personal"; FolderClass = "{f42ee2d3-909f-4907-8871-4c22fc0bf756}" };
    "Pictures" = @{Handle = $true; FolderName = "Pictures"; FolderClass = "{0DDD015D-B06C-45D5-8C4C-F59713854639}" };
    "Desktop" = @{Handle = $false; FolderName = "Desktop"; FolderClass = "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}" };
    "Video" = @{Handle = $false; FolderName = "Video"; FolderClass = "{35286A68-3C57-41A1-BBB1-0EAE73D76C95}" };
    "Music" = @{Handle = $false; FolderName = "Music"; FolderClass = "{A0C69A99-21C8-4671-8703-7934162FCF1D}" };
}

#Stop-Process -ProcessName explorer -Force
#Start-Sleep -Seconds 2

foreach($key in $userFolders.Keys)
{
    $handle = $userFolders[$key]["Handle"]
    $UserFolderName = $userFolders[$key]["FolderName"]
    $UserFolderClass = $userFolders[$key]["FolderClass"]

    $UserFolderPath = [System.IO.Path]::Combine($UserProfilesFolder, $key);

    if($handle){
        if (!(Test-Path $UserFolderPath)) {
            New-Item $UserFolderPath -ItemType Directory -ErrorAction SilentlyContinue -Force
        }

        Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" 
            -Name $UserFolderName -Value $UserFolderPath -Type String -Force
        Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" 
            -Name $UserFolderClass -Value $UserFolderPath -Type ExpandString
        Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" 
            -Name $UserFolderName -Value $UserFolderPath -Type ExpandString

        #attrib +r -s -h "%USERPROFILE%\Documents" /S /D
        start-sleep -Seconds 1
    }
}

if (!(get-process explorer -ErrorAction SilentlyContinue)) {
    Start-Process explorer
}