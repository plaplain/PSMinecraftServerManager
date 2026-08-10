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

Describe 'Start-MinecraftServer Unit Tests' -Tag 'Unit' {
    BeforeAll {
        if ($IsLinux) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FolderPath', Justification = 'False positive due to how Pester works.')]
            $FolderPath = '/home/minecraft'
        }
        else {
            $FolderPath = 'C:\Temp\'
        }

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

        $EulaPath = Join-Path -Path $FolderPath -ChildPath 'Live' -AdditionalChildPath 'eula.txt'
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter { $Path -eq $EulaPath } -MockWith { $false }

        Mock -ModuleName $ModuleName -CommandName Invoke-Command -MockWith {}

        Mock -ModuleName $ModuleName -CommandName Start-Job -MockWith {
            [PSCustomObject]@{
                State = 'Complete'
            }
        }

        Mock -ModuleName $ModuleName -CommandName Out-File -MockWith {}
        Mock -ModuleName $ModuleName -CommandName Get-Content -MockWith { 'false' }
        Mock -ModuleName $ModuleName -CommandName Start-Sleep -MockWith {}
    }

    Context "When input is valid" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }

        It 'Should not throw' {
            { Start-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }

        It 'Shoud run Test-Path 1 times' {
            Start-MinecraftServer -ServerName "TestServer"
            Should -Invoke Test-Path -ParameterFilter { $Path -eq $FolderPath } -Times 1 -ModuleName $ModuleName
        }

        It 'Shoud run Test-Path 2 times' {
            Start-MinecraftServer -ServerName "TestServer"
            Should -Invoke Test-Path -Times 2 -ModuleName $ModuleName
        }

        It 'Should run Out-File 1 times' {
            Start-MinecraftServer -ServerName "TestServer"
            Should -Invoke Out-File -Times 1 -ModuleName $ModuleName
        }

        It 'Should run Get-Content 1 times' {
            Start-MinecraftServer -ServerName "TestServer"
            Should -Invoke Get-Content -Times 1 -ModuleName $ModuleName
        }

        It 'Should run Invoke-Command 1 times' {
            Start-MinecraftServer -ServerName "TestServer" -InterativeMode
            Should -Invoke Invoke-Command -Times 1 -ModuleName $ModuleName
        }

        It 'Should run Invoke-Command 0 times' {
            Start-MinecraftServer -ServerName "TestServer"
            Should -Invoke Invoke-Command -Times 0 -ModuleName $ModuleName
        }

        It 'Should run Start-Job 1 times' {
            Start-MinecraftServer -ServerName "TestServer"
            Should -Invoke Start-Job -Times 1 -ModuleName $ModuleName
        }
    }
}

Describe 'Start-MinecraftServer Integration Tests' -Tag 'Integration' {
    BeforeAll{
        #Here we need to dot source dependencies.

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -HelperFiles 

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
    }
}