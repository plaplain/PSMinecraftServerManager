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
if (!(Test-Path -Path $OutputPath)) {
    Write-Error "Output path '$OutputPath' does not exist."
    exit 1
}

Write-Output "Generating markdown help for module '$ModuleName' at output path '$OutputPath'"
$NewMarkdownCommandHelpParams = @{
    ModuleInfo     = Get-Module -Name $ModuleName
    OutputFolder   = $OutputPath
    WithModulePage = $true
    Force          = $true
}

New-MarkdownCommandHelp @NewMarkdownCommandHelpParams

#Remove old files and move new files
Get-ChildItem -Path $OutputPath -File | Remove-Item -Force

$MarkdownPath = Join-Path -Path $OutputPath -ChildPath $ModuleName
Get-ChildItem -Path $MarkdownPath | Move-Item -Destination $OutputPath -Force

#Rename module page to index.md for GitHub Pages compatibility
$ModulePagePath = Join-Path -Path $OutputPath -ChildPath "$ModuleName.md"

if (!(Test-Path -Path $ModulePagePath)) {
    Write-Error "Module page '$ModulePagePath' was not created."
    exit 1
}

Rename-Item -Path $ModulePagePath -NewName "index.md"