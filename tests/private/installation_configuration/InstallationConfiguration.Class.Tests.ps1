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

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'JsonConfiguration', Justification = 'False positive due to how Pester works.')]
        $JsonConfiguration = $ExistingConfiguration | ConvertTo-Json

        if($IsLinux){
            $ConfigurationFolderPath = '/home/minecraft'
        }
        else{
            $ConfigurationFolderPath = 'C:\Minecraft'
        }
    }

    Context 'Expected values' {
        It 'Should not be null' {
            $InstallationConfiguration | Should -Not -BeNullOrEmpty
        }

        It 'Should Add a server' {
            $InstallationConfiguration.AddServer('PesterTest', $ConfigurationFolderPath)
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

        It 'Should load existing configuration in Windows' -Tag 'Windows' {
            Mock -CommandName Get-Content -MockWith {
                $JsonConfiguration
            }

            Mock -CommandName Test-Path -MockWith {
                $true
            }

            $InstallationConfiguration.LoadConfiguration($ConfigurationFolderPath)
            $InstallationConfiguration.GetServer('PesterTestExisting') | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Handle invalid values' {
        It 'Should throw when adding the same server name' {
            $InstallationConfiguration.AddServer('PesterTest', $ConfigurationFolderPath)
            {$InstallationConfiguration.AddServer('PesterTest', $ConfigurationFolderPath)} | Should -Throw
        }

        It 'Should throw settinng a server with an invalid object' {
            $InvalidData = [PSCustomObject]@{
                Invalid = 'Data'
            }

            {$InstallationConfiguration.SetServer('PesterTest',$InvalidData)} | Should -Throw
        }

        It 'LoadConfiguration should thow with invalid Test-Path'{
            Mock -CommandName Get-Content -MockWith {
                $JsonConfiguration
            }

            Mock -CommandName Test-Path -MockWith {
                $false
            }

            {$InstallationConfiguration.LoadConfiguration($ConfigurationFolderPath)} | Should -Throw
        }

        It 'LoadConfiguration should thow with invalid JSON'{
            Mock -CommandName Get-Content -MockWith {
                '{'
            }

            Mock -CommandName Test-Path -MockWith {
                $true
            }

            {$InstallationConfiguration.LoadConfiguration($ConfigurationFolderPath)} | Should -Throw
        }

        It 'LoadConfiguration should thow with incorrectly structured JSON'{
            Mock -CommandName Get-Content -MockWith {
                '{}'
            }

            Mock -CommandName Test-Path -MockWith {
                $true
            }

            {$InstallationConfiguration.LoadConfiguration($ConfigurationFolderPath)} | Should -Throw
        }
    }
}