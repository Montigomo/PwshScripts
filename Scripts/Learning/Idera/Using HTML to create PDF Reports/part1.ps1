

$path = "$env:temp\report.html"
 
# get data from any cmdlet you wish
$data = Get-Service | Sort-Object -Property Status, Name
 
# compose style sheet
$stylesheet = "
<style>
body { background-color:#AAEEEE;
font-family:Monospace;
font-size:10pt; }
table,td, th { border:1px solid blue;}
th { color:#00008B;
background-color:#EEEEAA; 
font-size: 12pt;}
table { margin-left:30px; }
h2 {
font-family:Tahoma;
color:#6D7B8D;
}
h1{color:#DC143C;}
h5{color:#DC143C;}
</style>
"
 
# output to HTML
$data | ConvertTo-Html -Title Report -Head $stylesheet | Set-Content -Path $path -Encoding UTF8
 
Invoke-Item -Path $path 