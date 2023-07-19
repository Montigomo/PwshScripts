
[CmdletBinding()]
param (
    [Parameter()][switch]$DCH
)

#region functions 

function WriteLog {
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Write-Output $LogString
    Add-content $LogFile -value $LogMessage
}

function search {
    param (
        [Parameter()] [string]$psid,
        [Parameter()] [string]$pfid,
        [Parameter()] [string]$osid,
        [Parameter()] [string]$lid,
        [Parameter()] [string]$whql,
        [Parameter()] [string]$lang,
        [Parameter()] [string]$dtcid
    )
    #$psid = 0       # Product series ID
    #$pfid = 0       # Product family ID
    #$osid = 0       # Operation system ID
    #$lid = 0        # Language ID
    #$whql = 0       # whql
    #$lang = 0       # lang for site
    #$ctk = 0        # ???
    $isQNF = 0      # ???
    $isSLB = 0      # ???
    $qnfslb = "$isQNF$isSLB"     # ???
    $dtcid = if ($dtcid) { "&dtcid=$dtcid" }else { "" }       # Windows Driver Type: 0 - Standard, 1 - DCH
    # https://www.nvidia.com/Download/processFind.aspx?psid=101&pfid=825&osid=27&lid=7&whql=&lang=en-us&ctk=0&qnfslb=00   sample request
    
    $uri = "https://www.nvidia.com/Download/processFind.aspx?psid={0}&pfid={1}&osid={2}&lid={3}&whql={4}&lang={5}&ctk={6}&qnfslb={7}{8}" `
        -f $psid, $pfid, $osid, $lid, $whql, $lang, $ctk, $qnfslb, $dtcid
            

    Invoke-RestMethod -Method Get -Uri $uri
}

function getLookupRequestBase {
    param (
        [Parameter(Position = 0)] [string]$typeId,
        [Parameter()] [string]$parentId
    )
    $parentId = if ( $parentId ) { "&ParentID=$parentId" } else { "" }
    $uri = "https://www.nvidia.com/Download/API/lookupValueSearch.aspx?TypeID={0}{1}" -f `
        $typeId, $parentId
    (Invoke-RestMethod -Method Get -Uri $uri).OuterXml
}

function getProductsAll {
    param (
        [Parameter()] [string]$productSeriesTypeId
    )
    getLookupRequestBase -typeId 3
}

function getProductSeries {
    param (
        [Parameter()] [string]$productSeriesTypeId
    )
    getLookupRequestBase -typeId 2 -parentId $productSeriesTypeId
}

function getLanguages {
    param (
        [Parameter()] [string]$productSeriesTypeId
    )
    getLookupRequestBase -typeId 5 -parentId $productSeriesTypeId
}

function getOS {
    param (
        [Parameter()] [string]$productSeriesTypeId
    )
    getLookupRequestBase -typeId 4 -parentId $productSeriesTypeId
}
# pid 
# 1 - Product type
# 2 - Product series
# 3 - Product
# 4 - Operation system
# 5 - Language  parentId - pid[2](Product series)
# 6 - 
# Windows Driver Type used only
# if (getSelectedOSName() in { 'Windows 10 64-bit': '', 'Windows Server 2022': '', 'Windows Server 2019': '', 'Windows Server 2016': '', 'Windows 11': ''} && selProductSeriesType.value in { '1': '', '3': '', '7': '', '11': '' })
# url += (getSelectedOSName() in { 'Windows 10 64-bit': '', 'Windows Server 2022': '', 'Windows Server 2019': '', 'Windows Server 2016': '', 'Windows 11': '' }) ? "&dtcid=" + selDownloadTypeDchObj.value : "&dtcid=0"; // Only Win-10-64

#endregion

#region variables and init
$DCH = $true
$Logfile = "$thisFileFolder\nvidia.log"

$productTypeId = 0
$productSeriesId = 0
$productId = 0
$operationSystemId = 0
$languageId = 1
$whql = ""
$language = "en-us"
# var ctk = (selCudaToolkitVersionObj.value == "0" || selProductSeriesType.value != "7") ? "0" : selCudaToolkitVersionObj.value;
$ctk = 0
$dtcid = if ($DCH) { 1 }else { 0 }

$gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.VideoProcessor -match "(NVIDIA )?GeForce" }
[System.Version]$drvCurrentVersion = $gpu.DriverVersion
$gpu = $gpu.VideoProcessor
$gpu = $gpu -replace "NVIDIA ", ""
WriteLog "GPU $gpu found."

$is64bit = [Environment]::Is64BitOperatingSystem

if (($psr = Get-PSRepository -Name "PSGallery") -and ($psr.InstallationPolicy -eq "Untrusted")) {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}

if (-not (Get-Module -ListAvailable -Name "PowerHTML")) {
    Install-Module -Name "PowerHTML"
}
Import-Module -Name "PowerHTML"
if (-not (Get-Module -Name "PowerHTML")) {
    Write-Error "Can't detect or install reqired module PowerHTML"
    throw "This is an error." 
}
WriteLog "PowerHTML installed successefuly."
#endregion

#region ProductID and Series ID search
$xml = [xml](getProductsAll)
$searchSuccess = $false

if ($xml["LookupValueSearch"] -and $xml["LookupValueSearch"].LookupValues) {
    foreach ($item in $xml["LookupValueSearch"].LookupValues.ChildNodes) {
        if ($item -and ($item.Name -eq $gpu)) {
            $productId = $item.Value
            $productSeriesId = $item.Attributes["ParentID"].Value
            $searchSuccess = $true
            break
        }
        
    }
}

if (-not $searchSuccess) {
    Write-Output -InputObject "Product id search unsuccesseful for $gpu" -Verbose
    return
}
#endregion

$filePath = "C:\Program Files\7-Zip\7z.exe"

if (Test-path "HKLM:\SOFTWARE\7-Zip") {
    $value = Get-ItemProperty "HKLM:\SOFTWARE\7-Zip\" -Name "Path" -ErrorAction SilentlyContinue
    if ($value) {
        $filePath = "{0}7z.exe" -f $value.Path
    }
}

if (-not (Test-Path $filePath)) {
    if (Test-Path -Path "$PSScriptRoot\install-7zip.ps1") {
        Import-Module -Name "$PSScriptRoot\install-7zip.ps1"
        Install-7Zip
        if (Test-path "HKLM:\SOFTWARE\7-Zip") {
            $value = Get-ItemProperty "HKLM:\SOFTWARE\7-Zip\" -Name "Path" -ErrorAction SilentlyContinue
            if ($value) {
                $filePath = "{0}7z.exe" -f $value.Path
            }
        }
    }
}
$archiver = $filePath

