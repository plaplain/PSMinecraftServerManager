<#

#>
param(
    [Parameter(Mandatory = $true)][string]$TestPath,
    [Parameter(Mandatory = $true)][string]$CodePath,
    [Parameter(Mandatory = $false)][string]$OutputPath,

    [ValidateSet('Unit', 'Integration', 'Linux')]
    [Parameter(Mandatory = $true)][string[]]$Tags
)

Import-Module Pester -Force

if($OutputPath){
    $TestResultsEnabled = $true
}
else {
    $TestResultsEnabled = $false
}

$PesterConfiguration = [PesterConfiguration]@{
    Run = @{
         Path = $TestPath
    }
    Filters = @{
        Tag = $Tags
    }
    Should = @{ # <- Should configuration.
        ErrorAction = 'Continue' # <- Always run all Should-assertions in a test
    }
    CodeCoverage = @{
        Enabled = $true
        RecursePaths = $true
        Path = $CodePath
    }
    TestResult = @{
        Enabled = $TestResultsEnabled
        OutputFormat = 'NUnitXml'
        OutputPath = $OutputPath
    }
    Output = @{
        Show = 'Header', 'Failed', 'Summary'
        CIFormat = 'GithubActions'
    }
}

Invoke-Pester -Configuration $PesterConfiguration