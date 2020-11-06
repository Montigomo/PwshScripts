# create temporary folder
$destination = Join-Path -Path $env:temp -ChildPath Scripts
$exists = Test-Path -Path $destination
if (!$exists) { $null = New-Item -Path $destination -ItemType Directory }
 
# offer to download scripts
Find-Script -Name Get-* | Select-Object -Property Name, Description |
  Out-GridView -Title 'Select script to download' -PassThru |
  ForEach-Object {
      Save-Script -Path $destination -Name $_.Name -Force
      $scriptPath = Join-Path -Path $destination -ChildPath "$($_. Name).ps1"
      ise $scriptPath
  } 



  $profile.PSObject.Properties.Name | Where-Object { $_ -ne 'Length' } | ForEach-Object { [PSCustomObject]@{Profile=$_; Present=Test-Path $profile.$_ ; Path=$profile.$_}} 