
# how many folders from last (include) if 0 all folders will be  unpacked
$last = 5;
$rarPath = "C:\Program Files\WinRAR\Rar.exe";
$fedFolder = "Федеральный\updates";
$regFolder = "Региональный\updates";
$rootFolder =  $PSScriptRoot;

# folder from which files be unpacked
#$path = [System.IO.Path]::Combine($rootFolder, $fedFolder);
$path = [System.IO.Path]::Combine($rootFolder, $regFolder);

$rarstr = 'rar e -or {0} {1}'

$dstfolder = 'E:\Консультант\RECEIVE'

$items = Get-ChildItem -Directory -Path $path 

if($last -gt 0)
{
    $items = Get-ChildItem -Directory -Path $path | Sort-Object -Property Name | Select-Object -Last $last
}

foreach($item in $items)
{
    $rarstr = [string]::Format('e "{0}\*.rar" "{1}"', $item.FullName, $dstfolder);
    $ps = new-object System.Diagnostics.Process;
    $ps.StartInfo.Filename = $rarPath;
    $ps.StartInfo.Arguments = $rarstr;
    $ps.StartInfo.RedirectStandardOutput = $false;
    $ps.StartInfo.UseShellExecute = $false;
    $ps.Start();
    #$ps.Exited;
    #$ps.WaitForExit();
}
