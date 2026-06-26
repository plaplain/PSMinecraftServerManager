function Backup-MinecraftServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName
    )

    $InstallationConfigurationPath = Get-InstallationConfigurationPath

    $Configuration = [InstallationConfiguration]::new($InstallationConfigurationPath)
    $ServerConfiguration = $Configuration.GetServer($ServerName)

    if($null -eq $ServerConfiguration){
        throw("Server '$ServerName' not found in configuration.")
    }

    $Folders = Get-FolderStructure -InstallationPath $ServerConfiguration.InstallationPath

    $LiveFolder = $Folders['Live']
    $BackupFolder = $Folders['Backup']

    if(!(Test-Path -Path $LiveFolder)){
        throw("Invalid live folder '$LiveFolder'")
    }

    if(!(Test-Path -Path $BackupFolder)){
        throw("Invalid live folder '$BackupFolder'")
    }

    try{
        Copy-Item -Path $LiveFolder -Destination $BackupFolder -Recurse -ErrorAction Stop
    }
    catch{
        throw("Unable to backup. Error: $($_.Exception.Message)")
    }    
}