


$modulesPath = "C:\Program Files\WindowsPowerShell\Modules"

$profilePath = $profile.AllUsersAllHosts;

$audioFile = "Audio.ps1"
$audioModuleName = "Audio-Typedef"
$AudioModulePathSrc = "$PSScriptRoot\$audioFile"
$AudioModulePathDst = "$modulesPath\$audioModuleName\$audioFile"

if( -not (Test-Path $AudioModulePathDst)) {
    New-Item -ItemType File -Path $AudioModulePathDst -Force
    Copy-Item $AudioModulePathSrc $AudioModulePathDst -Force
}

$content = Get-Content $profilePath

$str = "Import-Module ""$AudioModulePathDst"""
$matchStr = "^" + [regex]::escape("$str") + "$"

if( -not ($content -match $matchStr)) {
    $strAdd = "$([Environment]::NewLine)$str"
    $content += $strAdd
    $content | Set-Content $profilePath
}

return