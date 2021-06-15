

function Get-ReleaseUri
{
    <#
    .SYNOPSIS
        Get github project release uri
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