#!/usr/bin/pwsh -Command

#Install-Module PSWindowsUpdate -Force
#Import-Module PSWindowsUpdate

#$Computers = @("AgiLaptop")

# function Install-MSUpdates {
#     [CmdletBinding()]
#     Param(
#         [Parameter(Mandatory = $true)]
#         [string[]]$ComputerName,

#         [Parameter(Mandatory = $true, ParameterSetName = 'Now')]
#         [switch]$Now,

#         [Parameter(Mandatory = $true, ParameterSetName = 'At')]
#         [ValidateScript({ $_ -gt (Get-Date) })]
#         [datetime]$At,

#         [Parameter(Mandatory = $true)]
#         [ValidateSet('MicrosoftUpdate', 'WindowsUpdate')]
#         [string]$UpdateSource,

#         [Parameter(Mandatory = $false)]
#         [ValidateNotNullOrEmpty()]
#         [System.Management.Automation.PSCredential]$Credential
#     )

#     #BEGIN
#     $ErrorActionPreference = 'Stop'
#     $PackageProvider = 'NuGet'
#     $RepositorySource = 'PSGallery'
#     $UpdateModule = 'PSWindowsUpdate'

#     #PROCESS
#     ForEach ($Computer in $ComputerName) {
#         Try {
#             #Session
#             if (!$Credential) {
#                 $Session = New-PSSession -ComputerName $Computer
#             }
#             else {
#                 Try { $Session = New-PSSession -ComputerName $Computer -Credential $Credential }
#                 Catch { $Session = New-PSSession -ComputerName $Computer -UseSSL -Credential $Credential }
#             }
#             Write-Verbose "PSSession to $Computer created"

#             #Install Package Manager
#             Invoke-Command -Session $Session -ScriptBlock { Install-PackageProvider -Name $Using:PackageProvider -Force | Out-Null }
#             Write-Verbose "Package Provider $PackageProvider installed"

#             #Install Update Module
#             Invoke-Command -Session $Session -ScriptBlock { Install-Module -Name $Using:UpdateModule -Repository $Using:RepositorySource -Force }
#             Write-Verbose "$UpdateModule from $RepositorySource installed"

#             #Build Script Parameter for Invoke-WUJob
#             $Script = "ipmo $UpdateModule;Install-WindowsUpdate -AcceptAll -AutoReboot -$UpdateSource -UpdateType Software"

#             #Build Parameters for Invoke-WUJob
#             if ($Now) {
#                 $ScriptBlock = [ScriptBlock]::Create("Invoke-WUJob -Script '$Script' -RunNow -Confirm:`$false")
#             }
#             if ($At) {
#                 $AtDateString = $At.ToString()
#                 $ScriptBlock = [ScriptBlock]::Create("Invoke-WUJob -Script '$Script' -TriggerDate (Get-Date '$AtDateString') -Confirm:`$false")
#             }

#             #Send Update Command
#             Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
#             if ($Now) {
#                 Write-Verbose "Update task has been scheduled on $Computer for $(Get-Date)"
#             }
#             if ($At) {
#                 Write-Verbose "Update task has been scheduled on $Computer for $(Get-Date $At)"
#             }
#         }
#         Catch {
#             $PSCmdlet.WriteError($_)
#             Continue
#         }
#         Finally {
#             Try {
#                 if ($Session) {
#                     Remove-PSSession -Session $Session
#                     Write-Verbose "PSSession to $Computer closed"
#                 }
#             }
#             Catch {
#                 $PSCmdlet.WriteError($_)
#             }
#         }
#     }
# }


