



0..100 | ForEach-Object { (0..5 | Foreach-Object { '{0:x}{1:x}' -f (Get-Random -Minimum 0 -Maximum 15),(Get-Random -Minimum 0 -Maximum 15)})  -join ':' }