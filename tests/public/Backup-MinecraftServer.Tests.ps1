BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -HelperFiles 

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
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
                    Output     = '@{
                        InstallationPath = "C:\Temp\Bob"
                    }'
                }
            )
        }
    )

    Import-Cmdlet -TestFilePath $PSCommandPath -CmdletName 'Backup-MinecraftServer' -FunctionsToMock $FunctionDependencies -ClassesToMock $ClassDependencies
}

Describe 'Backup-MinecraftServer Unit Tests' -Tag 'Unit' {
    BeforeAll {
        if ($IsLinux) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FolderPath', Justification = 'False positive due to how Pester works.')]
            $FolderPath = '/home/minecraft'
        }
        else {
            $FolderPath = 'C:\Temp\'
        }

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
                @{FullPath = "/home/minecraft" }
            }
            else {
                @{FullPath = "C:\Temp\MinecraftServerManager" }
            }               
        }

        Mock -ModuleName $ModuleName -CommandName Copy-Item -MockWith {}

        Mock -ModuleName $ModuleName -CommandName Test-Path -MockWith { $true }
    }

    Context "When input is valid" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }

        It 'Backup-MinecraftServer should not throw' {
            { Backup-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }
    }

    Context "When input is invalid" {
        It 'Backup-MinecraftServer invalid folder path should throw' -ForEach @(
            @{ Folder = 'Live' }
            @{ Folder = 'Backup' }
            @{ Folder = 'Logs' }
        ) {
            $FolderPath = Join-Path -Path $FolderPath -ChildPath $Folder
            Mock -CommandName Test-Path -ParameterFilter { $Path -like $FolderPath } {
                $false
            }
            { Backup-MinecraftServer -ServerName "TestServer" } | Should -Not -Throw
        }

        It 'Backup-MinecraftServer should throw if Copy-Item fails' {
            Mock -ModuleName $ModuleName -CommandName Copy-Item -MockWith {
                throw('Failed to copy!')
            }

            { Backup-MinecraftServer -ServerName "TestServer" } | Should -Throw
        }
    }
}