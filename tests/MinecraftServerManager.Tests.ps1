BeforeAll {
    $Helpers = Get-ChildItem -Path "$PSScriptRoot\Helpers\" -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

    $ModuleName = 'MinecraftServerManager'
    $ModuleManifestName = "$ModuleName.psd1"
    $ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"
}

BeforeDiscovery{
    $PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\..\src\public\" -Recurse -Filter "*.ps1" -ErrorAction Stop
    $PrivateFunctions = Get-ChildItem -Path "$PSScriptRoot\..\src\private\" -Recurse -Filter "*.ps1" -ErrorAction Stop
}

Describe 'Module Manifest Tests' {   
    Context "module manifest validation" -Tag "Unit" {
        It 'Passes Test-ModuleManifest' {
            Test-ModuleManifest -Path $ModuleManifestPath | Should -Not -BeNullOrEmpty
            $? | Should -Be $true
        }
    }
}

Describe "Base Function Tests" {
    Context "Private functions are defined" -Tag "Unit" {
        foreach($File in $PrivateFunctions){
            It "Function is defined: $($File.BaseName)" -TestCases @{ File = $File} {
                Test-FunctionIsDefined -FilePath $File.FullName -FunctionName $File.BaseName
            }
        }
    }

    Context "Public functions are defined" -Tag "Unit" {
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