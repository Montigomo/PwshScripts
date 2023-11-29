function Install-WinRar {
    <#
    .SYNOPSIS
        Install WinRar 
    .DESCRIPTION
    .PARAMETER InstallFolder
       Folder to where WinRar (optional)
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    .NOTES
        Author : Agitech 
        Version : 1.0 
        Purpose : Get world better    
    #>
    Param
    (   
        [Parameter()]
        [string]$InstallFolder
    )

    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8)
    [version]$localVersion = [System.Version]::new(0, 0, 0)
    [version]$remoteVersion = [System.Version]::new(0, 0, 0)

    $filePath = "C:\Program Files\WinRAR\WinRAR.exe"

    if (Test-path "HKLM:\SOFTWARE\WinRAR") {
        $value = Get-ItemProperty "HKLM:\SOFTWARE\WinRAR\" -Name "exe64" -ErrorAction SilentlyContinue
        if ($value) {
            $filePath = $value.exe64
        }
    }

    #$fileFolder = [System.IO.Path]::GetDirectoryName($filePath);
    if (Test-Path $filePath) {
        $verinfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($filePath)
        $localVersion = $verinfo.ProductVersion
    }

    if (-not (Get-Module -ListAvailable -Name "PowerHTML")) {
        Install-Module -Name "PowerHTML"
    }
    Import-Module -Name "PowerHTML"
    if (-not (Get-Module -Name "PowerHTML")) {
        Write-Error "Can't detect or install reqired module PowerHTML"
        throw "This is an error." 
    }

    $htmlDoc = ConvertFrom-Html -URI "https://www.rarlab.com/download.htm"


    [version]$remoteVersion = [System.Version]::new(0, 0, 0)

    $nodes = $htmlDoc.SelectNodes('/html[1]/body[1]/table[1]/tr[1]/td[2]/table[5]/tr')

    if (-not $nodes) {
        return
    }
    [hashtable]$assets = @{}
    foreach ($node in $nodes) {
        try {
            $anode = $node.SelectSingleNode("td[1]/a[1]")
            if ($anode) {
                $href = "https://www.rarlab.com{0}" -f $anode.Attributes["href"].Value
                $lang = $anode.ChildNodes["b"].InnerText
                $ver = $node.SelectSingleNode("td[2]").InnerText
                $assets[$lang] = @{"href" = $href; "version" = $ver }
            }

        }
        catch {

        }
    }
    $key = "Russian ({0})" -f $(if ($IsOs64) { "64 bit" }else { "32 bit" })
    if (-not $assets.ContainsKey($key)) {
        return
    }

    $href = $assets[$key].href
    $remoteVersion = [System.Version]::Parse($assets[$key].version);
    if ($localVersion -ge $remoteVersion) {
        return;
    }

    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'exe' } -PassThru
    Invoke-WebRequest -OutFile $tmp $href
    
    Start-Process -FilePath $tmp.FullName -ArgumentList "/S" -WindowStyle Hidden -Wait
}