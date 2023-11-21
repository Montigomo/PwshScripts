function Get-GitReleaseInfo {
    <#
    .SYNOPSIS
        Get github project release uri.
    .DESCRIPTION
        Get latest version of product (software) that hosted on github, uri for download.
    .PARAMETER repository uri
        [mandatory][string] github project url
    .PARAMETER ReleasePattern
        [mandatory][string] Regex pattern for search release version
    .PARAMETER VersionPattern
        [string] Return release Version or Uri
    .PARAMETER LocalVersion
        [System.Version] local(installed) version of product
    .PARAMETER RemoteVersion
        [ref] the remote version of the product. This version value will be retrieved in the function and assigned to this variable.
    .PARAMETER UsePreview
        [switch] Use preview version product
    .EXAMPLE
        Get-GitReleaseInfo -Uri "https://api.github.com/repos/powershell/powershell/" -ReleasePattern "PowerShell-\d.\d.\d-win-x64.msi" -LocalVersion ([System.Version]::Parse("0.0.0")  -RemoteVersion ([ref]$remoteVersion)
    #>
    param(
        [Parameter(Mandatory = $true)] [string]$Uri,
        [Parameter(Mandatory = $true)] [string]$ReleasePattern,
        [Parameter(Mandatory = $false)] [string]$VersionPattern = "v(?<version>\d?\d.\d?\d.\d?\d)",
        [Parameter(Mandatory = $false)] [System.Version]$LocalVersion = [System.Version]::Parse("0.0.0"),
        [Parameter(Mandatory = $false)] [ref]$RemoteVersion,
        [Parameter(Mandatory = $false)] [switch]$UsePreview
    )
    $Uri = "$Uri/releases" -replace "(?<!:)/{2,}", "/"
    $json = (Invoke-RestMethod -Method Get -Uri $Uri)
    $releases = $json | Where-Object { $_.prerelease -eq $UsePreview.ToBool() } | Sort-Object -Property published_at -Descending
    $latestRelease = $releases | Select-Object -First 1
    $_remoteVersion = [System.Version]::Parse("0.0.0")
    if ($latestRelease.tag_name -match $VersionPattern) {
        $null = [System.Version]::TryParse($Matches["version"], [ref]$_remoteVersion);
    }
    if ($RemoteVersion) {
        $RemoteVersion.Value = $_remoteVersion
    }
    if ($LocalVersion -lt $_remoteVersion) {
        $item = $latestRelease.assets | Where-Object name -match $ReleasePattern | Select-Object -First 1
        return $item.browser_download_url
    }
    else {
        return $null
    }
}