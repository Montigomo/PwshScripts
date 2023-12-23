[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$RuleSetName
)

. "$PSScriptRoot\Init-Actions.ps1" | Out-Null

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
},{
    "RulesSetName" : "Simple_dnla",
    "Objects":  [
    {
        "RuleName" : "in_UDP",
        "RuleParams" : { 
            "DisplayName" : "{RulesSetName}_{RuleName}",  
            "Name" : "{RulesSetName}_{RuleName}",
            "Action" : "Allow",
            "Enabled" :  "True",
            "Direction": "Inbound",
            "Protocol" : "UDP",        
            "Program" : "D:\\software\\simpledlna\\simpledlna.exe",
            "Action" : "Allow",
            "EdgeTraversalPolicy" : "DeferToUser",
            "Profile" : "Private, Public"
        }
    },
    {
        "RuleName" : "in_TCP",
        "RuleParams" : {         
            "DisplayName" : "{RulesSetName}_{RuleName}",  
            "Name" : "{RulesSetName}_{RuleName}",
            "Action" : "Allow",
            "Enabled" :  "True",
            "Direction": "Inbound",
            "Protocol" : "TCP",        
            "Program" : "D:\\software\\simpledlna\\simpledlna.exe",
            "Action" : "Allow",
            "EdgeTraversalPolicy" : "DeferToUser",
            "Profile" : "Private, Public"
        }
    }]
}]
"@

# New-NetFirewallRule
#    [-PolicyStore <String>]
#    [-GPOSession <String>]
#    [-Name <String>]
#    -DisplayName <String>
#    [-Description <String>]
#    [-Group <String>]
#    [-Enabled <Enabled>]
#    [-Profile <Profile>]
#    [-Platform <String[]>]
#    [-Direction <Direction>]
#    [-Action <Action>]
#    [-EdgeTraversalPolicy <EdgeTraversal>]
#    [-LooseSourceMapping <Boolean>]
#    [-LocalOnlyMapping <Boolean>]
#    [-Owner <String>]
#    [-LocalAddress <String[]>]
#    [-RemoteAddress <String[]>]
#    [-Protocol <String>]
#    [-LocalPort <String[]>]
#    [-RemotePort <String[]>]
#    [-IcmpType <String[]>]
#    [-DynamicTarget <DynamicTransport>]
#    [-Program <String>]
#    [-Package <String>]
#    [-Service <String>]
#    [-InterfaceAlias <WildcardPattern[]>]
#    [-InterfaceType <InterfaceType>]
#    [-LocalUser <String>]
#    [-RemoteUser <String>]
#    [-RemoteMachine <String>]
#    [-Authentication <Authentication>]
#    [-Encryption <Encryption>]
#    [-OverrideBlockRules <Boolean>]
#    [-RemoteDynamicKeywordAddresses <String[]>]
#    [-CimSession <CimSession[]>]
#    [-ThrottleLimit <Int32>]
#    [-AsJob]
#    [-WhatIf]
#    [-Confirm]
#    [<CommonParameters>]


# DLNS
# I checked my own firewall setup on Windows 7 64 bit regarding UMS and I have following incoming 'allow' rules in place that you might want to check in your setup:
# - javaw.exe (TCP)
# - ums.exe (Any)
# - wrapper.exe (Any); you only need this one when running UMS as a service
# - port 5001 rule (Any); the default UMS listening port (also if you're using a different port number you have to use that value)
# - port 2869 rule (TCP); used for DLNA / uPNP discovery (SSDP)
# - port 1900 rule (UDP); used for DLNA / uPNP discovery (SSDP)


Get-ModuleAdvanced -ModuleName "NetSecurity"

function Import-FirewallRule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$RuleSetName
    )

    $jsonObject = ($jsonString | ConvertFrom-Json) | Where-Object { $_.RulesSetName -eq $RuleSetName }

    if (-not $jsonObject) {
        Write-Host "Ruleset $RuleSetName not founded" -ForegroundColor DarkYellow
        return
    }

    foreach ($item in $jsonObject.Objects) {
        $RuleName = $item.RuleName
        $Params = @{}
        foreach ($property in $item.RuleParams.PSObject.properties) {
            $name = $property.Name
            $value = $property.Value
            $value = $value -replace "{RulesSetName}", $RuleSetName
            $value = $value -replace "{RuleName}", $RuleName
            $Params[$name] = $value
        }

        New-NetFirewallRule @Params
    }
}

Import-FirewallRule -RuleSetName "Simple_dnla"