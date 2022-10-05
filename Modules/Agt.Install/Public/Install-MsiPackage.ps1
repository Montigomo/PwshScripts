
function Install-MsiPackage
{
    <#
    .SYNOPSIS
        Run msi package 
    .DESCRIPTION
    .PARAMETER FilePath
        Specifies path to msi package
    .PARAMETER PackageParams
        Specific msi package parameters
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    Param
    (   
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [string]$PackageParams = ""
    )

    $DataStamp = get-date -Format yyyyMMddTHHmmss

    $logFile = '{0}-{1}.log' -f $FilePath,$DataStamp

    $MSIArguments = '/i "{0}" {1} /qn /norestart /L*v $logFile' -f $FilePath, $PackageParams

    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}