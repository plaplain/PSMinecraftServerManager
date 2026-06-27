BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -TestFile -HelperFiles

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'New-FolderStructure Tests' -Tag 'Linux' {
    BeforeAll {
        if ($IsLinux) {
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

    Context "New-FolderStructure Expected values" {
        BeforeAll {
            function Get-FolderStructure {
                @{
                    Live   = 'Live'
                    Backup = 'Backup'
                    Logs   = 'Logs'
                }

                class DirectoryFound : System.Exception {
                    hidden $BaseErrorMessage = 'The directory exists when not expected to'

                    DirectoryFound() : base("$BaseErrorMessage.") {}

                    DirectoryFound([string]$DirectoryPath) : base("$BaseErrorMessage '$DirectoryPath'.") {}

                    DirectoryFound([string]$DirectoryPath, [System.Exception]$InnerExceptionMessage) : base(
                        "$BaseErrorMessage '$DirectoryPath'.",
                        $InnerExceptionMessage) {
                    }
                }
            }

            Mock -CommandName Test-Path -MockWith {
                $false
            }

            Mock -CommandName Test-Path -ParameterFilter { $Path -like $FolderPath } -MockWith {
                $true
            }

            Mock -CommandName New-Item -MockWith {
                $null
            }
        }

        It 'Should not throw' {
            { New-FolderStructure -Path $FolderPath } | Should -Not -Throw        
        }

        It 'Should throw if folders already exist' {
            $ExistingPath = Join-Path -Path $FolderPath -ChildPath 'Backup'
            Mock -CommandName Test-Path -ParameterFilter { $Path -like $ExistingPath } -MockWith {
                $true
            }

            { New-FolderStructure -Path $FolderPath } | Should -Throw
        }

        It 'Should not throw if folders already exist' {
            $ExistingPath = Join-Path -Path $FolderPath -ChildPath 'Backup'
            Mock -CommandName Test-Path -ParameterFilter { $Path -like $ExistingPath } -MockWith {
                $true
            }

            { New-FolderStructure -Path $FolderPath -Force } | Should -Not -Throw
        }
    }

    Context "New-FolderStructure Invalid vlaues" {
        It 'Should throw with Valid path' {
            Mock -CommandName Test-Path -ParameterFilter { $Path -like $FolderPath } -MockWith {
                $false
            }

            { New-FolderStructure -Path $FolderPath } | Should -Throw
        }
    }
}