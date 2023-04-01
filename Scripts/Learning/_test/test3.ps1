


$translation = @{
    0 = 'SUCCESS'
    1 = 'FAILURE'
    2 = 'ERROR'
}


1..255 | ForEach-Object { 
    # create the IP address to ping
    # make sure you adjust this to your segment!
    $ip = "192.168.2.$_"
    # execute ping.exe and disregard the text output
    ping -n 1 -w 500 $ip > $null 
    # instead return the translated return value found in $LASTEXITCODE
    [PSCustomObject]@{ 
         IpAddress = $ip
        Status    = $translation[$LASTEXITCODE]
    }
    }