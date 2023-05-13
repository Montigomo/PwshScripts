

# load WinRT and runtime types
[System.Void][Windows.System.Profile.AnalyticsInfo,Windows.System.Profile,ContentType= WindowsRuntime]
Add-Type -AssemblyName 'System.Runtime.WindowsRuntime'
 
# define call and information to query
[Collections.Generic.List[System.String]]$names = 'DeviceFamily' ,
                      'OSVersionFull',
                      'FlightRing', 
                      'App', 
                      'AppVer'
 
$task = [Windows.System.Profile.AnalyticsInfo]::GetSystemPropertiesAsync($names )
 
# use reflection to find method definition
$definition = [System.WindowsRuntimeSystemExtensions].GetMethods().Where{
    $_.Name -eq 'AsTask' -and 
    $_.GetParameters().Count -eq 1 -and 
    $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' 
}
 
# create generic method
$Method = $definition.MakeGenericMethod( [System.Collections.Generic.IReadOnlyDictionary [System.String,System.String]] )
 
# call async method and wait for completion
$task = $Method.Invoke.Invoke($null , $task)
$null = $task.Wait(-1)
 
# emit output
$task.Result 
