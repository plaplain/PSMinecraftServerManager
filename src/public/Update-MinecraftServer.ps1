<#
.SYNOPSIS
Updates a configured Minecraft server.

.DESCRIPTION
Updates a minecraft server

.PARAMETER ServerName
The name of the configured server. You will hahve set this when using Install-MinecraftServer

.PARAMETER NoBackup
Specify if you don't want the command to backup the server before updating.

.EXAMPLE
Update-MinecraftServer -ServerName "MyServer"
#>
function Update-MinecraftServer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $false)][switch]$NoBackup
    )

    $InstallationConfigurationPath = Get-InstallationConfigurationPath

    $Configuration = [InstallationConfiguration]::new($InstallationConfigurationPath)
    $ServerConfiguration = $Configuration.GetServer($ServerName)

    if (!$NoBackup) {
        Backup-MinecraftServer -ServerName $ServerName -ErrorAction Stop
    }

    switch ($ServerConfiguration.ServerType) {
        'PaperMc' {
            $DownloadUrl = Get-PaperMcDownloadUrl -Latest
        }
        Default {
            $DownloadUrl = Get-MinecraftDownloadUrl -Latest
        }
    }

    $FolderStructure = Get-FolderStructure -InstallationPath $ServerConfiguration.InstallationPath

    $LiveServerJar = Join-Path -Path $FolderStructure['Live'] -ChildPath 'minecraft_server.jar'

    if ($PSCmdlet.ShouldProcess($LiveServerJar)) {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $LiveServerJar
    }
}

Export-ModuleMember 'Update-MinecraftServer'