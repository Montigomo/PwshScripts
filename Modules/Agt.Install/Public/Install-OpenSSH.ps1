function Install-OpenSsh {  
    <#
    .SYNOPSIS
        Install OpenSsh
    .DESCRIPTION
        Install OpenSsh
    .PARAMETER Zip
        Install from msi or zip
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)] 
        [switch]$Zip
    )

    $IsAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
    if ( -not $IsAdmin) {
        Write-Error "Run as admin!"
        exit
    }
    $localVersion = [System.Version]::Parse("0.0.0")
    
    $gitUri = "https://api.github.com/repos/powershell/Win32-OpenSSH"
    [bool]$IsOs64 = $([System.IntPtr]::Size -eq 8);
    $exePath = if ($IsOs64) {
        "C:\Program Files\OpenSSH\ssh.exe"
    }
    else {
        "C:\Program Files (x86)\OpenSSH\ssh.exe"
    }

    if (Test-Path $exePath) {
        $vtext = ([System.Diagnostics.FileVersionInfo]::GetVersionInfo($exePath)).FileVersion
        $null = [System.Version]::TryParse($vtext, [ref]$localVersion)
    }

    if ($Zip) {
        $ReleasePattern = if ($IsOs64) { "OpenSSH-Win64.zip" }else { "OpenSSH-Win32.zip" }
        $downloadUri = Get-GitReleaseInfo -Uri $gitUri -ReleasePattern $ReleasePattern -LocalVersion $localVersion
        if ($downloadUri) {
            $destPath = "c:\Program Files\OpenSSH\"
            [System.IO.Directory]::CreateDirectory($destPath)
            $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
            Invoke-WebRequest -OutFile $tmp $downloadUri
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
            Set-EnvironmentVariable -Name 'Path' -Scope 'Machine' -Value $destPath
            $tmp | Remove-Item
        }
    }
    else {
        $ReleasePattern = if ($IsOs64) { "OpenSSH-Win64-v\d.\d.\d.\d.msi" }else { "OpenSSH-Win32-v\d.\d.\d.\d.msi" }        
        $downloadUri = Get-GitReleaseInfo -Uri $gitUri -ReleasePattern $ReleasePattern -LocalVersion $localVersion
        if ($downloadUri) {
            $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
            Invoke-WebRequest -OutFile $tmp $downloadUri
            Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""
        }
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
