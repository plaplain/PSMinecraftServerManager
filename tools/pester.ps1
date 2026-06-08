param(
    [Parameter(Mandatory = $true)][string]$TestPath,
    [Parameter(Mandatory = $true)][string]$CodePath,
    [Parameter(Mandatory = $true)][string]$OutputPath,

    [ValidateSet('Unit', 'Integration')]
    [Parameter(Mandatory = $true)][string[]]$Tags
)

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
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = $OutputPath
    }
    Output = @{
        Show = 'Header', 'Failed', 'Summary'
        CIFormat = 'GithubActions'
    }
}

Invoke-Pester -Configuration $PesterConfiguration