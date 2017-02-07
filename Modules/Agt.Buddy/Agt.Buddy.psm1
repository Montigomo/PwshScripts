


function Start-Buddy
{
   [CmdletBinding()]
    param(
        [string] $botFolder,
        [string] $botFile = "Fraps.exe",
        [int] $daysOld = 3
    )
begin
{
}
process
{
    $strFolders = @("Cache", "CompiledAssemblies", "Logs")
    $process = $botFolder + $botFile;

    foreach ($folder in $strFolders)
    {
      $bpath=($botFolder + $folder);

      if(Test-Path $bpath)
      {
        write ($bpath + " - " + (Get-ChildItem -Path $bpath -Recurse | Measure-Object).Count + " items")
        if($bpath.EndsWith("Logs"))
        {
            Remove-FilesCreatedBeforeDate -Path $bpath -DateTime ((Get-Date).AddDays(-$daysOld)) -DeletePathIfEmpty
        }
        else
        {
            Remove-Item -Recurse -Force $bpath -ErrorAction SilentlyContinue
        }
      }
    }

    if(Test-Path $process)
    {
        Start-Process ($process) -PassThru -ErrorAction SilentlyContinue
        #@(Get-Process | Where-Object {$_.Name -eq "Honorbuddy"}).Count
    }
    else
    {
        write ("File {0} dosn't exist" -f $process)
    }

    Start-Sleep 3
}
}

function Clear-BuddySessions
{
   [CmdletBinding()]
    param(
        [string] $Url = "",
        [string] $PostData = "",
        [System.Net.CookieContainer] $CookieContainer
    )
begin
{
}
process
{
    $baUserName = "RoloTomasi"
    $baPassword = "hjkj17njvfcb91"
    $urlLogin = "http://www.buddyauth.com/Account/LogOn"
    $urlSessions = "http://www.buddyauth.com/User/Sessions"
    $postString = "key=&selectedSessions%5B0%5D.Id={0}&selectedSessions%5B0%5D.IsChecked=true&selectedSessions%5B0%5D.IsChecked=true"
    $idValues = [string]::Empty
    $r = Invoke-WebRequest -Uri $urlLogin -SessionVariable basv
    
    $form = $r.Forms[0]
    $form.Fields["UserName"] = $baUserName
    $form.Fields["Password"] = $baPassword
    
    $r=Invoke-WebRequest -Uri $urlLogin -WebSession $basv -Method POST -Body $form.Fields
    
    if(($basv.Cookies.GetCookies("http://www.buddyauth.com") | Where {$_.Name -like ".ASPXAUTH"}).Count)
    {
        $r=Invoke-WebRequest -Uri $urlSessions -WebSession $basv
        $tr = $r.ParsedHtml.documentElement.getElementsByTagName("tr");
        ($tr).Count
        $tr | %{
            if(($_.getElementsByTagName("td") | Where {$_.innerText -eq "Honorbuddy"}) -ne $null)
            {
                $idValues = @(($_.getElementsByTagName("INPUT") | Where{$_.id -like "selectedSessions_*__Id"}).value)
            }
        }
        #$content | select-string $patt |%{$null = $_.Line -match $patt; $matches['digit'] }
        $idValues | ?{$_} | %{
            $postData = $postString -f $_
            Write-Warning "Tring to kill session with id=$_"
            Get-BuddyRequest -Url $urlSessions -PostData $postData -CookieContainer $basv.Cookies
        }
    }
}
}

