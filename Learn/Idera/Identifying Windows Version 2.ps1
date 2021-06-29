

# get raw Windows version
[int64]$rawVersion = [Windows.System.Profile.AnalyticsInfo,Windows.System.Profile,ContentType=WindowsRuntime].GetMember('get_VersionInfo').Invoke( $Null, $Null ).DeviceFamilyVersion
 
# decode bits to version bytes
$major = ( $rawVersion -band 0xFFFF000000000000l ) -shr 48
$minor = ( $rawVersion -band 0x0000FFFF00000000l ) -shr 32
$build = ( $rawVersion -band 0x00000000FFFF0000l ) -shr 16
$revision =   $rawVersion -band 0x000000000000FFFFl
 
# compose version
$winver = [System.Version]::new($major, $minor, $build, $revision)
$winver 
