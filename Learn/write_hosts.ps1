0#@echo off

#SET NEWLINE=^& echo.
#
# Powershell script for adding/removing/showing entries to the hosts file.
#
# Known limitations:
# - does not handle entries with comments afterwards ("<ip>    <host>    # comment")
#

$file = "C:\Windows\System32\drivers\etc\hosts"



$entries = @{
"activate.adobe.com" = "127.0.0.1";
"practivate.adobe.com" = "127.0.0.1";
"lmlicenses.wip4.adobe.com" = "127.0.0.1";
"lm.licenses.adobe.com" = "127.0.0.1";
"na1r.services.adobe.com" = "127.0.0.1";
"hlrcv.stage.adobe.com" = "127.0.0.1"
"activate-sea.adobe.com" = "127.0.0.1";
"activate-sjc0.adobe.com" = "127.0.0.1";
"ereg.adobe.com" = "127.0.0.1";
"activate.wip3.adobe.com" = "127.0.0.1";
"wip3.adobe.com" = "127.0.0.1";
"ereg.wip3.adobe.com" = "127.0.0.1";
"wwis-dubc1-vip60.adobe.com" = "127.0.0.1"
}

function add-host([string]$filename, [string]$ip, [string]$hostname) {
	remove-host $filename $hostname
	$ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $filename
}

function remove-host([string]$filename, [string]$hostname) {
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

function print-hosts([string]$filename) {
	$c = Get-Content $filename
	
	foreach ($line in $c) {
		$bits = [regex]::Split($line, "\t+")
		if ($bits.count -eq 2) {
			Write-Host $bits[0] `t`t $bits[1]
		}
	}
}

try {
	if ($args[0] -eq "add") {
	
		if ($args.count -lt 3) {
			throw "Not enough arguments for add."
		} else {
			add-host $file $args[1] $args[2]
		}
		
	} elseif ($args[0] -eq "remove") {
	
		if ($args.count -lt 2) {
			throw "Not enough arguments for remove."
		} else {
			remove-host $file $args[1]
		}
		
	} elseif ($args[0] -eq "show") {
		print-hosts $file
	} else {
		throw "Invalid operation '" + $args[0] + "' - must be one of 'add', 'remove', 'show'."
	}
} catch  {
	Write-Host $error[0]
	Write-Host "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>`n       hosts show"
}


#FIND /C /I "activate.adobe.com" %WINDIR%\system32\drivers\etc\hosts
#IF %ERRORLEVEL% NEQ 0 ECHO %NEWLINE%^62.116.159.4 ns1.intranet.de>>%WINDIR%\System32\drivers\etc\hosts


