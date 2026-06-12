<#
    .SYNOPSIS
    Queries the PaperMC API to list the available versions.

    .DESCRIPTION
    Can be used to list the latest version, and defaults to the STABLE channel.

    .PARAMETER Latest
    Get only the latest version.

    .PARAMETER Channel
    Defaults to the 'STABLE' channel, can be used with test channels.

    .NOTES
    See the following PaperMC documentation:
    https://docs.papermc.io/misc/downloads-service/
#>
function Get-PaperMcDownloadUrl {
    param(
        [Parameter(Mandatory = $false)][switch]$Latest,
        [Parameter(Mandatory = $false)][string]$Channel = 'STABLE'
    )

    $PaperMcApiUri = 'https://fill.papermc.io/v3/projects/paper'
    Write-Debug "Getting: $PaperMcApiUri"
    $VersionApi = Invoke-RESTMethod -Uri 'https://fill.papermc.io/v3/projects/paper'

    Write-Debug $VersionApi

    if ($Latest) {
        Write-Debug "Getting latest version."
        $VersionApiVersions = $VersionApi.versions
        $VersionNames = ($VersionApiVersions | Get-Member -Type NoteProperty).Name
        $TopLevelVersionName = ($VersionNames | Sort-Object { $_ -as [Version] } -Descending)[0]
        Write-Debug "Latest Top Level Version: $Versions"
        $Versions = $VersionApiVersions.$TopLevelVersionName[0]
        Write-Debug "Latest Version: $Versions"
    }
    else {
        $Versions = ($VersionApi.versions | Get-Member -Type NoteProperty).Name
    }

    foreach ($Version in $Versions) {

        try {
            $BuildApi = Invoke-RESTMethod -Uri "https://fill.papermc.io/v3/projects/paper/versions/$Version/builds" -StatusCodeVariable BuildApiResponseCode -ErrorAction Stop
        }
        catch {
            $ResponseError = $_
            switch ($_.Exception.Response.StatusCode) {
                "NotFound" {
                    Write-Warning "No build for version: $Version"
                }

                default {
                    throw($ResponseError)
                }
            }
        }
        $Builds = $BuildApi | Sort-Object -Descending id | Where-Object { $_.channel -eq $Channel }

        if ($Latest) {
            $Builds[0].downloads.'server:default'.Url
        }
        else {
            $Builds.downloads.'server:default'.Url
        }
    }
}