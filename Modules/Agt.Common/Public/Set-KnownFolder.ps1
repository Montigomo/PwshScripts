
# Known folders IDs - https://msdn.microsoft.com/en-us/library/windows/desktop/dd378457(v=vs.85).aspx

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace KnownFolders
{
	public static class KnownFolder
	{
		public static readonly Dictionary<string, Guid> Kguids = new Dictionary<string, Guid>
		{
			{"AddNewPrograms", new Guid("de61d971-5ebc-4f02-a3a9-6c82895e5c04") },
			{"AdminTools", new Guid("724EF170-A42D-4FEF-9F26-B60E846FBA4F") },
			{"AppUpdates", new Guid("a305ce99-f527-492b-8b1a-7e76fa98d6e4") },
			{"CDBurning", new Guid("9E52AB10-F80D-49DF-ACB8-4330F5687855") },
			{"ChangeRemovePrograms", new Guid("df7266ac-9274-4867-8d55-3bd661de872d") },
			{"CommonAdminTools", new Guid("D0384E7D-BAC3-4797-8F14-CBA229B392B5") },
			{"CommonOEMLinks", new Guid("C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D") },
			{"CommonPrograms", new Guid("0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8") },
			{"CommonStartMenu", new Guid("A4115719-D62E-491D-AA7C-E74B8BE3B067") },
			{"CommonStartup", new Guid("82A5EA35-D9CD-47C5-9629-E15D2F714E6E") },
			{"CommonTemplates", new Guid("B94237E7-57AC-4347-9151-B08C6C32D1F7") },
			{"ComputerFolder", new Guid("0AC0837C-BBF8-452A-850D-79D08E667CA7") },
			{"ConflictFolder", new Guid("4bfefb45-347d-4006-a5be-ac0cb0567192") },
			{"ConnectionsFolder", new Guid("6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD") },
			{"Contacts", new Guid("56784854-C6CB-462b-8169-88E350ACB882") },
			{"ControlPanelFolder", new Guid("82A74AEB-AEB4-465C-A014-D097EE346D63") },
			{"Cookies", new Guid("2B0F765D-C0E9-4171-908E-08A611B84FF6") },
			{"Desktop", new Guid("B4BFCC3A-DB2C-424C-B029-7FE99A87C641") },
			{"Documents", new Guid("FDD39AD0-238F-46AF-ADB4-6C85480369C7") },
			{"Downloads", new Guid("374DE290-123F-4565-9164-39C4925E467B") },
			{"Favorites", new Guid("1777F761-68AD-4D8A-87BD-30B759FA33DD") },
			{"FOLDERID_SkyDrive", new Guid("A52BBA46-E9E1-435f-B3D9-28DAA648C0F6") },
			{"Fonts", new Guid("FD228CB7-AE11-4AE3-864C-16F3910AB8FE") },
			{"Games", new Guid("CAC52C1A-B53D-4edc-92D7-6B2E8AC19434") },
			{"GameTasks", new Guid("054FAE61-4DD8-4787-80B6-090220C4B700") },
			{"History", new Guid("D9DC8A3B-B784-432E-A781-5A1130A75963") },
			{"InternetCache", new Guid("352481E8-33BE-4251-BA85-6007CAEDCF9D") },
			{"InternetFolder", new Guid("4D9F7874-4E0C-4904-967B-40B0D20C3E4B") },
			{"Links", new Guid("bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968") },
			{"LocalAppData", new Guid("F1B32785-6FBA-4FCF-9D55-7B8E7F157091") },
			{"LocalAppDataLow", new Guid("A520A1A4-1780-4FF6-BD18-167343C5AF16") },
			{"LocalizedResourcesDir", new Guid("2A00375E-224C-49DE-B8D1-440DF7EF3DDC") },
			{"Music", new Guid("4BD8D571-6D19-48D3-BE97-422220080E43") },
			{"NetHood", new Guid("C5ABBF53-E17F-4121-8900-86626FC2C973") },
			{"NetworkFolder", new Guid("D20BEEC4-5CA8-4905-AE3B-BF251EA09B53") },
      		{"OneDriveFolder", new Guid("A52BBA46-E9E1-435f-B3D9-28DAA648C0F6")},
			{"OriginalImages", new Guid("2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39") },
			{"PhotoAlbums", new Guid("69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C") },
			{"Pictures", new Guid("33E28130-4E1E-4676-835A-98395C3BC3BB") },
			{"Playlists", new Guid("DE92C1C7-837F-4F69-A3BB-86E631204A23") },
			{"PrintersFolder", new Guid("76FC4E2D-D6AD-4519-A663-37BD56068185") },
			{"PrintHood", new Guid("9274BD8D-CFD1-41C3-B35E-B13F55A758F4") },
			{"Profile", new Guid("5E6C858F-0E22-4760-9AFE-EA3317B67173") },
			{"ProgramData", new Guid("62AB5D82-FDC1-4DC3-A9DD-070D1D495D97") },
			{"ProgramFiles", new Guid("905e63b6-c1bf-494e-b29c-65b732d3d21a") },
			{"ProgramFilesX64", new Guid("6D809377-6AF0-444b-8957-A3773F02200E") },
			{"ProgramFilesX86", new Guid("7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E") },
			{"ProgramFilesCommon", new Guid("F7F1ED05-9F6D-47A2-AAAE-29D317C6F066") },
			{"ProgramFilesCommonX64", new Guid("6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D") },
			{"ProgramFilesCommonX86", new Guid("DE974D24-D9C6-4D3E-BF91-F4455120B917") },
			{"Programs", new Guid("A77F5D77-2E2B-44C3-A6A2-ABA601054A51") },
			{"Public", new Guid("DFDF76A2-C82A-4D63-906A-5644AC457385") },
			{"PublicDesktop", new Guid("C4AA340D-F20F-4863-AFEF-F87EF2E6BA25") },
			{"PublicDocuments", new Guid("ED4824AF-DCE4-45A8-81E2-FC7965083634") },
			{"PublicDownloads", new Guid("3D644C9B-1FB8-4f30-9B45-F670235F79C0") },
			{"PublicGameTasks", new Guid("DEBF2536-E1A8-4c59-B6A2-414586476AEA") },
			{"PublicMusic", new Guid("3214FAB5-9757-4298-BB61-92A9DEAA44FF") },
			{"PublicPictures", new Guid("B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5") },
			{"PublicVideos", new Guid("2400183A-6185-49FB-A2D8-4A392A602BA3") },
			{"QuickLaunch", new Guid("52a4f021-7b75-48a9-9f6b-4b87a210bc8f") },
			{"Recent", new Guid("AE50C081-EBD2-438A-8655-8A092E34987A") },
			{"RecycleBinFolder", new Guid("B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC") },
			{"ResourceDir", new Guid("8AD10C31-2ADB-4296-A8F7-E4701232C972") },
			{"RoamingAppData", new Guid("3EB685DB-65F9-4CF6-A03A-E3EF65729F3D") },
			{"SampleMusic", new Guid("B250C668-F57D-4EE1-A63C-290EE7D1AA1F") },
			{"SamplePictures", new Guid("C4900540-2379-4C75-844B-64E6FAF8716B") },
			{"SamplePlaylists", new Guid("15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5") },
			{"SampleVideos", new Guid("859EAD94-2E85-48AD-A71A-0969CB56A6CD") },
			{"SavedGames", new Guid("4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4") },
			{"SavedSearches", new Guid("7d1d3a04-debb-4115-95cf-2f29da2920da") },
			{"SEARCH_CSC", new Guid("ee32e446-31ca-4aba-814f-a5ebd2fd6d5e") },
			{"SEARCH_MAPI", new Guid("98ec0e18-2098-4d44-8644-66979315a281") },
			{"SearchHome", new Guid("190337d1-b8ca-4121-a639-6d472d16972a") },
			{"SendTo", new Guid("8983036C-27C0-404B-8F08-102D10DCFD74") },
			{"SidebarDefaultParts", new Guid("7B396E54-9EC5-4300-BE0A-2482EBAE1A26") },
			{"SidebarParts", new Guid("A75D362E-50FC-4fb7-AC2C-A8BEAA314493") },
			{"StartMenu", new Guid("625B53C3-AB48-4EC1-BA1F-A1EF4146FC19") },
			{"Startup", new Guid("B97D20BB-F46A-4C97-BA10-5E3608430854") },
			{"SyncManagerFolder", new Guid("43668BF8-C14E-49B2-97C9-747784D784B7") },
			{"SyncResultsFolder", new Guid("289a9a43-be44-4057-a41b-587a76d7e7f9") },
			{"SyncSetupFolder", new Guid("0F214138-B1D3-4a90-BBA9-27CBC0C5389A") },
			{"System", new Guid("1AC14E77-02E7-4E5D-B744-2EB1AE5198B7") },
			{"SystemX86", new Guid("D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27") },
			{"Templates", new Guid("A63293E8-664E-48DB-A079-DF759E0509F7") },
			{"TreeProperties", new Guid("5b3749ad-b49f-49c1-83eb-15370fbd4882") },
			{"UserProfiles", new Guid("0762D272-C50A-4BB0-A382-697DCD729B80") },
			{"UsersFiles", new Guid("f3ce0f7c-4901-4acc-8648-d5d44b04ef8f") },
			{"Videos", new Guid("18989B1D-99B5-455B-841C-AB7C74E4DDFC") },
			{"Windows", new Guid("F38BF404-1D43-42F2-9305-67DE0B28FC23") }
		};

		[DllImport("shell32.dll", CharSet = CharSet.Unicode)]
		private static extern int SHGetKnownFolderPath(
		 [MarshalAs(UnmanagedType.LPStruct)] Guid rfid,
		 uint dwFlags,
		 IntPtr hToken,
		 out IntPtr pszPath);

		[DllImport("shell32.dll", CharSet = CharSet.Unicode)]
		public extern static int SHSetKnownFolderPath(
			[MarshalAs(UnmanagedType.LPStruct)] Guid rfid,  //ref Guid folderId,
			uint flags,
			IntPtr token,
			[MarshalAs(UnmanagedType.LPWStr)] string path);

		public static string GetKnownFolderPath(Guid rfid)
		{
			IntPtr pszPath;
			if (SHGetKnownFolderPath(rfid, 0, IntPtr.Zero, out pszPath) != 0)
				return ""; // add whatever error handling you fancy
			string path = Marshal.PtrToStringUni(pszPath);
			Marshal.FreeCoTaskMem(pszPath);
			return path;
		}

		public static int SetKnownFolderPath(Guid rfid, string path)
		{
			return SHSetKnownFolderPath(rfid, 0, IntPtr.Zero, path);
		}
	}
}
"@

