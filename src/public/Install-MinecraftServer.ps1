<#
.SYNOPSIS
Installs Minecraft Server

.DESCRIPTION
Installs Minecraft Server to a custom installationn path.

.PARAMETER ServerName
The name of the server. You will use the name later on to start, update, and backup the server.

.PARAMETER InstallationPath
The path you want to install the server to.

.PARAMETER PaperMc
If you want the server to be installed using PaperMc instead of vanilla Minecraft.

.PARAMETER Force
Specify this if you are wanting to overwrite and existing installation.

.EXAMPLE
Install-MinecraftServer -ServerName "MyServer" -InstallationPath "C:\MinecraftServer" -PaperMc
#>
function Install-MinecraftServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $true)][string]$InstallationPath,
        [Parameter(Mandatory = $false)][switch]$PaperMc,
        [Parameter(Mandatory = $false)][switch]$Force
    )

    # Check for Java
    if(!(Test-JavaInstallation)){
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
    $InstallationConfigurationFilePath = Join-Path -Path $InstallationConfigurationPath -ChildPath 'configuration.json'
    $ConfigurationTest = Test-Path -Path $InstallationConfigurationFilePath

    if($ConfigurationTest){
        $Configuration = [InstallationConfiguration]::new($InstallationConfigurationPath)
    }
    else{
        $Configuration = [InstallationConfiguration]::new()
    }

    $ServerAdded = $false

    try{
        $Configuration.AddServer($ServerName,$InstallationPath,$PaperMc)
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

    if($ConfigurationTest){
        $Configuration.ExportConfigurationToFile($InstallationConfigurationPath,$true)
    }
    else{
        $Configuration.ExportConfigurationToFile($InstallationConfigurationPath)
    }

    #Install
    Update-MinecraftServer -ServerName $ServerName -NoBackup    
}

Export-ModuleMember 'Install-MinecraftServer'