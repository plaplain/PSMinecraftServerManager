function New-ImportCmdletParameterString {
    param(
        [Parameter(Mandatory=$true)][array]$SplitParameters
    )

    $ParameterIndex = 0
    $OutputString = ''

    while($ParameterIndex -lt $SplitParameters.count){
        $Parameter = $SplitParameters[$ParameterIndex]
        $LastParameter = $false

        if(($ParameterIndex + 1) -eq $SplitParameters.count){
            $LastParameter = $true
        }

        if($null -ne $Parameter){
            $OutputString += [string]$Parameter + '$' + $ParameterIndex
        }

        if($LastParameter -eq $false){
            $OutputString += ','
        }

        $ParameterIndex++
    }

    $OutputString
}