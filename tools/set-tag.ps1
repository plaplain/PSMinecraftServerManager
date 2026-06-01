        # Only proceed if we're on main branch
        if ($env:GITHUB_REF -ne "refs/heads/main") {
          Write-Output "Not on main branch, skipping version update"
          exit 0
        }
        
        # Get the latest tag following vM.m.p format
        $LatestTag = git describe --tags --abbrev=0 --match "v[0-9]*.[0-9]*.[0-9]*" 2>$null
        
        # Extract version components
        if ($LatestTag -match "v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)") {
          $Major = [int]$Matches.Major
          $Minor = [int]$Matches.Minor
          $Patch = [int]$Matches.Patch
          Write-Output "Latest tag version: $Major.$Minor.$Patch"
        } else {
          Write-Output "No existing tag found, starting with v1.0.0"
          $Major = 1
          $Minor = 0
          $Patch = 0
        }
        
        # Get module version from PSD1 file
        $ModulePath = "src\PSMinecraftServerManager.psd1"
        if (Test-Path $ModulePath) {
          $ModuleVersion = (Import-PowerShellDataFile -Path $ModulePath).ModuleVersion
          Write-Output "Current module version: $ModuleVersion"
          
          # Parse module version
          if ($ModuleVersion -match "(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)") {
            $ModuleMajor = [int]$Matches.Major
            $ModuleMinor = [int]$Matches.Minor
            $ModulePatch = [int]$Matches.Patch
            Write-Output "Module version components: Major=$ModuleMajor, Minor=$ModuleMinor, Patch=$ModulePatch"
          } else {
            Write-Output "Error: Could not parse module version from PSD1"
            exit 1
          }
        } else {
          Write-Output "Error: PSD1 file not found at $ModulePath"
          exit 1
        }
        
        # Compare versions
        if ($ModuleMajor -eq $Major -and $ModuleMinor -eq $Minor) {
          # Same major.minor, increment patch
          $NewPatch = $ModulePatch + 1
          $NewVersion = "$Major.$Minor.$NewPatch"
          Write-Output "Incrementing patch version to: $NewVersion"
        } else {
          # New major.minor, reset patch to 0
          $NewVersion = "$Major.$Minor.0"
          Write-Output "New major.minor version: $NewVersion"
        }
        
        # Update PSD1 file
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
        
        # Create new tag
        $NewTagName = "v$NewVersion"
        Write-Output "Creating tag: $NewTagName"
        
        # Commit changes
        git config --global user.name 'github-actions[bot]'
        git config --global user.email 'github-actions[bot]@users.noreply.github.com'
        git add .
        git commit -m "Update version to $NewVersion and update module manifest"
        git tag $NewTagName
        
        # Set outputs
        echo "new_version=$NewVersion" >> $env:GITHUB_OUTPUT
        echo "new_tag=$NewTagName" >> $env:GITHUB_OUTPUT