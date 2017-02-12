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

$file = "C:\Windows\System32\drivers\etc\hosts"

function Add-Host([string]$filename, [string]$ip, [string]$hostname)
{
	remove-host $filename $hostname
	$ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $filename
}

function Remove-Host([string]$filename, [string]$hostname)
{
	$c = Get-Content $filename
	$newLines = @()
	
	foreach ($line in $c) {
		$bits = [regex]::Split($line, "\t+")
		if ($bits.count -eq 2) {
			if ($bits[1] -ne $hostname) {
				$newLines += $line
			}
		} else {
			$newLines += $line
		}
	}
	
	# Write file
	Clear-Content $filename
	foreach ($line in $newLines) {
		$line | Out-File -encoding ASCII -append $filename
	}
}

function Print-Hosts([string]$filename) 
{
	$c = Get-Content $filename
	
	foreach ($line in $c) {
		$bits = [regex]::Split($line, "\t+")
		if ($bits.count -eq 2) {
			Write-Host $bits[0] `t`t $bits[1]
		}
	}
}

# Uncomment lines with localhost on them:
#$hosts = $hosts | Foreach {if ($_ -match '^\s*#\s*(.*?\d{1,3}.*?localhost.*)') {$matches[1]} else {$_}}
#$hosts | Out-File $hostsPath -enc ascii
# Comment lines with localhost on them:
#$hosts = get-content $hostsPath
#$hosts | Foreach {if ($_ -match '^\s*([^#].*?\d{1,3}.*?localhost.*)')       {"# " + $matches[1]} else {$_}}
#$hosts |      Out-File $hostsPath -enc ascii
#$hosts
#print-hosts($file)
#$hosts = $hosts | Foreach {if ($_ -match '(?<ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)\s+(?<host>[^\s]+)') {$Matches["ip"]} else {}}


if((Test-Path variable:global:hostsPath) -eq $false) {$hostsPath = "$env:windir\System32\drivers\etc\hosts"}

$hosts = get-content $hostsPath

$hostsDictionary = @{}

function GetHosts()
{
	foreach($line in $hosts)
	{
		if ($line -match '(?<ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)\s+(?<host>[^\s]+)')
		{
			#$Matches["ip"] + " - " + $Matches["host"]
			if(-not $hostsDictionary.ContainsKey($Matches["host"]))
			{
				$hostsDictionary.Add($Matches["host"], $Matches["ip"])
			}
		}
	}
}

foreach($line in $hostsDictionary.Keys)
{
	$line + " = " + $hostsDictionary[$line]
}