


$puttyPath = 'D:\tools\network\PuTTY\putty.exe'
$keysStore = 'D:\tools\network\PuTTY\keys\'
$pgAgent = 'D:\tools\network\PuTTY\PAGEANT.EXE'

$puttyItems = @{
    'WinSCP' = @{'Path' = "D:\tools\__this\WinSCP.lnk"; 'Args' = ""};
    #'asus router' =  @{'Path' = $puttyPath; 'Args' = "-load asus"} ;
    #'eomy' = @{'Path' = $puttyPath; 'Args' = "-load eomy"};
    #'ubnt' = @{'Path' = $puttyPath; 'Args' = "-load ubnt"}
};

$values = get-childitem -Path "HKCU:\Software\SimonTatham\PuTTY\Sessions" | Select -Property Name | Foreach {$_.Name} | Foreach {
    if($_.LastIndexOf("\") -ne -1){ $_.Substring($_.LastIndexOf("\") + 1);   }
}

foreach($item in $values)
{
    $puttyItems.Add($item, @{'Path' = $puttyPath; 'Args' = "-load $item"});

}

$tt = 12;