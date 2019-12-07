# author agitch 

$hapPath = $PSScriptRoot + "\..\assemblies\htmlagilitypack\1.11.17\lib\Net45\HtmlAgilityPack.dll";
#add-type -Path $hapPath


if(-not (Test-Path $hapPath))
{
    exit;
}

Write-Host "Start getting collection." -ForegroundColor Green


$url = "https://docs.microsoft.com/en-us/windows/win32/shell/knownfolderid"

[Reflection.Assembly]::LoadFile($hapPath) | Out-Null
[HtmlAgilityPack.HtmlWeb]$web = @{}


#$webclient = new-object System.Net.WebClient

$cred = new-object System.Net.NetworkCredential
$defaultCredentials =  $cred.UseDefaultCredentials

$proxyAddr = (get-itemproperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').ProxyServer
$proxy = new-object System.Net.WebProxy
$proxy.Address = $proxyAddr
$proxy.useDefaultCredentials = $true 
$proxy

[HtmlAgilityPack.HtmlDocument]$doc = $web.Load($url,"GET",$proxy,$defaultCredentials ) 
#//*[@id="main"]/div[1]
[HtmlAgilityPack.HtmlNodeCollection]$nodes = $doc.DocumentNode.SelectNodes('//*[@id="main"]/table/tbody/tr[@class="odd" or @class="even"]')

$nodes.Count
$sb = [System.Text.StringBuilder]::new()
foreach($node in $nodes)
{
    if($node.SelectSingleNode("td[2]/table") -ne $null)
    {

        #$tnode = $node.SelectSingleNode("td[1]/dl/dt/strong");
        #$tnode.InnerText

        #$node.SelectNodes("td[2]/table/tbody/tr[1]/td")[0].InnerText
        #$node.SelectNodes("td[2]/table/tbody/tr[1]/td")[1].InnerText

        #$node.SelectNodes("td[2]/table/tbody/tr[2]/td")[0].InnerText
        #$node.SelectNodes("td[2]/table/tbody/tr[2]/td")[1].InnerText

        #$node.SelectNodes("td[2]/table/tbody/tr[3]/td")[0].InnerText
        #$node.SelectNodes("td[2]/table/tbody/tr[3]/td")[1].InnerText
    
        #$node.SelectNodes("td[2]/table/tbody/tr[4]/td")[0].InnerText
        #$node.SelectNodes("td[2]/table/tbody/tr[4]/td")[1].InnerText

        $value1 = $node.SelectSingleNode("td[1]/dl/dt/strong").InnerText.toLower() -replace "folderid_",""
        $value2 = $node.SelectNodes("td[2]/table/tbody/tr[1]/td")[1].InnerText -replace "{",""  -replace "}",""
        $line = '{{"{0}", new Guid("{1}") }},' -f $value1, $value2;
        [void]$sb.AppendLine($line)
        $line

    }
}
Set-Clipboard -Value $sb.ToString()
#$nodes



