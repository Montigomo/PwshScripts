


$servers = 'dc-01', 'dc-02', 'msv3', 'msv4'
$ports = 80, 445, 5985

$servers | ForEach-Object {
    $server = $_
    Write-Progress -Activity 'Checking Servers' -Status $server -Id 1

    $ports | ForEach-Object {
        $port = $_
        Write-Progress -Activity 'Checking Port' -Status $port -Id 2

        # here would be your code that performs some task, i.e. a port test:
         Start-Sleep -Seconds 1
    }
} 