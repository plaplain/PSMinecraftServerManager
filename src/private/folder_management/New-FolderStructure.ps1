function New-FolderStructure {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $false)][switch]$Force
    )

    if (!(Test-Path -Path $Path)) {
        throw([System.IO.FileNotFoundException]::new("Invalid path '$Path'"))
    }

    $FoldersToCreate = @(
        'Configuration',
        'Backup',
        'Server'
        'Logs'
    )

    $FolderPaths = @()

    foreach ($Folder in $FoldersToCreate) {
        $GeneratedFolderPath = Join-Path -Path $Path -ChildPath $Folder

        if ((Test-Path -Path $GeneratedFolderPath) -and !$Force) {
            throw([DirectoryFound]::new($GeneratedFolderPath))
        }

        $FolderPaths += $GeneratedFolderPath
    }

    foreach ($SelectedFolderPath in $FolderPaths) {
        $NewItemParams = @{
            Path        = $SelectedFolderPath
            ItemType    = 'Directory'
            ErrorAction = 'Stop'
            Force       = $Force
        }

        New-Item @NewItemParams | Out-Null
    }
}