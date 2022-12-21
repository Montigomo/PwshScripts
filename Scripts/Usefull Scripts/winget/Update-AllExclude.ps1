

$excludeIds = @("Adobe.Acrobat.Reader.64-bit")

(winget upgrade) | Where-Object { 
    $_
}