$oses = @{
    "win11"    = "Windows 11";
    "win10"    = "Windows 10 {0}" -f $(if ($is64bit) { "64-bit" } else { "32-bit" } );
    "win8"     = "Windows 8 {0}" -f $(if ($is64bit) { "64-bit" } else { "32-bit" } );
    "win8.1"   = "Windows 8.1 {0}" -f $(if ($is64bit) { "64-bit" } else { "32-bit" } );
    "win7"     = "Windows 7 {0}" -f $(if ($is64bit) { "64-bit" } else { "32-bit" } );
    "winVista" = "Windows Vista {0}" -f $(if ($is64bit) { "64-bit" } else { "32-bit" } );
    "winXp"    = "Windows XP{0}" -f $(if ($is64bit) { " 64-bit" } else { "" } );
}
$step = 0;
while ($true) {

    #region Os search
    $os = Get-CimInstance -ClassName "Win32_OperatingSystem"
    $osName = $os.Caption
    $osVersion = [System.Version]$os.Version
    
    # windows 11
    if ($osVersion -ge ([System.Version]"10.0.22000")) {
        switch ($step) {
            2 { $osName = $oses["win7"] }
            1 { $osName = $oses["win10"] }
            0 { $osName = $oses["win11"] }
        }
    }# window 10
    elseif ($osVersion -ge ([System.Version]"10.0.10240")) {
        switch ($step) {
            2 { $osName = $oses["winXp"] }
            1 { $osName = $oses["win7"] }
            0 { $osName = $oses["win10"] }
        }
    }# windows 8.1
    elseif ($osVersion -ge ([System.Version]"6.3.9600")) {
    }# windows 8
    elseif ($osVersion -ge ([System.Version]"6.2.9200")) {
    }# windows 7
    elseif ($osVersion -ge ([System.Version]"6.1.7600")) {
    }# windows vista
    elseif ($osVersion -ge ([System.Version]"6.0.6000")) {
    }# windows xp
    elseif ($osVersion -ge ([System.Version]"5.1.2600")) {
    }

    $xml = [xml](getOS $productSeriesId)
    $searchSuccess = $false
    if ($xml["LookupValueSearch"] -and $xml["LookupValueSearch"].LookupValues) {
        foreach ($item in $xml["LookupValueSearch"].LookupValues.ChildNodes) {
            if ($item -and ($osName -eq $item.Name)) {
                $operationSystemId = $item.Value
                #$productSeriesId = $item.Attributes["ParentID"].Value
                $searchSuccess = $true
                break
            }
        
        }
    }
    #endregion

    $response = search -psid $productSeriesId -pfid $productId -osid $operationSystemId -lid $languageId -whql $whql -lang $language -dtcid $dtcid

    $htmlDoc = ConvertFrom-Html -Content $response
    $nodes = $htmlDoc.SelectNodes('//tr[@id="driverList"]')
    [System.Collections.ArrayList]$drivers = @()

    foreach ($item in $nodes) {
        $url = ""
        $version = ""
        $name = ""
        $node = $item.SelectSingleNode('td[@class="gridItem driverName"]//a')
        if ($node) {
            $url = $node.Attributes["href"].Value
            $name = $node.InnerText
        }
        $node = $item.SelectSingleNode('td[3]')
        if ($node) {
            $version = [System.Version]$node.InnerText
        }
        $drivers.Add(@{"version" = $version; "url" = $url; "name" = $name }) | Out-Null
    }
    if (($drivers -and $drivers.Count -gt 0) -or $step -ge 2) {
        break
    }
    if (-not $drivers -or $drivers.Count -eq 0) {
        if ($dtcid -eq 1) {
            $dtcid = 0
        }
        else {
            $step++
            $dtcid = 1
        }
    }
}
if ( -not $drivers -or $drivers.Count -eq 0 ) {
    Write-Output "Can't find any driver for this video adapter." -Verbose
    return
}
$lastDriver = $drivers | Sort-Object { $_.version } -Descending | Select-Object -First 1

#WriteLog "productSeriesId=$productSeriesId, "
WriteLog "Installed driver version: $drvCurrentVersion, found $($lastDriver["version"]) version."

[System.Uri]$url = "https:{0}" -f $lastDriver["url"]

$htmlDoc = ConvertFrom-Html -URI $url
$node = $htmlDoc.SelectSingleNode('//a[@id="lnkDwnldBtn"]')
if ($node) {
    [System.Uri]$url = "https://www.nvidia.com/{0}" -f $node.Attributes["href"].Value
}

$query = $url.Query
$params = [System.Web.HttpUtility]::ParseQueryString($query)
$url = "https://us.download.nvidia.com{0}" -f $params["url"]

WriteLog "Last driver url $url"

$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'exe' } -PassThru
Invoke-WebRequest -Uri $url -OutFile $tmp

$fileName = $tmp.FullName
$fileFolder = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($fileName), [System.IO.Path]::GetFileNameWithoutExtension($fileName));

$filesToExtract = "Display.Driver HDAudio NVI2 PhysX EULA.txt ListDevices.txt setup.cfg setup.exe"

if ($archiver) {
    Start-Process -FilePath $archiver -NoNewWindow -ArgumentList "x -bso0 -bsp1 -bse1 -aoa $fileName $filesToExtract -o""$fileFolder""" -wait
}
#elseif ($archiverProgram -eq $winrarpath) {
#    Start-Process -FilePath $archiverProgram -NoNewWindow -ArgumentList 'x $dlFile $extractFolder -IBCK $filesToExtract' -wait
#}

(Get-Content "$fileFolder\setup.cfg") | Where-Object { $_ -notmatch 'name="\${{(EulaHtmlFile|FunctionalConsentFile|PrivacyPolicyFile)}}' } | Set-Content "$fileFolder\setup.cfg" -Encoding UTF8 -Force

$iargs = "-passive -noreboot -noeula -nofinish -s"

# if ($clean) {
#     $args = $install_args + " -clean"
# }

Start-Process -FilePath "$($fileFolder)\setup.exe" -ArgumentList $iargs -wait

WriteLog "Installation successfully completed. Computer must be restarted for fihish up."
return