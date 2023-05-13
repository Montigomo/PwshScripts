function Set-PinnedCommand {
    <#
    .SYNOPSIS
        Add a command to sturtup (profile)
    .DESCRIPTION
    .PARAMETER ModuleName
        (Mandatory) Module from which the comand wil be exported
    .PARAMETER MethodName
        (Mandatory) Comand what be exported and pinned
    .PARAMETER InlineCommandCall
        Is pinned command will be callaed at startup
    .PARAMETER Argumens
        Arguments substituted to inline cmmand call
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>  
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        # [ValidateScript({
        #     $_ -match "^Agt\..*" -or 
        #     $(throw 'Wrong module name')
        #   })]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$CommandName,
        [switch]$InlineCommandCall,
        [string]$Arguments
    )

    Import-Module $ModuleName -ErrorAction SilentlyContinue

    if ( -not (Get-Module $ModuleName) -or (-not $?)) {
        Write-Host -ForegroundColor DarkYellow "Module $ModuleName was not found."
        return
    }

    $commandBody = (Get-Command -Module $ModuleName -Name $CommandName).Definition
    $command = "`r`nfunction $CommandName{`r`n$commandBody`r`n}"

    if ($InlineCommandCall) {
        $command = $command + "`r`n$CommandName $Arguments"
    }

    #$profilePath = "$PSHOME\Profile.ps1"
    $profilePath = $profile.CurrentUserAllHosts
    if (!(Test-Path $profilePath)) {
        New-Item -Path $profilePath -Type "file" -Force
    }

    $profileContent = Get-Content -Path $profilePath
    $regexString = "^function $([regex]::escape($MethodName)){"
    if (([string]::IsNullOrWhiteSpace($profileContent) -or (-not ($profileContent -match $regexString)))) {
        $profileContent = ($profileContent + $command)
        $profileContent | Out-File -FilePath $profilePath -Force
    }

}
