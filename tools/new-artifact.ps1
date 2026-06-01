        # Only proceed if we're on main branch
        if ($env:GITHUB_REF -ne "refs/heads/main") {
          Write-Output "Not on main branch, skipping artifact creation"
          exit 0
        }
        
        # Create artifact
        $ArtifactName = "PSMinecraftServerManager"
        $SourcePath = "src"
        
        # Create zip archive
        Compress-Archive -Path "$SourcePath\*" -DestinationPath "$ArtifactName.zip" -Force
        
        Write-Output "Created artifact: $ArtifactName.zip"