# author agitch 

$hapPath = $PSScriptRoot + "\assemblies\htmlagilitypack\1.11.16\lib\Net45\HtmlAgilityPack.dll";
#add-type -Path $hapPath


if(-not (Test-Path $hapPath))
{
    exit;
}

Write-Host "Start getting Ratiborus collection." -ForegroundColor Green

$initialItems = @("KMSAuto Lite Portable")


$url = 'https://www.solidfiles.com/folder/bd7165a0d4/'
#$wr = (Invoke-WebRequest -Uri $URL)

[Reflection.Assembly]::LoadFile($hapPath) | Out-Null
[HtmlAgilityPack.HtmlWeb]$web = @{}

#$url = "http://lansweeper:81/user.aspx?username=sam&userdomain=mydomain"

$webclient = new-object System.Net.WebClient

$cred = new-object System.Net.NetworkCredential
$defaultCredentials =  $cred.UseDefaultCredentials

$proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
$proxy = new-object System.Net.WebProxy
$proxy.Address = $proxyAddr
$proxy.useDefaultCredentials = $true 
$proxy

[HtmlAgilityPack.HtmlDocument]$doc = $web.Load($url,"GET",$proxy,$defaultCredentials ) 
[HtmlAgilityPack.HtmlNodeCollection]$nodes = $doc.DocumentNode.SelectNodes("//div[@class='col-lg-4 col-md-6 col-centered'][1]/*/li/i[@class='filetype-icon filetype-archive' or @class='filetype-icon filetype-unknown']")

foreach($node in $nodes)
{


}

$nodes


$t = 0


