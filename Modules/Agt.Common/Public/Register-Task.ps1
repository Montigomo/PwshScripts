
function Register-Task
{  
    <#
    .SYNOPSIS
        Is powershell session runned in admin mode 
    .DESCRIPTION
    .PARAMETER Name
    .INPUTS
    .OUTPUTS
    .EXAMPLE
    .LINK
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [hashtable]$TaskData,
        [ValidateSet('system', 'author', 'none')]
        [string]$Principal = 'none',
        [switch]$Force
    )

    $taskName = $TaskData["Name"];

    $xmlDefinition = [xml]$TaskData["XmlDefinition"];

    if((Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) )
    {
      if(-not $Force)
      {
        return
      }
      else {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false;
      }
    }

    $principals = @{"author" = '<Principal id="Author"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>'};
    $contexts = @{"author" = "Author"}

    #<Principal id="Author" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>

    switch ($principal)
    {
        'none'
        {
            Register-ScheduledTask -Xml $xmlDefinition.OuterXml -TaskName $taskName
        }
        'system'
        {
            Register-ScheduledTask -Xml $xmlDefinition.OuterXml -TaskName $taskName -User System
        }
        'author'
        {
            $xmlDefinition.Task.Principals.InnerXml = $principals["author"];
            $xmlDefinition.Task.Actions.SetAttribute("Context", $contexts["author"])
            Register-ScheduledTask -Xml $xmlDefinition.OuterXml -TaskName $TaskName
        }    
    }
}