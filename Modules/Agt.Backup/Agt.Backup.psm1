  
function Invoke-Backup
{
<#  
.SYNOPSIS  
    Change the registry key in order that double-clicking on a file with .PS1 extension
    start its execution with PowerShell.
.DESCRIPTION
    This operation bring (partly) .PS1 files to the level of .VBS as far as execution
    through Explorer.exe is concern.
    This operation is not advised by Microsoft.
.NOTES  
    File Name   : ModifyExplorer.ps1  
    Author      : J.P. Blanc - jean-paul_blanc@silogix-fr.com
    Prerequisite: PowerShell V2 on Vista and later versions.
    Copyright 2010 - Jean Paul Blanc/Silogix    
.LINK  
    Script posted on:  
    http://www.silogix.fr  
.EXAMPLE  
    PS C:\silogix> Set-PowAsDefault -On
    Call Powershell for .PS1 files.
    Done !
.EXAMPLE    
    PS C:\silogix> Set-PowAsDefault
    Tries to go back  
    Done !
#>
  [CmdletBinding()]
  Param
  (
    [Parameter(mandatory=$false,ValueFromPipeline=$false)]
    [Alias("Active")]
    [switch]
    [bool]$On
  )

  begin 
  {
    if ($On.IsPresent)
    {
      Write-Host "Call Powershell for .PS1 files."
    }
    else
    {
      Write-Host "Try to go back."
    }
  }

  Process 
  {
    # Text Menu
    [string]$TexteMenu = "Go inside PowerShell"

    # Text of the program to create
    [string] $TexteCommande = "%systemroot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command ""&'%1'"""

    # Key to create
    [String] $clefAModifier = "HKLM:\SOFTWARE\Classes\Microsoft.PowerShellScript.1\Shell\Open\Command"

    try
    {
      $oldCmdKey = $null
      $oldCmdKey = Get-Item $clefAModifier -ErrorAction SilentlyContinue
      $oldCmdValue = $oldCmdKey.getvalue("")

      if ($oldCmdValue -ne $null)
      {
        if ($On.IsPresent)
        {
          $slxOldValue = $null
          $slxOldValue = Get-ItemProperty $clefAModifier -Name "slxOldValue" -ErrorAction SilentlyContinue
          if ($slxOldValue -eq $null)
          {
            New-ItemProperty $clefAModifier -Name "slxOldValue" -Value $oldCmdValue  -PropertyType "String" | Out-Null
            New-ItemProperty $clefAModifier -Name "(default)" -Value $TexteCommande  -PropertyType "ExpandString" | Out-Null
            Write-Host "Done !"
          }
          else
          {
            Write-Host "Already done !"          
          }

        }
        else
        {
          $slxOldValue = $null
          $slxOldValue = Get-ItemProperty $clefAModifier -Name "slxOldValue" -ErrorAction SilentlyContinue 
          if ($slxOldValue -ne $null)
          {
            New-ItemProperty $clefAModifier -Name "(default)" -Value $slxOldValue."slxOldValue"  -PropertyType "String" | Out-Null
            Remove-ItemProperty $clefAModifier -Name "slxOldValue" 
            Write-Host "Done !"
          }
          else
          {
            Write-Host "No former value !"          
          }
        }
      }
    }
    catch
    {
      $_.exception.message
    }
  }
  end {}
}
