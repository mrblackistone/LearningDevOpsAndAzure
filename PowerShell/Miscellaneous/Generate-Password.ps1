Function Get-Password {
    param (
        [parameter(ParameterSetName="Special")]
        [Switch]
        $Special,

        [parameter(ParameterSetName="LowerCase")]
        [Switch]
        $LowerCase,

	    [Int]$MaxLength = 16
    )

    If ($special) {
	    $source = @(1,2,3,4,5,6,7,8,9,0,"Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m",".","-","_","!","#","^","~")
    } elseif ($lowerCase) {
        $source = @(1,2,3,4,5,6,7,8,9,0,"q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m")
    } else {
	    $source = @(1,2,3,4,5,6,7,8,9,0,"Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m")
    }

    [int]$location = 0
    [string]$result = ""

    Do {
	    $number = get-random -maximum ($source.count - 1)
	    $result = $result + $source[$number]
	    $location++
    } until ($location -ge $maxlength)

    write-host "Your randomly-generated string is:" $result
}
