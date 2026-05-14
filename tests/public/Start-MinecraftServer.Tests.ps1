BeforeAll {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '',Justification='False positive due to how Pester works.')]

    $Helpers = Get-ChildItem -Path "$PSScriptRoot\..\Helpers\" -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

	$ScriptRelativePath = "..\..\src\public\Start-MinecraftServer.ps1"
	$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptRelativePath
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

