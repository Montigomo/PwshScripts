

function Pin-App
{
    param(
        [string]$appname,
        [switch]$unpin
    )
    try
    {
        $shellVar = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}');
        if ($unpin.IsPresent)
        {
            ($shellVar.Items() | 
            Where-Object{$_.Name -eq $appname}).Verbs() | 
            Where-Object{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | 
            ForEach-Object{$_.DoIt()}
            return "App '$appname' unpinned from Start"
        }
        else
        {
            ($shellVar.Items() | ?{$_.Name -eq $appname}).Verbs() | Where-Object{$_.Name.replace('&','') -match 'To "Start" Pin|Pin to Start'} | ForEach-Object{$_.DoIt()}
            return "App '$appname' pinned to Start"
        }
    }
    catch
    {
        Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
    }
}