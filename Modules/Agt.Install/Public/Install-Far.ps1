function Install-Far {  
    <#
    .SYNOPSIS
        Install far
    .DESCRIPTION
    .PARAMETER IsWait
    .PARAMETER UsePreview
    .NOTES
        Author : Agitech 
        Version : 1.0 
        Purpose : Get world better    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] [switch]$IsWait,
        [Parameter(Mandatory = $false)] [switch]$UsePreview
    )

    $farPath = "C:\Program Files\Far Manager\Far.exe";
    $farFolder = [System.IO.Path]::GetDirectoryName($farPath);
    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8);
    [version]$localVersion = [System.Version]::new(0, 0, 0)

    if (Test-Path $farPath) {
        $localVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($farPath)).ProductVersion.Split(" ")[0]
    }

    [version]$remoteVersion = [System.Version]::new(0, 0, 0)
    $repoUri = "https://api.github.com/repos/FarGroup/FarManager"
    $versionPattern = "ci\/v(?<version>\d\.\d\.\d\d\d\d\.\d\d\d\d)"
    $ReleasePattern = if ($IsOs64) { "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi" }else { "Far.x86.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi" }
    $downloadUri = Get-GitReleaseInfo -Uri $repoUri -ReleasePattern $ReleasePattern -LocalVersion $localVersion -VersionPattern $versionPattern -RemoteVersion ([ref]$remoteVersion)
    $remoteVersion = [System.Version]::new($remoteVersion.Major, $remoteVersion.Minor, $remoteVersion.Build)
    if (($localVersion -lt $remoteVersion) -and ($downloadUri)) {
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
        Invoke-WebRequest -Uri $downloadUri -OutFile $tmp
        #region msi section
        $msiPath = $tmp.FullName
        $msiIsWait = $IsWait
        $logFile = '{0}-{1}.log' -f $msiPath, (get-date -Format yyyyMMddTHHmmss)
        $packageOptions = "ADDLOCAL=ALL"
        $arguments = "/i {0} {1} /quiet /norestart /L*v {2}" -f $msiPath, $packageOptions, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait:$msiIsWait
        #endregion msi section
        #   set path environment variable
        Set-EnvironmentVariable -Value $farFolder -Scope "Machine" -Action "Add"
    }
}