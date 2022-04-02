


function Get-Package
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $UriSource,
        [Parameter(Mandatory=$true)]
        [string]
        $DestinationPath,
        [Parameter(Mandatory=$false)]
        [ValidateSet("Install", "Unpack")]
        [string]
        $Action,
        [Parameter(Mandatory=$false)]
        [Object]
        $Arguments,
        [Parameter(Mandatory=$false)]
        [switch]
        $AddToPath
    )
    <#

    #>
        
    # create target directory
    [System.IO.Directory]::CreateDirectory($destinationPath)
    #New-Item -ItemType Directory -Path $destPath -Force

    $extension = [System.IO.Path]::GetExtension($UriSource)

    # tmpDA3F.tmp  tmp2A7F.7z
    # create temp with zip extension (or Expand will complain)
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace '.tmp$', $extension } –PassThru
  
    #download
    Invoke-WebRequest -OutFile $tmp $UriSource

    if($Action -eq "Unpack")
    {
        #exract to destination folder 
        #$tmp | Expand-Archive -DestinationPath $destPath -Force
        Add-Type -Assembly System.IO.Compression.FileSystem

        #extract list entries for dir 
        $zip = [IO.Compression.ZipFile]::OpenRead($tmp.FullName)

        $entries = $zip.Entries | Where-Object {-not [string]::IsNullOrWhiteSpace($_.Name) } #| where {$_.FullName -like 'myzipdir/c/*' -and $_.FullName -ne 'myzipdir/c/'} 

        #create dir for result of extraction
        #New-Item -ItemType Directory -Path "c:\temp\c" -Force

        #extraction
        foreach($entry in $entries)
        {
            $dpath = $destPath + $entry.Name
            [IO.Compression.ZipFileExtensions]::ExtractToFile( $entry, $dpath, $true)
        }
        #$entries | ForEach-Object {[IO.Compression.ZipFileExtensions]::ExtractToFile( $_, $destPath + $_.Name, $true) }

        #free object
        $zip.Dispose()

    }

    
    $tmp | Remove-Item    
    
    # set environment path vartiable
    if($addToPath)
    {
        [Environment]::SetEnvironmentVariable("Path",[Environment]::GetEnvironmentVariable("Path", 
        [EnvironmentVariableTarget]::Machine) + ";$DestinationPath",[EnvironmentVariableTarget]::Machine)
    }

    # remove temporary file
}

Get-Package -UriSource "https://www.farmanager.com/files/Far30b5577.x64.20200327.7z" -DestinationPath "D:\temp\5"

#https://www.7-zip.org/a/7z1900-x64.exe