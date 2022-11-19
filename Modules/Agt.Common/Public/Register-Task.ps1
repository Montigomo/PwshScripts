
function Register-Task {  
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
        [hashtable]$Replacements,
        [ValidateSet('system', 'author', 'none')]
        [string]$Principal = 'none',
        [switch]$OnlyCheck,
        [switch]$Force
    )

    $taskName = $TaskData["Name"];
    
    function Replaceitems([string]$text){
        #
        $outText = $text
        foreach($item in $Replacements.Keys) {
            $findtext = "{$item}"
            $value = $Replacements[$item]
            if($outText -match $findtext){
                $outText = $outText -replace $findtext, $value
            }
        }
        return $outText
    }  

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
                $innerText = Replaceitems -text $innerText
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