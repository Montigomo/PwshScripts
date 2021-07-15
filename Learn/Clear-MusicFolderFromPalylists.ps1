
function Clear-MusicFolderFromPlayLists
{
	[CmdletBinding()]
	Param
	(
		[Parameter(mandatory=$true,ValueFromPipeline=$true)]
		[ValidateSet('D:\\music')]
		[string]$MusicFolderPath
	)
	Process 
	{
		$playlistsfolder = [System.IO.Path]::Combine($MusicFolderPath, "\\Playlists")
		$templists = Get-ChildItem -Recurse -Path $MusicFolderPath | Where-Object { ($_.Extension -eq ".m3u") -and ($_.FullName  -notmatch $playlistsfolder)}
		foreach ($row in $templists)
		{
				#$row.FullName
			Remove-Item  -LiteralPath $row.FullName -Force -ErrorAction SilentlyContinue -Verbose
		}
	}
}