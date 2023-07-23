#Requires -RunAsAdministrator

New-PSDrive -Name HKCR_RMTO -PSProvider Registry -Root 'HKEY_CLASSES_ROOT'
pushd HKCR_RMTO:

$keys = '*\shellex\ContextMenuHandlers\ FileSyncEx', 'Directory\Background\shellex\ContextMenuHandlers\ FileSyncEx', 'Directory\shellex\ContextMenuHandlers\ FileSyncEx', 'IE.AssocFile.URL\shellex\ContextMenuHandlers\ FileSyncEx', 'lnkfile\shellex\ContextMenuHandlers\ FileSyncEx'
$rights = 'ChangePermissions', 'CreateSubKey', 'Delete', 'FullControl', 'SetValue', 'TakeOwnership', 'WriteKey'

foreach ($key in $keys) {
    REG DELETE "HKEY_CLASSES_ROOT\$key" /ve /f
    
    $reg = "\$key"
    $acl = Get-Acl -LiteralPath $reg
    foreach ($right in $rights) {
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule("everyone",$right,"Deny")
        $acl.AddAccessRule($rule)
    }

    $acl | Format-List
    Set-Acl -LiteralPath $reg -AclObject $acl
}

popd
Remove-PSDrive -Name HKCR_RMTO