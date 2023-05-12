
function DoConfig {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$SrcFile,
        [Parameter()]
        [string]$DstFile,
        [Parameter()]
        [hashtable[]]$Patterns
    )

    function GetMatch {
        param(
            [object]$item
        )
        if ($item -is [string]) {
            $item
        }
        elseif ($item -is [hashtable]) {
            if ($item["Match"]) {
                $item["Match"] -f $item["Value"] 
            }
            else {
                $item["Value"]
            }
        }
    }
    function GetValue {
        param(
            [object]$item
        )
        if ($item -is [string]) {
            $item
        }
        elseif ($item -is [hashtable]) {
            $item["Value"]
        }
    }
    [Collections.Generic.List[String]]$Content = (Get-Content $SrcFile)

    foreach ($item in $Patterns) {
        $key = $item["Key"]
        $action = $item["Action"];
        $value = $item["Value"];
        $after = $item["After"];
        switch ($action) {
            "Uncomment" {
                $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $key) })
                if ($index -gt -1) {
                    $Content[$index] = $Content[$index] -replace '\#+(.*)', '$1'
                }
            }
            "Comment" {
                $indexFrom = 0;
                if ($after) {
                    $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $after) })
                    $indexFrom = if ($index -gt -1) { $index }else { 0 }
                }
                $index = $Content.FindIndex($indexFrom, [Predicate[String]] { param($s) $s -match (GetMatch $key) })
                if ($index -gt -1) {
                    $Content[$index] = "#$($Content[$index])"
                }
            }
            "SetValue" {
                $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $key) })
                if ($index -gt -1) {
                    $Content[$index] = "$(GetValue $key) $value"
                }
            }
            "Append" {
                $c = ($Content | Where-Object { $_ -eq $value }).Count
                if ($c -lt 1) {
                    if ($after) {
                        $index = $Content.FindIndex([Predicate[String]] { param($s) $s -match (GetMatch $after) })
                    }
                    if ($index -gt -1) {
                        $Content.Insert($index + 1, $value)
                    }
                    else {
                        $Content.Add($value);
                    }
                }               
            }
            "Distinct" {
                $c = ($Content | Where-Object { $_ -eq (GetValue $key) }).Count
                if ($c -le 1) {
                    continue;
                }
                do {
                    $Content.RemoveAt($Content.FindLastIndex([Predicate[String]] { param($s) $s -match (GetMatch $key) }));
                    $c = ($Content | Where-Object { $_ -eq (GetValue $key) }).Count
                }while ($c -gt 1)

            }
        }
    }

    $Content |  Out-File $DstFile
}






$sshConfigFile = "$env:ProgramData/ssh/sshd_config"

$SrcFile = "D:/temp/2/sshd_config_default"
$DstFile = "D:/temp/3/sshd_config"


$patterns = @(
    @{
        "Key"    = @{"Value" = "PubkeyAuthentication"; "Match" = "\#?\s*{0}.*" }; 
        "Action" = "SetValue"; 
        "Value"  = "yes" 
    },
    @{
        "Key"    = @{"Value" = "StrictMode"; "Match" = "\#?\s*{0}.*" };
        "Action" = "SetValue"; 
        "Value"  = "no" 
    }
    @{
        "Key"    = @{"Value" = "PasswordAuthentication"; "Match" = "\#?\s*{0}.*" };
        "Action" = "SetValue"; 
        "Value"  = "no" 
    }
    @{
        "Key"    = @{"Value" = "Subsystem" }; 
        "Action" = "Append"; 
        "Value"  = "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile";
        "After"  = "\#\s*override default of no subsystems"; 
    }
    @{
        "Key"    = @{"Value" = "Subsystem powershell pwsh.exe -sshs -NoLogo -NoProfile" }; 
        "Action" = "Distinct"; 
    }
    @{
        "Key"    = @{"Value" = "Match Group administrators" };
        "Action" = "Comment"; 
    }
    @{
        "Key"    = @{"Value" = "AuthorizedKeysFile" };
        "Action" = "Comment"; 
        "After"  = @{"Value" = "Match Group administrators"; "Match" = "\#?\s*{0}.*" }
    }
)

DoConfig -SrcFile $SrcFile -DstFile $DstFile -Patterns $patterns