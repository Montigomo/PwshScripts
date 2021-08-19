
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
        [string]$ParameterA
    )

    if(!(Get-IsAdmin))
    {
        Write-Error "Run as administrator"
        exit
        $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
        #$pp = $MyInvocation.MyCommand.Path
        if(((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas"))
        {
            Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
        }
    }

    $gitUri = "https://api.github.com/repos/powershell/powershell"
    $gitUriReleases = "$gitUri/releases"
    $gitUriReleasesLatest = "$gitUri/releases/latest"
    $pattern = (@("PowerShell-(?<version>\d?\d.\d?\d.\d?\d)-win-x64.zip","v(?<version>\d?\d.\d?\d.\d?\d)"))[1]
    $remoteVersion = [System.Version]::Parse("0.0.0")

    $pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");
    
    $latestRelease = (Invoke-RestMethod -Method Get -Uri $gitUriReleasesLatest)
    
    if($latestRelease.tag_name -match $pattern)
    {
        $remoteVersion = [System.Version]::Parse($Matches["version"]);
    }
    
    $localVersion = $PSVersionTable.PSVersion
    
    if($localVersion -lt $remoteVersion)
    {
        $pwshUri = ((Invoke-RestMethod -Method GET -Uri $gitUriReleases)[0].assets | Where-Object name -match "PowerShell-\d.\d.\d-win-x64.msi").browser_download_url

        # create temp file
        $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

        Invoke-WebRequest -OutFile $tmp $pwshUri

        # command line arguments
        # ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL - This property controls the option for adding the Open PowerShell item to the context menu in Windows Explorer.
        # ENABLE_PSREMOTING - This property controls the option for enabling PowerShell remoting during installation.
        # REGISTER_MANIFEST - This property controls the option for registering the Windows Event Logging manifest.

        $logFile = '{0}-{1}.log' -f $tmp.FullName, (get-date -Format yyyyMMddTHHmmss)
        $arguments = "/i {0} ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 /qn /norestart /L*v {1}" -f $tmp.FullName, $logFile
        Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow 
    }
}

#Install-Powershell