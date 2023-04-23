
function Get-Hosts{
    param(
        [string]$HostsFilePath = "$env:windir\System32\drivers\etc\hosts"
    )
    $regexip4 = "(?<ip>(((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])))";
    
    $RegexEntry = "(?<!#.*)$regexip4\s*(?<host>[^\s]+)(\s*\#.*)?";

    $hostsDictionary = New-Object System.Collections.Specialized.OrderedDictionary

	$lines = Get-Content $HostsFilePath;

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
        [Parameter(Mandatory=$true)]
        [System.Collections.Specialized.OrderedDictionary]$Hosts,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName
    )   

    $directory = [System.IO.Path]::GetDirectoryName($FileName)
    
    if(!(Test-Path $directory))
    {
        return
    }
    
    $arrayList = New-Object System.Collections.ArrayList;
    foreach($item in $Hosts.GetEnumerator())
    {
        $arrayList.Add($item.Value["line"]) | Out-Null
    }
    
    $arrayList | Out-File $FileName
}

function Add-Host
{
    param
    (
        [Parameter(Mandatory=$true)]        
        [string]$HostIp,
        [Parameter(Mandatory=$true)]        
        [string]$HostName,
        [string]$HeaderLine,
        [string]$Comment,
        [string]$HostFileDestination = "D:\temp1\hosts" #$env:windir + "\system32\drivers\etc"
    )

    $hosts = New-Object System.Collections.Specialized.OrderedDictionary
    $hosts = Get-Hosts;
    [ipaddress]$IpAddress = New-Object System.Net.IPAddress(0x7FFFFFFF)
    if([ipaddress]::TryParse($HostIp, [ref]$IpAddress))
    {
        $ExHosts = ($hosts.GetEnumerator() | Where-Object {$_.Value["ip"] -eq $HostIp -and $_.Value["host"] -eq $HostName})
        if($ExHosts.Count -eq 0)
        {
            if($HeaderLine)
            {
                $hosts.Add($count, @{"line" = $line; "host" = $null; "ip" = $null});
            }
            if($Comment.StartsWith("#")){
                $line = "$HostIp $HostName  $Comment"
            }
            else {
                $line = "$HostIp $HostName"                
            }
            $count = $hosts.Count + 1
            $hosts.Add($count, @{"line" = $line; "host" = $hosts; "ip" = $ip});
            Write-Hosts -Hosts $hosts -FileName $HostFileDestination
        }
    }
}

function Remove-Host
{
    param
    (
        [Parameter(Mandatory=$true)]        
        [string]$HostIp,
        [Parameter(Mandatory=$true)]        
        [string]$HostName,
        [string]$HostFileDestination  = "D:\temp1\hosts" #$env:windir + "\system32\drivers\etc"
    )

    $hosts = New-Object System.Collections.Specialized.OrderedDictionary
    $hosts = Get-Hosts;
    [ipaddress]$IpAddress = New-Object System.Net.IPAddress(0x7FFFFFFF)
    if([ipaddress]::TryParse($HostIp, [ref]$IpAddress))
    {
        $ExHosts = ($hosts.GetEnumerator() | Where-Object {$_.Value["ip"] -eq $HostIp -and $_.Value["host"] -eq $HostName})
        if($ExHosts.Count -gt 0)
        {
            foreach($item in $ExHosts)
            {
                $hosts.Remove($item.Key);
            }
            Write-Hosts -Hosts $hosts -FileName $HostFileDestination
        }
    }
}

#$hosts = Get-Hosts;

# 163.172.167.207 bt.t-ru.org
#Add-Host -HostIp "163.172.167.207" -HostName "bt.t-ru.test.org"

#Remove-Host  -HostIp "163.172.167.207" -HostName "bt.t-ru.org"

#Add-Host -HostIp "163.172.167.207" -HostName "bt.t-ru.org"

#Write-Hosts