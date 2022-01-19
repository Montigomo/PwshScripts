



$items = @("D:\_software\")

foreach($item in $items)
{
    Add-MpPreference -ExclusionPath $item
}
