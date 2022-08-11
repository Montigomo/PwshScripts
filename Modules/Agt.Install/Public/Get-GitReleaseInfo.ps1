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
        [Parameter(Mandatory=$false)] [string] $Pattern,
        [Parameter(Mandatory=$false)] [switch] $Version
    )

    $releasesUri = $Repouri

    $releasesUri = "$Repouri/releases/latest"

    $json = Invoke-RestMethod -Method GET -Uri $releasesUri

    if($Version)
    {
        $Pattern = "v(?<version>\d?\d.\d?\d.\d?\d)"
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

# debug section
# $uri1 = "https://api.github.com/repos/powershell/Win32-OpenSSH"
# $uri2 = "https://api.github.com/repos/powershell/powershell"

# $patterns = (@("PowerShell-(?<version>\d?\d.\d?\d.\d?\d)-win-x64.zip", "PowerShell-\d.\d.\d-win-x64.msi", "v(?<version>\d?\d.\d?\d.\d?\d)"))

# $vera = Get-GitReleaseUri $uri2 -Version
# $uria = Get-GitReleaseUri $uri2 -Pattern "PowerShell-\d.\d.\d-win-x64.msi"

# $verb = Get-GitReleaseUri $uri1 -Version
# $urib = Get-GitReleaseUri $uri1 -Pattern "OpenSSH-Win32-v\d.\d.\d.\d.msi"

# exit