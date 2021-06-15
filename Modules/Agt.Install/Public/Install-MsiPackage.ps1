
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
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
    Param
    (   
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath,
        [string]
        $PackageParams
    )

    $DataStamp = get-date -Format yyyyMMddTHHmmss

    $logFile = '{0}-{1}.log' -f $FilePath,$DataStamp
    
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f $FilePath)
        ($PackageParams ?? "")
        "/qn"
        "/norestart"
        "/L*v"
        $logFile
    )

    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}