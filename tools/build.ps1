param(
    [Parameter(Mandatory=$true)][string]$ModulePath
)

$Helpers = Get-ChildItem -Path tools\build\*.ps1 -Recurse
foreach ($Helper in $Helpers) {
    . $Helper.FullName
}

# Get-ModuleManifest
$ModuleManifestPath = Get-ModuleManifestPath -ModulePath $ModulePath
$ModuleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath

# Get-Version
$Version = Get-Version -ModuleManifest $ModuleManifest

# Update-Manifest
Update-Manifest -ModulePath $ModulePath -ManifestPath $ModuleManifestPath -Version $Version