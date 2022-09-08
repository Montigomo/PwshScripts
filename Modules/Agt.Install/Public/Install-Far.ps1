
function Install-Far {  
    <#
    .SYNOPSIS
        Install far
    .DESCRIPTION
    .PARAMETER Name
    .PARAMETER Extension
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>

    $farPath = "C:\Program Files\Far Manager\Far.exe";
    $farFolder = [System.IO.Path]::GetDirectoryName($farPath);

    [version]$localVersion = [System.Version]::new(0, 0, 0)

    if (Test-Path $farPath) {
        $localVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($farPath)).ProductVersion.Split(" ")[0]
    }

    [version]$remoteVersion = [System.Version]::new(0, 0, 0)

    $repoUri = "https://api.github.com/repos/FarGroup/FarManager"
    $versionPattern = "ci\/v(?<version>\d\.\d\.\d\d\d\d\.\d\d\d\d)"
    $remoteVersion = Get-GitReleaseInfo -Repouri $repoUri  -Pattern $versionPattern -Version

    $pattern = "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi"
    $requestUri = Get-GitReleaseInfo -Repouri $repoUri -Pattern $pattern

    if ($localVersion -ge $remoteVersion) { exit; }

    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
    Invoke-WebRequest -OutFile $tmp $requestUri
    #   Far msi package installation options
    Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""
    #   set path environment variable
    Set-EnvironmentVariable -Value $farFolder -Scope "Machine" -Action "Add"
}

#Install-Far