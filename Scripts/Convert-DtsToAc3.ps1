[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$SourceFileName
)
Set-StrictMode -Version 3.0

# tune ffmpeg pathes
$ffmpegPath =[IO.Path]::GetFullPath("$PSScriptRoot\..\ffmpeg\bin\ffmpeg.exe")
$ffprobePath = [IO.Path]::GetFullPath("$PSScriptRoot\..\ffmpeg\bin\ffprobe.exe")

if(-not (Test-Path $ffmpegPath) -or -not (Test-Path $ffprobePath)){
	Write-Host "Can't find ffmpeg.exe." -ForegroundColor DarkYellow
	exit
}

function Test-ffmpeg {
	# print info
	#& $ffprobe $inputFile -print_format default > "$PSScriptRoot/input-file-info.txt" 2>&1
	# print info
	#& $ffprobe $outputFile -print_format default > "$PSScriptRoot/output-file-info.txt" 2>&1
}

function EncodeDtsToAc3 {
	param (
		[Parameter(Mandatory = $true)] [string]$SourceFile,
		[Parameter(Mandatory = $true)] [string]$DestinationFile
	)

	# just encode all tracks
	#& $ffmpegPath -i $SourceFile -map 0 -vcodec copy -scodec copy -acodec ac3 -b:a 640k $DestinationFile -loglevel 8 -stats
	& $ffmpegPath -i $SourceFile -vcodec copy -scodec copy -acodec ac3 -b:a 640k $DestinationFile -loglevel 8 -stats
}


$path00 = [System.IO.Path]::GetDirectoryName($SourceFileName)
$path01 = [System.IO.Path]::GetFileNameWithoutExtension($SourceFileName)
$path02 = [System.IO.Path]::GetExtension($SourceFileName)

$DestinationFileName = "$path00\$path01.ac3$path02"

EncodeDtsToAc3 -SourceFile $SourceFileName -DestinationFile $DestinationFileName 	