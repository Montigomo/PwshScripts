
<#
.SYNOPSIS
	Get Is powershell session runned in admin mode 
.DESCRIPTION
.PARAMETER Name
.PARAMETER Extension
.INPUTS
.OUTPUTS
.EXAMPLE
.EXAMPLE
.EXAMPLE
.LINK
http://www.xxx.com
#>

function Invoke-RunAs
{
    [CmdletBinding()]
    param(
        [Alias('PSPath')]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        ${FilePath},

        [Parameter(Mandatory = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},

        [Alias('Args')]
        [Parameter(ValueFromRemainingArguments = $true)]
        [System.Object[]]
        ${ArgumentList},

        [Parameter(Position = 1)]
        [System.Collections.IDictionary]
        $NamedArguments
    )
    begin
    {
        # First we set up a separate managed powershell process
        Write-Verbose "Creating PowerShellProcessInstance and runspace"
        $ProcessInstance = [System.Management.Automation.Runspaces.PowerShellProcessInstance]::new($PSVersionTable.PSVersion, $Credential, $null, $false)

        # And then we create a new runspace in said process
        $Runspace = [runspacefactory]::CreateOutOfProcessRunspace($null, $ProcessInstance)
        $Runspace.Open()
        Write-Verbose "Runspace state is $($Runspace.RunspaceStateInfo)"
    }
    process
    {
        foreach($path in $FilePath){
            Write-Verbose "In process block, Path:'$path'"
            try{
                # Add script file to the code we'll be running
                $powershell = [powershell]::Create([initialsessionstate]::CreateDefault2()).AddCommand((Resolve-Path $path).ProviderPath, $true)

                # Add named param args, if any
                if($PSBoundParameters.ContainsKey('NamedArguments')){
                    Write-Verbose "Adding named arguments to script"
                    $powershell = $powershell.AddParameters($NamedArguments)
                }

                # Add argument list values if present
                if($PSBoundParameters.ContainsKey('ArgumentList')){
                    Write-Verbose "Adding unnamed arguments to script"
                    foreach($arg in $ArgumentList){
                        $powershell = $powershell.AddArgument($arg)
                    }
                }

                # Attach to out-of-process runspace
                $powershell.Runspace = $Runspace

                # Invoke, let output bubble up to caller
                $powershell.Invoke()

                if($powershell.HadErrors){
                    foreach($e in $powershell.Streams.Error){
                        Write-Error $e
                    }
                }
            }
            finally{
                # clean up
                if($powershell -is [IDisposable]){
                    $powershell.Dispose()
                }
            }
        }
    }
    end
    {
        foreach($target in $ProcessInstance,$Runspace){
            # clean up
            if($target -is [IDisposable]){
                $target.Dispose()
            }
        }
    }
}