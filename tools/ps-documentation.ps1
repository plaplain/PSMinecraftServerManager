param(
    [Parameter(Mandatory = $true)][string]$OutputPath,
    [Parameter(Mandatory = $true)][string]$ModulePsdPath,
    [Parameter(Mandatory = $true)][string]$ModuleName
)

Install-Module -Name Microsoft.PowerShell.PlatyPS -Force -ErrorAction Stop
Import-Module Microsoft.PowerShell.PlatyPS -Force -ErrorAction Stop

Import-Module $ModulePath

if(!(Test-Path -Path $OutputPath) -or !(Test-Path -Path $CodePath)) {
    Write-Error "Output path '$OutputPath' or code path '$CodePath' does not exist."
    exit 1
}

$NewMarkdownCommandHelpParams = @{
    ModuleInfo = Get-Module -Name $ModuleName
    OutputFolder = $OutputPath
    WithModulePage = $true
}

New-MarkdownCommandHelp @NewMarkdownCommandHelpParams