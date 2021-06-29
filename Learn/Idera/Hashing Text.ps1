$text = 'this is a test'
 
$memoryStream = [System.IO.MemoryStream]::new()
$streamWriter = [System.IO.StreamWriter]::new($MemoryStream)
$streamWriter.Write($text)
$streamWriter.Flush()
$memoryStream.Position = 0
$hash = Get-FileHash -InputStream $MemoryStream -Algorithm 'SHA1'
$memoryStream.Dispose()
$streamWriter.Dispose()
$hash.Hash  