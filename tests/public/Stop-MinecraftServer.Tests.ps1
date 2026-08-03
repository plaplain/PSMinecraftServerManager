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

Describe 'Stop-MinecraftServer Tests' {
    BeforeAll {}

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Test 'Start-MinecraftServer'" {
        BeforeAll {
            Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Stop-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies

            $ModuleName = "TestPs1Module_Stop-MinecraftServer"

            Mock -CommandName Get-Job -ModuleName $ModuleName -MockWith {
                [PSCustomObject]@{
                    State = 'Running'
                    Id = 1234
                }
            }

            Mock -CommandName Stop-Job -ModuleName $ModuleName -MockWith {}
        }

        It 'Should not throw' {
            { Stop-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }

        It 'Shoud run Stop-Job 1 times' {
            Stop-MinecraftServer -ServerName "TestServer"
            Should -Invoke Stop-Job -Times 1 -ModuleName $ModuleName
        }

        It 'Shoud run Get-Job 1 times' {
            Stop-MinecraftServer -ServerName "TestServer"
            Should -Invoke Get-Job -Times 1 -ModuleName $ModuleName
        }

        It 'Should throw if no job'{
            Mock -CommandName Get-Job -ModuleName $ModuleName -MockWith {}
            { Stop-MinecraftServer -ServerName "TestServer" } | Should -Throw
        }
    }
}