function Unpack-items
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER Folder
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DestinationFolder,
        [Parameter(Mandatory=$true)]
        [string]$SourceFolder,
        [Parameter(Mandatory=$false)]
        [string]$RarPath = "C:\Program Files\WinRAR\Rar.exe",
        [Parameter(Mandatory=$false)]
        [int]$First = 0,
        [Parameter(Mandatory=$false)]
        [int]$Last = 0,
        [Parameter(Mandatory=$false)]
        [int]$Skip = 0,
        [Parameter(Mandatory=$false)]
        [int]$SkipLast = 0
    )

    $items = Get-ChildItem -Directory -Path $SourceFolder | Sort-Object -Property Name
    $items = $items | Select-Object -Skip $Skip | Select-Object -SkipLast $SkipLast
    if($first -gt 0)
    {
        $items = $items | Select-Object -First $first
    }
    if($last -gt 0)
    {
        $items = $items | Select-Object -Last $last
    }

    foreach($item in $items)
    {
        $rarstr = [string]::Format('e "{0}\*.rar" "{1}"', $item.FullName, $DestinationFolder);
        $ps = new-object System.Diagnostics.Process
        $ps.StartInfo.Filename = $RarPath
        $ps.StartInfo.Arguments = $rarstr
        $ps.StartInfo.RedirectStandardOutput = $false
        $ps.StartInfo.UseShellExecute = $false
        $ps.Start()
        #$ps.Exited
        #$ps.WaitForExit()
    }
}

Unpack-items -DestinationFolder "E:\Консультант\RECEIVE" -SourceFolder "Y:\Consultant\Updates"