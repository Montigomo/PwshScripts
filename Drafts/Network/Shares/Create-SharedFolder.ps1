


$Acl = Get-Acl "\\R9N2WRN\Share"

$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("user", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$Acl.SetAccessRule($Ar)
Set-Acl "\\R9N2WRN\Share" $Acl