
function Show-ConsoleDialog
{
  param
  (
    [Parameter(Mandatory)]
    [string]
    $Message,
    
    [string]
    $Title = 'PowerShell',
    
    # do not use choices with duplicate first letter
    # submit any number of choices you want to offer
    [string[]]
    $Choice = ('Yes', 'No')
  
    
  
  )
 
 
  # turn choices into ChoiceDescription objects
  $choices = foreach ($_ in $choice)
  {
    [System.Management.Automation.Host.ChoiceDescription]::new("&$_", $_)
  }
 
  # translate the user choice into the name of the chosen choice
  $choices[$host.ui.PromptForChoice($title, $message, $choices, 1)]. Label.Substring(1)
} 

$result = Show-ConsoleDialog -Message 'Restarting Server?' -Title 'Will restart server for maintenance' -Choice 'Yes','No' ,'Later','Never','Always'
 
switch ($result)
{
    'Yes'        { 'restarting' }
    'No'         { 'doing nothing' }
    'Later'      { 'ok, later' }
    'Never'      { 'will not ask again' }
    'Always'     { 'restarting without notice now and ever' }
}