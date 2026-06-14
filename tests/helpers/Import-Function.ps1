function Import-Function {
    param (
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    if(!(Test-Path -Path $FilePath)){
        Throw('Invalid file path.')
    }

    . $File.FullName

    $ImportedFunction = Get-Command -Name $FunctionName

    if($null -eq $ImportedFunction){
        Throw('Function not imported.')
    }

    if($ImportedFunction.CommandType -ne 'Function'){
        Throw("Command is not of type 'Function'")
    }
}