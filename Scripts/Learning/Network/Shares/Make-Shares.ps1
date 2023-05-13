
# Ð¡Ð¾Ð·Ð´Ð°Ð½Ð¸Ðµ Ð°ÐºÐºÐ°ÑƒÐ½Ñ‚Ð¾Ð² Ð¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»ÐµÐ¹

function Add-SmbUsers {
    param(
        [Parameter(Mandatory = $true)]
        [System.Array] $Users
    )
    $keys = @("Password", "UserName", "Description")
    foreach ($user in $users) {
        if ([System.Linq.Enumerable]::Any([System.Linq.Enumerable]::Except([string[]]$user.Keys, [string[]]$keys))) {
            continue;
        }
        $Password = $user["Password"];
        $UserName = $user["UserName"]; 
        $Description = $user["Description"];

        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

        # ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ° Ð½Ð°Ð»Ð¸Ñ‡Ð¸Ñ ÑƒÑ‡ÐµÑ‚Ð½Ð¾Ð¹ Ð·Ð°Ð¿Ð¸ÑÐ¸
        if (!(Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
            New-LocalUser -Name $UserName -Description $Description -Password $SecurePassword -PasswordNeverExpires:$true
        }
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        Set-LocalUser -Name $UserName -Password $SecurePassword
    }
}

function Set-AccessSharedFolder {
    param(
        [Parameter(Mandatory = $true)]
        [string] $UserName,
        [Parameter(Mandatory = $true)]
        [string] $Folder,
        [Parameter()]
        [string]$ShareName,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Full", "Change", "Read")]
        [string]$AccessRight
    )

    # ÐŸÑ€ÐµÐ´Ð¾ÑÑ‚Ð°Ð²Ð»ÐµÐ½Ð¸Ðµ Ð¾Ð±Ñ‰ÐµÐ³Ð¾ Ð´Ð¾ÑÑ‚ÑƒÐ¿Ð° Ðº Ð¿Ð°Ð¿ÐºÐµ
    if (!(Get-SmbShare $ShareName -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $ShareName -Path $Folder
    }

    # Check if user has access
    $acim = Get-SmbShareAccess $ShareName
    $flag = $true
    foreach ($item in $acim) {
        $accounName = $item.CimInstanceProperties["AccountName"].Value
        # 2 - read, 1 - change, 0 - full
        $arvalue = switch ($AccessRight) { "Full" { 2 } "Read" { 1 } "Change" { 1 } }
        $accessRights = $item.CimInstanceProperties["AccessRight"].Value
        if ($accounName.EndsWith($UserName) -and $accessRights -eq $arvalue) {
            $flag = $false
            break
        }
    }

    if ($flag) {
        Grant-SmbShareAccess -Name $ShareName -AccountName $UserName -AccessRight $AccessRight -Force
    }
}

# ÐÐ°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ° Ð¿Ð°Ñ€Ð°Ð¼ÐµÑ‚Ñ€Ð¾Ð² Ð¾Ð±Ñ‰ÐµÐ³Ð¾ Ð´Ð¾ÑÑ‚ÑƒÐ¿Ð° Ðº ÑÐµÑ‚Ð¸

# Ð’Ð½ÐµÑÐµÐ½Ð¸Ðµ ÑƒÑ‡ÐµÑ‚Ð½Ð¾Ð¹ Ð·Ð°Ð¿Ð¸ÑÐ¸ Ð¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»Ñ Ð² Ð°Ð´Ñ€ÐµÑÐ½ÑƒÑŽ ÐºÐ½Ð¸Ð³Ñƒ Ricon

function Update-SmbServices {
    # ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ° Ð½Ð°Ð»Ð¸Ñ‡Ð¸Ñ, Ñ€ÐµÐ¶Ð¸Ð¼Ð° Ð·Ð°Ð¿ÑƒÑÐºÐ° Ð¸ Ð²ÐºÐ»ÑŽÑ‡Ð¸Ðµ Ð½ÐµÐ¾Ð±Ñ…Ð¾Ð´Ð¸Ð¼Ñ‹Ñ… ÑÐ»ÑƒÐ¶Ð±
    # If none of those work, make sure all networking services are running. The following services should all be set to Automatic and be currently running:
    # DNS Client
    # Function Discovery Provider Host
    # Function Discovery Resource Publication
    # HomeGroup Provider
    # HomeGroup Listener
    # Peer Networking Grouping
    # SSDP Discovery
    # UPnP Device Host

    $items = @("dnscache", "fdphost", "FDResPub", "p2psvc", "ssdpsrv", "upnphost")
    foreach ($item in $items) {
        if (($service = Get-Service -Name $item -ErrorAction SilentlyContinue)) {
            # ($service.StartType) -eq [System.ServiceProcess.ServiceStartMode]::Manual 
            if ($service.StartType -ne [System.ServiceProcess.ServiceStartMode]::Automatic) {
                $service | Set-Service -StartupType ([System.ServiceProcess.ServiceStartMode]::Automatic)
            }
            if ($service.Status -ne "Running") {
                $service | Start-Service
            }
        }
    }
}

#create firewall rules
function CreateFirewallRules {
    # setting for file and printers sharing

    $filesAndPrintersSharing = @("File And Printer Sharing", "Общий доступ к файлам и принтерам")

    try {
    
        foreach ($item in $filesAndPrintersSharing) {
            Set-NetFirewallRule -DisplayGroup $item -Enabled True -Profile Private
        }
    }
    catch {
        Write-Host $_
    }

    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

    netsh firewall set service type=fileandprint mode=enable profile=all


    # setting Network sharing

    netsh advfirewall firewall set rule group=â€network discoveryâ€ new enable=yes

    #Get-NetFirewallRule -DisplayGroup 'Network discovery' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true

    #Get-NetFirewallRule -DisplayGroup 'ÐžÐ±Ð½Ð°Ñ€ÑƒÐ¶ÐµÐ½Ð¸Ðµ ÑÐµÑ‚Ð¸' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true    
}


#Update-SmbServices

$users = @(
    @{ UserName = "SmbLibrary"; Password = "fubntx1791"; Description = "LibraryReader" },
    @{ UserName = "SmbAgitech"; Password = "fubntx17cfv,f91"; Description = "SmbAgitech" });

Add-SmbUsers -Users $users

#Set-AccessSharedFolder -UserName "SmbLibrary" -AccessRight "Read" -ShareName "Library" -Folder "D:"

Set-AccessSharedFolder -UserName "SmbAgitech" -AccessRight "Full" -ShareName "DLib" -Folder "D:"
