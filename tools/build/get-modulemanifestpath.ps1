param(
    [Parameter(Mandatory=$true)][string]$ModulePath
)

$ManifestFiles = Get-ChildItem -Path $ModulePath -Filter "*.psd1"

if($null -eq $ManifestFiles) {
    throw("No manifest files found in $ModulePath")
}

if($ManifestFiles.Count -gt 1) {
    throw("Multiple manifest files found in $ModulePath. Please ensure only one PSD1 file is present.")
}

$ManifestFiles[0].FullName