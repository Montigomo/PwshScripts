

# Define the script block to be executed by the new PowerShell instance.
$scriptBlock={
    param($projectFolder)
    # For demonstration, simply *output* the parameter values.
    "folder: [$projectFolder]; arguments: [$Args]"
  }
  
  # Parameter values to pass.
  $projectFolder = 'c:\temp'
  $argList='-v -f'
  
  # Determine the temporary script path.
  $tempScript = "$env:TEMP\temp-$PID.ps1"
  
  # Create the script from the script block and append the self-removal command.
  # Note that simply referencing the script-block variable inside `"..."`
  # expands to the script block's *literal* content (excluding the enclosing {...})
  "$scriptBlock; Remove-Item `$PSCommandPath" > $tempScript
  
  # Now invoke the temporary script file, passing the arguments as literals.
  Start-Process -NoNewWindow powershell -ArgumentList '-NoProfile', '-File', $tempScript, $projectFolder, $argList