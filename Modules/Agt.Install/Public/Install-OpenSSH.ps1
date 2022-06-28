


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

    if(!(Get-IsAdmin))
    {
        Write-Error "Run as administrator"
        exit
    }
    
    ### Download OpenSSH archive from github and try to install it

    $osuri = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip"

    $destPath = "c:\Program Files\OpenSSH\"

    $installScriptPath = Join-Path $destPath "install-sshd.ps1"

    # create target directory
    [System.IO.Directory]::CreateDirectory($destPath)
    #New-Item -ItemType Directory -Path $destPath -Force

    # create temp with zip extension (or Expand will complain)
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } –PassThru

    # download
    Invoke-WebRequest -OutFile $tmp $osuri

    # exract to destination folder

    $tmp | Expand-Archive -DestinationPath $destPath -Force

    Add-Type -Assembly System.IO.Compression.FileSystem

    # extract list entries for dir 
    $zip = [IO.Compression.ZipFile]::OpenRead($tmp.FullName)

    $entries = $zip.Entries | Where-Object {-not [string]::IsNullOrWhiteSpace($_.Name) } #| where {$_.FullName -like 'myzipdir/c/*' -and $_.FullName -ne 'myzipdir/c/'} 

    #create dir for result of extraction
    #New-Item -ItemType Directory -Path "c:\temp\c" -Force

    if((get-service sshd -ErrorAction SilentlyContinue).Status -eq "Running")
    {
        Stop-Service sshd
    }

    # extraction
    foreach($entry in $entries)
    {
        $dpath = $destPath + $entry.Name
        [IO.Compression.ZipFileExtensions]::ExtractToFile( $entry, $dpath, $true)
    }
    #$entries | ForEach-Object {[IO.Compression.ZipFileExtensions]::ExtractToFile( $_, $destPath + $_.Name, $true) }

    #free object
    $zip.Dispose()

    # set environment path vartiable
    #[Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";C:\Program Files\OpenSSH",[EnvironmentVariableTarget]::Machine)
    Set-EnvironmentVariable -Name 'Path' -Scope 'Machine' -Value $destPath

    # remove temporary file
    $tmp | Remove-Item


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
        New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String –Force
    }

    # try to run installation script
    if(Get-IsAdmin)
    {
        & $installScriptPath
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