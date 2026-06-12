
function Test-FunctionThrowsWithMissingParameter {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'FunctionName', Justification='False positive due to how Pester works.')]
    param(
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    { & $FunctionName } | Should -Throw
}