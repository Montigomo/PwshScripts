Set-StrictMode -Version 3.0
function Get-VSStudio {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet("2017", "2019", "2022")][string]$Version,
        [Parameter(Mandatory = $true)][ValidateSet("com", "pro", "ent")][string]$Edition,
        [Parameter(Mandatory = $false)][string]$FolderPath,
        [Parameter(Mandatory = $false)][switch]$ClearFolder
    )

    [hashtable]$assets = @{
        "2017" = @{
            "version" = 15
            "urls"    = @{
                "com" = "https://aka.ms/vs/15/release/vs_community.exe"
                "pro" = "https://aka.ms/vs/15/release/vs_professional.exe"
                "ent" = "https://aka.ms/vs/15/release/vs_enterprise.exe"
            }
        }
        "2019" = @{
            "version" = 16
            "urls"    = @{
                "com" = "https://aka.ms/vs/16/release/vs_community.exe"
                "pro" = "https://aka.ms/vs/16/release/vs_professional.exe"
                "ent" = "https://aka.ms/vs/16/release/vs_enterprise.exe"
            }
        }        
        "2022" = @{
            "version" = 17
            "urls"    = @{
                "com" = "https://aka.ms/vs/17/release/vs_community.exe"
                "pro" = "https://aka.ms/vs/17/release/vs_professional.exe"
                "ent" = "https://aka.ms/vs/17/release/vs_enterprise.exe"
            }
        }        
    }

    if (-not $FolderPath) {
        $FolderPath = $PSScriptRoot
    }

    #$src = ($sources | Out-GridView -Title 'Select destination path' -OutputMode Single)

    if ( $assets.Keys -inotcontains $Version) {
        Write-Host "Can't find $Version vs version" -ForegroundColor Red
        return
    }
    if ( $assets[$Version]["urls"].Keys -inotcontains $Edition) {
        Write-Host "Can't find vs-$Version $Edition edition" -ForegroundColor Red
        return
    }

    [System.Uri]$url = $assets[$Version]["urls"][$Edition]

    $filename = [System.IO.Path]::GetFileName($url.LocalPath);
    $installerPath = [System.IO.Path]::GetFullPath("$FolderPath\$filename")
    $layoutPath = [System.IO.Path]::GetFullPath("$FolderPath\components")

    if ($ClearFolder) {
        Remove-Item -Path "$FolderPath\*" -Force -Confirm:$false -Recurse
    }
    elseif (Test-Path $installerPath) {
        Remove-Item -Path $installerPath -Force -Confirm:$false
    }

    #New-Item -ItemType Directory -Force -Path $layoutPath

    Invoke-WebRequest -Uri $url -OutFile $installerPath

    . $installerPath --layout $layoutPath --lang en-US
}