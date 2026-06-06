function Get-Version {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)][hashtable]$ModuleManifest
    )

    # Running pwsh seperately to prevent LASTEXITCODE from being overwritten by git commands
    $LatestTag = pwsh -Command 'git describe --tags --abbrev=0 --match "v[0-9]*.[0-9]*.[0-9]*"'

    $ModuleVersion = $ModuleManifest.ModuleVersion

    # Extract version components
    if ($LatestTag -match "v(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)(?:-.+)?") {
        $GitMajor = [int]$Matches.Major
        $GitMinor = [int]$Matches.Minor
        $GitPatch = [int]$Matches.Patch
        Write-Verbose "Latest tag version: $Major.$Minor.$Patch"
    }
    else {
        Write-Verbose "No existing tag found, starting with v0.0.0"
        $GitMajor = 0
        $GitMinor = 0
        $GitPatch = 0
    }

    Write-Verbose "Git version components: Major=$GitMajor, Minor=$GitMinor"

    if ($ModuleVersion -match "(?<Major>\d+)\.(?<Minor>\d+)\.(?<Patch>\d+)") {
        $ModuleMajor = [int]$Matches.Major
        $ModuleMinor = [int]$Matches.Minor
    }
    else {
        $ModuleMajor = 0
        $ModuleMinor = 0
    }

    Write-Verbose "Module version components: Major=$ModuleMajor, Minor=$ModuleMinor"

    if ($ModuleMajor -gt $GitMajor -or $ModuleMinor -gt $GitMinor) {
        [version]::new($ModuleMajor, $ModuleMinor, 0)
    }
    else {
        $NewPatch = $GitPatch + 1
        [version]::new($GitMajor, $GitMinor, $NewPatch)
    }
}