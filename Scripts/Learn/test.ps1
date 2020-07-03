

function Test-ArgumentCompleter {
    [CmdletBinding()]
     param (
            [Parameter(Mandatory=$true)]
            [ValidateSet('Fruits', 'Vegetables')]
            $Type,
            [Parameter(Mandatory=$true)]
            [ArgumentCompleter( {
                param ( $commandName,
                        $parameterName,
                        $wordToComplete,
                        $commandAst,
                        $fakeBoundParameters )
    
                $possibleValues = @{
                    Fruits = @('Apple', 'Orange', 'Banana')
                    Vegetables = @('Tomato', 'Squash', 'Corn')
                }
                if ($fakeBoundParameters.ContainsKey('Type'))
                {
                    $possibleValues[$fakeBoundParameters.Type] | Where-Object {
                        $_ -like "$wordToComplete*"
                    }
                }
                else
                {
                    $possibleValues.Values | ForEach-Object {$_}
                }
            } )]
            $Value
          )
    }



    # $appname = "Windows PowerShell"

    # $shellVar = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}');

    # ($shellVar.Items() | 
    # Where-Object{$_.Name -eq $appname}).Verbs() | 
    # Where-Object{$_.Name.replace('&','') -match 'From "Start" UnPin|Unpin from Start'} | 
    # ForEach-Object {$_.DoIt()}


    # $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
    # if(Test-Path $pwshPath -PathType Leaf)
    # {
    #     if(!(Test-Path "HKLM:\SOFTWARE\OpenSSH"))
    #     {
    #         New-Item 'HKLM:\Software\OpenSSH' -Force #| New-ItemProperty -Name DisableHelpSticker -Value 1 -Force | Out-Null
    #     }
    #     New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String –Force
    # }

    if(Get-Service  sshd -ErrorAction SilentlyContinue)
    {
        if((get-service sshd).StartType -eq [System.ServiceProcess.ServiceStartMode]::Manual)
        {
            Get-Service -Name sshd | Set-Service -StartupType 'Automatic'
            Start-Service sshd
        }
    }