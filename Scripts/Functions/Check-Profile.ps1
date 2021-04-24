#
# $prefix - 
# $folder - folder path with modules that need import
# [CmdletBinding()]
param(
    [string]$prefix,
    [string]$folder
    )

$outSrting = '
$folder = "{0}\{{0}}.ps1"

$modules = @(
    {1}
)

foreach($item in $modules)
{{
    if(!(Get-Module $item))
    {{
        Import-Module -Name ($folder -f $item)
    }}
}}'

# Write-Host ("prefix {0}  -  folder {1}" -f $prefix, $folder)

if(!($folder) -or !(Test-Path $folder))
{
    $folder = $PSScriptRoot
}

Write-Host  (Get-ChildItem -Path ("{0}\*.ps1" -f $folder))

$items = Get-ChildItem -Path ("{0}\*.ps1" -f $folder) #> $null
$arraystr = ""
foreach($item in $items) #item type is System.IO.FileSystemInfo
{
    # if(!(get-Module ([System.IO.Path]::GetFileNameWithoutExtension($item.Name))) -and !($item.FullName -eq $PSCommandPath))
    # {
    if(!($item.FullName -eq $PSCommandPath))
    {
        $val = ([System.IO.Path]::GetFileNameWithoutExtension($item.Name))
        #Import-Module -Name ($item.FullName)
        if($arraystr.Length -eq 0)
        {
            $arraystr += ('"{0}"' -f $val)
        }
        else
        {
            $arraystr += (', "{0}"' -f $val)
        }
    }
    # }
}

$outputFileText = ( $outSrting -f $PSScriptRoot, $arraystr) 
$outputFileText | Out-File -FilePath $profile.AllUsersAllHosts

Write-Output "Profile aaprovement completed"
start-sleep -Seconds 3