function Install-MSUpdatesSsh {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [Parameter(Mandatory = $true, ParameterSetName = 'Now')]
        [switch]$Now,
        [Parameter(Mandatory = $true, ParameterSetName = 'At')]
        [ValidateScript({ $_ -gt (Get-Date) })]
        [datetime]$At
    )
    
    begin {
      
    }
    
    process {

        $ErrorActionPreference = 'Stop'
        $PackageProvider = 'NuGet'
        $RepositorySource = "PSGallery"
        $UpdateModule = "PSWindowsUpdate" 

        Try {

            #Invoke-Command -Session $Session -ScriptBlock { Install-PackageProvider -Name $PackageProvider -Force | Out-Null }
            #Write-Verbose "Package Provider $PackageProvider installed"

            $psversion = Invoke-Command -Session $Session -ScriptBlock { $PSVersionTable }

            if ($psversion.PSVersion.Major -eq 5) {
                #Install Package Manager
                #Invoke-Command -Session $Session -ScriptBlock { Install-PackageProvider -Name $Using:PackageProvider -Force | Out-Null }
                #Write-Verbose "Package Provider $PackageProvider installed"
            }
            else {
                #$sourceArgs = @{
                #    Name = 'nuget.org'
                #    Location = 'https://api.nuget.org/v3/index.json'
                #    ProviderName = 'NuGet'
                #}
                #$nugetPackage = Invoke-Command -Session $Session -ScriptBlock { Get-PackageProvider -ListAvailable | Where-Object {$_.Name -eq 'nuget'} }
                #if($nugetPackage){
                #    Invoke-Command -Session $Session -ScriptBlock { UnRegister-PackageSource $Using:sourceArgs }
                #}

                #Invoke-Command -Session $Session -ScriptBlock { Install-PackageProvider -Name $Using:PackageProvider -Force | Out-Null }
                #Write-Verbose "Package Provider $PackageProvider installed"
            }

            #Install Update Module
            Invoke-Command -Session $Session -ScriptBlock { Install-Module -Name $Using:UpdateModule -Repository $Using:RepositorySource -Force }
            Write-Verbose "$UpdateModule from $RepositorySource installed"

            #Build Script Parameter for Invoke-WUJob
            $Script = "ipmo $UpdateModule;Install-WindowsUpdate -AcceptAll -AutoReboot -$UpdateSource -UpdateType Software"

            #Build Parameters for Invoke-WUJob
            if ($Now) {
                $ScriptBlock = [ScriptBlock]::Create("Invoke-WUJob -Script '$Script' -RunNow -Confirm:`$false")
            }
            if ($At) {
                $AtDateString = $At.ToString()
                $ScriptBlock = [ScriptBlock]::Create("Invoke-WUJob -Script '$Script' -TriggerDate (Get-Date '$AtDateString') -Confirm:`$false")
            }

            #Send Update Command
            Invoke-Command -Session $Session -ScriptBlock $ScriptBlock
            if ($Now) {
                Write-Verbose "Update task has been scheduled on $Computer for $(Get-Date)"
            }
            if ($At) {
                Write-Verbose "Update task has been scheduled on $Computer for $(Get-Date $At)"
            }
        }
        Catch {
            $_
            Continue
        }
        Finally {
            Try {
                if ($Session) {
                    Remove-PSSession -Session $Session
                    Write-Verbose "PSSession to $Computer closed"
                }
            }
            Catch {
                $PSCmdlet.WriteError($_)
            }
        }      
    }
    
    end {
        
    }
}


#$credential = Get-Credential -UserName "agitech@outlook.com" -Message 'Enter Password'
#Install-MSUpdates -ComputerName "AgiLaptop" -Now -UpdateSource MicrosoftUpdate -Credential $credential -Verbose

#$credential = Get-Credential -UserName "nidaleb@outlook.com" -Message 'Enter Password'
#Install-MSUpdates -ComputerName "NidalebLaptop" -Now -UpdateSource MicrosoftUpdate -Credential $credential -Verbose

#$session = New-PSSession -HostName NidalebLaptop -UserName nidaleb@outlook.com
#Install-MSUpdatesSsh -Session $session -Now -Verbose


$session = New-PSSession -HostName 192.168.0.20 -UserName montigomo@outlook.com
Install-MSUpdatesSsh -Session $session -Now -Verbose

exit 





# $params=@{
#     HostName = "NidalebLaptop"
#     UserName = "nidaleb@outlook.com"
# }

# $session = New-PSSession $params

#New-PSSession -SSHConnection $sshConnections

#Check-WindowsUpdate -PSSession (New-PSSession -ComputerName "AgiLaptop" -Credential agitech@outlook.com)
#(New-PSSession -ComputerName "NidalebLaptop" -Credential nidaleb@outlook.com))




$credential = Get-Credential -UserName "agitech@outlook.com" -Message 'Enter Password'
$session = New-PSSession -ComputerName "AgiLaptop" -Credential $credential
Invoke-Command -Session $session -ScriptBlock { $PSVersionTable }
# Name                           Value
# ----                           -----
# BuildVersion                   10.0.19041.2673
# PSEdition                      Desktop
# WSManStackVersion              3.0
# PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
# PSRemotingProtocolVersion      2.3
# SerializationVersion           1.1.0.1
# PSVersion                      5.1.19041.2673
# CLRVersion                     4.0.30319.42000


$session = New-PSSession -HostName AgiLaptop -UserName agitech@outlook.com
Invoke-Command -Session $session -ScriptBlock { $PSVersionTable }
# Name                           Value
# ----                           -----
# GitCommitId                    7.3.3
# PSEdition                      Core
# OS                             Microsoft Windows 10.0.19045
# Platform                       Win32NT
# PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
# PSRemotingProtocolVersion      2.3
# WSManStackVersion              3.0
# PSVersion                      7.3.3
# SerializationVersion           1.1.0.1