BeforeAll {
    $HelperPath = Join-Path -Path $PSScriptRoot -ChildPath '\..\..\helpers\'
    $Helpers = Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = "..\..\src\private\installation\Get-InstallationConfigurationPathl.ps1"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptPath', Justification = 'False positive due to how Pester works.')]
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptRelativePath

    . $ScriptPath

    $Tests = {
        It 'Should return a hashtable' {
            $InstallationConfigurationPath | Should -BeOfType [hashtable]
        }

        It 'Should contain the keys FullPath and Parent Path' {
            $InstallationConfigurationPath.Keys | Should -Contain 'FullPath'
            $InstallationConfigurationPath.Keys | Should -Contain 'ParentPath'
        }

        It 'The value of keys FullPath and ParentPath should not be null or empty.' {
            $InstallationConfigurationPath.FullPath | Should -Not -BeNullOrEmpty
            $InstallationConfigurationPath.ParentPath | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Get-InstallationConfiguration Tests' {
    BeforeEach {
        $Env:APPDATA = 'C:\Users\Username\AppData\Roaming'
        $Env:HOME = '/home/Username'
        
    }

    Context "'Get-InstallationConfiguration'" -Foreach @(
        @{ IsLinux = $true}
        @{ IsLinux = $false}
    ) {
        BeforeAll {
            Mock Get-Variable -ParameterFilter { $Name -eq 'IsLinux' } -MockWith {
                return $false
            }

            $InstallationConfigurationPath = Get-InstallationConfiguration
        }

        Invoke-Command -ScriptBlock $Tests
    }

    Context "'Get-InstallationConfiguration' on Linux" {
        BeforeAll {
            Mock Get-Variable -ParameterFilter { $Name -eq 'IsLinux' } -MockWith {
                return $true
            }

            $InstallationConfigurationPath = Get-InstallationConfiguration
        }

        Invoke-Command -ScriptBlock $Tests
    }
}