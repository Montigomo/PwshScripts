
# https://localhost:44338/api/GetFile?fileName=Runner.ps1
$uri = "http://192.168.1.101:8080";

function GetUri
{
    #[CmdletBinding()]
    param (
        [Parameter()]
        [string]$FileName
    )
    #$uri = "http://192.168.1.101:8080/GetFile";
    return $uri+"/GetFile?fileName=$FileName";
}

function GetFile
{
        #[CmdletBinding()]
        param (
            [Parameter()]
            [string]$FileName,
            [Parameter()]
            [string]$OutFileName
        )
        $fileUri = GetUri -FileName $FileName
        Invoke-RestMethod -Uri $fileUri -OutFile $OutFileName
}

$destinationFolder = $PSScriptRoot
#$destinationFolder = "C:\Users\agite\OneDrive\Powershell\Learn\coins"

# download files
$thisFileName = "Runner.ps1"

# get files and save its to the disk
$getFilesUri = $uri+"/GetFiles"
$files = Invoke-RestMethod -Uri $getFilesUri

# foreach($item in $files)
# {
#     if($item -ne $thisFileName)
#     {
#         $outFileName = [System.IO.Path]::Combine($destinationFolder, $item);
#         $checkFolder = [System.IO.Path]::GetDirectoryName($outFileName);
#         if(-not (Test-Path $checkFolder))
#         {
#             New-Item -ItemType Directory -Force -Path $checkFolder
#         }
#         $item
#         GetFile -FileName $item -OutFileName $outFileName
#     }
# }




# $fileName = "Runner.ps1"
# $outFolder = $PSScriptRoot
# $outName = [System.IO.Path]::Combine($outFolder, "test", $fileName);
# $fileUri = GetUri $fileName

# $checkFolder = [System.IO.Path]::GetDirectoryName($outName);

# if(-not (Test-Path $checkFolder))
# {
#     New-Item -ItemType Directory -Force -Path $checkFolder
# }

# Invoke-RestMethod -Uri $fileUri -OutFile $outName

### register task

$watcherFileName = [System.IO.Path]::Combine($destinationFolder, "AdobeWatcherX.ps1");

if(Test-Path -Path $watcherFileName)
{
    Invoke-Expression "& `"$watcherFileName`" -action init"
}