BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -HelperFiles 

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ModuleName', Justification = 'False positive due to how Pester works.')]
    $ModuleName = "TestPs1Module_Update-MinecraftServer"
}

Describe 'Update-MinecraftServer Unit Tests' -Tag 'Unit' {
    BeforeAll {
        if ($IsLinux) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FolderPath', Justification = 'False positive due to how Pester works.')]
            $FolderPath = '/home/minecraft'
        }
        else {
            $FolderPath = 'C:\Temp\'
        }
        <#
        $FunctionDependencies = @(
            'Get-FolderStructure',
            'Get-InstallationConfigurationPath',
            'Backup-MinecraftServer',
            'Get-PaperMcDownloadUrl',
            'Get-MinecraftDownloadUrl'
        )

        Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

        Mock -ModuleName $ModuleName -CommandName Backup-MinecraftServer -MockWith {}

        Mock -ModuleName $ModuleName -CommandName Get-InstallationConfigurationPath -MockWith {
            if ($IsLinux) {
                "/home/minecraft"
            }
            else {
                "C:\Temp\MinecraftServerManager"
            }               
        }

        Mock -ModuleName $ModuleName -CommandName Get-FolderStructure -MockWith {
            @{
                Live   = Join-Path -Path $FolderPath -ChildPath 'Live'
                Backup = Join-Path -Path $FolderPath -ChildPath 'Backup'
                Logs   = Join-Path -Path $FolderPath -ChildPath 'Logs'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {}

        Mock -ModuleName $ModuleName -CommandName Get-PaperMcDownloadUrl -MockWith {
            "https://test-papermc-url.com"
        }

        Mock -ModuleName $ModuleName -CommandName Get-MinecraftDownloadUrl -MockWith {
            "https://test-minecraft-url.com"
        }
            #>
    }

    Context "When input is valid" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Input is valid with vanilla Minecraft'" {
        BeforeAll {
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
                        InstallationPath = "C:\Temp\"
                    }'
                        }
                    )
                }
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            $FunctionDependencies = @(
                'Get-FolderStructure',
                'Get-InstallationConfigurationPath',
                'Backup-MinecraftServer',
                'Get-PaperMcDownloadUrl',
                'Get-MinecraftDownloadUrl'
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            Mock -ModuleName $ModuleName -CommandName Backup-MinecraftServer -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-InstallationConfigurationPath -MockWith {
                if ($IsLinux) {
                    "/home/minecraft"
                }
                else {
                    "C:\Temp\MinecraftServerManager"
                }               
            }

            Mock -ModuleName $ModuleName -CommandName Get-FolderStructure -MockWith {
                @{
                    Live   = Join-Path -Path $FolderPath -ChildPath 'Live'
                    Backup = Join-Path -Path $FolderPath -ChildPath 'Backup'
                    Logs   = Join-Path -Path $FolderPath -ChildPath 'Logs'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-PaperMcDownloadUrl -MockWith {
                "https://test-papermc-url.com"
            }

            Mock -ModuleName $ModuleName -CommandName Get-MinecraftDownloadUrl -MockWith {
                "https://test-minecraft-url.com"
            }

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

    Context "Input is valid  with PaperMc" {
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
                        InstallationPath = "C:\Temp\"
                        ServerType = "PaperMc"
                    }'
                        }
                    )
                }
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            $FunctionDependencies = @(
                'Get-FolderStructure',
                'Get-InstallationConfigurationPath',
                'Backup-MinecraftServer',
                'Get-PaperMcDownloadUrl',
                'Get-MinecraftDownloadUrl'
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Update-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            Mock -ModuleName $ModuleName -CommandName Backup-MinecraftServer -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-InstallationConfigurationPath -MockWith {
                if ($IsLinux) {
                    "/home/minecraft"
                }
                else {
                    "C:\Temp\MinecraftServerManager"
                }               
            }

            Mock -ModuleName $ModuleName -CommandName Get-FolderStructure -MockWith {
                @{
                    Live   = Join-Path -Path $FolderPath -ChildPath 'Live'
                    Backup = Join-Path -Path $FolderPath -ChildPath 'Backup'
                    Logs   = Join-Path -Path $FolderPath -ChildPath 'Logs'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Invoke-WebRequest -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-PaperMcDownloadUrl -MockWith {
                "https://test-papermc-url.com"
            }

            Mock -ModuleName $ModuleName -CommandName Get-MinecraftDownloadUrl -MockWith {
                "https://test-minecraft-url.com"
            }
        }

        It 'Should call only Get-PaperMcDownloadUrl' {
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Invoke Get-PaperMcDownloadUrl
            Update-MinecraftServer -ServerName "TestServer" | Should -ModuleName $ModuleName -Not -Invoke Get-MinecraftDownloadUrl
        }
    }
}