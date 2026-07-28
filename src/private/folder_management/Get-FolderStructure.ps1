function Get-FolderStructure {
    param(
        [Parameter(Mandatory = $false)][string]$InstallationPath
    )

    if ($InstallationPath) {
        @{
            Live   = Join-Path -Path $InstallationPath -ChildPath 'Live'
            Backup = Join-Path -Path $InstallationPath -ChildPath 'Backup'
            Logs   = Join-Path -Path $InstallationPath -ChildPath 'Logs'
        }
    }
    else {
        @{
            Live   = 'Live'
            Backup = 'Backup'
            Logs   = 'Logs'
        }
    }
}