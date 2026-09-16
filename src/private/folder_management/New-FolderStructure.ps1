function New-FolderStructure {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $false)][switch]$Force
    )

    if (!(Test-Path -Path $Path)) {
        throw([System.IO.FileNotFoundException]::new("Invalid path '$Path'"))
    }

    $FoldersToCreate = Get-FolderStructure -InstallationPath $Path

    $FolderPaths = @()

    foreach ($Folder in $FoldersToCreate.GetEnumerator()) {
        $GeneratedFolderPath = $Folder.Value

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

        if ($PSCmdlet.ShouldProcess($SelectedFolderPath)) {
            New-Item @NewItemParams | Out-Null
        }
    }
}