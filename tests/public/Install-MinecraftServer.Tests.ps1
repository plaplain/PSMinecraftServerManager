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
    $ModuleName = "TestPs1Module_Install-MinecraftServer"
}

Describe 'Install-MinecraftServer Tests' {
    BeforeAll {
        if ($IsLinux) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FolderPath', Justification = 'False positive due to how Pester works.')]
            $InstallationPath = '/home/minecraft'
        }
        else {
            $InstallationPath = 'C:\Temp\'
        }
    }

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Test 'Install-MinecraftServer' for new server" {
        BeforeAll {
  
            $FunctionDependencies = @(
                'New-FolderStructure',
                'Get-InstallationConfigurationPath',
                'Update-MinecraftServer',
                'Test-JavaInstallation'
            )

            $ClassDependencies = @(
                [PSCustomObject]@{
                    ClassName    = 'InstallationConfiguration'
                    Constructors = @($null, '[string]')
                    Methods      = @(
                        [PSCustomObject]@{
                            Name       = 'AddServer'
                            Inputs     = '[string];[string]'
                            OutputType = 'void'
                            Output     = $null
                        },
                        [PSCustomObject]@{
                            Name       = 'ExportConfigurationToFile'
                            Inputs     = '[string]'
                            OutputType = 'void'
                            Output     = $null
                        }
                    )
                },
                [PSCustomObject]@{
                    ClassName    = 'DirectoryFound'
                    Constructors = @($null)
                    Methods      = @()
                }
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Install-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            Mock -ModuleName $ModuleName -CommandName New-FolderStructure -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-InstallationConfigurationPath -MockWith {
                if ($IsLinux) {
                    @{FullPath = "/home/minecraft" }
                }
                else {
                    @{FullPath = "C:\Temp\MinecraftServerManager" }
                }
            }

            Mock -ModuleName $ModuleName -CommandName Update-MinecraftServer -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Get-Command -MockWith {$true}

            Mock -ModuleName $ModuleName -CommandName Test-JavaInstallation -MockWith {$true}
        }

        It 'Should not throw installing vanilla' {
            { Install-MinecraftServer -ServerName "TestServer" -InstallationPath $InstallationPath } | Should -Not -Throw
        }

        It 'Should not throw installing PaperMC' {
            { Install-MinecraftServer -ServerName "TestServer" -InstallationPath $InstallationPath -PaperMc } | Should -Not -Throw
        }

        It 'Should throw if install path not found' {
            Mock -ModuleName $ModuleName -CommandName New-FolderStructure -MockWith {
                throw [System.IO.FileNotFoundException]::new("File not found.")
            }

            { Install-MinecraftServer -ServerName "TestServer" -InstallationPath $InstallationPath } | Should -Throw
        }

        It 'Should throw if directory found' {
            Mock -ModuleName $ModuleName -CommandName New-FolderStructure -MockWith {
                throw [DirectoryFound]::new("Directory found!")
            }

            { Install-MinecraftServer -ServerName "TestServer" -InstallationPath $InstallationPath } | Should -Throw
        }

        It 'Should throw if Java not found' {
            Mock -ModuleName $ModuleName -CommandName Test-JavaInstallation -MockWith {$false}

            { Install-MinecraftServer -ServerName "TestServer" -InstallationPath $InstallationPath } | Should -Throw
        }

        It 'Should not throw if directory found' {
            $ScriptBlock = Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Install-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies -OutputScriptBlockOnly

            . $ScriptBlock

            Mock -CommandName Test-JavaInstallation -MockWith {$true}

            Mock -CommandName Get-InstallationConfigurationPath -MockWith {
                if ($IsLinux) {
                    @{FullPath = "/home/minecraft" }
                }
                else {
                    @{FullPath = "C:\Temp\MinecraftServerManager" }
                }
            }

            { Install-MinecraftServer -ServerName "TestServer" -InstallationPath $InstallationPath -Force } | Should -Not -Throw
        }
    }
}