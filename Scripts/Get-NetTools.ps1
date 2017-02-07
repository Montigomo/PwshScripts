
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  
Add-Type -AssemblyName PresentationFramework

#Build the GUI
[xml]$xaml = @"
<Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window" Title="Putty helper" WindowStartupLocation = "CenterScreen" ResizeMode="NoResize"
    Width = "300" Height = "125" ShowInTaskbar = "True" Background = "lightgray"> 
    <StackPanel >
        <ComboBox x:Name="combobox" Margin="10"/>
        <Button x:Name="buttonConnect" Content="CONNECT" Height="25" Width="90"/>
    </StackPanel>
</Window>
"@

$puttyPath = 'D:\tools\network\PuTTY\putty.exe'

$puttyItems = @{
    'WinSCP' = @{'Path' = "D:\tools\__this\WinSCP.lnk"; 'Args' = ""};
    'asus router' =  @{'Path' = $puttyPath; 'Args' = "-load asus"} ;
    'eomy' = @{'Path' = $puttyPath; 'Args' = "-load eomy -l root"}
};

#Start-Process $puttyPath -ArgumentList ("-load asus")
#Start-Process $puttyPath -ArgumentList ("-load eomy -l root") 

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
$Window=[Windows.Markup.XamlReader]::Load( $reader )

$buttonConnect = $Window.FindName('buttonConnect');
$combobox = $Window.FindName('combobox')


$combobox.SelectedItem = 'eomy'

foreach($actItem in $puttyItems.GetEnumerator())
{
    $combobox.Items.Add($actItem.Key)  | Out-Null
}

#Events
$buttonConnect.Add_Click({
    $action = $puttyItems.Get_Item($combobox.SelectedItem.ToString());
    $pathi = $action['Path'];
    $argsi = $action['Args'];
    Start-Process $pathi -ArgumentList $argsi
    $Window.Close();
})

$Window.ShowDialog() | Out-Null