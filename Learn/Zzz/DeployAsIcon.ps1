$code = {
    # place your code here (must be less than 4096 characters)
    # (this example generates a battery report on notebooks
    #  and opens it in your default browser)
    $r = "$env:temp\report.html"
    powercfg /batteryreport /duration 14 /output $r
    Invoke-Item -Path $r
    Start-Sleep -Seconds 2
    Remove-Item -Path $r
 }
  
 # turn code into a one-liner, remove comments, escape double-quotes
 # NOTE: this is a very simplistic conversion. Does not support block comments
 #  or quoted double quotes or any edgy stuff
 #  USE with simple staight-forward code only
 $oneliner = $code.ToString().Trim(). Replace('"','\"').
               Replace([Char[]]10,'').Split([Char[]]13).
               Trim().Where{!$_.StartsWith('#' )} -join ';'
  
 # create path to a link file. It is always placed on your desktop
 # and named "clickme.lnk"
 $desktop = [Environment]::GetFolderPath('Desktop')
 $linkpath = Join-Path -Path $desktop -ChildPath 'ClickMe.lnk'
  
 # create a shortcut file
 $com = New-Object -ComObject WScript.Shell
 $shortcut = $com.CreateShortcut($linkpath)
 # minimize window so PowerShell won't pop up
 $shortcut.WindowStyle = 7
 # use a different icon. Adjust icon index if you want
 $shortcut.IconLocation = 'shell32.dll,8'
 # run PowerShell
 $shortcut.TargetPath = "powershell.exe"
 # submit code as an argument
 $shortcut.Arguments = "-noprofile $oneliner"
  
 # save and create the shortcut file
 $shortcut.Save()