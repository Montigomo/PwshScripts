function Install-Powershell {  
    <#
    .SYNOPSIS
        Install latest Powershell core
    .DESCRIPTION
        Install latest Powershell core
    .PARAMETER IsWait
        Waits for the installation process to complete
    .PARAMETER UsePreview
        Use or not beta versions
    #>
    [CmdletBinding()]
    param(
        [switch]$IsWait,
        [switch]$UsePreview
    )
    $IsAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    if ( -not $IsAdmin) {
        Write-Error "Run as admin!"
        exit
    }
    $localVersion = [System.Version]::Parse("0.0.0")
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
    $downloadUri = Get-GitReleaseInfo -Uri "https://api.github.com/repos/powershell/powershell/" -ReleasePattern $ReleasePattern -LocalVersion $localVersion
    if ($downloadUri) {
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
        Invoke-WebRequest -OutFile $tmp $downloadUri
        $logFile = '{0}-{1}.log' -f $tmp.FullName, (get-date -Format yyyyMMddTHHmmss)

        # https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3#install-the-msi-package-from-the-command-line
        $arguments = "/i {0} /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1 /norestart /L*v {1}" -f $tmp.FullName, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait:$IsWait
    }
}