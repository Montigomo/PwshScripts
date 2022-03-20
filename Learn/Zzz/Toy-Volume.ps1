

$vv = 0;  
$s = 0;
$step = 0.05;
$stsl = 2;
do{ 
    start-sleep -second $stsl; 
    if($vv -lt 0 -or  $vv-eq 0) {$s = 0;}
    if($vv -gt 1 -or $vv -eq 1) { $s=1}; 
    if($s -eq 0) {$vv = $vv + $step} else { $vv = $vv - $step};
    $vv
    [audio]::Volume = $vv;
    
}while($true)



$vv = 0;$s = 0;$step = 0.05;do{start-sleep -second 1;if($vv -lt 0 -or  $vv-eq 0) {$s = 0;}if($vv -gt 1 -or $vv -eq 1) { $s=1};if($s -eq 0) {$vv = $vv + $step} else { $vv = $vv - $step};[audio]::Volume = $vv;}while($true)