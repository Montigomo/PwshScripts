function Install-7zip {
    <#
    .SYNOPSIS
        Install 7zip archiver
    .DESCRIPTION
        Install 7zip archiver
    .PARAMETER InstallFolder
       Folder to where install 7zip (optional)
    #>
    Param
    (   
        [Parameter()]
        [string]$InstallFolder
    )
    #How can I install 7-Zip in silent mode?
    #For exe installer: Use the "/S" parameter to do a silent installation and the /D="C:\Program Files\7-Zip" parameter to specify the "output directory". These options are case-sensitive.
    #For msi installer: Use the /q INSTALLDIR="C:\Program Files\7-Zip" parameters.

    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8)
    [version]$localVersion = [System.Version]::new(0, 0, 0)

    $filePath = "C:\Program Files\7-Zip\7z.exe"

    if (Test-path "HKLM:\SOFTWARE\7-Zip") {
        $value = Get-ItemProperty "HKLM:\SOFTWARE\7-Zip\" -Name "Path" -ErrorAction SilentlyContinue
        if ($value) {
            $filePath = "{0}7z.exe" -f $value.Path
        }
    }

    $fileFolder = [System.IO.Path]::GetDirectoryName($filePath);
    if (Test-Path $filePath) {
        $verinfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filePath)
        #$localVersion = $verinfo.ProductVersion
    }

    if (-not (Get-Module -ListAvailable -Name "PowerHTML")) {
        Install-Module -Name "PowerHTML"
    }
    Import-Module -Name "PowerHTML"
    if (-not (Get-Module -Name "PowerHTML")) {
        Write-Error "Can't detect or install reqired module PowerHTML"
        throw "This is an error." 
    }

    $htmlDoc = ConvertFrom-Html -URI "https://7-zip.org/download.html"

    $downloadUrix64 = $null
    $downloadUri = $null

    [version]$remoteVersion = [System.Version]::new(0, 0, 0)

    $node = $htmlDoc.SelectSingleNode('/html[1]/body[1]/table[1]//tr[1]/td[2]/p[1]/b')
    if ($node) {
        $nodeText = $node.InnerText
        if ($nodeText -match "Download 7-Zip (?<version>\d\d.\d\d) \((?<date>\d\d\d\d-\d\d-\d\d)\)") {
            $remoteVersion = [System.Version]::Parse($Matches["version"]);
        }
    }
    #$node = $htmlDoc.SelectSingleNode('/html/body/table/tr/td[2]/table[1]/tr[2]/td[1]/a') # exe
    $node = $htmlDoc.SelectSingleNode('/html/body/table/tr/td[2]/table[1]/tr[5]/td[1]/a') # msi
    #$node = $htmlDoc.SelectSingleNode('/html[1]/body[1]/table[1]/tr[1]/td[2]/table[1]/tr[1]/td[1]/table[1]/tr[2]/td[1]/a[1]') # main page
    if ($node) {
        $downloadUrix64 = "https://7-zip.org/{0}" -f $node.Attributes["href"].Value
    }
    $node = $htmlDoc.SelectSingleNode('/html/body/table/tr/td[2]/table[1]/tr[6]/td[1]/a'); # msi
    #$node = $htmlDoc.SelectSingleNode('/html[1]/body[1]/table[1]/tr[1]/td[2]/table[1]/tr[1]/td[1]/table[1]/tr[3]/td[1]/a[1]') # main page
    if ($node) {
        $downloadUri = "https://7-zip.org/{0}" -f $node.Attributes["href"].Value
    }

    if ($localVersion -ge $remoteVersion) {
        return;
    }

    $requestUri = $downloadUrix64
    if (-not $IsOs64) {
        $requestUri = $downloadUri
    }

    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
    Invoke-WebRequest -OutFile $tmp $requestUri
    
    Install-MsiPackage -FilePath $tmp.FullName -PackageParams "/q"
}