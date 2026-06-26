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

Describe 'InstallationConfiguration Class Tests' {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'InstallationConfiguration', Justification = 'False positive due to how Pester works.')]
        $DirectoryFound = New-Object -Type 'DirectoryFound'
    }

    Context 'Expected values' {
        It 'Should not be null' {
            $DirectoryFound | Should -Not -BeNullOrEmpty
        }

        It 'InnerException should be null' {
            $DirectoryFound.InnerException | Should -BeNullOrEmpty
        }

        It 'InnerException should be populated' {
            $DirectoryFound = [DirectoryFound]::new("C:\Temp")
            $DirectoryFound.Message | Should -Not -BeNullOrEmpty
            $DirectoryFound.Message | Should -BeLike "*C:\Temp*"
        }

        It 'InnerException should be populated' {
            $DirectoryFound = [DirectoryFound]::new("C:\Temp","InnerException")
            $DirectoryFound.InnerException | Should -Not -BeNullOrEmpty
        }
    }
}