
function Move-UserFolder {
    [CmdletBinding()]
    param (
        [Parameter()][string]$UserProfilesFolder = $env:USERPROFILE
    )

    $userFolders = @{
        "Documents" = @{Handle = $true; FolderName = "Personal"; FolderClass = "{f42ee2d3-909f-4907-8871-4c22fc0bf756}"; ComfortName = "Documents" };
        "Pictures"  = @{Handle = $true; FolderName = "My Pictures"; FolderClass = "{0DDD015D-B06C-45D5-8C4C-F59713854639}"; ComfortName = "Pictures" };
        "Desktop"   = @{Handle = $false; FolderName = "Desktop"; FolderClass = "{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}"; ComfortName = "Desktop" };
        "Video"     = @{Handle = $false; FolderName = "My Video"; FolderClass = "{35286A68-3C57-41A1-BBB1-0EAE73D76C95}"; ComfortName = "Video" };
        "Music"     = @{Handle = $false; FolderName = "My Music"; FolderClass = "{A0C69A99-21C8-4671-8703-7934162FCF1D}"; ComfortName = "Music" };
    }

    if (-not $debug) {
        Stop-Process -ProcessName explorer -Force
        Start-Sleep -Seconds 2
    }

    foreach ($key in $userFolders.Keys) {
        $handle = $userFolders[$key]["Handle"]
        $UserFolderName = $userFolders[$key]["FolderName"]
        $UserFolderClass = $userFolders[$key]["FolderClass"]
        $ComfortName = $userFolders[$key]["ComfortName"]
        $UserFolderPath = [System.IO.Path]::Combine($UserProfilesFolder, $ComfortName);

        if ($handle) {
            if (!(Test-Path $UserFolderPath)) {
                New-Item $UserFolderPath -ItemType Directory -ErrorAction SilentlyContinue -Force
            }

            Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" `
                -Name $UserFolderName -Value $UserFolderPath -Type String -Force
            Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
                -Name $UserFolderClass -Value $UserFolderPath -Type ExpandString
            Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
                -Name $UserFolderName -Value $UserFolderPath -Type ExpandString

            #attrib +r -s -h "%USERPROFILE%\Documents" /S /D
            start-sleep -Seconds 1
        }
    }

    if (!(get-process explorer -ErrorAction SilentlyContinue)) {
        Start-Process explorer
    }
}
# {374DE290-123F-4565-9164-39C4925E467B} : C:\Users\nidal\Downloads
# {24D89E24-2F19-4534-9DDE-6A6671FBB8FE} : C:\Users\nidal\OneDrive\Изображения\Документы
# {754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5} : D:\_users\nidaleb\Desktop
# {F42EE2D3-909F-4907-8871-4C22FC0BF756} : C:\Users\nidal\OneDrive\Изображения\Документы
# {0DDD015D-B06C-45D5-8C4C-F59713854639} : C:\Users\nidal\Pictures
# {339719B5-8C47-4894-94C2-D8F77ADD44A6} : C:\Users\nidal\OneDrive\Изображения
# {767E6811-49CB-4273-87C2-20F355E1085B} : C:\Users\nidal\OneDrive\Изображения\Пленка
# {B7BEDE81-DF94-4682-A7D8-57A52620B86F} : C:\Users\nidal\OneDrive\Изображения\Снимки экрана
# {AB5FB87B-7CE2-4F83-915D-550846C9537B} : C:\Users\nidal\OneDrive\Изображения\Пленка
# {35286A68-3C57-41A1-BBB1-0EAE73D76C95} : D:\video


# Move-UserFolder -UserProfilesFolder "D:\_users\gai\"