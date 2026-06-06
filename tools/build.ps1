param(
    [Parameter(Mandatory=$true)][string]$ModulePath
)

Write-Information "Starting build process for module at path: $ModulePath"

$Helpers = Get-ChildItem -Path tools\build\*.ps1 -Recurse

Write-Information "Sourcing helper scripts from tools\build:"
foreach ($Helper in $Helpers) {
    . $Helper.FullName
}

# Get-ModuleManifest
Write-Information "Retrieving module manifest for module at path: $ModulePath"
$ModuleManifestPath = Get-ModuleManifestPath -ModulePath $ModulePath
$ModuleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath

# Get-Version
Write-Information "Calculating new version based on module manifest and git tags"
$Version = Get-Version -ModuleManifest $ModuleManifest

# Update-Manifest
Write-Information "Updating module manifest for version: $Version"
Update-Manifest -ModulePath $ModulePath -ModuleManifestPath $ModuleManifestPath -Version $Version