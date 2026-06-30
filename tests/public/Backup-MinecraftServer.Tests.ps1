BeforeAll {
    Class InstallationConfiguration {
        InstallationConfiguration($InstallationConfigurationPath){}
    }

    New-MockObject -Type ([InstallationConfiguration])

    . (Join-Path -Path $PSScriptRoot -ChildPath '..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -HelperFiles 

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }

    $Dependencies = @(
        'Get-FolderStructure',
        'Get-InstallationConfigurationPath'
    )
    Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Backup-MinecraftServer' -FunctionsToMock $Dependencies
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
            $ModuleName = "TestPs1Module_Backup-MinecraftServer"

            Mock -ModuleName $ModuleName -CommandName Get-FolderStructure -MockWith {
                @{
                    Live   = Join-Path -Path $FolderPath -ChildPath 'Live'
                    Backup = Join-Path -Path $FolderPath -ChildPath 'Backup'
                    Logs   = Join-Path -Path $FolderPath -ChildPath 'Logs'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Get-InstallationConfigurationPath -MockWith {
                if ($IsLinux) {
                    "/home/minecraft"
                }
                else {
                    "C:\Temp\MinecraftServerManager"
                }               
            }

            Mock -CommandName Copy-Item -MockWith {}

            Mock -CommandName Test-Path -MockWith { $true }
         
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