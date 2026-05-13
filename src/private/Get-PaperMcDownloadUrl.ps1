<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Latest
Parameter description

.PARAMETER Channel
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-PaperMcDownloadUrl {
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