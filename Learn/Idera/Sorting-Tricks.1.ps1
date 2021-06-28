

$displayName = @{
    Expression = "DisplayName"
    Descending = $false
}
 
#Get-Service | Sort-Object -Property Status, @{    Expression = "DisplayName";   Descending = $false} -Descending


# compose password out of these
$Capitals = 2
$Numbers = 1
$lowerCase = 3
$Special = 1
 
# collect random chars from different lists in $chars
$chars = & {
    'ABCDEFGHKLMNPRSTUVWXYZ'.ToCharArray() | Get-Random -Count $Capitals
    '23456789'.ToCharArray() | Get-Random -Count $Numbers
    'abcdefghkmnprstuvwxyz'.ToCharArray() | Get-Random -Count $lowerCase
    '!§$%&?=#*+-'.ToCharArray() | Get-Random -Count $Special
} | # <- don't forget pipeline symbol!
# sort them randomly
Sort-Object -Property { Get-Random }
 
# convert chars to one string
$password =  -join $chars 
$password 