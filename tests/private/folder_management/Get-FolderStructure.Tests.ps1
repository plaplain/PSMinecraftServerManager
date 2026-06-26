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

Describe 'Get-FolderStructure Tests' {

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Get-FolderStructure Expected values" {
        It 'Should not throw' {
            { Get-FolderStructure } | Should -Not -Throw
            { Get-FolderStructure -InstallationPath "C:\Temp" } | Should -Not -Throw
        }

        It 'Should return only folder names' {
            (Get-FolderStructure)['Live'] | Should -EQ 'Live'
        }

        It 'Should return folder path' {
            (Get-FolderStructure -InstallationPath "C:\Temp\")['Live'] | Should -EQ 'C:\Temp\Live'
        }
    }
}