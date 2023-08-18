


$s = @("AGIDESKTOP");
foreach ($computer in $s)
{
try
{
Stop-computer -computername $computer -force -erroraction stop
}
catch
{
 "$computer failed" | out-file -append "reboot_failed - $(get-date -f dd-MMM_@hh).csv"
 }
}