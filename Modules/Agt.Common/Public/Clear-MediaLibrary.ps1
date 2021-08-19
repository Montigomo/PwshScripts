
function Clear-MediaLibrary
{
    [CmdletBinding()]
    param()
    if(get-service "WMPNetworkSvc*" -ne $null)
    {
        Get-Service "WMPNetworkSvc" | Stop-Service 

    }

    # CurrentDatabase_***.wmdb and LocalMLS_*.wmdb

    $folder = "$env:USERPROFILE\AppData\Local\Microsoft\Media Player\"

    $items = Get-ChildItem $folder -Filter CurrentDatabase_*.wmdb

    foreach($item in $items)
    {
        $item.Delete();
    }

    $items = Get-ChildItem $folder -Filter LocalMLS_*.wmdb

    foreach($item in $items)
    {
        $item.Delete();
    }
}