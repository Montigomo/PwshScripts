

$nr = $true
$currentVersion = [System.Version]::Parse("0.0.0")
[System.Version]::TryParse("1.17.0", [ref]$currentVersion)

function test{
    $nr = $true
    $currentVersion = [System.Version]::Parse("0.0.0")
    $null = [System.Version]::TryParse("1.17.0", [ref]$currentVersion)
    return $nr;
}

$t = $nr
$t2 = test
exit