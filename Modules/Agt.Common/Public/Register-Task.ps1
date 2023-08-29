function Register-Task {  
    <#
    .SYNOPSIS
        Is powershell session runned in admin mode 
    .DESCRIPTION
    .PARAMETER TaskData
        [hashtable] data for task, key = value
            "Name"   = task name
            "Values" =  hashtable for the values to be substituted into the XmlDefinition of the task
                        before the task is reregistered. Format [xpath to node] = [node value]. Examples:
                        "/ns:Task/ns:Actions/ns:Exec/ns:Command"   = "D:\temp\funny.exe";
                        "/ns:Task/ns:Actions/ns:Exec/ns:Argumetns" = "-set=12"
                        The values for the nodes on the specified xpath will be replaced with the specified ones
            "XmlDefinition" = xml task definition (can be obtained when exporting a task)
                        task xml definition contains key <Version>xxx</Version> which can be used to check the task is registred in the Task Scheduller
                        is actual, if task definition that send has a higher version number than registred in the Task Sheduller
                        registred task will be unregistred and new will one
    .PARAMETER Principal
        [string] one of the set values, which is used as the princiapl when registering the task (not used in the current edition)
    .PARAMETER OnlyCheck
        [switch] Just check if task with specified name exist
    .PARAMETER Force
        [switch] for future use
    .INPUTS
    .OUTPUTS
    .NOTES
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
        [switch]$OnlyCheck,
        [switch]$Force
    )

    $taskName = $TaskData["Name"];
    
    $xml = [xml]$TaskData["XmlDefinition"];
  
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
  
    $registredTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
  
    $needRegister = $false;
  
    if ($registredTask) {
        $registrationInfo = $xml.SelectSingleNode("/ns:Task/ns:RegistrationInfo/ns:Version", $ns);
        if ($registrationInfo) {
   
            $currentVersion = [System.Version]::Parse("0.0.0")
            $result = [System.Version]::TryParse($registrationInfo.InnerText, [ref]$currentVersion)
            $installedVersion = [System.Version]::Parse("0.0.0")
            $result = [System.Version]::TryParse($registredTask.Version, [ref]$installedVersion)
            $needRegister = ($currentVersion -gt $installedVersion)
  
        }
        if ( (-not $needRegister)) {
            $needRegister = ($registredTask.State -eq "Disabled")
        }
    }
    else {
        $needRegister = $true
    }
  
    if ($OnlyCheck) {
        return -not $needRegister
    }
  
    if (!$needRegister) {
        return $needRegister
    }
  
    # replace values

    if ($TaskData["Values"]) {
        foreach ($item in $TaskData["Values"].Keys) {
            $xmlNode = $xml.SelectSingleNode($item, $ns);
            if ($xmlNode) {
                $innerText = $TaskData["Values"][$item]
                $xmlNode.InnerText = $innerText
            }
        }
    }

    if ($registredTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }
  
    $principals = @{"author" = '<Principal id="Author"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>' };
    $contexts = @{"author" = "Author" }
  
    #<Principal id="Author" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><GroupId>S-1-1-0</GroupId><RunLevel>HighestAvailable</RunLevel></Principal>
  
    switch ($principal) {
        'none' {
            Register-ScheduledTask -Xml $xml.OuterXml -TaskName $taskName
        }
        'system' {
            Register-ScheduledTask -Xml $xml.OuterXml -TaskName $taskName -User System
        }
        'author' {
            $xml.Task.Principals.InnerXml = $principals["author"];
            $xml.Task.Actions.SetAttribute("Context", $contexts["author"])
            Register-ScheduledTask -Xml $xml.OuterXml -TaskName $TaskName
        }    
    }
    return $true
}