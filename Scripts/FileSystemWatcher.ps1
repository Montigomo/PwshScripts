$folder = $home 
$filter = '*'  
 
 
try
{
   $fsw = New-Object System.IO.FileSystemWatcher $folder , $filter -ErrorAction Stop
}
catch [System.ArgumentException]
{
   Write-Warning "Oops: $_"
   return
}
 
$fsw.IncludeSubdirectories = $true
$fsw.NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
 
do
{
   $result = $fsw.WaitForChanged([ System.IO.WatcherChangeTypes]::All, 1000)
   if ($result.TimedOut) { continue }
   
   $result
   Write-Host "Change in $($result.Name) - $( $result.ChangeType)"
 
} while ($true)