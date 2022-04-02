$url = 'https://mars.nasa.gov/system/downloadable_items/41764_20180703_marsreport-1920.mp4'
$targetfolder = $env:temp
$filename = Split-Path -Path $url -Leaf
$targetFile = Join-Path -Path $targetfolder -ChildPath $filename
 
Start-BitsTransfer -Source $url -Destination $targetfolder -Description 'Downloading Video...' -Priority Low 
 
 
Start-Process -FilePath $targetFile 