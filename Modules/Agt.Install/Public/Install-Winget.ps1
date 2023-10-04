function Install-Winget {  
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER Name
    .PARAMETER Extension
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param(
        [switch]$IsWait,
        [switch]$UsePreview
    )

    $IsAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    if ( -not $IsAdmin) {
        Write-Error "Run as admin!"
        exit
    }
    
    $gitUri = "https://api.github.com/repos/microsoft/winget-cli"
    $gitUriReleases = "$gitUri/releases"
    $remoteVersion = [System.Version]::Parse("0.0.0")
    $localVersion = [System.Version]::Parse("0.0.0")
    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8);

    $versionPattern = "v(?<version>\d?\d.\d?\d.\d?\d?\d?\d)"
    
    $wrq = (Invoke-RestMethod -Method Get -Uri $gitUriReleases)
    $releases = $wrq | Where-Object { $_.prerelease -eq $UsePreview.ToBool() } | Sort-Object -Property published_at -Descending
  
    $latestRelease = $releases | Select-Object -First 1
    
    if ($latestRelease.tag_name -match $versionPattern) {
        $remoteVersion = [System.Version]::Parse($Matches["version"]);
    }

    if ($(winget --version) -match $versionPattern) {
        $localVersion = [System.Version]::Parse($Matches["version"]);
    }



    if ($localVersion -lt $remoteVersion) {
        $ReleasePattern = ".*\.msixbundle"
        $assets = $latestRelease.assets | Where-Object name -match $ReleasePattern | Select-Object -First 1
        $uri = $assets.browser_download_url
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
        Invoke-WebRequest -Uri $uri -OutFile $tmp
        Add-AppxPackage $tmp
    }
}