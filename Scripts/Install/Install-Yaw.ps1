
function Install-Yaw
{  
    <#
    .SYNOPSIS
        
    .DESCRIPTION
    .PARAMETER Name
    .PARAMETER Extension
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>


    # $PSVersionTable
    # $MyInvocation | format-list *
    # Get-Host
    # $host
    #$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'zip' } –PassThru
    #msiexec.exe /package PowerShell-7.0.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1
    # Set Remove Path variable
    # crete shortcuts

    $lnkDstPath = Join-Path (Get-KnownfolderPath -KnownFolder Desktop) "OneDrive.lnk"
    $lnkSrcPath = (Get-KnownfolderPath -KnownFolder OneDriveFolder)

    Set-ShortCut $lnkSrcPath $lnkDstPath

}