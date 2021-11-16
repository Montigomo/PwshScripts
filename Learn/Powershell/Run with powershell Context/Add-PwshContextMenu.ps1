

function Add-PwshContextMenu
{
  #$oldVarDefault = (Get-ItemProperty -path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command)."(Default)"
  #$oldVarDefautValue = '%systemroot%\system32\WindowsPowerShell\v1.0\powershell.exe -Command "&''%1''"'

  $pwshVarMenu = "$((Get-Command pwsh).Path) -Command ""&'%1'"""

  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command -Type ExpandString -Name '(Default)' -Value $pwshVarMenu

  New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64 -Force
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64 -Name "Icon" -Value $pwshPath -Type String
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64 -Name "MUIVerb" -Value "Run with PowerShell 7" -Type String
  New-Item -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64\Command -Force
  $keyValue = 'C:\Program Files\PowerShell\7\pwsh.exe -Command "$host.UI.RawUI.WindowTitle = ''PowerShell 7 (x64)''; if((Get-ExecutionPolicy ) -ne ''AllSigned'') { Set-ExecutionPolicy -Scope Process Bypass }; & ''%1''"' 
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64\Command -Name '(Default)' -Value $keyValue -Type String
  Set-ItemProperty -Path Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\PowerShell7x64\Command -Name "PowerShellPath" -Value $pwshPath -Type String

  #"C:\Program Files\PowerShell\7\pwsh.exe" -WindowStyle Hidden "-Command" ""& {Start-Process """C:\Program Files\PowerShell\7\pwsh.exe""" -ArgumentList '-ExecutionPolicy RemoteSigned -File \"%1\"' -Verb RunAs;start-sleep 1}"
  $keyName = "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Run with PowerShell 7 (Admin)"
  New-Item -Path $keyName -Force
  Set-ItemProperty -Path $keyName -Name "Icon" -Value $pwshPath -Type String
  Set-ItemProperty -Path $keyName "MUIVerb" -Value "Run with PowerShell 7 (Admin)" -Type String
  New-Item -Path "$keyName\Command" -Force
  $keyValue = 'C:\Program Files\PowerShell\7\pwsh.exe" -WindowStyle Hidden "-Command" ""& {Start-Process """C:\Program Files\PowerShell\7\pwsh.exe""" -ArgumentList ''-ExecutionPolicy RemoteSigned -File \"%1\"'' -Verb RunAs;start-sleep 1}'
  Set-ItemProperty -Path "$keyName\Command" -Name '(Default)' -Value $keyValue -Type String
  Set-ItemProperty -Path "$keyName\Command" -Name "PowerShellPath" -Value $pwshPath -Type String
}

Add-PwshContextMenu