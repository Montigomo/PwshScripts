$address = 'Bahnhofstrasse 12, Hannover'
$encoded = [Net.WebUtility]::UrlEncode($address)
$encoded

<#
'One Microsoft Way, Redmond',
'Bahnhofstrasse 12, Hannover, Germany' |
 ForEach-Object -Begin {
    $url = 'https://geocode.xyz'
    $null = Invoke-RestMethod $url -S session
 } -Process {
   $address = $_
   $encoded = [Net.WebUtility]::UrlEncode($address )
   Invoke-RestMethod "$url/${encoded}?json=1" -W $session|
     ForEach-Object {
       [PSCustomObject]@{
         Address = $address
         Long = $_.longt
         Lat = $_.latt
       }
     }
 }
#>

 '52.37799,9.75195' |
 ForEach-Object -Begin {$url='https://geocode.xyz'
   $null = Invoke-RestMethod $url -S session
 } -Process {
   $coord = $_
   Invoke-RestMethod "$url/${address}?geoit=json" -W $session
 }