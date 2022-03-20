
#process.StartInfo = new ProcessStartInfo("powershell.exe", String.Format(@" -NoProfile -ExecutionPolicy unrestricted -encodedCommand ""{0}""",encodedCommand))
#               {
#                   WorkingDirectory = executablePath,
#                   UseShellExecute = false,
#                   CreateNoWindow = true
#               };



$onedrive = Get-KnownFolderPath -KnownFolder OneDriveFolder

# Windows before 10
#(Get-ItemProperty -Path "hkcu:\Software\Microsoft\Windows\CurrentVersion\SkyDrive\" -Name UserFolder).UserFolder
# Windows 10
#(Get-ItemProperty -Path "hkcu:\Software\Microsoft\OneDrive\" -Name UserFolder).UserFolder


$scriptPath = "{0}\Powershell\Scripts\Get-NetTools.ps1" -f $onedrive

start-process PowerShell.exe -arg $scriptPath -WindowStyle Hidden