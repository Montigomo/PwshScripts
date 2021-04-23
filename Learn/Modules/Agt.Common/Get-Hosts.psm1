<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER HostsPath
.INPUTS
.OUTPUTS
.EXAMPLE
.NOTES
.LINK
#>

function Get-Hosts
{
    [OutputType([System.Collections.Hashtable])]
    Param
    (
    [Parameter(ValueFromPipeline=$true)]
    [String]$HostsPath = "$env:windir\System32\drivers\etc\hosts"
    )

    $hosts = get-content $HostsPath

   	$hostsTable = @{}

    foreach($line in $hosts)
	{
		if($line -match '(?<cm>\#\s*)?(?<ip>\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b)\s+(?<host>[^\s]+)')
		{
			if(-not $hostsTable.ContainsKey($matches['host']))
			{
                #Write-Host  ($matches['cm'].Trim() ).GetType()

                $ips = if($matches['cm'] -ne $null) { $matches['cm'].Trim() + $matches['ip'].Trim()} else {$matches['ip'].Trim()}
				$hostsTable.Add($matches['host'].Trim(), $ips)

				#$line		
			}
		}
	}
    $hostsTable
}

function Merge-HashTable {
    param(
        [hashtable] $default, # your original set
        [hashtable] $uppend # the set you want to update/append to the original set
    )

    # clone for idempotence
    $default1 = $default.Clone() ;

    # remove any keys that exists in original set
    foreach ($key in $uppend.Keys) {
        if ($default1.ContainsKey($key)) {
            $default1.Remove($key) ;
        }
    }

    # union both sets
    return $default1 + $uppend ;
}

function Write-Hosts
{
    Param
    (
    [Parameter(ValueFromPipeline=$true, Mandatory = $true)]
    [System.Collections.Hashtable]$Hosts,

    [Parameter(ValueFromPipeline=$true)]
    [String]$HostsPath = "$env:windir\System32\drivers\etc\hosts"
    )

    $sb = New-Object -TypeName "System.Text.StringBuilder";
    [void]$sb.Append([System.Environment]::NewLine + "# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.");
    [void]$sb.Append([System.Environment]::NewLine + "# Writed by Write-Hosts PS cmdlet." + [System.Environment]::NewLine + [System.Environment]::NewLine);
    $sip = "{0}`t`t`t`t{1}`t`t{2}"

    foreach($key in $hosts.Keys)
	{
        [void]$sb.AppendFormat($sip, $hosts[$key], $key, [System.Environment]::NewLine ) 
	}
    
    $sb.ToString() | Out-File -FilePath $HostsPath
}

