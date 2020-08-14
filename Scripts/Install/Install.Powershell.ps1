# this script install powershell 7

# functions and typedefs
function Install-MsiPackage
{
    Param($FilePath, $PackageParams)
    $DataStamp = get-date -Format yyyyMMddTHHmmss
    $logFile = '{0}-{1}.log' -f $FilePath,$DataStamp
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f $FilePath)
        $PackageParams
        "/qn"
        "/norestart"
        "/L*v"
        $logFile
    )
    Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 
}

function Invoke-RunAs
{
    [CmdletBinding()]
    param(
        [Alias('PSPath')]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FilePath},

        [Parameter(Mandatory = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Alias('Args')]
        [Parameter(ValueFromRemainingArguments = $true)]
        [System.Object[]]
        ${ArgumentList},

        [Parameter(Position = 1)]
        [System.Collections.IDictionary]
        $NamedArguments
    )
    begin
    {
        # First we set up a separate managed powershell process
        Write-Verbose "Creating PowerShellProcessInstance and runspace"
        $ProcessInstance = [System.Management.Automation.Runspaces.PowerShellProcessInstance]::new($PSVersionTable.PSVersion, $Credential, $null, $false)

        # And then we create a new runspace in said process
        $Runspace = [runspacefactory]::CreateOutOfProcessRunspace($null, $ProcessInstance)
        $Runspace.Open()
        Write-Verbose "Runspace state is $($Runspace.RunspaceStateInfo)"
    }
    process
    {
        foreach($path in $FilePath){
            Write-Verbose "In process block, Path:'$path'"
            try{
                # Add script file to the code we'll be running
                $powershell = [powershell]::Create([initialsessionstate]::CreateDefault2()).AddCommand((Resolve-Path $path).ProviderPath, $true)

                # Add named param args, if any
                if($PSBoundParameters.ContainsKey('NamedArguments')){
                    Write-Verbose "Adding named arguments to script"
                    $powershell = $powershell.AddParameters($NamedArguments)
                }

                # Add argument list values if present
                if($PSBoundParameters.ContainsKey('ArgumentList')){
                    Write-Verbose "Adding unnamed arguments to script"
                    foreach($arg in $ArgumentList){
                        $powershell = $powershell.AddArgument($arg)
                    }
                }

                # Attach to out-of-process runspace
                $powershell.Runspace = $Runspace

                # Invoke, let output bubble up to caller
                $powershell.Invoke()

                if($powershell.HadErrors){
                    foreach($e in $powershell.Streams.Error){
                        Write-Error $e
                    }
                }
            }
            finally{
                # clean up
                if($powershell -is [IDisposable]){
                    $powershell.Dispose()
                }
            }
        }
    }
    end
    {
        foreach($target in $ProcessInstance,$Runspace){
            # clean up
            if($target -is [IDisposable]){
                $target.Dispose()
            }
        }
    }
}

function Pin-App
{
    param(
        [string]$appname,
        [switch]$unpin
    )
    try
    {
        $shellVar = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}');
        if ($unpin.IsPresent)
        {
            ($shellVar.Items() | 
            Where-Object{$_.Name -eq $appname}).Verbs() | 
            Where-Object{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | 
            ForEach-Object{$_.DoIt()}
            return "App '$appname' unpinned from Start"
        }
        else
        {
            ($shellVar.Items() | ?{$_.Name -eq $appname}).Verbs() | Where-Object{$_.Name.replace('&','') -match 'To "Start" Pin|Pin to Start'} | ForEach-Object{$_.DoIt()}
            return "App '$appname' pinned to Start"
        }
    }
    catch
    {
        Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
    }
}

function Get-IsAdmin  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    [bool](New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

#Write-Host "run flag  $global:runFlag"
#$global:runFlag = $true;

if(!(Get-IsAdmin))
{
    Write-Error "Run as administrator"
    exit
    $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
    #$pp = $MyInvocation.MyCommand.Path
    if(((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas"))
    {
        Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
    }
}

function Get-PowershellUrl
{
    $repo = "https://api.github.com/repos/powershell/powershell"
    $filenamePattern = "PowerShell-\d.\d.\d-win-x64.msi"
    $preRelease = $false

    if ($preRelease) {
        $releasesUri = "$repo/releases"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri)[0].assets | Where-Object name -like $filenamePattern ).browser_download_url
    }
    else {
        $releasesUri = "$repo/releases/latest"
        $downloadUri = ((Invoke-RestMethod -Method GET -Uri $releasesUri).assets | Where-Object name -match $filenamePattern ).browser_download_url
    }

    return $downloadUri
}

$pswhInstalled = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName.Contains("C:\Program Files\PowerShell\7\pwsh.exe");

#if(!$pswhInstalled)
#{

$pwshUri = Get-PowershellUrl

# create temp file

$tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msi' } -PassThru

Invoke-WebRequest -OutFile $tmp $pwshUri

# ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL - This property controls the option for adding the Open PowerShell item to the context menu in Windows Explorer.
# ENABLE_PSREMOTING - This property controls the option for enabling PowerShell remoting during installation.
# REGISTER_MANIFEST - This property controls the option for registering the Windows Event Logging manifest.

Install-MsiPackage -FilePath $tmp.FullName -PackageParams "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1"

#}

#Pin-App  "PowerShell 7 (x64)"
#msiexec.exe /package PowerShell-7.0.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1

/*
Замена зщцукырудд по умолчании
Установка модулей

*/