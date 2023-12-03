function Install-MsiPackage {
    <#
    .SYNOPSIS
        Run msi package 
    .PARAMETER FilePath
        Specifies path to msi package
    .PARAMETER PackageParams
        Specific msi package 
    .NOTES
        Author : Agitech 
        Version : 1.0 
        Purpose : Get world better        
    #>
    Param
    (   
        [Parameter(Mandatory = $true)][string]$MsiPackagePath,
        [Parameter(Mandatory = $false)][string]$PackageOptions = "",
        [Parameter(Mandatory = $false)] [switch]$IsWait
    )
    # https://learn.microsoft.com/en-us/windows/win32/msi/command-line-options
    #region msi section
    $msiPath = $MsiPackagePath
    $msiIsWait = $IsWait
    $logFile = '{0}-{1}.log' -f $msiPath, (get-date -Format yyyyMMddTHHmmss)
    $packageOptions = $PackageOptions
    $arguments = "/i {0} {1} /quiet /norestart /L*v {2}" -f $msiPath, $packageOptions, $logFile
    Start-Process "msiexec.exe" -ArgumentList $arguments -NoNewWindow -Wait:$msiIsWait
    #endregion msi section
}