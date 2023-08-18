


$gitUri = "https://api.github.com/repos/powershell/powershell/releases/latest"
$releases = (Invoke-RestMethod -Method Get -Uri $gitUri)

$remoteVersion = [System.Version]::Parse("0.0.0")
$pattern = (@("PowerShell-(?<version>\d?\d.\d?\d.\d?\d)-win-x64.zip","v(?<version>\d?\d.\d?\d.\d?\d)"))[1]

if($releases.tag_name -match $pattern)
{
    $remoteVersion = [System.Version]::Parse($Matches["version"]);
}

$localVersion = $PSVersionTable.PSVersion

if($localVersion -lt $remoteVersion)
{
    Write-Output "Need update"
}

exit