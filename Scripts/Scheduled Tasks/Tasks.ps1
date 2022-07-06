
$folder = $PSScriptRoot;
$skipExist = $false;
$tasksNames = @{'RTP' = "RTP"; 'test' = "test"};
$tasks = Get-ScheduledTask;
#$tasks.GetType();

foreach($name in $tasksNames.GetEnumerator())
{
    $fileName = "$($folder)\$($name.Key).xml";
    
    $tv = $tasks.Where{ $_.TaskName -eq $name.Key};
    
    if(($tv -and (-not $skipExist)) -or (-not $tv))
    {
        #Write-Output $tv;
        if(Test-Path $fileName)
        {

          Register-ScheduledTask -Xml (Get-Content $fileName | Out-String) -TaskName $name.Key

          Write-Host "Task - $($name.Key) $($name.Value) added." -ForegroundColor Green;

        }
    }
}