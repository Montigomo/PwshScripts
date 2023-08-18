

#Get-ChildItem HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | % { Get-ItemProperty $_.PsPath } | Select DisplayName,InstallLocation | Sort-Object Displayname -Descending
$rarItem = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object { Get-ItemProperty $_.PsPath } | Where-Object {$_.DisplayName -like "WinRAR*"}

if(!$rarItem)
{
    Write-Output "WinRar not installed on this machine."
    exit
}
$destinationPath = $rarItem.InstallLocation
$lisenseFilePath = "${PSScriptRoot}\rarreg.key"
if(!(Test-Path -Path $lisenseFilePath))
{
    Write-Output "License file did not find."
    exit
}
if(!(Test-Path -Path $destinationPath))
{
    Write-Output "Destination path ${$destinationPath} don't exest."
    exit
}
Copy-Item -Path $lisenseFilePath -Destination $destinationPath -Force
