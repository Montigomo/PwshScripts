



# testing whether type exists
$type = 'Management.Automation.Platform' -as [Type ]
$isWPS = $null -eq $type
 
if ($isWPS)
{
  Write-Warning 'Windows PowerShell'
}
else
{
  # query all public properties
  $properties = $type.GetProperties().Name
  $properties | ForEach-Object -Begin { $hash = @{} } -Process { 
$hash[$_] = $type::$_  
} -End { $hash }
} 