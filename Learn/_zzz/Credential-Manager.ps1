Names default to here(1);

loadmodule = "
		if (!(Get-Module -ListAvailable -Name CredentialManager)) {
			Install-Module CredentialManager -force -Scope CurrentUser
		}
		";


//Function to run command in powershell, strips trailing line breaks
RunPowershell = Function( {command},
	Regex(RunProgram(
		Executable( "powershell.exe" ),
		Options( {"/c", command } ),
		ReadFunction( "text" )
	), "^(.*?)[\r\n]+$", "\1")
);


// Set password
SetPass = Function( {target,user,pass},
	RunPowershell(
		"$target = '" || target || "'
		$usr = '" || user || "'
		$pswd = '" || pass || "'
		" || loadmodule || "
		New-StoredCredential -Target $target -UserName $usr -Password $pswd -Persist LocalMachine
	);
	1; //password is returned as free text, don't return the response
);

// Get password
GetPass = Function( {target},
	RunPowershell(
		"$target = '" || target || "'
		" || loadmodule || "
		$creds = Get-StoredCredential -Target $target

		$creds.GetNetworkCredential().Password"
	)
);

// Get username
GetUser = Function( {target},
	RunPowershell(
		"$target = '" || target || "'
		" || loadmodule || "
		$creds = Get-StoredCredential -Target $target

		$creds.GetNetworkCredential().UserName"
	)
);