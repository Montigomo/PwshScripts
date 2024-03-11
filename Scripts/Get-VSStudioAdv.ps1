#Requires -Version 6.0
#Requires -PSEdition Core
#Requires -RunAsAdministrator
Set-StrictMode -Version 3.0

#region Functions

# https://learn.microsoft.com/en-us/visualstudio/install/create-a-network-installation-of-visual-studio?view=vs-2022#download-the-visual-studio-bootstrapper-to-create-the-layout
# https://learn.microsoft.com/en-us/visualstudio/install/command-line-parameter-examples?view=vs-2022

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

function Get-VSStudio {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][ValidateSet("2017", "2019", "2022")][string]$Version,
        [Parameter(Mandatory = $true)][ValidateSet("com", "pro", "ent")][string]$Edition,
        [Parameter(Mandatory = $false)][string]$FolderPath,
        [Parameter(Mandatory = $false)][switch]$ClearFolder
    )
    <#
    .SYNOPSIS
        Download Visual Studio packages.
    .DESCRIPTION
        Download Visual Studio (2017[15],2019[16],2022[17]) all components and workloads to selected folder.
    .PARAMETER Version
        [string] Visual Studio version. Allowed values "2017", "2019", "2022"
    .PARAMETER Edition
        [string] Visual Studio edition. Allowed values "com" (community), "pro" (professiaonal), "ent" (enterprise)
    .PARAMETER FolderPath
        [string] Destination folder path. To where it will be ddownloaded
    .PARAMETER ClearFolder
        [switch] If set all content of destination folder will be deleted
    .INPUTS
        none
    .OUTPUTS
        none
    .NOTES
        Author : Agitech 
        Version : 1.0 
        Purpose : Get world better
    .EXAMPLE
        Get-VSStudio -Version 2022 -Edition "pro" -FolderPath "D:\vs\20222\pro" -ClearFolder
    .LINK
    #>
    if (-not $FolderPath) {
        $FolderPath = $PSScriptRoot
    }

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

    if (-not (Test-Path -Path $FolderPath  -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $layoutPath
    }

    if ($ClearFolder) {
        Remove-Item -Path "$FolderPath\*" -Force -Confirm:$false -Recurse
    }
    elseif (Test-Path -Path $installerPath -PathType Leaf) {
        Remove-Item -Path $installerPath -Force -Confirm:$false
    }

    Invoke-WebRequest -Uri $url -OutFile $installerPath

    . $installerPath --layout $layoutPath --lang en-US

    Start-Sleep -Seconds 3

    $shortcutPath = "$DownLoadFolderPath\setup.lnk"
    $targetPath = "components\vs_setup.exe"
    New-Item -ItemType SymbolicLink -Path $shortcutPath -Target $targetPath -Force
}

#endregion

#region XAML
#Form Start

Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration

[xml]$XAML = @'

<Window x:Name="wndMain" x:Class="Demo_App_1.Window1"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Demo_App_1"
        mc:Ignorable="d"
        Title="VSDownloader" Height="235" Width="377" Icon="/Gear_00_61x61.png" ResizeMode="CanMinimize">
    <Grid Background="#FFF3F3F3">
        <ComboBox x:Name="cmbVersion" HorizontalAlignment="Left" Margin="16,32,0,0" VerticalAlignment="Top" Width="148" Height="22" SelectionChanged="cmbVersion_SelectionChanged"/>
        <ComboBox x:Name="cmbEdition" HorizontalAlignment="Left" Margin="200,32,0,0" VerticalAlignment="Top" Width="148" Height="22"/>
        <TextBox x:Name="txtFolderPath" HorizontalAlignment="Left" Margin="16,92,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="312" Height="18"/>
        <Button x:Name="btnSelectFolder" Content="..." HorizontalAlignment="Left" Margin="327,92,0,0" VerticalAlignment="Top" Height="18" Width="21" Click="btnSelectFolder_Click"/>
        <Button x:Name="btnStart" Content="Start" HorizontalAlignment="Center" Margin="0,138,0,0" VerticalAlignment="Top" Height="20" Width="92" Click="btnStart_Click"/>
        <Label x:Name="lblInfo" Content="Select VS version, edition, destination folder and press start" HorizontalAlignment="Left" Margin="16,168,0,0" VerticalAlignment="Top" Width="332" Foreground="#FF007800"/>
        <CheckBox x:Name="chkClearFolder" Content="Clear destination folder" HorizontalAlignment="Left" Margin="16,64,0,0" VerticalAlignment="Top" IsChecked="True"/>
    </Grid>
</Window>

'@ -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'x:Class="\S+"', '' -replace 'Icon="\S+"', '' -replace '(SelectionChanged|Click)="\S+"', ''

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $XAML)
$wndMain = [Windows.Markup.XamlReader]::Load($reader)
$XAML.SelectNodes("//*[@Name]") | % { Set-Variable -Name ($_.Name) -Value $wndMain.FindName($_.Name) }

#endregion

#region XAML Controlls

[string]$IconB64 = @"
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
"@

$bitmap = New-Object System.Windows.Media.Imaging.BitmapImage
$bitmap.BeginInit()
$bitmap.StreamSource = [System.IO.MemoryStream][System.Convert]::FromBase64String($IconB64)
$bitmap.EndInit()
$bitmap.Freeze()

$wndMain.Icon = $bitmap

$cmbVersion.Items.Clear()
$cmbEdition.Items.Clear()

function FillCmbEditions {
    $selectedVersion = $cmbVersion.SelectedItem.ToString() -replace ' (\S+)', ''
    if ($selectedVersion) {
        $cmbEdition.ItemsSource = $assets[$selectedVersion]["urls"].Keys
        $cmbEdition.SelectedIndex = 0
    }
}

$cmbVersion.ItemsSource = ($assets.Keys | Sort-Object -Descending | ForEach-Object { "$_ ($($assets[$_].version))" })
$cmbVersion.SelectedIndex = 0
$cmbVersion.add_SelectionChanged({
        FillCmbEditions
    })

FillCmbEditions

$btnStart.Add_Click({
        $VsVersion = $cmbVersion.SelectedItem.ToString() -replace ' (\S+)', ''
        $VsEdition = $cmbEdition.SelectedItem.ToString()
        $DownLoadFolderPath = $txtFolderPath.Text

        if (-not $DownLoadFolderPath) {
            $lblInfo.Foreground = "#FFFF5151"
            $lblInfo.Content = "Select Destination folder."
            $txtFolderPath.Focus()
            return
        }

        $VsUrl = $assets[$VsVersion]["urls"][$VsEdition]

        $lblInfo.Foreground = "#FF007800"
        $lblInfo.Content = "The download is going to start. $VsUrl"

        Get-VSStudio -Version $VsVersion -Edition $VsEdition -FolderPath $DownLoadFolderPath -ClearFolder:($chkClearFolder.IsChecked)

        $wndMain.Close()
    })

$btnSelectFolder.Add_Click({
        $folderDialog = New-Object -TypeName Microsoft.Win32.OpenFolderDialog
        $folderDialog.Title = "Select Folder"
        #$folderDialog.InitialDirectory = "$PSScriptRoot"
        if ($folderDialog.ShowDialog()) {
            $folderName = $folderDialog.FolderName;
            $txtFolderPath.Text = $folderName
            $lblInfo.Content = ""
        }
    })

$wndMain.ShowDialog()

#endregion