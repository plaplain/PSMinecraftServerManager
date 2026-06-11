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

Write-Output "Testing if output path '$OutputPath' and module path '$ModulePsdPath' exist"
if(!(Test-Path -Path $OutputPath) -or !(Test-Path -Path $ModulePsdPath)) {
    Write-Error "Output path '$OutputPath' or module path '$ModulePsdPath' does not exist."
    exit 1
}

Write-Output "Generating markdown help for module '$ModuleName' at output path '$OutputPath'"
$NewMarkdownCommandHelpParams = @{
    ModuleInfo = Get-Module -Name $ModuleName
    OutputFolder = $OutputPath
    WithModulePage = $true
}

New-MarkdownCommandHelp @NewMarkdownCommandHelpParams