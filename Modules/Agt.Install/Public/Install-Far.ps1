
function Install-Far {  
    <#
    .SYNOPSIS
        Install far
    .DESCRIPTION
    .PARAMETER Name
    .PARAMETER Extension
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>

    # Far.x64.3.0.5650.1688.e0c026b3fc3c63f815c818ec14861c9b1ea6480b.msicls
    # Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9].msi
    # https://github.com/FarGroup/FarManager/releases/download/ci/v3.0.5709.1852/Far.x64.3.0.5709.1852.689c635c5b5bbc01acd667f489a94e18626ad6a4.msi
    $pattern = "Far.x64.\d.\d.\d\d\d\d.\d\d\d\d.[a-z0-9]{40}.msi"
    $requestUri = Get-GitReleaseUri -Repouri "https://api.github.com/repos/FarGroup/FarManager" -Pattern $pattern

    $farPath = "C:\Program Files\Far Manager\Far.exe";
    $farFolder = [System.IO.Path]::GetDirectoryName($farPath);
    #[version]$localVersion = New-Object System.Version -ArgumentList "0.0.0"
    $localVersion = [System.Version]::new(0, 0, 0)
    if (Test-Path $farPath) {
        $localVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($farPath)).ProductVersion.Split(" ")[0]
    }

    (((Invoke-RestMethod -Method GET -Uri  "https://api.github.com/repos/FarGroup/FarManager/releases").tag_name | Select-Object -First 1) -match "ci\/v(?<version>\d\.\d\.\d\d\d\d\.\d\d\d\d)")
    
    [version]$remoteVersion = $matches["version"];

    if ($localVersion -ge $remoteVersion) { exit; }

    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
    Invoke-WebRequest -OutFile $tmp $requestUri
    #   Far msi package installation options
    Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""
    #   set path environment variable
    Set-EnvironmentVariable -Value $farFolder -Scope "Machine" -Action "Add"
}

