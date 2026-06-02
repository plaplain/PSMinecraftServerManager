       
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
        write-output "new_version=$NewVersion" >> $env:GITHUB_OUTPUT
        write-output "new_tag=$NewTagName" >> $env:GITHUB_OUTPUT