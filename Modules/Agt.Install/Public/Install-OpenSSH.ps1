
function Install-OpenSsh
{  
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

    if(!(Get-IsAdmin))
    {
        Write-Error "Run as administrator"
        exit
    }
    
    ### Download OpenSSH archive from github and try to install it

    $gitUri = "https://api.github.com/repos/powershell/Win32-OpenSSH"

    $version = Get-GitReleaseInfo $gitUri -Version

    if($Zip)
    {
        $releaseUri = Get-GitReleaseInfo $gitUri -Pattern "OpenSSH-Win64.zip"

        $destPath = "c:\Program Files\OpenSSH\"
    
        $installScriptPath = Join-Path $destPath "install-sshd.ps1"
    
        [System.IO.Directory]::CreateDirectory($destPath)
    
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } -PassThru
    
        Invoke-WebRequest -OutFile $tmp $releaseUri
    
        Add-Type -Assembly System.IO.Compression.FileSystem
    
        $zip = [IO.Compression.ZipFile]::OpenRead($tmp.FullName)
    
        $entries = $zip.Entries | Where-Object {-not [string]::IsNullOrWhiteSpace($_.Name) } #| where {$_.FullName -like 'myzipdir/c/*' -and $_.FullName -ne 'myzipdir/c/'} 

        if((get-service sshd -ErrorAction SilentlyContinue).Status -eq "Running")
        {
            Stop-Service sshd
        }

        foreach($entry in $entries)
        {
            $dpath = $destPath + $entry.Name
            [IO.Compression.ZipFileExtensions]::ExtractToFile( $entry, $dpath, $true)
        }

        $zip.Dispose()
    
        # set environment path vartiable
        #[Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\Program Files\OpenSSH",[EnvironmentVariableTarget]::Machine)
        Set-EnvironmentVariable -Name 'Path' -Scope 'Machine' -Value $destPath
    
        # remove temporary file
        $tmp | Remove-Item
    }else
    {
        $releaseUri = Get-GitReleaseInfo $gitUri -Pattern "OpenSSH-Win32-v\d.\d.\d.\d.msi"
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
        Invoke-WebRequest -OutFile $tmp $releaseUri
        Install-MsiPackage -FilePath $tmp.FullName -PackageParams ""
    }

    # remove old capabilities
    if((Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Server*").State -eq "Installed")
    {
        Remove-WindowsCapability -Online  -Name  "OpenSSH.Server*"
    }

    if((Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*").State -eq "Installed")
    {
        Remove-WindowsCapability -Online  -Name  "OpenSSH.Client*"
    }

    # change default ssh shell to powershell
    $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
    if(Test-Path $pwshPath -PathType Leaf)
    {
        if(!(Test-Path "HKLM:\SOFTWARE\OpenSSH"))
        {
            New-Item 'HKLM:\Software\OpenSSH' -Force
        }
        #New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String –Force
        #New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String –Force
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String -Force
    }

    #setup sshd service startup type and start it
    if(Get-Service  sshd -ErrorAction SilentlyContinue)
    {
        # if((get-service sshd).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
        Get-Service -Name sshd | Set-Service -StartupType 'Automatic'
        Start-Service sshd
    }

    #setup ssh-agent service startup type and start it
    if(Get-Service  ssh-agent -ErrorAction SilentlyContinue)
    {
        # if((get-service ssh-agent).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
        Get-Service -Name ssh-agent | Set-Service -StartupType 'Automatic'
        Start-Service ssh-agent
    }
}

#Install-OpenSsh