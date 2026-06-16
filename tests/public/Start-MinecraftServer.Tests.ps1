BeforeAll {
    $HelperPath = Join-Path -Path $PSScriptRoot -ChildPath '\..\helpers\'
    $Helpers = Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification='False positive due to how Pester works.')]
	$ScriptRelativePath = "..\..\src\public\Start-MinecraftServer.ps1"

	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptPath', Justification='False positive due to how Pester works.')]
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

