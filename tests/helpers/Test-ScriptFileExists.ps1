function Test-ScriptFileIsPresent {
    param(
        [Parameter(Mandatory = $true)][string]$PSScriptRoot,
        [Parameter(Mandatory = $true)][string]$ScriptRelativePath
    )

    $Resolved = Resolve-Path (Join-Path $PSScriptRoot $ScriptRelativePath) -ErrorAction Stop
    Test-Path $Resolved | Should -Be $true
}