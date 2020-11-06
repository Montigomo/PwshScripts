

# install far

function Get-Release
{
    param(
        [Parameter(Mandatory=$true)] [string] $Repouri,
        [Parameter(Mandatory=$true)] [string] $Pattern,
        [Parameter(Mandatory=$false)] [switch] $Prerelease
    )

    if ($Prerelease.IsPresent) 
    {
        $releasesUri = "$Repouri/releases"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -match $Pattern ).browser_download_url
    }
    else
    {
        $releasesUri = "$Repouri/releases/latest"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -match $Pattern ).browser_download_url
    }


    return $downloadUri
}

function Install-MsiPackage
{
    Param($FilePath, $PackageParams)
    $DataStamp = get-date -Format yyyyMMddTHHmmss
    $logFile = '{0}-{1}.log' -f $FilePath,$DataStamp
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f $FilePath)
        "/qn"
        "/norestart"
        "/L*v"
        $logFile
    )
    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}

function Set-EnvironmentVariablePath
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Value,
        [Parameter(Mandatory=$false)]
        [ValidateSet('User', 'Process', 'Machine')]
        [string] $Scope = "User",
        [Parameter(Mandatory=$false)]
        [ValidateSet('Add', 'Remove')]
        [string] $Action = "Add"
    )
    if($Action -eq "Add")
    {        
        $path = [Environment]::GetEnvironmentVariable('Path', $Scope)
        if(!($path.Contains($Value)))
        {
            $newpath = $path + ";$Value"
            [Environment]::SetEnvironmentVariable("Path", $newpath, $Scope)
        }
    }
    else {
        $oev = [Environment]::GetEnvironmentVariable('Path', $Scope).Split(";")
        $oevNew = ($oev -notlike $Value) -join ";"
        [Environment]::SetEnvironmentVariable("Path", $oevNew, $Scope)        
    }
}



$test = Get-Release -Repouri "https://api.github.com/repos/powershell/powershell" -Pattern "PowerShell-\d.\d.\d-win-x64.msi"

Write-Output $test

# Far.x64.3.0.5650.1688.e0c026b3fc3c63f815c818ec14861c9b1ea6480b.msi
# Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9].msi

$test = Get-Release -Repouri "https://api.github.com/repos/FarGroup/FarManager" -Pattern "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi"

Write-Output $test


$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

Invoke-WebRequest -OutFile $tmp $test

#   Far msi package installation options
#   ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL - This property controls the option for adding the Open PowerShell item to the context menu in Windows Explorer.
#   ENABLE_PSREMOTING - This property controls the option for enabling PowerShell remoting during installation.
#   REGISTER_MANIFEST - This property controls the option for registering the Windows Event Logging manifest.

Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""

#   set path environment variable

$farPathes = @("C:\Program Files\Far Manager")

foreach($item in $farPathes)
{
    Set-EnvironmentVariablePath -Value $item -Scope "Machine" -Action "Add"
}