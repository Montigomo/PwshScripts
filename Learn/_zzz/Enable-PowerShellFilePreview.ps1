function Enable-PowerShellFilePreview
{
   [CmdletBinding()]
   param
   (
       [string]
       $Font = 'Courier New',
       
       [int]
       $FontSize = 60
   )
   
   # set the font and size (also applies to Notepad)
   $path = "HKCU:\Software\Microsoft\Notepad"
   Set-ItemProperty -Path $path -Name lfFaceName -Value $Font
   Set-ItemProperty -Path $path -Name iPointSize -Value $FontSize
   
   # enable the preview of PowerShell files
   $path = 'HKCU:\Software\Classes\.ps1'
   $exists = Test-Path -Path $path
   if (!$exists){
       $null = New-Item -Path $Path 
   }
   $path = 'HKCU:\Software\Classes\.psd1'
   $exists = Test-Path -Path $path
   if (!$exists){
       $null = New-Item -Path $Path 
   }
   
   $path = 'HKCU:\Software\Classes\.psm1'
   $exists = Test-Path -Path $path
   if (!$exists){
       $null = New-Item -Path $Path 
   }
 
   
   Get-Item HKCU:\Software\Classes\* -Include .ps1,.psm1 ,.psd1 | Set-ItemProperty -Name PerceivedType -Value text
}