
#region Example
# Copyright (c) 1993-2009 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
#      102.54.94.97     rhino.acme.com          # source server
#       38.25.63.10     x.acme.com              # x client host
# localhost name resolution is handled within DNS itself.
#	127.0.0.1       localhost
#	::1             localhost
#endregion

#region Variables & Internal Function 
if((Test-Path variable:global:regexline) -eq $false) 
{
    #"(?<ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)\s+(?<host>[^\s]+)";
    New-Variable -Name regexip4 -Value "(?<ip>(((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])))\s+(?<host>[^\s]+)";
}
if((Test-Path variable:global:hostsPath) -eq $false) 
{
    New-Variable -Name hostsPath -Value "$env:windir\System32\drivers\etc\hosts";
}
if((Test-Path variable:global:hostsDictionary) -eq $false) 
{    New-Variable -Name hostsDictionary -Value @{};}
else{
    $hostsDictionary = @{};
}

# The host file contains lines of text consisting of an IP address in the first text field follewed by one or more host names.
# 127.0.0.1  localhost loopback
# ::1        localhost


function Get-Hosts{
	$lines = Get-Content $hostsPath | Where-Object {-not $_.StartsWith("#")};

    #$rx = [regex]::new($pattern)

    #foreach($item in $rx.Matches($lines))

	foreach ($line in  $lines)
    {
        if($line -match $pattern)
        {
            "$($Matches["ip"]) - $($Matches["host"])";

            if(-not $hostsDictionary.ContainsKey($Matches["host"]))
			{
				$hostsDictionary.Add($Matches["host"], $Matches["ip"])
			}
        }


    	#if ($line -match '(?<ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)\s+(?<host>[^\s]+)')
		#{
		#	#$Matches["ip"] + " - " + $Matches["host"]
		#	if(-not $hostsDictionary.ContainsKey($Matches["host"]))
		#	{
		#		$hostsDictionary.Add($Matches["host"], $Matches["ip"])
		#	}
		#}

        #$bits = [regex]::Split($line, "\s+");
		#if ($bits.count -eq 2){
        #    $bkey = $bits[1];
        #    $bvalue = $bits[0];
        #    if(-not $hostsDictionary.ContainsKey($bkey))
        #    {
        #        $hostsDictionary.Add($bkey, $bvalue);
        #    }
		#}
	}

}

function Write-Hosts{

}

function Test-Hosts {
    if(-not (Test-Path $hostsPath)){return $false;}
    try{
        Get-Hosts;
    }
    catch{
        return $false;
    }
    return $true;
}

Get-Hosts;
#endregion


function Print-Hosts([string]$filename) 
{
    if(Test-Hosts){
	    
	    
    }
}

function Add-Host([string]$hostname, [string]$ip)
{
    if(Test-Hosts){
	    
	    
    }
}


function Remove-Host([string]$hostname)
{
    if(Test-Hosts){
	    
	    
    }
}

