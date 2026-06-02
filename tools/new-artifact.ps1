     
        # Create artifact
        $ArtifactName = "PSMinecraftServerManager"
        $SourcePath = "src"
        
        # Create zip archive
        Compress-Archive -Path "$SourcePath\*" -DestinationPath "$ArtifactName.zip" -Force
        
        Write-Output "Created artifact: $ArtifactName.zip"