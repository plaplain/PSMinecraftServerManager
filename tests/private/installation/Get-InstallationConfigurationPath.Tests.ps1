BeforeAll {
    $HelperPath = Join-Path -Path $PSScriptRoot -ChildPath '\..\..\helpers\'
    $Helpers = Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

    $ScriptRelativePath = "..\..\..\src\private\installation\Get-InstallationConfigurationPath.ps1"
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptRelativePath

    . $ScriptPath

    $IsLinuxRelativePath = "..\..\..\src\private\Get-IsLinux.ps1"
    $IsLinuxPath = Join-Path -Path $PSScriptRoot -ChildPath $IsLinuxRelativePath

    . $IsLinuxPath
}

Describe 'Get-InstallationConfiguration Tests' {
    BeforeAll {
        $Env:APPDATA = 'C:\Users\Username\AppData\Roaming'
        $Env:HOME = '/home/Username'
    }

    Context "'Get-InstallationConfiguration'" {
        BeforeAll {
            Mock Get-IsLinux -MockWith {
                $false
            }

            $InstallationConfigurationPathWindows = Get-InstallationConfigurationPath

            Mock Get-IsLinux -MockWith {
                $true
            }

            $InstallationConfigurationPathLinux = Get-InstallationConfigurationPath
        }

        It 'Should return a hashtable' {
            $InstallationConfigurationPathWindows | Should -BeOfType [hashtable]
            $InstallationConfigurationPathLinux | Should -BeOfType [hashtable]
            
        }

        It 'Should contain the keys FullPath and Parent Path' {
            $InstallationConfigurationPathWindows.Keys | Should -Contain 'FullPath'
            $InstallationConfigurationPathWindows.Keys | Should -Contain 'ParentPath'

            $InstallationConfigurationPathLinux.Keys | Should -Contain 'FullPath'
            $InstallationConfigurationPathLinux.Keys | Should -Contain 'ParentPath'
        }

        It 'The value of keys FullPath and ParentPath should not be null or empty.' {
            $InstallationConfigurationPathWindows.FullPath | Should -Not -BeNullOrEmpty
            $InstallationConfigurationPathWindows.ParentPath | Should -Not -BeNullOrEmpty

            $InstallationConfigurationPathLinux
            $InstallationConfigurationPathLinux
        }
    }
}