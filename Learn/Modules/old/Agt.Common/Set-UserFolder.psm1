
function Set-UserFolder
{
    Param (
            [Parameter(Mandatory = $true)]
            [ValidateSet('Favorites')]
            [string]$KnownFolder,

            [Parameter(Mandatory = $true)]
            [string]$Path
    )
	$regKeyPath = @(
		"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders",
		"HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders")
	
	$userFolders = @{
        "Favorites" = @("Favorites", (Join-Path $regKeyPath[0] "Favorites"), (Join-Path $regKeyPath[1] "Favorites"))
		#("My Pictures", (Join-Path $destFolder "Pictures")),
		#("Personal", (Join-Path $destFolder "Documents")),
		#("My Music", "D:\music")
		#("Desktop", (Join-Path $destFolder "Desktop"))
	}

	$useReg = $false
	
	$removeErrors = @()
    $regPathName = ""

	if([System.Environment]::OSVersion.Version -lt (New-Object 'Version' 6.1))
	{
		Read-Host "Unsupported OS version. Press any key to exit..."
		exit
	}
    
    if([System.IO.Directory]::Exists($Path) -eq $false)
    {
	#	[System.IO.Directory]::CreateDirectory($value[1])
	#	Read-Host "Folder doesn't exist"
	#	exit
	}

    foreach($regPath in $regKeyPath)
    {
        $regPathName = $userFolders[$KnownFolder][0]

        $regValue = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Select -expandproperty $regPathName
        Set-ItemProperty $regPath -Name $regPathName -Value $Path

		#if($regValueA -ne $regValueB)
		#{
		#	Write-Error "$regValueA not equal to $regValueB"
		#}
		#$directory = Get-Item $srcDirRegistry
		#$targetJunctionPath = Get-SymbolicLinkTarget($directory.FullName)
		#if($targetJunctionPath -ne  $destPath)
		#{
		#	"$targetJunctionPath --- {0}" -f $destPath
		#	$srcDirRegistry
		#	#continue
		#	try
		#	{
		#		New-Junction $srcDirRegistry $destPath  -ErrorVariable removeErrors -ErrorAction SilentlyContinue | Out-Null
		#	}
		#	catch
		#	{
		#		if($removeErrors.Message -like '*it is being used by another process*')
		#		{
		#			try
		#			{
		#				Remove-Item $srcDirRegistry -Force
		#				New-Junction $srcDirRegistry $destPath -ErrorVariable removeErrors
		#			}
		#			catch
		#			{
		#				Write-Host $removeErrors.Message
		#			}
		#		}
		#	}
		#$removeErrors
		#break
		#Test-Path $value[1]
		#}
    }
}
