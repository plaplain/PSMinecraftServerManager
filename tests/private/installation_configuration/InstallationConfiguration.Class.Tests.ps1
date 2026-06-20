BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '\..\..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'InstallationConfiguration Class Tests' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'InstallationConfiguration', Justification = 'False positive due to how Pester works.')]
        $InstallationConfiguration = New-Object -Type 'InstallationConfiguration'

        $ExistingConfiguration = @{
            Servers = @{
                'PesterTestExisting' = [PSCustomObject]@{
                    Name               = 'PesterTestExisting'
                    InstallationFolder = 'C:\Temp'
                }
            }
        }

        $JsonConfiguration = $ExistingConfiguration | ConvertTo-Json
    }

    Context 'Expected values' {
        It 'Should not be null' {
            $InstallationConfiguration | Should -Not -BeNullOrEmpty
        }

        It 'Should Add a server' {
            $InstallationConfiguration.AddServer('PesterTest', 'C:\temp')
            $InstallationConfiguration.GetServer('PesterTest') | Should -Not -BeNullOrEmpty
        }

        It 'Should Set the server name' {
            $ServerConfig = $InstallationConfiguration.GetServer('PesterTest')
            $ServerConfig.Name = "PesterRename"
            $InstallationConfiguration.SetServer('PesterTest', $ServerConfig)
            $AllServers = $InstallationConfiguration.GetAllServers()

            $AllServers.Keys | Should -Contain 'PesterRename'
            $AllServers.Keys | Should -Not -Contain 'PesterTest'
        }

        It 'Should Remove a server' {
            $InstallationConfiguration.GetServer('PesterRename') | Should -Not -BeNullOrEmpty
            $InstallationConfiguration.RemoveServer('PesterRename')
            $InstallationConfiguration.GetServer('PesterRename') | Should -BeNullOrEmpty
        }

        It 'Should load existing configuration' {
            Mock -CommandName Get-Content -MockWith {
                $JsonConfiguration
            }

            Mock -CommandName Test-Path -MockWith {
                $true
            }

            $InstallationConfiguration.LoadConfiguration("C:\Temp")
            $InstallationConfiguration.GetServer('PesterTestExisting') | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Handle invalid values' {

    }
}