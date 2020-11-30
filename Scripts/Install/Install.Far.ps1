
# install far

$includePath = "{0}\Learn" -f (Split-Path $PSScriptRoot -Parent)

$importFunctions = @(
    "Get-Release",
    "Install-MsiPackage",
    "Set-EnvironmentVariablePath"
)

foreach($item in $importFunctions)
{
    $scriptPath = "{0}\{1}.ps1" -f $includePath, $item
    #Import-Module -Name  $scriptPath -Verbose
}

@(
    "Get-Release",
    "Install-MsiPackage",
    "Set-EnvironmentVariablePath"
) |
ForEach-Object {Import-Module -Name ("{0}\Learn\{1}.ps1" -f (Split-Path $PSScriptRoot -Parent), $_) -Verbose}


#$test = Get-Release -Repouri "https://api.github.com/repos/powershell/powershell" -Pattern "PowerShell-\d.\d.\d-win-x64.msi"
#Write-Output $test

# Far.x64.3.0.5650.1688.e0c026b3fc3c63f815c818ec14861c9b1ea6480b.msicls

# Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9].msi

# https://github.com/FarGroup/FarManager/releases/download/ci/v3.0.5709.1852/Far.x64.3.0.5709.1852.689c635c5b5bbc01acd667f489a94e18626ad6a4.msi

$requestUri = Get-Release -Repouri "https://api.github.com/repos/FarGroup/FarManager" -Pattern "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi"

Write-Output $test

#3.0.5698.0

$farPath = "C:\Program Files\Far Manager\Far.exe";

if(Test-Path $farPath)
{
    $vart = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($farPath)
}

#3.0.5698.0 x64

$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

Invoke-WebRequest -OutFile $tmp $requestUri

#   Far msi package installation options

Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""

#   set path environment variable

$farPathes = @("C:\Program Files\Far Manager")

foreach($item in $farPathes)
{
    Set-EnvironmentVariablePath -Value $item -Scope "Machine" -Action "Add"
}