#
#
#

$userProfileFolder = "D:\___users\_ali" #$env:USERPROFILE

$userFolders = $(
    "$userProfileFolder\Documents"
    # "$userProfileFolder\Pictures",
    # "$userProfileFolder\Desktop",
    # "$userProfileFolder\Video"
    )

Stop-Process -ProcessName explorer -Force

start-sleep -Seconds 2

foreach($userFolder in $userFolders)
{

    if(!(Test-Path $userFolder))
    {
        New-Item $userFolder -ItemType Directory -ErrorAction SilentlyContinue -Force
    }

    Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Name "Personal" -Value $userFolder -Type String -Force
    Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folder" -Name "{f42ee2d3-909f-4907-8871-4c22fc0bf756}" -Value $userFolder -Type ExpandString
    Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Personal" -Value $userFolder -Type ExpandString
    #attrib +r -s -h "%USERPROFILE%\Documents" /S /D
    start-sleep -Seconds 1

}

if(!(get-process explorer -ErrorAction SilentlyContinue))
{
    Start-Process explorer
}