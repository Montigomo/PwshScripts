# adjust the name of the module
# code will list all commands shipped by that module
# list of all modules: Get-Module -ListAvailable
$ModuleName = "PrintManagement"
$Title = "PowerShell Print Management Commands"
$OutFile = "$env:temp\commands.html";
$OutFile = [Environment]::GetFolderPath("Desktop") + "\commands.html";
$StyleSheet = @"
<title>$Title</title>
<style>
h1, th { text-align: center; font-family: Segoe UI; color:#0046c3;}
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
$Header = "<h1 align='center'>$title</h1>"
Get-Command -Module $moduleName | 
 Get-Help | 
 Select-Object -Property Name, Synopsis |
 ConvertTo-Html -Title $Title -Head $StyleSheet -PreContent $Header |
 Set-Content -Path $OutFile
 
# adjust the name of the module
# code will list all commands shipped by that module
# list of all modules: Get-Module -ListAvailable
$ModuleName = "PrintManagement"
 
$Description = @{
   Name = "Description"
   Expression = { $_.Description.Text -join " " }
}
 
Get-Command -Module $moduleName | 
 Get-Help | 
 Select-Object -Property Name, $Description

Invoke-Item -Path $OutFile