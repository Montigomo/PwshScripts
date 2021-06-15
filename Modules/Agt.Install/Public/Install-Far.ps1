

function Install-Far
{  
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

    # install far

    # Far.x64.3.0.5650.1688.e0c026b3fc3c63f815c818ec14861c9b1ea6480b.msicls

    # Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9].msi

    # https://github.com/FarGroup/FarManager/releases/download/ci/v3.0.5709.1852/Far.x64.3.0.5709.1852.689c635c5b5bbc01acd667f489a94e18626ad6a4.msi

    $requestUri = Get-Release -Repouri "https://api.github.com/repos/FarGroup/FarManager" -Pattern "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi"

    Write-Output $test

    #3.0.5698.0

    $farPath = "C:\Program Files\Far Manager\Far.exe";

    $vl = $null;
    $vr  = $null
    if(Test-Path $farPath)
    {
        $vl = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($farPath)
    }
    if(((Invoke-RestMethod -Method GET -Uri  "https://api.github.com/repos/FarGroup/FarManager/releases").tag_name | Select-Object -First 1) -match "ci\/v(?<version>\d\.\d\.\d\d\d\d\.\d\d\d\d)")
    {
        $vr = $matches["version"];
    }


    #3.0.5698.0 x64

    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

    Invoke-WebRequest -OutFile $tmp $requestUri

    #   Far msi package installation options

    Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""

    #   set path environment variable

    $farPathes = @("C:\Program Files\Far Manager")

    foreach($item in $farPathes)
    {
        Set-EnvironmentVariablePath -Value $item -Scope "Machine" -Action "Add"
    }
}