<#
.SYNOPSIS
Tests if Java is installed.

.OUTPUTS
[boolean]
#>
function Test-JavaInstallation {
    [OutputType([boolean])]
    param()

    try{
        Get-Command -Name 'java' -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}