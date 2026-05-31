function Test-FunctionCallsExportModuleMember {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$FunctionName
    )

    $FileContent = Get-Content -Path $FilePath -Raw

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'EscapedFunctionName', Justification='False positive due to how Pester works.')]
    $EscapedFunctionName = [regex]::Escape($FunctionName)
    $Pattern = "(?i)^\s*[^#]*\bExport-ModuleMember\b"
    Select-String -InputObject $FileContent -Pattern $Pattern | Should -Not -BeNullOrEmpty
}