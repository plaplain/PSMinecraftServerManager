function Test-ClassIsDefined {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$ClassName
    )

    . $FilePath
    New-Object -TypeName $ClassName | Should -Not -BeNullOrEmpty
}