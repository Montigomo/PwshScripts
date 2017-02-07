
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

###
if((Test-Path variable:global:SETTING_OPTIONS) -eq $false)
{
    # typedef enum  {
    New-Variable -Name SETTING_OPTIONS -Value (@{
        'Logitech' = @{
            'Backup' = @{
                'copyfiles' = @{
                    [System.IO.Path]::Combine($env:LOCALAPPDATA, "Logitech\Logitech Gaming Software", "settings.json") = 
                    [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments") ,"_info\Logitech", "settings.json");
                    [System.IO.Path]::Combine($env:LOCALAPPDATA, "Logitech\Logitech Gaming Software\profiles", "{09D92D75-3C8C-4723-B06C-4090BCB899C0}.xml") = 
                    [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments") ,"_info\Logitech", "{09D92D75-3C8C-4723-B06C-4090BCB899C0}.xml")
                }
            };
            'Restore' = @{
                'copyfiles' = @{
                   
                    [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments") ,"_info\Logitech", "settings.json") =
                    [System.IO.Path]::Combine($env:LOCALAPPDATA, "Logitech\Logitech Gaming Software", "settings.json");
                    [System.IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments") ,"_info\Logitech", "{09D92D75-3C8C-4723-B06C-4090BCB899C0}.xml") = 
                    [System.IO.Path]::Combine($env:LOCALAPPDATA, "Logitech\Logitech Gaming Software\profiles", "{09D92D75-3C8C-4723-B06C-4090BCB899C0}.xml")
                }
            }
        }
    }) -Option constant
    # }   SETTING_OPTIONS;
}
###





function Operate-WithSettings
{
  [CmdletBinding()]
  Param
  (
    [Parameter(mandatory=$true)]
    [ValidateSet('All', 'Logitech')]
    [string]$Provider,
    [Parameter(mandatory=$true)]
    [ValidateSet('Backup', 'Restore')]
    [string]$Action
  )

  begin 
  {
  }

  process
  {
    $actionFlag = if($Action -eq 'Backup') {$false} else {$true}

    $prov = $SETTING_OPTIONS.Get_Item($Provider);
    if(!$prov) { return;}
    $actions = $prov.Get_Item($Action);
    if(!$actions) { return;}

    foreach($actItem in $actions.GetEnumerator())
    {
        if($actItem.Key -eq 'copyfiles')
        {
            foreach($caitem in $actItem.Value.GetEnumerator())
            {
                Write-Output ('{0} coping {1}from {2}{3}to {4}{5}' -f  $Action, [System.Environment]::NewLine, $caitem.Key, [System.Environment]::NewLine, $caitem.Value, [System.Environment]::NewLine);
                Copy-Item -Path $caitem.Key -Destination $caitem.Value #-WhatIf
            }
        }
    }

   }
   end
   {
   }
}













$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(600,400)  

############################################## Start functions

function pingInfo
{
    $provider=$DropDownBox.SelectedItem.ToString() #populate the var with the value you selected

    if ($RadioButton1.Checked -eq $true)
    {
        $pingResult= Operate-WithSettings -Provider $provider -Action Restore
    }
    elseif($RadioButton2.Checked -eq $true)
    {
        $pingResult= Operate-WithSettings -Provider $provider -Action Backup
    }
            $outputBox.text=$pingResult
} #end pingInfo

############################################## end functions

############################################## Start group boxes

$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(270,20) 
$groupBox.size = New-Object System.Drawing.Size(100,100) 
$groupBox.text = "Nr of pings:" 
$Form.Controls.Add($groupBox) 

############################################## end group boxes

############################################## Start radio buttons

$RadioButton1 = New-Object System.Windows.Forms.RadioButton 
$RadioButton1.Location = new-object System.Drawing.Point(15,15) 
$RadioButton1.size = New-Object System.Drawing.Size(80,20) 
$RadioButton1.Checked = $true 
$RadioButton1.Text = "Restore" 
$groupBox.Controls.Add($RadioButton1) 

$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = new-object System.Drawing.Point(15,45)
$RadioButton2.size = New-Object System.Drawing.Size(80,20)
$RadioButton2.Text = "Backup"
$groupBox.Controls.Add($RadioButton2)

############################################## end radio buttons

############################################## Start drop down boxes

$DropDownBox = New-Object System.Windows.Forms.ComboBox
$DropDownBox.Location = New-Object System.Drawing.Size(20,50) 
$DropDownBox.Size = New-Object System.Drawing.Size(180,20) 
$DropDownBox.DropDownHeight = 200 
$Form.Controls.Add($DropDownBox) 

$wksList={@()}.Invoke();

foreach($item in $SETTING_OPTIONS.GetEnumerator())
{
    $wksList.Add(($item.Key))
}

foreach ($wks in $wksList) {
                      $DropDownBox.Items.Add($wks)
                              } #end foreach
$DropDownBox.SelectedIndex = 0;
############################################## end drop down boxes

############################################## Start text fields

$outputBox = New-Object System.Windows.Forms.TextBox 
$outputBox.Location = New-Object System.Drawing.Size(10,150) 
$outputBox.Size = New-Object System.Drawing.Size(565,200) 
$outputBox.MultiLine = $True 

$outputBox.ScrollBars = "Vertical" 
$Form.Controls.Add($outputBox) 

############################################## end text fields

############################################## Start buttons

$Button = New-Object System.Windows.Forms.Button 
$Button.Location = New-Object System.Drawing.Size(400,30) 
$Button.Size = New-Object System.Drawing.Size(110,80) 
$Button.Text = "Run" 
$Button.Add_Click({pingInfo}) 
$Form.Controls.Add($Button) 

############################################## end buttons

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()
