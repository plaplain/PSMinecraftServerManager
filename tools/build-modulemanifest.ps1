# Update PSD1 file
        # Get the latest tag following vM.m.p format
        $LatestTag = git describe --tags --abbrev=0 --match "v[0-9]*.[0-9]*.[0-9]*" 2>$null

        # Extract version components
        if ($LatestTag -match "v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)") {
          $Major = [int]$Matches.Major
          $Minor = [int]$Matches.Minor
          $Patch = [int]$Matches.Patch
          Write-Output "Latest tag version: $Major.$Minor.$Patch"
        } else {
          Write-Output "No existing tag found, starting with v0.0.0"
          $Major = 0
          $Minor = 0
          $Patch = 0
        }

        $ModulePath = "src\PSMinecraftServerManager.psd1"

$PSD1Content = Get-Content -Path $ModulePath -Raw
$UpdatedPSD1Content = $PSD1Content -replace "ModuleVersion\s*=\s*['""]\d+\.\d+\.\d+['""]", "ModuleVersion = '$NewVersion'"
Set-Content -Path $ModulePath -Value $UpdatedPSD1Content

# Update Cmdlets and PrivateFunctions
$PublicCmdlets = Get-ChildItem -Path "src\public" -Filter "*.ps1" -Recurse | ForEach-Object { $_.BaseName }
$PrivateFunctions = Get-ChildItem -Path "src\private" -Filter "*.ps1" -Recurse | ForEach-Object { $_.BaseName }

# Build Cmdlets list
$CmdletsList = $PublicCmdlets -join "', `n        '"
$CmdletsList = "        '$CmdletsList'"

# Build PrivateFunctions list
$PrivateFunctionsList = $PrivateFunctions -join "', `n        '"
$PrivateFunctionsList = "        '$PrivateFunctionsList'"

# Update the PSD1 with updated cmdlets and private functions
$UpdatedPSD1Content = $PSD1Content -replace "CmdletsToExport\s*=\s*\[\s*\]", "CmdletsToExport = `n        [`n$CmdletsList`n        `]"
$UpdatedPSD1Content = $UpdatedPSD1Content -replace "PrivateData\s*=\s*\{\s*\}", "PrivateData = `n        {`n            PSData = `n            {`n                PrivateFunctions = `n                [`n$PrivateFunctionsList`n                `]`n            }`n        }"

# Handle case where PrivateData doesn't exist
if ($UpdatedPSD1Content -notmatch "PrivateData") {
  $UpdatedPSD1Content = $UpdatedPSD1Content -replace "(\s*}\s*)$", "`n        PrivateData = `n        {`n            PSData = `n            {`n                PrivateFunctions = `n                [`n$PrivateFunctionsList`n                `]`n            }`n        }`n        }"
}

Set-Content -Path $ModulePath -Value $UpdatedPSD1Content