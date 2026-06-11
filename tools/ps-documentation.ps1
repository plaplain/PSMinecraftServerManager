param(
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [Parameter(Mandatory = $true)][string]$ModulePsdPath,
    [Parameter(Mandatory = $true)][string]$ModuleName
)

Write-Output "Installing and importing PlatyPS module"
Install-Module -Name Microsoft.PowerShell.PlatyPS -Force -ErrorAction Stop
Import-Module Microsoft.PowerShell.PlatyPS -Force -ErrorAction Stop

Write-Output "Importing module from path: $ModulePsdPath"
Import-Module $ModulePsdPath

Write-Output "Testing if output path '$OutputPath'"
if(!(Test-Path -Path $OutputPath)) {
    Write-Error "Output path '$OutputPath' does not exist."
    exit 1
}

Write-Output "Generating markdown help for module '$ModuleName' at output path '$OutputPath'"
$NewMarkdownCommandHelpParams = @{
    ModuleInfo = Get-Module -Name $ModuleName
    OutputFolder = $OutputPath
    WithModulePage = $true
}

New-MarkdownCommandHelp @NewMarkdownCommandHelpParams

New-HelpDocument `
    -Path $OutputPath\index.md `
    -Title $ModuleName `
    -Contents @(
        # Add custom introductory text (optional)
        @{'type'='text';'value'='## Overview`nThis module provides the following cmdlets:'}
        # Auto‑list all exported commands and link to their markdown files
        @{'type'='commandlist';'module'=$ModuleName}
    )