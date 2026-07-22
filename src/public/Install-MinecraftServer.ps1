function Install-MinecraftServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $true)][string]$InstallationPath,
        [Parameter(Mandatory = $false)][switch]$PaperMc,
        [Parameter(Mandatory = $false)][switch]$Force
    )

    # Check for Java
    try{
        Get-Command -Name 'java' -ErrorAction Stop
    }
    catch {
        throw('Java not detected. Please install Java, this is a prerequisite.')
    }

    # Directory creation.
    try {
        $NewFolderStructureParams = @{
            Path  = $InstallationPath
            Force = $Force
            ErrorAction = 'Stop'
        }
        New-FolderStructure @NewFolderStructureParams
    }
    catch [System.IO.FileNotFoundException] {
        Throw("Installation path '$InstallationPath' not found!")
    }
    catch [DirectoryFound] {
        if(!$Force){
            Throw("Existing installation detected! If you want to lose this installation, run again using -Force")
        }
    }
    catch {
        Throw("Unexpected error: $($_.Exception.Message)")
    }


    # Configuration initialization
    $InstallationConfigurationPath = Get-InstallationConfigurationPath

    if((Test-Path -Path $InstallationConfigurationPath.FullPath)){
        $Configuration = [InstallationConfiguration]::new($InstallationConfigurationPath)
    }
    else{
        $Configuration = [InstallationConfiguration]::new()
    }

    $ServerAdded = $false

    try{
        $Configuration.AddServer($ServerName,$InstallationPath)
        $ServerAdded = $true
    }
    catch{
        if(!$Force){
            throw($_)
        }
    }

    if(!$ServerAdded -and $Force){
        $ServerConfig = $Configuration.GetServer($ServerName)
        $ServerConfig.InstallationFolder = $InstallationPath
        $Configuration.SetServer($Server)
    }

    $Configuration.ExportConfigurationToFile($InstallationPath)


    #Install
    Update-MinecraftServer -ServerName $ServerName -NoBackup    
}

Export-ModuleMember 'Install-MinecraftServer'