param(
    [Parameter(Mandatory=$true)][string]$ModulePath
)

Write-Output "Starting build process for module at path: $ModulePath"

$Helpers = Get-ChildItem -Path tools\build\*.ps1 -Recurse

Write-Output "Sourcing helper scripts from tools\build:"
foreach ($Helper in $Helpers) {
    . $Helper.FullName
}

# Get-ModuleManifest
Write-Output "Retrieving module manifest for module at path: $ModulePath"
$ModuleManifestPath = Get-ModuleManifestPath -ModulePath $ModulePath
$ModuleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath

# Get-Version
Write-Output "Calculating new version based on module manifest and git tags"
$Version = Get-Version -ModuleManifest $ModuleManifest

# Update-Manifest
Write-Output "Updating module manifest for version: $Version"
#Update-Manifest -ModulePath $ModulePath -ModuleManifestPath $ModuleManifestPath -Version $Version

Write-Output "Build process completed successfully for module at path: $ModulePath with version: $Version"