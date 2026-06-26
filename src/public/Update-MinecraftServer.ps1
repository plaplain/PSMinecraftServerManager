function Update-MinecraftServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $false)][switch]$NoBackup
    )

    $InstallationConfigurationPath = Get-InstallationConfigurationPath

    $Configuration = [InstallationConfiguration]::new($InstallationConfigurationPath)
    $ServerConfiguration = $Configuration.GetServer($ServerName)

    if(!$NoBackup){
        Backup-MinecraftServer -ServerName $ServerName -ErrorAction Stop
    }

    switch($ServerConfiguration.ServerType){
        'PaperMc'{
            $DownloadUrl = Get-PaperMcDownloadUrl -Latest
        }
        Default {
            $DownloadUrl = Get-MinecraftDownloadUrl -Latest
        }
    }

    $FolderStructure = Get-FolderStructure -InstallationPath $ServerConfiguration.InstallationPath

    $LiveServerJar = Join-Path -Path $FolderStructure['Live'] -ChildPath 'minecraft_server.jar'

    Invoke-WebRequest -Uri $DownloadUrl -OutFile $LiveServerJar
}