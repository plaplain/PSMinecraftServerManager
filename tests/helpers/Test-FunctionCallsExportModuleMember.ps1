function Test-FunctionCallsExportModuleMember {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    $FileContent = Get-Content -Path $FilePath -Raw

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'EscapedFunctionName', Justification='False positive due to how Pester works.')]
    $EscapedFunctionName = [regex]::Escape($FunctionName)
    $Pattern = "(?<!#(?:\s*))Export-ModuleMember '$EscapedFunctionName'"
    $FileContent -match $Pattern | Should -BeTrue
}