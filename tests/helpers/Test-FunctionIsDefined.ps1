function Test-FunctionIsDefined {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    . $FilePath
    (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue) | Should -Not -BeNullOrEmpty
}