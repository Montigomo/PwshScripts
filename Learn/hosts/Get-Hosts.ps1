

#region Variables & Internal Function 
$debug = $false

# (?<!\s*[\#]\s*)
$regexip4 = "(?<ip>(((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])))";
$RegexEntry = "(?<!#.*)$regexip4\s*(?<host>[^\s]+)(\s*\#.*)?";

#$hostPath = "D:\temp\hosts";

$hostPath = "$env:windir\System32\drivers\etc\hosts";

function Get-Hosts{

    $hostsDictionary = New-Object System.Collections.Specialized.OrderedDictionary

	$lines = Get-Content $hostsPath;

    $count = 0;

    $pattern = $RegexEntry

	foreach ($line in  $lines)
    {
        $ip = $null;
        $hosts = $null;
        if($line -match $pattern)
        {
            $ip = $Matches["ip"];
            $hosts =  $($Matches["host"]);
        }
        $hostsDictionary.Add($count, @{"line" = $line; "host" = $hosts; "ip" = $ip});
        $count++;
	}
    return $hostsDictionary;
}

function Write-Hosts
{
    param
    (
        [ValidateNotNullOrEmpty()]
        [string]$fileName
    )   

    $hosts =  Get-Hosts;
    $arrayList = New-Object System.Collections.ArrayList;
    foreach($item in $hosts.GetEnumerator())
    {
        $arrayList.Add($item.Value["line"]) | Out-Null
    }
    $arrayList | Out-File "D:\temp\hosts"
}


function Remove-Host([string]$hostname)
{

}

#$hosts = Get-Hosts;
# $hosts.GetType()
# ($hosts.GetEnumerator() | Where-Object {$_.Value["ip"]}).Count


Write-Hosts

exit