$arr = New-Object -TypeName "string[]" -ArgumentList ([KnownFolders.KnownFolder]::Kguids.Keys.Count)
[KnownFolders.KnownFolder]::Kguids.Keys.CopyTo($arr,0)
function Set-KnownFolderPath {
	<#
	.SYNOPSIS
		Sets a known folder's path using SHSetKnownFolderPath.
	.PARAMETER Folder
		The known folder name whose path need to set.
	.PARAMETER Path
		The path to new folder location.
	.NOTES
		Name: Set-KnownFolderPath
		Author: Agitech
	.EXAMPLE
		Set-KnownFolderPath -KnownFolder Desktop -Path 'D:\Desktop'
	#>
	Param (
		[Parameter(Mandatory = $true)]
		[ArgumentCompleter({param($cmd, $param, $wordToComplete) $arr -like "$wordToComplete*"})]		
		[ValidateScript({
			if ($_ -in $arr) { return $true }
			throw "'$_' is not in the set of the supported values: $($arr -join ', ')"
		  })]
		[string]$KnownFolder,

		[Parameter(Mandatory = $true)]
		[string]$Path
    )
    [bool]$result = $false;
    if ((Test-Path $Path -PathType Container))
    {
        if([KnownFolders.KnownFolder]::SetKnownFolderPath([KnownFolders.KnownFolder]::Kguids[$KnownFolder],$Path) -eq 0)
        {
            $result = $true
        }
    }
    else
    {
        $result = $false;
    }
    return $result;
}

function Get-KnownFolderPath {
	<#
	.SYNOPSIS
		Get a known folder's path using SHGetKnownFolderPath.
	.PARAMETER Folder
		The known folder name whose path to get.
	.NOTES
		Name: Get-KnownFolderPath
		Author: Agitech
	.EXAMPLE
		Get-KnownFolderPath -KnownFolder Desktop
	#>
	Param (
		[Parameter(Mandatory = $true)]
		[ArgumentCompleter({param($cmd, $param, $wordToComplete) $arr -like "$wordToComplete*"})]		
		[ValidateScript({
			if ($_ -in $arr) { return $true }
			throw "'$_' is not in the set of the supported values: $($arr -join ', ')"
		  })]
		[string]$KnownFolder
    )
    return [KnownFolders.KnownFolder]::GetKnownFolderPath([KnownFolders.KnownFolder]::Kguids[$KnownFolder]);
}