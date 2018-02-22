
$wpath = "D:\\temp";
$wpath = "D:\Media Library\Растровые клипарты\Datacraft\Sozaijiten";
$swPiece = "SJ";
$excludeNames = @("pdf", "PDF catalogs");
$addSwPiece = $true;
$remSwPiece = $true;

foreach($item in (Get-ChildItem -Path $wpath))
{
    if($excludeNames -match $item.Name)
    {
        continue;
    }
    if($item.Name.StartsWith($swPiece))
    {
        if($remSwPiece)
        {
            $newName = $item.Name.Substring($swPiece.Length, $item.Name.Length - $swPiece.Length);
            #Rename-Item -Path $item.FullName -NewName $newName -Verbose;

        }
    }
    else
    {
        if($addSwPiece)
        {
            $newName = ($swPiece + $item.Name);
            #Rename-Item -Path $item.FullName -NewName $newName -Verbose;
        }
    }
}