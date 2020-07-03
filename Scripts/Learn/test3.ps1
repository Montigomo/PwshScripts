




New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String –ForcetesNew-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String –Force



If (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name SCRNSAVE.EXE -ErrorAction SilentlyContinue) {

    Write-Output 'Value exists'

} Else {

    Write-Output 'Value DOES NOT exist'

}