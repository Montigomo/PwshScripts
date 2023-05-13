


# # process a list of things, can be anything
# $somedataToProcess = 1,2,3, 4,5,6
 
# # empty array:
# $array = @()
# foreach ($item in $somedataToProcess)
# {
#     # add array elements
#     $array += $item * $item
# }
# $array.Count


# process a list of things, can be anything
$somedataToProcess = 1,2,3, 4,5,6
 
$array = foreach ($item in $somedataToProcess)
{
    $item * $item
}
$array.Count