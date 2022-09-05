



function ReplaceString1 {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SrcFile,
        [Parameter()]
        [string]
        $DstFile
    )
    $repl_arr = @(
        "#PubkeyAuthentication yes|PubkeyAuthentication yes",
        "#PasswordAuthentication no|PasswordAuthentication no",
        "#PasswordAuthentication yes|PasswordAuthentication no",
        "PasswordAuthentication yes|PasswordAuthentication no"
    )

    $string = [System.IO.File]::ReadAllText($SrcFile)

    foreach ($item in $repl_arr) {
        $tmp = $item.Split("|")
        $string = $string.Replace($tmp[0], $tmp[1])

    }
    [System.IO.File]::WriteAllText($DstFile, $string)
}

function ReplaceString2 {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $SrcFile,
        [Parameter()]
        [string]
        $DstFile       
    )
    
    (Get-Content $SrcFile) | 
    Foreach-Object {
        $_ # send the current line to output
        if ($_ -match "Subsystem") {
            #Add Lines after the selected pattern 
            "Text To Add"
        }
    } | Set-Content $DstFile

}

function ReplaceString3 {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$SrcFile,
        [Parameter()]
        [string]$DstFile,
        [Parameter()]
        [string[]]$Patterns
    )

    $FileContent = Get-Content $SrcFile
    $NewFileContent = @()
    foreach ($itemj in $Patterns) {
        $tmp = $itemj.Split("|")        
        foreach ($itemi in $FileContent) {
            if ($itemi -match $tmp[0]) {
                switch ($tmp[2]) {
                    "replace" {
                        $NewFileContent += $tmp[1]
                    }
                    "append" {
                        $NewFileContent += $itemi
                        $NewFileContent += $tmp[1]
                    }
                }
            }
            else {
                $NewFileContent += $itemi
            }    
        }
        $FileContent = $NewFileContent
        $NewFileContent = @()
    }
    $FileContent |  Out-File $DstFile
}


$fileName1 = "D:\temp\1\sshd_config_default"
$fileName2 = "D:\temp\2\sshd_config_1"
$fileName3 = "D:\temp\2\sshd_config_2"

$patterns = @(
    "^\#PubkeyAuthentication yes|PubkeyAuthentication yes|replace",
    "^\#PasswordAuthentication no|PasswordAuthentication no|replace",
    "^\#PasswordAuthentication yes|PasswordAuthentication no|replace",
    "^PasswordAuthentication yes|PasswordAuthentication no|replace",
    "^\# override default of no subsystems|Subsystem	powershell pwsh.exe -sshs -NoLogo -NoProfile|append"
)

#ReplaceString1 -SrcFile $fileName1 -DstFile $fileName2

ReplaceString3 -SrcFile $fileName1 -DstFile $fileName3 -Patterns $patterns

#$s1 = [System.IO.File]::ReadAllText($fileName) #string
#$s2 = Get-Content $fileName # string[]

exit