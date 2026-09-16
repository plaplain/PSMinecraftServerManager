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

        [ValidateSet('ALPHA', 'BETA', 'STABLE')]
        [Parameter(Mandatory = $false)][string]$Channel = 'STABLE'
    )

    $PaperMcApiUri = 'https://fill.papermc.io/v3/projects/paper'
    Write-Debug "Getting: $PaperMcApiUri"
    $VersionApi = Invoke-RESTMethod -Uri 'https://fill.papermc.io/v3/projects/paper' -ErrorAction Stop

    Write-Debug $VersionApi

    $VersionApiVersions = $VersionApi.versions
    $MajorMinorVersions = ($VersionApiVersions | Get-Member -Type NoteProperty).Name | Sort-Object { $_ -as [Version] } -Descending

    foreach ($Version in $MajorMinorVersions) {

        $BuildVersions = $VersionApiVersions.$Version

        foreach ($BuildVersion in $BuildVersions) {
            try {
                $BuildApi = Invoke-RESTMethod -Uri "https://fill.papermc.io/v3/projects/paper/versions/$BuildVersion/builds" -ErrorAction Stop
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

            $VersionBuilds = $BuildApi | Sort-Object -Descending id | Where-Object { $_.channel -eq $Channel }

            if($Latest -and $Null -ne $VersionBuilds){
                Write-Verbose "Latest build found"
                return $VersionBuilds[0].downloads.'server:default'.Url
            }
            elseif(!$Latest){
                $VersionBuilds.downloads.'server:default'.Url
            }
        }
    }
}