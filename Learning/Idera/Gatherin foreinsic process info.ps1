$Path = "$env:temp\processList.csv"
 
# get all processes...
Get-CimInstance -ClassName Win32_Process | 
    # select forensic properties...
    Select-Object -Property Name, HandleCount, ProcessId, ParentProcessId, Path, CommandLine  | 
    # write to a CSV file
    Export-Csv -Path $Path -Encoding UTF8 -UseCulture -NoTypeInformation
 
# load CSV into Excel (needs to be installed of course)
Start-Process -FilePath excel -ArgumentList $Path 