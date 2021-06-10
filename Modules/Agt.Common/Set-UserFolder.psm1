<#
    .SYNOPSIS
        Used to set user folser location

    .PARAMETER KnownFolder
        Any of user folders like Desktop, Pictures, Documents

    .PARAMETER Path
        Path to what need set user folder value

#>
function Set-UserFolder
{
    Param (
		[Parameter(Mandatory = $true)]
		[ValidateSet('Favorites', 'Desktop', 'Pictures', 'Music')]
		[string]$KnownFolder,
		[Parameter(Mandatory = $true)]
		[string]$Path
    )

	$RegistryKeys = @(
		"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
		"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders")
	
	$UserFolders = @{
        "Favorites" = @("Favorites", "Favorites");
		"Desktop" = @("Desktop", "Desktop");
		"Pictures" = @("My Pictures", "My Pictures");
		"Music" = @("My Music","My Music")
	}

	if([System.Environment]::OSVersion.Version -lt (New-Object 'Version' 6.1))
	{
		Read-Host "Unsupported OS version. Press any key to exit..."
		exit
	}

    $RegPath = $RegistryKeys[0]
    $RegValue = $UserFolders[$KnownFolder][0]

    $test = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Select -expandproperty $RegValue

    Set-ItemProperty $RegPath -Name $RegValue -Value $Path

    $RegPath = $RegistryKeys[1]
    $RegValue = $UserFolders[$KnownFolder][1]

    $test = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Select -expandproperty $RegValue

    Set-ItemProperty $RegPath -Name $RegValue -Value $Path
}