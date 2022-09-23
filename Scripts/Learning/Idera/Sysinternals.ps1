


function Download-Sysinternals
{
    $destinationZipPath = "$env:temp\pstools.zip"
    $destinationFolder  = "$env:temp\pstools"
    
    $link = "https://download.sysinternals.com/files/PSTools.zip "
    Invoke-RestMethod -Uri $link -OutFile $destinationZipPath  -UseBasicParsing
    Unblock-File -Path $destinationZipPath
    Expand-Archive -Path $destinationZipPath -DestinationPath $destinationFolder  -Force
    Remove-Item -Path $destinationZipPath
    
    explorer /select,$destinationFolder
}

#
$path = "Registry::HKEY_CURRENT_USER\Software\Sysinternals"
$name = 'EulaAccepted'
Set-ItemProperty -Path $path -Name $name  -Value 1