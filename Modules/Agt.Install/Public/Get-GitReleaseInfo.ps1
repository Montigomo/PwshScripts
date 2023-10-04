function Get-GitReleaseInfo {
    <#
    .SYNOPSIS
        Get github project release uri
    .DESCRIPTION
    .PARAMETER Repouri
        Uri github project
    .PARAMETER Pattern
        Regex pattern for search release version
    .PARAMETER Version
        [switch] Return release Version or Uri
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