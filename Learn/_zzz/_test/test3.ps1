# this is the URL we got:
#$URLRaw = 'http://go.microsoft.com/fwlink/?LinkID=135173'
# we do not allow automatic redirection and instead read the information
# returned by the webserver ourselves:
#$page = Invoke-WebRequest -Uri $URLRaw -UseBasicParsing -MaximumRedirection 0 -ErrorAction Ignore
#$target = $page.Headers.Location
 
#"$URLRaw -> $target" 


$URLRaw = 'https://github.com/PowerShell/PowerShell/releases/latest'
# we do not allow automatic redirection and instead read the information
# returned by the webserver ourselves:
$page = Invoke-WebRequest -Uri $URLRaw -UseBasicParsing #-MaximumRedirection 0 -ErrorAction Ignore
$realURL = $page.Headers.Location
$version = Split-Path -Path $realURL -Leaf 
 
"PowerShell 7 latest version: $version"