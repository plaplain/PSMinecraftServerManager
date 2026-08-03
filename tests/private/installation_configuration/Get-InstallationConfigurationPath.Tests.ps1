BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -TestFile -HelperFiles

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'Get-InstallationConfiguration Unit Tests' -Tag 'Unit' {
    BeforeAll {
        $Env:APPDATA = 'C:\Users\Username\AppData\Roaming'
        $Env:HOME = '/home/Username'
    }

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
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