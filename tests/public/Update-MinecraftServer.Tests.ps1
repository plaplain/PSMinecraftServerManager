BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -HelperFiles 

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'Update-MinecraftServer Tests' {
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

    Context "Test 'Update-MinecraftServer with vanilla Minecraft'" {
        BeforeAll {
            $FunctionDependencies = @(
                'Get-FolderStructure',
                'Get-InstallationConfigurationPath',
                'Backup-MinecraftServer',
                'Get-PaperMcDownloadUrl',
                'Get-MinecraftDownloadUrl'
            )

            $ClassDependencies = @(
                [PSCustomObject]@{
                    ClassName    = 'InstallationConfiguration'
                    Constructors = @('[string]')
                    Methods      = @(
                        [PSCustomObject]@{
                            Name       = 'GetServer'
                            Inputs     = '[string]'
                            OutputType = 'PSCustomObject'
                            Output     = '@{
                        InstallationPath = "C:\Temp\Bob"
                    }'
                        }
                    )
                }
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            $ModuleName = "TestPs1Module_Update-MinecraftServer"

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

            Mock -ModuleName $ModuleName -CommandName Backup-MinecraftServer -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-PaperMcDownloadUrl -MockWith {
                "https://test-papermc-url.com"
            }

            Mock -ModuleName $ModuleName -CommandName Get-MinecraftDownloadUrl -MockWith {
                "https://test-minecraft-url.com"
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {}         
        }

        It 'Should not throw' {
            { Update-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }

        It 'Should call Backup-MinecraftServer' {
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Invoke Backup-MinecraftServer
        }

        It 'Should call Get-InstallationConfigurationPath' {
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Invoke Get-InstallationConfigurationPath
        }

        It 'Should call Get-FolderStructure' {
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Invoke Get-FolderStructure
        }

        It 'Should not call Backup-MinecraftServer' {
            Update-MinecraftServer -ServerName "TestServer" -NoBackup | Should -ModuleName $ModuleName -Not -Invoke Backup-MinecraftServer
        }

        It 'Should call only Get-MinecraftDownloadUrl' {
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Invoke Get-MinecraftDownloadUrl
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Not -Invoke Get-PaperMcDownloadUrl
        }
    }

    Context "Test Update-MinecraftServer with PaperMc" {
        BeforeAll {
            $FunctionDependencies = @(
                'Get-FolderStructure',
                'Get-InstallationConfigurationPath',
                'Backup-MinecraftServer',
                'Get-PaperMcDownloadUrl',
                'Get-MinecraftDownloadUrl'
            )

            $ClassDependencies = @(
                [PSCustomObject]@{
                    ClassName    = 'InstallationConfiguration'
                    Constructors = @('[string]')
                    Methods      = @(
                        [PSCustomObject]@{
                            Name       = 'GetServer'
                            Inputs     = '[string]'
                            OutputType = 'PSCustomObject'
                            Output     = '@{
                        InstallationPath = "C:\Temp\Bob"
                        ServerType = "PaperMc"
                    }'
                        }
                    )
                }
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            $ModuleName = "TestPs1Module_Update-MinecraftServer"

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

            Mock -ModuleName $ModuleName -CommandName Backup-MinecraftServer -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-PaperMcDownloadUrl -MockWith {
                "https://test-papermc-url.com"
            }

            Mock -ModuleName $ModuleName -CommandName Get-MinecraftDownloadUrl -MockWith {
                "https://test-minecraft-url.com"
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {}         
        }

        It 'Should call only Get-PaperMcDownloadUrl' {
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Invoke Get-PaperMcDownloadUrl
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Not -Invoke Get-MinecraftDownloadUrl
        }
    }
}