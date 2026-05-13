BeforeAll {
    $Helpers = Get-ChildItem -Path "$PSScriptRoot\..\Helpers\" -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

	$ScriptRelativePath = "..\..\src\public\Start-MinecraftServer.ps1"
	$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptRelativePath
}

Describe 'Start-MinecraftServer Tests' {

	Context "unit tests" -Tag "Unit" {
		It 'Export-ModuleMember is defined & uncommented' {
			Test-FunctionCallsExportModuleMember -FilePath $ScriptPath -FunctionName 'Start-MinecraftServer'
		}

		It 'Script file exists' {
			Test-ScriptFileExists -PSScriptRoot $PSScriptRoot -ScriptRelativePath $ScriptRelativePath
		}
	}

	Context "integration tests" -Tag "Integration" {
		It 'Start-MinecraftServer throws when required parameters are missing' {
			Test-CmdletThrowWithNoParameters -FilePath $ScriptPath -CmdletName 'Start-MinecraftServer'
		}
	}
}

