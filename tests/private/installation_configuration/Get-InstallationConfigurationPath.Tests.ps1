BeforeAll {
    $HelperPath = Join-Path -Path $PSScriptRoot -ChildPath '\..\..\helpers\'
    $Helpers = Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

    $ScriptRelativePath = "..\..\..\src\private\installation\Get-InstallationConfigurationPath.ps1"
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptRelativePath

    . $ScriptPath


}

Describe 'Get-InstallationConfiguration Tests' -Tag 'Linux' {
    BeforeAll {
        $Env:APPDATA = 'C:\Users\Username\AppData\Roaming'
        $Env:HOME = '/home/Username'
    }

    Context "'Get-InstallationConfiguration'" {
        BeforeAll {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'InstallationConfigurationPath', Justification = 'False positive due to how Pester works.')]
            $InstallationConfigurationPath = Get-InstallationConfigurationPath
        }

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