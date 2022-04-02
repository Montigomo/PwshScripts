
# specify the folder that you want to discover
# $home is the root folder of your user profile
# you can use any folder: $path = 'c:\somefolder'
$path = $HOME
 
# specify the depth you want to examine (the number of levels you'd like
# to dive into the folder tree)
$Depth = 3
 
# find all subfolders...
Get-ChildItem $path -Directory -Recurse -ErrorAction Ignore -Depth $Depth  |
ForEach-Object {
  Write-Progress -Activity 'Calculating Folder Size' -Status $_.FullName
 
  # return the desired information as a new custom object 
  [pscustomobject]@{
    RelativeSize = Get-ChildItem -Path $_.FullName -File -ErrorAction Ignore | & { begin { $c = 0 } process { $c += $_.Length } end { $c }}
    TotalSize = Get-ChildItem -Path $_.FullName -File -Recurse -ErrorAction Ignore | & { begin { $c = 0 } process { $c += $_.Length } end { $c }}
    FullName  = $_.Fullname.Substring($path. Length+1)
  }
} 