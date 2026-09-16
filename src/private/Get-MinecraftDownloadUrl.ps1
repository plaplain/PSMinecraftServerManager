function Get-MinecraftDownloadUrl {
    param(
        [Parameter(Mandatory = $false)][switch]$Latest,

        [ValidateSet('release', 'snapshot')]
        [Parameter(Mandatory = $false)][string]$Type = 'release'
    )

    $ApiData = Invoke-RestMethod -Uri 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json'

    if (!$Latest) {
        return ($ApiData.versions | Where-Object { $_.type -eq $Type }).url
    }

    switch ($Type) {
        'release' {
            $LatestVersion = $ApiData.latest.$Type
            $SelectedVersion = $ApiData.versions | Where-Object { $_.id -eq $LatestVersion -and $_.type -eq $Type }
        }
        'snapshot' {
            $SelectedVersion = ($ApiData.versions | Where-Object { $_.type -eq 'snapshot' } | Sort-Object { $_.id -as [Version] } -Descending)[0]
        }
    }
    
    if ($null -eq $SelectedVersion) {
        throw('Unable to find the latest version')
    }
    else {
        $SelectedVersion.url
    }
}