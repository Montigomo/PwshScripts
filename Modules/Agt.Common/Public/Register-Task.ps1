
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
        [string]$TaskName,
        [Parameter(Mandatory)]
        [xml]$XmlDefinition,
        [ValidateSet('system', 'author', 'none')]
        [string]$Principal = 'none'
    )

    if(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue)
    {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    $principals = @{"author" = '<Principal id="Author"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>'};
    $contexts = @{"author" = "Author"}

    #<Principal id="Author" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>

    switch ($principal)
    {
        'none'
        {
            Register-ScheduledTask -Xml $XmlDefinition.OuterXml -TaskName $TaskName
        }
        'system'
        {
            Register-ScheduledTask -Xml $XmlDefinition.OuterXml -TaskName $TaskName -User System
        }
        'author'
        {
            $xmlDef.Task.Principals.InnerXml = $principals["author"];
            $xmlDef.Task.Actions.SetAttribute("Context", $contexts["author"])
            Register-ScheduledTask -Xml $xmlDef.OuterXml -TaskName $TaskName
        }    
    }
}