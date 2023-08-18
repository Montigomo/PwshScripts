

sfc /scannow

dism /Online /Cleanup-Image /ScanHealth

# repair


# reset
winget source reset --force

$package = Get-AppxPackage | Where-Object { $_.Name -like "*WinGet*" }
if ($package) {
    $name = $package.PackageFullName
    Reset-AppxPackage $name
}