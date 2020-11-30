

$folder = "C:\Users\agite\OneDrive\Powershell\Scripts\Functions\{0}.ps1"

$modules = @(
    "Set-Audio"
)

foreach($item in $modules)
{
    if(!(get-Module $item))
    {
        Import-Module -Name ($folder -f $item)
    }
}



$outSrting = '
$folder = "{0}{{0}}.ps1"

$modules = @(
    {1}
)

foreach($item in $modules)
{
    if(!(get-Module $item))
    {
        Import-Module -Name ($folder -f $item)
    }
}'