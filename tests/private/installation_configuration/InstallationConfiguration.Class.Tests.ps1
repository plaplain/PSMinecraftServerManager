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
        $InstallationConfiguration = New-Object -Type 'InstallationConfiguration'
    }

    Context 'Expected values' {
        It 'Should not be null' {
            $InstallationConfiguration | Should -Not -BeNullOrEmpty
        }

        It 'Should Add a server' {
            $InstallationConfiguration.AddServer('PesterTest','C:\temp')
            $InstallationConfiguration.GetServer('PesterTest') | Should -Not -BeNullOrEmpty
        }

        It 'Should Update the server name' {
            $ServerConfig = $InstallationConfiguration.GetServer('PesterTest')
            $ServerConfig.Name = "PesterRename"
            $InstallationConfiguration.SetServer('PesterTest',$ServerConfig)
            $AllServers = $InstallationConfiguration.GetAllServers()

            $AllServers.Keys | Should -Contain 'PesterRename'
            $AllServers.Keys | Should -Not -Contain 'PesterTest'
        }

        It 'Should remove a server' {
            $InstallationConfiguration.RemoveServer('PesterTest') | Should -Not -BeNullOrEmpty
        }
    }
}