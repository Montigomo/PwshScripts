﻿
Add-Type -AssemblyName PresentationFramework

#Build the GUI
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Putty helper" WindowStartupLocation = "CenterScreen" ResizeMode="NoResize"
    Width = "300" Height = "150" ShowInTaskbar = "True" Background = "lightgray"> 
    <StackPanel >
        <ComboBox x:Name="combobox" Margin="10"/>
        <Button x:Name="buttonConnect" Content="CONNECT" Height="25" Width="90"/>
        <Button x:Name="buttonPagent" Content="Pagent" Height="25" Width="90" Margin="5,10"/>
    </StackPanel>
</Window>
"@

$puttyPath = 'D:\tools\network\PuTTY\putty.exe'
$keysStore = 'D:\tools\network\PuTTY\keys\'
$pgAgent = 'D:\tools\network\PuTTY\PAGEANT.EXE'

$puttyItems = @{
    'WinSCP' = @{'Path' = "D:\tools\__this\WinSCP.lnk"; 'Args' = ""};
    'asus router' =  @{'Path' = $puttyPath; 'Args' = "-load asus"} ;
    'eomy' = @{'Path' = $puttyPath; 'Args' = "-load eomy -l root"};
    'ubnt' = @{'Path' = $puttyPath; 'Args' = "-load ubnt -l ubnt"}
};


$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )
$buttonConnect = $Window.FindName('buttonConnect');
$buttonPagent = $Window.FindName('buttonPagent');
$combobox = $Window.FindName('combobox')
$combobox.SelectedIndex = 0 ;#'eomy'

foreach($actItem in $puttyItems.GetEnumerator())
{
    $combobox.Items.Add($actItem.Key)  | Out-Null
}

#Events
$buttonConnect.Add_Click({
    $action = $puttyItems.Get_Item($combobox.SelectedItem.ToString());
    $pathi = $action['Path'];
    $argsi = $action['Args'];
    if($argsi)
    {
        Start-Process $pathi -ArgumentList $argsi
    }
    else
    {
        Start-Process $pathi
    }

    $Window.Close();
})

$buttonPagent.Add_Click({
    $argList = @(
        #'{0}asus\private.ppk', 
        '{0}eomy\private.ppk' , 
        '{0}ubnt\ssh_key.ppk');
    Start-Process $pgAgent -ArgumentList (($argList -join ' ') -f $keysStore)
})




$Window.ShowDialog() | Out-Null