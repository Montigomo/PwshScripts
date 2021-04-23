

# create a sample file
$desktop = [Environment]::GetFolderPath('Desktop')
$path = Join-Path -Path $desktop -ChildPath 'testfile.txt'
'Test' | Out-File -FilePath $Path
 
# attach hidden info to the file
'this is hidden' | Set-Content -Path "${path} :myHiddenStream"
 
# attach even more hidden info to the file
'this is also hidden' | Set-Content -Path "${path} :myOtherHiddenStream"
 
# show file
#explorer /select,$Path 


# get hidden info from the file
Get-Content -Path "${path} :myHiddenStream"
Get-Content -Path "${path} :myOtherHiddenStream" 