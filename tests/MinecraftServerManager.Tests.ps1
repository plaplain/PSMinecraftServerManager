BeforeAll {
    $HelperPath = Join-Path -Path $PSScriptRoot -ChildPath 'helpers\'
    $Helpers = Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

    $ModuleName = 'MinecraftServerManager'
    $ModuleManifestName = "$ModuleName.psd1"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptPath', Justification='False positive due to how Pester works.')]
    $ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"
}

BeforeDiscovery{

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'PublicFunctions', Justification='False positive due to how Pester works.')]
    $PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\..\src\public\" -Recurse -Filter "*.ps1" -ErrorAction Stop

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'PrivateFunctions', Justification='False positive due to how Pester works.')]
    $PrivateFunctions = Get-ChildItem -Path "$PSScriptRoot\..\src\private\" -Recurse -Filter "*.ps1" -Exclude "*.Class.ps1" -ErrorAction Stop

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Classes', Justification='False positive due to how Pester works.')]
    $Classes = Get-ChildItem -Path "$PSScriptRoot\..\src\private\" -Recurse -Filter "*Class.ps1" -ErrorAction Stop
}

Describe 'Module Manifest Tests' {   
    Context "module manifest validation" -Tag "Unit" {
        It 'Passes Test-ModuleManifest' {
            Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
            $? | Should -Be $true
        }
    }
}

Describe "Base Function & Class Tests" {
    Context "Private functions are defined" -Tag "Unit" {
        foreach($File in $PrivateFunctions){
            It "Function is defined: $($File.BaseName)" -TestCases @{ File = $File} {
                Test-FunctionIsDefined -FilePath $File.FullName -FunctionName $File.BaseName
            }
        }
    }

    Context "Classes are defined" {
        foreach($File in $Classes){
            $ClassName = ($File.BaseName).Replace('.Class','')
            It "Class is defined $ClassName" -TestCases @{ File = $File; ClassName = $ClassName} {
                Test-ClassIsDefined -FilePath $File.FullName -ClassName $ClassName
            }
        }
    }

    Context "Public Cmdlet are defined" -Tag "Unit" {
        foreach($File in $PublicFunctions){
            It "Function is defined: $($File.BaseName)" -TestCases @{ File = $File} {
                Test-CmdletIsDefined -FilePath $File.FullName -CmdletName $File.BaseName
            }

            It "Export-ModuleMember is defined & uncommented: $($File.BaseName)" -TestCases @{ File = $File} {
			    Test-FunctionCallsExportModuleMember -FilePath $File.FullName -FunctionName $File.BaseName
		    }
        }
    }
}