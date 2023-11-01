function Install-Git {  
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
    [CmdletBinding()]
    param(
        [switch]$IsWait,
        [switch]$UsePreview
    )
	exit

    $IsAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    if ( -not $IsAdmin) {
        Write-Error "Run as admin!"
        exit
    }
    $gitUri = "https://api.github.com/repos/powershell/powershell"
    $gitUriReleases = "$gitUri/releases"
    #$gitUriReleasesLatest = "$gitUri/releases/latest"
    $remoteVersion = [System.Version]::Parse("0.0.0")
    $localVersion = [System.Version]::Parse("0.0.0")

    #$pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");
    
    $wrq = (Invoke-RestMethod -Method Get -Uri $gitUriReleases)
    $releases = $wrq | Where-Object { $_.prerelease -eq $UsePreview.ToBool() } | Sort-Object -Property published_at -Descending
  
    $latestRelease = $releases | Select-Object -First 1
    
    if ($latestRelease.tag_name -match "v(?<version>\d?\d.\d?\d.\d?\d)") {
        $remoteVersion = [System.Version]::Parse($Matches["version"]);
    }
    
    # check pwsh and get it version
    $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
    if (Test-Path $pwshPath) {
        $localVersion = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($pwshPath)).ProductVersion.Split(" ")[0]
    }
    else {
        $localVersion = $PSVersionTable.PSVersion
    }



    if ($localVersion -lt $remoteVersion) {
        $ReleasePattern = "PowerShell-\d.\d.\d-win-x64.msi"      
        $assets = $latestRelease.assets | Where-Object name -match $ReleasePattern | Select-Object -First 1
        $pwshUri = $assets.browser_download_url

        # create temp file
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

        Invoke-WebRequest -OutFile $tmp $pwshUri

        $logFile = '{0}-{1}.log' -f $tmp.FullName, (get-date -Format yyyyMMddTHHmmss)
        $arguments = "/i {0} /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /norestart /L*v {1}" -f $tmp.FullName, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait:$IsWait
    }
}