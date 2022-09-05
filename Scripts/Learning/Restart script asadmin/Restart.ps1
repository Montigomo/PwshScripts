

    # Rerun (not complited)
    $pswPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName;
    $pp = $MyInvocation.MyCommand.Path
    if(((New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList $pswPath).Verbs).Contains("runas"))
    {
        Start-Process -FilePath $pswPath -ArgumentList "-File $PSCommandPath" -Verb RunAs
    }