function Get-BuddyRequest
{
   [CmdletBinding()]
    param(
        [string] $Url = "",
        [string] $PostData = "",
        [System.Net.CookieContainer] $CookieContainer
    )
begin
{}
process
{
    $buffer = [text.encoding]::ascii.getbytes($postData)
    [net.httpWebRequest] $req = [net.webRequest]::create($urlSessions)
    $req.method = "POST"
    $req.Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
    $req.Headers.Add("Accept-Language: en-US")
    $req.Headers.Add("Accept-Encoding: gzip,deflate")
    $req.Headers.Add("Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7")
    $req.AllowAutoRedirect = $true
    $req.ContentType = "application/x-www-form-urlencoded"
    $req.ContentLength = $buffer.length
    $req.TimeOut = 50000
    $req.KeepAlive = $true
    $req.Headers.Add("Keep-Alive: 300")
    $req.CookieContainer = $CookieContainer
    $reqst = $req.getRequestStream()
    $reqst.write($buffer, 0, $buffer.length)
    $reqst.flush()
    $reqst.close()
    [net.httpWebResponse] $res = $req.getResponse()
    $resst = $res.getResponseStream()
    $sr = new-object IO.StreamReader($resst)
    $result = $sr.ReadToEnd()
    #$result
}
}

# Function to remove all empty directories under the given path. 
# If -DeletePathIfEmpty is provided the given Path directory will also be deleted if it is empty. 
# If -OnlyDeleteDirectoriesCreatedBeforeDate is provided, empty folders will only be deleted if they were created before the given date. 
# If -OnlyDeleteDirectoriesNotModifiedAfterDate is provided, empty folders will only be deleted if they have not been written to after the given date. 
function Remove-EmptyDirectories(
    [parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, 
    [switch] $DeletePathIfEmpty, 
    [DateTime] $OnlyDeleteDirectoriesCreatedBeforeDate = [DateTime]::MaxValue,
    [DateTime] $OnlyDeleteDirectoriesNotModifiedAfterDate = [DateTime]::MaxValue) 
{ 
    Get-ChildItem -Path $Path -Recurse -Force -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -Force -File) -eq $null } |  
        Where-Object { $_.CreationTime -lt $OnlyDeleteDirectoriesCreatedBeforeDate -and $_.LastWriteTime -lt $OnlyDeleteDirectoriesNotModifiedAfterDate } |  
        Remove-Item -Force -Recurse
  
    # If we should delete the given path when it is empty, and it is a directory, and it is empty, and it meets the date requirements, then delete it. 
    if ($DeletePathIfEmpty -and (Test-Path -Path $Path -PathType Container) -and (Get-ChildItem -Path $Path -Force) -eq $null -and
        ((Get-Item $Path).CreationTime -lt $OnlyDeleteDirectoriesCreatedBeforeDate) -and ((Get-Item $Path).LastWriteTime -lt $OnlyDeleteDirectoriesNotModifiedAfterDate)) 
    { Remove-Item -Path $Path -Force } 
} 
  
# Function to remove all files in the given Path that were created before the given date, as well as any empty directories that may be left behind. 
function Remove-FilesCreatedBeforeDate([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [parameter(Mandatory)][DateTime] $DateTime, [switch] $DeletePathIfEmpty) 
{ 
    Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object { $_.CreationTime -lt $DateTime } | Remove-Item -Force
    Remove-EmptyDirectories -Path $Path -DeletePathIfEmpty:$DeletePathIfEmpty -OnlyDeleteDirectoriesCreatedBeforeDate $DateTime
} 
  
# Function to remove all files in the given Path that have not been modified after the given date, as well as any empty directories that may be left behind. 
function Remove-FilesNotModifiedAfterDate([parameter(Mandatory)][ValidateScript({Test-Path $_})][string] $Path, [parameter(Mandatory)][DateTime] $DateTime, [switch] $DeletePathIfEmpty) 
{ 
    Get-ChildItem -Path $Path -Recurse -Force -File | Where-Object { $_.LastWriteTime -lt $DateTime } | Remove-Item -Force
    Remove-EmptyDirectories -Path $Path -DeletePathIfEmpty:$DeletePathIfEmpty -OnlyDeleteDirectoriesNotModifiedAfterDate $DateTime
}

#[text.Regex] $regex = "\<a\s+href=\""\/User\/Sessions\""\>Sessions\<\/a\>"