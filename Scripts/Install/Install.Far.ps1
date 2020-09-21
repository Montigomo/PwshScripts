

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

$test = Get-Release -Repouri "https://api.github.com/repos/powershell/powershell" -Pattern "PowerShell-\d.\d.\d-win-x64.msi"

Write-Output $test

# Far.x64.3.0.5650.1688.e0c026b3fc3c63f815c818ec14861c9b1ea6480b.msi
# Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9].msi

$test = Get-Release -Repouri "https://api.github.com/repos/FarGroup/FarManager" -Pattern "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi"

Write-Output $test