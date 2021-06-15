

function Get-Sysinternals
{
    <#
    .SYNOPSIS
        Download sysinternals programs to the desired folder
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
    param
    (
        [string]$destination
    )

    $fileName = "SysinternalsSuite.zip";

    $filePath = "D:\_software\system\Sysinternals\$fileName";

    $dstPath = "D:\tools\sysinternals"

    if(-not (Test-Path -Path $dstPath -PathType Container))
    {
        Write-Error "Path $dstPath does not exist";
        exit;
    }

    if(-not (Test-Path -Path $filePath -PathType Leaf))
    {
        $filePath = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru
    }

    $uri = "https://download.sysinternals.com/files/SysinternalsSuite.zip"

    Invoke-WebRequest -Uri $uri -OutFile $filePath

    Expand-Archive -Path $filePath -DestinationPath $dstPath -Force

}