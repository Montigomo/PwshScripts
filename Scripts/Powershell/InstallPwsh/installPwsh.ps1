
#. .\Get-IsAdmin.ps1
#.\Install-Powershell.ps1
#$script1 = $PSScriptRoot\Get-IsAdmin.ps1
#& "$PSScriptRoot\Get-IsAdmin.ps1"
#& "$PSScriptRoot\Install-Powershell.ps1"
#if((Get-IsAdmin))    {         Write-Error "Run as administrator"    }
#Install-Powershell
#Write-Host -NoNewLine 'Press any key to continue...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

function Get-IsAdmin  
{  
    <#
    .SYNOPSIS
        Is powershell session runned in admin mode 
    .DESCRIPTION
    .PARAMETER Name
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param(
        [string]$Parameter
    )
    # $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    # [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    # Determine if admin powershell process
    # ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    $wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $prp=new-object System.Security.Principal.WindowsPrincipal($wid)
    $adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
    [bool]$prp.IsInRole($adm)

}
function Install-Powershell
{  
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
        [string]$Parameter
    )

    if(!(Get-IsAdmin))
    {
        Write-Error "Run as administrator"
        exit
    }
    # Rerun (not complited)
    # $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
    # $pp = $MyInvocation.MyCommand.Path
    # if(((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas"))
    # {
    #     Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
    # }

    $gitUri = "https://api.github.com/repos/powershell/powershell"
    $gitUriReleases = "$gitUri/releases"
    $gitUriReleasesLatest = "$gitUri/releases/latest"
    $pattern = (@("PowerShell-(?<version>\d?\d.\d?\d.\d?\d)-win-x64.zip","v(?<version>\d?\d.\d?\d.\d?\d)"))[1]
    $remoteVersion = [System.Version]::Parse("0.0.0")

    #$pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");
    
    $latestRelease = (Invoke-RestMethod -Method Get -Uri $gitUriReleasesLatest)
    
    if($latestRelease.tag_name -match $pattern)
    {
        $remoteVersion = [System.Version]::Parse($Matches["version"]);
    }
    
    $localVersion = $PSVersionTable.PSVersion
    
    if($localVersion -lt $remoteVersion)
    {
        $wrq = Invoke-RestMethod -Method GET -Uri $gitUriReleases
        $releases = $wrq | Where-Object {$_.prerelease -eq $false} | Sort-Object -Property published_at -Descending 
        $pwshUri = ($releases[0].assets | Where-Object name -match "PowerShell-\d.\d.\d-win-x64.msi").browser_download_url

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

        $logFile = '{0}-{1}.log' -f $tmp.FullName, (get-date -Format yyyyMMddTHHmmss)
        $arguments = "/i {0} ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 /qn /norestart /L*v {1}" -f $tmp.FullName, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait
    }
}

Install-Powershell

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');