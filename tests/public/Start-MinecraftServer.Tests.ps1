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

Describe 'Start-MinecraftServer Tests' {
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

    Context "Test 'Start-MinecraftServer'" {
        BeforeAll {
            $FunctionDependencies = @(
                'Get-FolderStructure',
                'Get-InstallationConfigurationPath'
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
                            Output     = "@{
                                InstallationPath = '$FolderPath'
                            }"
                        }
                    )
                }
            )

            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Start-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            $ModuleName = "TestPs1Module_Start-MinecraftServer"

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

            Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }

            $LivePath = Join-Path -Path $FolderPath -ChildPath 'Live'
            Mock -CommandName Test-Path -ParameterFilter { $Path -like $LivePath } -MockWith { $false }

            Mock -CommandName Invoke-Command -MockWith {}

            Mock -CommandName Start-Job -MockWith {}
        }

        It 'Should not throw' {
            { Start-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }

        It 'Shoud run Start-Job 2 times'{
            Start-MinecraftServer -ServerName "TestServer" | Should -Invoke Start-Job -Times 2 -ModuleName $ModuleName
        }

    }
}