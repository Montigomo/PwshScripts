function Disable-FastStartUp {
	param(
	)

	# /v is the REG_DWORD /t Specifies the type of registry entries /d Specifies the data for the new entry /f Adds or deletes registry content without prompting for confirmation.
	REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d "0" /f
}

function Enable-WakeOnLan {
	[CmdletBinding()]
	param(
		[ciminstance]$NetAdapter
	)

	$paramsSet = @{
		"Wake on Magic Packet"      = "Enabled|On"
		#"Wake on Pattern Match" = ""
		"Shutdown Wake-On-Lan"      = "Enabled"
		"Shutdown Wake Up"          = "Enabled"
		"Energy Efficient Ethernet" = "Disabled|Off"
		"Green Ethernet"            = "Disabled"
	}


	$adapterProperties = Get-NetAdapterAdvancedProperty -InterfaceDescription $NetAdapter.InterfaceDescription #| Where-Object { $params.ContainsKey($_.DisplayName) } | Select-Object -ExpandProperty DisplayName


	#$paramsSet

	$paramsKey = $paramsSet.Keys | Where-Object { [System.Array]::Exists($adapterProperties, ([Predicate[Object]] { param($s) 	 $s.DisplayName -eq $_ })) }


	foreach ($item in $paramsKey) {
		foreach ($value in $paramsSet[$item].Split("|")) {
			try {
				Set-NetAdapterAdvancedProperty -InterfaceDescription $NetAdapter.InterfaceDescription -DisplayName $item -DisplayValue $value -ErrorAction Stop
				break;
			}
			catch [Microsoft.Management.Infrastructure.CimException] {
				Write-Verbose $_.Exception.Message
			}
		}
	}
}


$interface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.ifAlias -eq "Ethernet" }

Enable-WakeOnLan -NetAdapter $interface -Verbose

Disable-FastStartUp

exit