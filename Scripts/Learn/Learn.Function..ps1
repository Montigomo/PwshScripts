


# In functions that have the CmdletBinding attribute, unknown parameters and positional arguments that have no matching positional parameters cause parameter binding to fail.
function TestA
{
    [CmdletBinding()]
    Param([switch] $A,[switch] $B,[switch] $C)
    Write-Output "A:$A, B:$B, C:$C"
}

function TestB
{
    Param([switch] $A,[switch] $B,[switch] $C)
    Write-Output "A:$A, B:$B, C:$C"
}

# fail
#TestA -dddd -A
#not fail
#TestB -dddd -A

# test $input variable
function InputA
{
    [CmdletBinding()]
    Param($a,$b,$c,$d)
    #Write-Output $input.GetType()
    #Write-Output $PSCmdlet.GetType() 
    #$Args.GetType()# | ForEach-Object {Write-Output $_}
}
function InputB
{
    #Write-Output $input.GetType()
    #Write-Output $Args.GetType()
    #$Args# | ForEach-Object {Write-Output $_}
    $input | ForEach-Object {Write-Output $_}
}

#(InputA 1 2 3 4)#.GetType() # ForEach-Object {Write-Output $_}
#(InputB 1 2 3 4) | ForEach-Object {Write-Output $_}
{
    param($a)
    $input.GetType()
    $input | ForEach-Object {Write-Output $_};
    $Args.GetType()
    $Args | ForEach-Object {Write-Output $_};
}.Invoke(1, 2, 3, 4)
