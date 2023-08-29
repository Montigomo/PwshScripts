function Get-GitReleaseInfo
{
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
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    param(
        [Parameter(Mandatory=$true)] [string] $Repouri,
        [Parameter(Mandatory=$false)] [string] $Pattern = "v(?<version>\d?\d.\d?\d.\d?\d)",
        [Parameter(Mandatory=$false)] [switch] $Version
    )

    $releasesUri = $Repouri

    $releasesUri = "$Repouri/releases/latest"

    $json = Invoke-RestMethod -Method GET -Uri $releasesUri

    if($Version)
    {
        #$Pattern = if($Pattern) {"v(?<version>\d?\d.\d?\d.\d?\d)"} else {$Pattern}
        $ver = [System.Version]::Parse("0.0.0")
        if($json.tag_name -match $pattern)
        {
            $ver = [System.Version]::Parse($Matches["version"]);
        }
        return $ver
    }

    $assets = ($json.assets) | Sort-Object -Property "created_at" -Descending

    if(!$assets)
    {
        return
    }

    $asset = $assets | Where-Object name -match $Pattern
    
    $downloadUri = $asset.browser_download_url

    return $downloadUri
}