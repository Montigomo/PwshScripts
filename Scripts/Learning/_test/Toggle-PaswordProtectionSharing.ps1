

Param (
    [switch]$Reboot=$false
)
$scriptpath = $MyInvocation.MyCommand.Path | Split-Path
$script = $MyInvocation.MyCommand.Path


If (([Security.Principal.WindowsIdentity]::GetCurrent()).Name -eq "NT AUTHORITY\SYSTEM")
{
    # Add the network access permission for the Everyone group
    # This allows the radio button to be flipped
    $everyonepath='HKLM:\SECURITY\Policy\Accounts\S-1-1-0\ActSysAc'
    $ekv=(Get-ItemProperty $everyonepath).'(Default)'
    $eBit=2
    $eDisable=0

    # Add the share permission for the Guest user
    # This flips the radio button
    $guestSID=(Get-Localuser | Where { $_.SID -match ".*-501" }).SID.Value
    $guestpath="HKLM:\SECURITY\Policy\Accounts\$guestSID\ActSysAc"
    # Guest account must be enabled to allow no password setting
    Get-LocalUser -SID $guestSID | Enable-LocalUser
    $gkv=(Get-ItemProperty $guestpath).'(Default)'
    $gBit=128
    $gDisable=1

    # Bit flips
    if (($ekv[0] -band $eBit) -eq 0) # If radio button can't be flipped
    {
        $ekv[0] = $ekv[0] + $eBit # Allow flip
        if (($gkv[0] -band $gBit) -ne 0) # If radio button isn't flipped on already
        {
            $gkv[0] = $gkv[0] - $gBit # Flip it on
        }
    }
    else # If radio button can be flipped
    {
        $ekv[0] = $ekv[0] - $eBit # Disallow flip
        if (($gkv[0] -band $gBit) -eq 0) # If radio button is flipped on already
        {
            $gkv[0] = $gkv[0] + $gBit # Flip it off
        }
    }

    New-ItemProperty -Path $everyonepath -Name '(Default)' -PropertyType None -Value $ekv -Force
    New-ItemProperty -Path $guestpath -Name '(Default)' -PropertyType None -Value $gkv -Force
    #gpupdate /force # Contrary to documentation, this does not update the security template. Reboot required
}
Else
{
    try
    {
        $taskname = "temp_ToggleNoPWShare"
        $taskdescription = $taskname
        $arguments = "-Executionpolicy bypass -NoProfile -file `"$script`""
        If ($Reboot) { $arguments = $arguments + " -Reboot" }
        $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $arguments
        Register-ScheduledTask -Action $action -TaskName $taskname -Description $taskdescription -User "System"
        Start-ScheduledTask -TaskName "$taskname"
        Sleep 5
        Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
        If ($Reboot) { Start-Process -FilePath "shutdown.exe" -ArgumentList "-r -t 15" }
    }
    catch
    {
        Write-Host "Exception $_"
        Get-Variable -Scope Script
    }
}