param(
  [Parameter(Mandatory=$true)][string]$ModulePath
)

$Helpers = Get-ChildItem -Path tools\build\*.ps1 -Recurse
foreach ($Helper in $Helpers) {
    . $Helper.FullName
}

# Get-ModuleManifest
$ModuleManifestPath = Get-ModuleManifest -ModulePath $ModulePath
$ModuleManifest = Import-PowerShellDataFile -Path $ModuleManifestPath

# Get-Version
$Version = Get-Version -ModuleManifest $ModuleManifest
        
# Create new tag
$TagName = "v$Version"
Write-Output "Creating tag: $TagName"

# Commit changes
git config --global user.name 'github-ps-build'
git config --global user.email 'github-ps-build@noreply.github.com'
git add .
git commit -m "Update version to $Version and update module manifest"
git tag $TagName