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

Describe 'Get-FolderStructure Unit Tests' -Tag 'Unit' {
    BeforeAll{
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

    Context "Get-FolderStructure Expected values" {
        It 'Should not throw' {
            { Get-FolderStructure } | Should -Not -Throw
            { Get-FolderStructure -InstallationPath $FolderPath } | Should -Not -Throw
        }

        It 'Should return only folder names' {
            (Get-FolderStructure)['Live'] | Should -EQ 'Live'
        }

        It 'Should return folder path' {
            $LivePath = Join-Path -Path $FolderPath -ChildPath 'Live'
            (Get-FolderStructure -InstallationPath $FolderPath)['Live'] | Should -EQ $LivePath
        }
    }
}