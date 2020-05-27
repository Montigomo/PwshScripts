

$of = (Get-Content Env:\USERPROFILE)+"\OneDrive"

# get any object
$object = Get-Process -Id $pid
 
# try and access the PSObject
$object.PSObject
 
# get another object
$object = "Hello"
 
# try again
$object.PSObject 