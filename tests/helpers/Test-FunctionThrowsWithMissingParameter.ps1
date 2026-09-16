
function Test-FunctionThrowsWithMissingParameter {
    param(
        #[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'FunctionName', Justification='False positive due to how Pester works.')] 
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    { & $FunctionName } | Should -Throw
}