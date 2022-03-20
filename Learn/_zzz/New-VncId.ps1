

<?php
$mac = 'B6-B6-13-18-FF-FF';
$mac = str_split(str_replace([':', '-'], '', $mac));
$sum = 0;
foreach($mac as $part) {
	$number = hexdec($part);
	$sum = (($sum * 16) + $number) % 99999999;
	if($sum < 10000000) $sum += 10000000;
}
echo("$sum\n");
?>