

# this script assign to all cd drives on the PC letterrs from ((char)Z - cddrives.Count) to Z
# before :  cddrive1 - G:  cddrive2 - H:  cddrive3 - I:
# after  :  cddrive1 - X:  cddrive2 - Y:  cddrive3 - Z:
# GLYBS [Good Luck to You & Best Scripts]

$cddrives = Get-WMIObject -Class Win32_CDROMDrive -ComputerName $env:COMPUTERNAME -ErrorAction Stop
$sch = [byte][char]'Z' - $cddrives.Count + 1

foreach($drive in $cddrives)
{
    $drv = Get-WmiObject win32_volume -filter ('DriveLetter = "{0}"' -f $drive.Drive);
    $drv.DriveLetter = ("{0}:" -f ([char]$sch));
    $drv.Put() | out-null;
    $sch = $sch + 1;
}
