function Install-Powershell {  
    <#
    .SYNOPSIS
        Install latest Powershell core
    .DESCRIPTION
        Install latest Powershell core
    .PARAMETER IsWait
        [switch] Waits for the installation process to complete
    .PARAMETER UsePreview
        [switch] Use or not beta versions
    .NOTES
        Author : Agitech 
        Version : 1.0 
        Purpose : Get world better        
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)] [switch]$IsWait,
        [Parameter(Mandatory = $false)] [switch]$UsePreview
    )

    $IsAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    if ( -not $IsAdmin) {
        Write-Error "Run as admin!"
        exit
    }
    [version]$localVersion = [System.Version]::Parse("0.0.0")
    [version]$remoteVersion = [System.Version]::new(0, 0, 0)
    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8);
    # check pwsh and get it version
    $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
    if (-not (Test-Path $pwshPath)) {
        if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\31ab5147-9a97-4452-8443-d9709f0516e1" -ErrorAction SilentlyContinue) {
            $pwshPath = "{0}pwsh.exe" -f (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShellCore\InstalledVersions\31ab5147-9a97-4452-8443-d9709f0516e1\" -Name "InstallLocation").InstallLocation
        }
    }
    if (Test-Path $pwshPath) {
        $vtext = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($pwshPath)).ProductVersion.Split(" ")[0]
        $null = [System.Version]::TryParse($vtext, [ref]$localVersion)
    }
    else {
        $localVersion = $PSVersionTable.PSVersion
    }
    $ReleasePattern = if ($IsOs64) { "PowerShell-\d.\d.\d-win-x64.msi" } else { "PowerShell-\d.\d.\d-win-x86.msi" }
    $downloadUri = GetGitReleaseInfo -Uri "https://api.github.com/repos/powershell/powershell/" -ReleasePattern $ReleasePattern -LocalVersion $localVersion -RemoteVersion ([ref]$remoteVersion)
    if ($downloadUri) {
        Write-Host - "Updating pwsh. Local version $localVersion  Remote version $remoteVersion."
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
        Invoke-WebRequest -OutFile $tmp $downloadUri
        #region msi section
        $msiPath = $tmp.FullName
        $msiIsWait = $IsWait
        $logFile = '{0}-{1}.log' -f $msiPath, (get-date -Format yyyyMMddTHHmmss)
        $packageOptions = "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1"
        $arguments = "/i {0} {1} /quiet /norestart /L*v {2}" -f $msiPath, $packageOptions, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait:$msiIsWait
        #endregion msi section
    }
}