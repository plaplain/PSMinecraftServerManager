function Install-MinecraftServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $true)][string]$InstallationPath,
        [Parameter(Mandatory = $false)][switch]$Force
    )

    #TODO: Check Java is installed.
    try {
        $NewFolderStructureParams = @{
            Path  = $InstallationPath
            Force = $Force
            ErrorAction = Stop
        }
        New-FolderStructure
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

    
}