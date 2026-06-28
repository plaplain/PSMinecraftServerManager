BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -HelperFiles 

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }

    Import-Cmdlet -FilePath $PSCommandPath -CmdletName 'Backup-MinecraftServer'
}

Describe 'Backup-MinecraftServer Tests' {
    BeforeAll {
        if ($IsLinux) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FolderPath', Justification = 'False positive due to how Pester works.')]
            $FolderPath = '/home/minecraft'
        }
        else {
            $FolderPath = 'C:\Temp\'
        }
    }

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Test 'Backup-MinecraftServer'" {
        BeforeAll {
            
            function Get-InstallationConfigurationPath {}

            function Get-FolderStructure {
                @{
                    Live   = Join-Path -Path $FolderPath -ChildPath 'Live'
                    Backup = Join-Path -Path $FolderPath -ChildPath 'Backup'
                    Logs   = Join-Path -Path $FolderPath -ChildPath 'Logs'
                }
            }

            Mock -CommandName Copy-Item -MockWith {}

            Mock -CommandName Test-Path -MockWith { $true }

            Mock -CommandName Get-InstallationConfigurationPath -MockWith {
                if ($IsLinux) {
                    "/home/minecraft"
                }
                else {
                    "C:\Temp\MinecraftServerManager"
                }
            }
        }

        It 'Backup-MinecraftServer should not throw' {
            Backup-MinecraftServer -ServerName "TestServer" | Should -Not -Throw
        }

        It 'Backup-MinecraftServer invalid folder path should throw' -ForEach @(
            @{ Folder = 'Live' }
            @{ Folder = 'Backup' }
            @{ Folder = 'Logs' }
        ) {
            $FolderPath = Join-Path -Path $FolderPath -ChildPath $Folder
            Mock -CommandName Test-Path -ParameterFilter { $Path -like $FolderPath } {
                $false
            }
            Backup-MinecraftServer -ServerName "TestServer" | Should -Not -Throw
        }

        It 'Backup-MinecraftServer should throw if Copy-Item fails' {
            Mock -CommandName Copy-Item -MockWith {
                throw('Failed to copy!')
            }

            Backup-MinecraftServer -ServerName "TestServer" | Should -Throw
        }
    }
}