
function Test-FunctionThrowsWithMissingParameters {
    param(
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    { & $FunctionName } | Should -Throw
}