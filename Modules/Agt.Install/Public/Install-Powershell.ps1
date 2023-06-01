function Install-Powershell {  
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

    if (!(Get-IsAdmin)) {
        Write-Error "Run as administrator"
        exit
    }
    
    $gitUri = "https://api.github.com/repos/powershell/powershell"
    $gitUriReleases = "$gitUri/releases"
    #$gitUriReleasesLatest = "$gitUri/releases/latest"
    $remoteVersion = [System.Version]::Parse("0.0.0")
    $localVersion = [System.Version]::Parse("0.0.0")
    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8);

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
        $ReleasePattern = if ($IsOs64) { "PowerShell-\d.\d.\d-win-x64.msi" } else { "PowerShell-\d.\d.\d-win-x86.msi" }
        $assets = $latestRelease.assets | Where-Object name -match $ReleasePattern | Select-Object -First 1
        $pwshUri = $assets.browser_download_url

        # create temp file
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

        Invoke-WebRequest -OutFile $tmp $pwshUri

        # command line arguments
        # USE_MU - This property has two possible values:
        #   1 (default) - Opts into updating through Microsoft Update, WSUS, or Configuration Manager
        #   0 - Do not opt into updating through Microsoft Update, WSUS, or Configuration Manager
        # ENABLE_MU
        #   1 (default) - Opts into using Microsoft Update for Automatic Updates
        #   0 - Do not opt into using Microsoft Update
        # ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL - This property controls the option for adding the Open PowerShell item to the context menu in Windows Explorer.
        # ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL - This property controls the option for adding the Run with PowerShell item to the context menu in Windows Explorer.
        # ENABLE_PSREMOTING - This property controls the option for enabling PowerShell remoting during installation.
        # REGISTER_MANIFEST - This property controls the option for registering the Windows Event Logging manifest.
        # ADD_PATH - This property controls the option for adding PowerShell to the Windows PATH environment variable.

        $logFile = '{0}-{1}.log' -f $tmp.FullName, (get-date -Format yyyyMMddTHHmmss)
        $arguments = "/i {0} /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /norestart /L*v {1}" -f $tmp.FullName, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait:$IsWait
    }
}