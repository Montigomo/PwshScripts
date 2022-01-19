

$processes = @(
    "D:\tools\hardware\linx\linx.exe",
    "D:\tools\hardware\RealTemp\RealTemp.exe")

foreach($process in $processes)
{
    if(!(Get-Process | Where { $_.Path -eq $process}))
    {
        Start-Process ($process) -PassThru -ErrorAction SilentlyContinue
    }
}

