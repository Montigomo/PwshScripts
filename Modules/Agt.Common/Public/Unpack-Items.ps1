function Unpack-items
{
    <#
    .SYNOPSIS
    .DESCRIPTION
        Unpacks archives from source folder to destination. In source folder files (archives) sorts in alphabetical and then this order used for select what files will be unpacked.

    .PARAMETER DestinationFolder
        Folder to where archives will be unpacked

        Required?                    true
        Position?                    0
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?
    .PARAMETER SourceFolder
      Folder where archives are located

        Required?                    true
        Position?                    0
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?      
    .PARAMETER RarPath 
        Path to unpacker programm
    .PARAMETER First
        How many archives unpack from first (in alphabetical archives list)
    .PARAMETER Last
        How many archives unpack from last (in alphabetical archives list)
    .PARAMETER Skip
        How many archives skip from first (in alphabetical archives list)
    .PARAMETER SkipLast
        How many archives unpack from last (in alphabetical archives list)      
    .INPUTS
    .OUTPUTS
    .EXAMPLE
        Unpack-items -DestinationFolder "***" -SourceFolder "***" -First 3 -Last 3 -Skip 2 -SkipLast 1
        fileA (skipped  [-Skip 2])
        fileB (skipped  [-Skip 2])
        fileC (unpacked [-First 3])
        fileD (unpacked [-First 3])
        fileE (unpacked [-First 3])
        fileF (nor prepared)
        fileG (nor prepared)
        ...
        fileV (nor prepared)
        fileW (unpacked [-Last 3])
        fileX (unpacked [-Last 3])
        fileY (unpacked [-Last 3])
        fileZ (skipped  [-SkipLast 1])
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

    # [X500:/C=CountryCode/O=Organization/OU=OrganizationUnit/CN=CommonName]
    $subject = (Get-PfxCertificate "C:\Program Files\WinRAR\WinRAR.exe").Subject
    if($subject -match 'O=(?<org>[^\,]*)\,?')
    {
        $org = $Matches["org"];
    }

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