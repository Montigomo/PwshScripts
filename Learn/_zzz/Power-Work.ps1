
Class powerObject{
    
    [string] $Name;
    [string] $Guid;
    [bool] $Active;

    powerObject([string] $NameIn, [string] $guid, [string] $active) {
        $this.Name = $NameIn;
        $this.Guid = $guid;
        $this.Active = if([string]::IsNullOrWhiteSpace($active)) {$false} else {$true};
    }
 
    [string] Dump() {
        #$a = $null
        #[char[]]$this.Name| Sort-Object {Get-Random} | %{ $a = $PSItem + $a}
        return ("Name: {0} Guid: {1} Active: {2}" -f $this.Name, $this.Guid, $this.Active);
    }
}

$rxs = "Power\s+Scheme\s+GUID:\s+(?<guid>[{(]?[0-9A-Fa-f]{8}[-]?([0-9A-Fa-f]{4}[-]?){3}[0-9A-Fa-f]{12}[)}]?)\s+\((?<name>[A-Za-z\s]+)\)\s?(?<active>\*)?"

$powerp = New-Object System.Collections.ArrayList;

foreach($item in (powercfg -LIST))
{
    $match = [regex]::Match($item,$rxs)
    if($match.Success)
    {
        $x = [powerObject]::new($match.Groups["name"], $match.Groups["guid"], $match.Groups["active"]);
        #$x.Dump();
        $powerp.Add($x) > $null;
    }
}

Write-Output $powerp

powercfg -x disk-timeout-ac 0
powercfg -x disk-timeout-dc 0

#$data = 0..10
#[System.Linq.Enumerable]::Where($data,[Func[object,bool]]{ param($d) $true })
#[System.Linq.Enumerable]::Where($data, [Func[object,bool]]{ param($x) $x -gt 5 })