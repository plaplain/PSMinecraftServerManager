BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '\..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'Start-MinecraftServer Tests' {

	Context "unit tests" -Tag "Unit" {
		It 'Script file exists' {
			Test-ScriptFileIsPresent -PSScriptRoot $PSScriptRoot -ScriptRelativePath $ScriptRelativePath
		}
	}

	Context "integration tests" -Tag "Integration" {
		It 'Start-MinecraftServer throws when required parameters are missing' {
			Test-CmdletThrowWithNoParameter -FilePath $ScriptPath -CmdletName 'Start-MinecraftServer'
		}
	}
}

