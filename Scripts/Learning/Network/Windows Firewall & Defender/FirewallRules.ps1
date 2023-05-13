
$jsonString = @"
[{
    "RulesSetName" : "utorrentWebUI",
    "Objects": [
    {
        "RuleName":"TCP_out",
        "RuleParams" : { 
            "DisplayName" : "{RulesSetName}_{RuleName}",  
            "Name" : "{RulesSetName}_{RuleName}",
            "Direction" : "Outbound",
            "InterfaceType" : "Any",
            "Action" : "Allow",
            "RemoteAddress" : "Any",
            "LocalPort" : "9999",
            "Protocol" : "TCP",
            "Enabled" : "True"
        }
    },
    {
        "RuleName" : "TCP_in",
        "RuleParams" : { 
            "DisplayName" : "{RulesSetName}_{RuleName}",  
            "Name" : "{RulesSetName}_{RuleName}",
            "Direction" : "Inbound",
            "InterfaceType" : "Any",
            "Action" : "Allow",
            "RemoteAddress" : "Any",
            "LocalPort" : "9999",
            "Protocol" : "TCP",
            "Enabled" : "True"
        }
    },
    {
        "RuleName" : "UDP_out",
        "RuleParams" : { 
            "DisplayName" : "{RulesSetName}_{RuleName}",  
            "Name" : "{RulesSetName}_{RuleName}",
            "Direction" : "Inbound",
            "InterfaceType" : "Any",
            "Action" : "Allow",
            "RemoteAddress" : "Any",
            "LocalPort" : "9999",
            "Protocol" : "UDP",
            "Enabled" : "True"
        }
    },
    {
        "RuleName" : "UDP_in",
        "RuleParams" : { 
            "DisplayName" : "{RulesSetName}_{RuleName}",  
            "Name" : "{RulesSetName}_{RuleName}",
            "Direction" : "Inbound",
            "InterfaceType" : "Any",
            "Action" : "Allow",
            "RemoteAddress" : "Any",
            "LocalPort" : "9999",
            "Protocol" : "UDP",
            "Enabled" : "True"
        }
    }]
},
{
    "RulesSetName" : "YAWC_Service",
    "Objects":  [
    {
        "_000": { 
            "DisplayName" : "###",  
            "Name" : "###",
            "Direction" : "Outbound",
            "Program" : "C:\\Program Files (x86)\\Yawcam\\Yawcam_Service.exe",
            "Profile" : "Any",
            "Action" : "Allow",
            "Enabled" : "True"
        }
    },
    {
        "_001": { 
            "DisplayName" : "###",  
            "Name" : "###",
            "Program" : "C:\\Program Files (x86)\\Yawcam\\Yawcam_Service.exe",
            "RemoteAddress" : "LocalSubnet",
            "Action" : "Allow",
            "Protocol" : "ICMPv4",
            "IcmpType" : "8",
            "Enabled" :  "True",
            "Profile" : "Any",
            "Action" : "Allow"
        }
    }]
}]
"@

Import-Module NetSecurity

function Import-FirewallRule{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RuleSetName
    )

    $jsonObject = ($jsonString | ConvertFrom-Json -Depth 5) | Where-Object { $_.RulesSetName -eq $RuleSetName}

    foreach($item in $jsonObject.Objects){
        $RuleName = $item.RuleName
        $Params = @{}
        foreach($property in $item.RuleParams.PSObject.properties){
            $name = $property.Name
            $value = $property.Value
            $value = $value -replace "{RulesSetName}", $RuleSetName
            $value = $value -replace "{RuleName}", $RuleName
            $Params[$name] = $value
        }

        New-NetFirewallRule @Params
    }
}

Import-FirewallRule -RuleSetName "utorrentWebUI"

### usefull commands
# view state of windows firewall
# Get-NetFirewallProfile | select Name, Enabled
# turn on|off
# Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled True
# Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

#New-NetFirewallRule -DisplayName 'Custom Inbound' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort 11000-12000

exit 

function RestWeb {
    Import-Module NetSecurity
    # rest web api
    New-NetFirewallRule -Name "RestWebRunner" -DisplayName “RestWebRunner” -Description “RestWebRunner”-Protocol TCP -Profile Any -Action Allow -Enabled True -LocalPort 8080
}

function FilePrinterShares {
    Set-NetFirewallRule -DisplayGroup “File And Printer Sharing” -Enabled True -Profile Private
}

function SqlServer {
    New-NetFirewallRule -DisplayName "SQLServer default instance" -Direction Inbound -LocalPort 1433 -Protocol TCP -Action Allow
    New-NetFirewallRule -DisplayName "SQLServer Browser service" -Direction Inbound -LocalPort 1434 -Protocol UDP -Action Allow	
}

function GitServer {
    [CmdletBinding()]
    param ([Parameter()][switch]$Remove)
    New-NetFirewallRule -Name "BonoboGetServer" -DisplayName "Bonobo Git Server" -Description "Git Server" `
        -Protocol TCP -Profile Any -Action Allow -Enabled True -LocalPort 8888
}