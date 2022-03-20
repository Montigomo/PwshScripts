

$url = 'https://github.com/yanxyz'
try {
  $chrome = (Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe').'(Default)'
  Start-Process "$chrome" $url
}
catch {
  Start-Process $url
}