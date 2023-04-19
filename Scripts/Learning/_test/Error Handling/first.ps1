
# clearing global error list:
$error.Clear()
# hiding errors:
$ErrorActionPreference = 'SilentlyContinue'
 
# do stuff:
Stop-Service -Name Spooler
dir c:\gibtsnichtabc
 
 
# check errors at end:
$error.Count 
$error | Out-GridView

#exit

# hiding errors:
$ErrorActionPreference = 'SilentlyContinue'
# telling all cmdlets to use a private variable for error logging:
$PSDefaultParameterValues.Add('*:ErrorVariable', '+myErrors')
# initializing the variable:
$myErrors = $null
 
# do stuff:
Stop-Service -Name Spooler
dir c:\gibtsnichtabc
 
 
# check errors at end USING PRIVATE VARIABLE:
$myErrors.Count
$myErrors | Out-GridView 