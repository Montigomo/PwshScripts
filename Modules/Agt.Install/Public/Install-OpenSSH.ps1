
function Install-OpenSsh {  
    <#
    .SYNOPSIS
        Install OpenSsh
    .DESCRIPTION
    .PARAMETER Name
    .PARAMETER Extension
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]$Zip
    )

    if (!(Get-IsAdmin)) {
        Write-Error "Run as administrator"
        exit
    }
    
    $remoteVersion = [System.Version]::Parse("0.0.0")
    $localVersion = [System.Version]::Parse("0.0.0")
    
    ### Download OpenSSH archive from github and try to install it

    $gitUri = "https://api.github.com/repos/powershell/Win32-OpenSSH"

    $remoteVersion = Get-GitReleaseInfo $gitUri -Version
    

    #detect OS arch
    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8);

    #get local version
    $exePath = if ($IsOs64) {
        "C:\Program Files\OpenSSH\ssh.exe"
    }
    else {
        "C:\Program Files (x86)\OpenSSH\ssh.exe"
    }

    if (Test-Path $exePath) {
        [System.Version]::TryParse( ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($exePath)).FileVersion, [ref]$localVersion)
    }

    if ($localVersion -ge $remoteVersion) {
        return
    }

    if ($Zip) {

        $pattern = if ($IsOs64) { "OpenSSH-Win64.zip" }else { "OpenSSH-Win32.zip" }
        $releaseUri = Get-GitReleaseInfo $gitUri -Pattern $pattern
        $destPath = "c:\Program Files\OpenSSH\"
        #$installScriptPath = Join-Path $destPath "install-sshd.ps1"
        [System.IO.Directory]::CreateDirectory($destPath)
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
        Invoke-WebRequest -OutFile $tmp $releaseUri
        Add-Type -Assembly System.IO.Compression.FileSystem
        $zip = [IO.Compression.ZipFile]::OpenRead($tmp.FullName)
        $entries = $zip.Entries | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Name) } #| where {$_.FullName -like 'myzipdir/c/*' -and $_.FullName -ne 'myzipdir/c/'} 
        if ((get-service sshd -ErrorAction SilentlyContinue).Status -eq "Running") {
            Stop-Service sshd
        }
        foreach ($entry in $entries) {
            $dpath = $destPath + $entry.Name
            [IO.Compression.ZipFileExtensions]::ExtractToFile( $entry, $dpath, $true)
        }
        $zip.Dispose()
        # set environment path vartiable
        #[Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\Program Files\OpenSSH",[EnvironmentVariableTarget]::Machine)
        Set-EnvironmentVariable -Name 'Path' -Scope 'Machine' -Value $destPath
        # remove temporary file
        $tmp | Remove-Item
    }
    else {
        $pattern = if ($IsOs64) { "OpenSSH-Win64-v\d.\d.\d.\d.msi" }else { "OpenSSH-Win32-v\d.\d.\d.\d.msi" }        
        $releaseUri = Get-GitReleaseInfo $gitUri -Pattern $pattern
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
        Invoke-WebRequest -OutFile $tmp $releaseUri
        Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""
    }

    # remove old capabilities
    if ((Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*").State -eq "Installed") {
        foreach ($item in (Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*")) {
            Remove-WindowsCapability -Online  -Name  $item.Name
        }
    }

    if ((Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*").State -eq "Installed") {
        foreach ($item in (Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*")) {
            Remove-WindowsCapability -Online  -Name  $item.Name
        }
    }

    # change default ssh shell to powershell
    $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
    if (Test-Path $pwshPath -PathType Leaf) {
        if (!(Test-Path "HKLM:\SOFTWARE\OpenSSH")) {
            New-Item 'HKLM:\Software\OpenSSH' -Force
        }
        #New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String –Force
        #New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String –Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String -Force
    }

    #setup sshd service startup type and start it
    if (Get-Service  sshd -ErrorAction SilentlyContinue) {
        # if((get-service sshd).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
        Get-Service -Name sshd | Set-Service -StartupType 'Automatic'
        Start-Service sshd
    }

    #setup ssh-agent service startup type and start it
    if (Get-Service  ssh-agent -ErrorAction SilentlyContinue) {
        # if((get-service ssh-agent).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
        Get-Service -Name ssh-agent | Set-Service -StartupType 'Automatic'
        Start-Service ssh-agent
    }
}


#. "D:\_software\PwshScripts\Modules\Agt.Common\Public\Get-IsAdmin.ps1"
#. "D:\_software\PwshScripts\Modules\Agt.Install\Public\Get-GitReleaseInfo.ps1"
#. "D:\_software\PwshScripts\Modules\Agt.Install\Public\Install-MsiPackage.ps1"

#Install-OpenSsh
