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
                [PSCustomObject]@{
                    FullPath = $FolderPath
                }            
            }

            Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter { $Path -eq $FolderPath } -MockWith { $true }

            $LivePath = Join-Path -Path $FolderPath -ChildPath 'Live'
            Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter { $Path -eq $LivePath } -MockWith { $false }

            Mock -ModuleName $ModuleName -CommandName Invoke-Command -MockWith {}

            Mock -ModuleName $ModuleName -CommandName Start-Job -MockWith {
                [PSCustomObject]@{
                    State = 'Complete'
                }
            }

            Mock -ModuleName $ModuleName -CommandName Out-File -MockWith {}
            Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith {}
            Mock -ModuleName $ModuleName -CommandName Start-Sleep -MockWith {}
        }

        It 'Should not throw' {
            { Start-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }

        It 'Shoud run Test-Path 2 times' {
            Start-MinecraftServer -ServerName "TestServer" | Should -Invoke Test-Path -ParameterFilter $Path -eq "C:\Temp\MinecraftServerManager"   -Times 1 -ModuleName $ModuleName
        }

        It 'Shoud run Test-Path 2 times' {
            Start-MinecraftServer -ServerName "TestServer" | Should -Invoke Start-Job -Times 2 -ModuleName $ModuleName
        }

        It 'Should run Out-File 1 times' {
            Start-MinecraftServer -ServerName "TestServer" | Should -Invoke Out-File -Times 1 -ModuleName $ModuleName
        }

        It 'Should run Get-Content 1 times' {
            Start-MinecraftServer -ServerName "TestServer" | Should -Invoke Get-Content -Times 1 -ModuleName $ModuleName
        }

        It 'Should run Start-Sleep 1 times' {
            Start-MinecraftServer -ServerName "TestServer" | Should -Invoke Start-Sleep -Times 1 -ModuleName $ModuleName
        }

    }
}