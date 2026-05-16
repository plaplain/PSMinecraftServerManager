
function Test-FunctionThrowsWithMissingParameter {
    param(
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    { & $FunctionName } | Should -Throw
}