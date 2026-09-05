# Written by fflaten: https://github.com/pester/Pester/discussions/2365
function New-SequentialResultsMockBehavior {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object[]] $SequentialResults
    )

    $mockCallCounter = 0

    $mockScriptBlock = {
        $currentIndex = $script:mockCallCounter++
        if ($mockCallCounter -gt $SequentialResults.Count) {
            throw 'Unexpected call. No more results are available.'
        }

        return $SequentialResults[$currentIndex]
    }.GetNewClosure()

    return $mockScriptBlock
}