BeforeAll {
    $HelperPath = Join-Path -Path $PSScriptRoot -ChildPath 'helpers\'
    $Helpers = Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop
    foreach ($Helper in $Helpers) {
        . $Helper.FullName
    }

    $ModuleName = 'MinecraftServerManager'
    $ModuleManifestName = "$ModuleName.psd1"

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptPath', Justification = 'False positive due to how Pester works.')]
    $ModuleManifestPath = "$PSScriptRoot\..\src\$ModuleManifestName"
}

BeforeDiscovery {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'PublicFunctions', Justification = 'False positive due to how Pester works.')]
    $PublicFunctions = Get-ChildItem -Path "$PSScriptRoot\..\src\public\" -Recurse -Filter "*.ps1" -ErrorAction Stop

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'PrivateFunctions', Justification = 'False positive due to how Pester works.')]
    $PrivateFunctions = Get-ChildItem -Path "$PSScriptRoot\..\src\private\" -Recurse -Filter "*.ps1" -Exclude "*.Class.ps1" -ErrorAction Stop

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Classes', Justification = 'False positive due to how Pester works.')]
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

Describe "Base Function & Class Tests" -Tag 'Unit' {
    Context "Private functions are defined" {
        foreach ($File in $PrivateFunctions) {
            It "Function is defined: $($File.BaseName)" -TestCases @{ File = $File } {
                Test-FunctionIsDefined -FilePath $File.FullName -FunctionName $File.BaseName
            }
        }
    }

    Context "Classes are defined" -Tag 'Unit' {
        foreach ($File in $Classes) {
            $ClassName = ($File.BaseName).Replace('.Class', '')
            It "Class is defined $ClassName" -TestCases @{ File = $File; ClassName = $ClassName } {
                Test-ClassIsDefined -FilePath $File.FullName -ClassName $ClassName
            }
        }
    }

    Context "Public Cmdlet are defined" {
        foreach ($File in $PublicFunctions) {
            It "Function is defined: $($File.BaseName)" -TestCases @{ File = $File } {
                Test-CmdletIsDefined -FilePath $File.FullName -CmdletName $File.BaseName
            }

            It "Export-ModuleMember is defined & uncommented: $($File.BaseName)" -TestCases @{ File = $File } {
                Test-FunctionCallsExportModuleMember -FilePath $File.FullName -FunctionName $File.BaseName
            }
        }
    }
}

Describe "MinecraftServerManager Integration Tests" -Tag 'Integration' {
    BeforeAll {
        $ModuleName = 'MinecraftServerManager'

        if ($IsLinux) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'FolderPath', Justification = 'False positive due to how Pester works.')]
            $FolderPath = '/home/minecraft'
        }
        else {
            $FolderPath = 'C:\Temp\'
        }

        $LiveFolderPath = Join-Path -Path $FolderPath -ChildPath 'Live'
        $BackupFolderPath = Join-Path -Path $FolderPath -ChildPath 'Backup'
        $LogsFolderPath = Join-Path -Path $FolderPath -ChildPath 'Logs'
        $InstallationConfigurationPath = Join-Path -Path $FolderPath -ChildPath 'MinecraftServerManager' -AdditionalChildPath 'Install.json'

        # Install-MinecraftServer Mocks
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter {$Name -like $InstallationConfigurationPath} -MockWith {$true}

        # Test-Javainstallation Mocks
        Mock -ModuleName $ModuleName -CommandName Get-Command -ParameterFilter {$Name -like 'java'} -MockWith {}

        # New-FolderStructure Mocks
        Mock -CommandName Test-Path -ParameterFilter {$Path -like $FolderPath} -MockWith {$true}
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter {$Path -like $LiveFolderPath} -MockWith {$false}
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter {$Path -like $BackupFolderPath} -MockWith {$false}
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter {$Path -like $LogsFolderPath} -MockWith {$false}
        Mock -ModuleName $ModuleName -CommandName New-Item -MockWith {}

        # InstallationConfigurationClass Mocks
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter {$Path -like $FolderPath} -MockWith {}
        $ConfigurationFilePath = Join-Path -Path $FolderPath -ChildPath 'configuration.json'
        Mock -ModuleName $ModuleName -CommandName Test-Path -ParameterFilter {$Path -like $ConfigurationFilePath} -MockWith {}
        Mock -ModuleName $ModuleName -CommandName Out-File -MockWith {}

        $MockVersionResponses = @{
            '26.2-rc-2' = @(
                [PSCustomObject]@{
                    id        = 70
                    time      = (Get-Date '06/01/2026')
                    channel   = 'STABLE'
                    commits   = @{
                        sha     = '70eaed653d2260e42e510ea16e8fcb50152aa5ef'
                        time    = (Get-Date '05/01/2026')
                        message = 'Soft limit projectile list size (#13954)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.2/Stable'
                        }
                    }
                },
                [PSCustomObject]@{
                    id        = 69
                    time      = (Get-Date '04/01/2026')
                    channel   = 'BETA'
                    commits   = @{
                        sha     = '76d2ac758cb3abe75aceefa88207443768f585c6'
                        time    = (Get-Date '03/01/2026')
                        message = 'Soft limit projectile list size (#13954)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.2/Beta'
                        }
                    }
                },
                [PSCustomObject]@{
                    id        = 68
                    time      = (Get-Date '02/01/2026')
                    channel   = 'ALPHA'
                    commits   = @{
                        sha     = '3580fa4066c0081b96c4b3b2fb3a5ca2214a98c0'
                        time    = (Get-Date '01/01/2026')
                        message = 'Soft limit projectile list size (#13954)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.2/Alpha'
                        }
                    }
                }
            )
            '26.1.2' = @(
                [PSCustomObject]@{
                    id = 60
                    time = (Get-Date '11/12/2025')
                    channel = 'STABLE'
                    commits = @{
                        sha = '70eaed653d2260e42e510ea15e8fcb50152aa5ef'
                        time = (Get-Date '10/12/2025')
                        message = 'Soft limit projectile list size (#13953)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.1/Stable'
                        }
                    }
                },
                [PSCustomObject]@{
                    id        = 59
                    time      = (Get-Date '09/12/2025')
                    channel   = 'BETA'
                    commits   = @{
                        sha     = '76d2ac758cb3abe75aceeed88207443768f585c6'
                        time    = (Get-Date '08/12/2025')
                        message = 'Soft limit projectile list size (#13952)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.1/Beta'
                        }
                    }
                },
                [PSCustomObject]@{
                    id        = 58
                    time      = (Get-Date '07/12/2025')
                    channel   = 'ALPHA'
                    commits   = @{
                        sha     = '3580fa4066c0081b96c4b5a2fb3a5ca2214a98c0'
                        time    = (Get-Date '06/12/2025')
                        message = 'Soft limit projectile list size (#13951)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.1/Alpha'
                        }
                    
                    }
                }
            )
            '26.1.1' = @(
                [PSCustomObject]@{
                    id = 57
                    time = (Get-Date '05/12/2025')
                    channel = 'STABLE'
                    commits = @{
                        sha = '70eaed653d2260e42e510ea15e8fcb50152aa5ef'
                        time = (Get-Date '04/12/2025')
                        message = 'Soft limit projectile list size (#13953)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.1/Stable'
                        }
                    }
                },
                [PSCustomObject]@{
                    id        = 56
                    time      = (Get-Date '03/12/2025')
                    channel   = 'BETA'
                    commits   = @{
                        sha     = '76d2ac758cb3abe75aceeed88207443768f585c6'
                        time    = (Get-Date '02/12/2025')
                        message = 'Soft limit projectile list size (#13952)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.1/Beta'
                        }
                    }
                },
                [PSCustomObject]@{
                    id        = 55
                    time      = (Get-Date '01/12/2025')
                    channel   = 'ALPHA'
                    commits   = @{
                        sha     = '3580fa4066c0081b96c4b5a2fb3a5ca2214a98c0'
                        time    = (Get-Date '06/11/2025')
                        message = 'Soft limit projectile list size (#13951)'
                    }
                    downloads = @{
                        'server:default' = @{
                            Url = 'https://fakeUrl.com/26.1/Alpha'
                        }
                    
                    }
                }
            )
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://fill.papermc.io/v3/projects/paper/versions/26.2-rc-2/builds" } -MockWith {
            $MockVersionResponses['26.2-rc-2']
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://fill.papermc.io/v3/projects/paper/versions/26.1.2/builds" } -MockWith {
            $MockVersionResponses['26.1.2']
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://fill.papermc.io/v3/projects/paper/versions/26.1.1/builds" } -MockWith {
            $MockVersionResponses['26.1.1']
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-RestMethod -ParameterFilter { $Uri -eq 'https://fill.papermc.io/v3/projects/paper' } -MockWith {
            @{
                project  = [PSCustomObject]@{
                    id   = 'paper'
                    name = 'Paper'
                }
                versions = [PSCustomObject]@{
                    '26.2' = @(
                        '26.2-rc-2'
                    )
                    '26.1' = @(
                        '26.1.2',
                        '26.1.1'
                    )
                }
            }
        }

        Mock -ModuleName $ModuleName -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json' } -MockWith {
            [PSCustomObject]@{
                latest = [PSCustomObject]@{
                    release = '26.2'
                    snapshot = '26.2'
                }
                versions = @(
                    [PSCustomObject]@{
                        id = '26.2'
                        type = 'release'
                        url = 'https://piston-meta.mojang.com/v1/packages/4c3cd3500ce8b9ea104c358a784634fedb2a610f/26.2.json'
                        releaseTime = '16/06/2026 13:03:33'
                    },
                    [PSCustomObject]@{
                        id = '26.1.2'
                        type = 'release'
                        url = 'https://piston-meta.mojang.com/v1/packages/e3510ae9ff09fba9410cbbb8a02bfd819632155d/26.1.2.json'
                        releaseTime = '09/04/2026 11:12:23'
                    },
                    [PSCustomObject]@{
                        id = '26.2-rc-2'
                        type = 'snapshot'
                        url = 'https://piston-meta.mojang.com/v1/packages/606a0e2eb54d953ac478774efcfcedcdf59f4cc5/26.2-rc-2.json'
                        releaseTime = '12/06/2026 12:32:28'
                    },
                    [PSCustomObject]@{
                        id = '26.2-rc-1'
                        type = 'snapshot'
                        url = 'https://piston-meta.mojang.com/v1/packages/f7053b943901bf8734b73723f43b31a9a8b6b776/26.2-rc-1.json'
                        releaseTime = '11/06/2026 12:57:50'
                    },
                    [PSCustomObject]@{
                        id = '26.2-pre-6'
                        type = 'snapshot'
                        url = 'https://piston-meta.mojang.com/v1/packages/020b103ce898979439db892c0c259d76936f559d/26.2-pre-6.json'
                        releaseTime = '10/06/2026 13:20:24'
                    }
                )
            }
        }
    }

    Context "Module can load" {
        BeforeAll{
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'GetModule', Justification = 'False positive due to how Pester works.')]
            $GetModule = Get-Module $ModuleName

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Cmdlets', Justification = 'False positive due to how Pester works.')]
            $Cmdlets = @(
                @{Cmdlet ='Install-MinecraftServer'}
                @{Cmdlet ='Update-MinecraftServer'},
                @{Cmdlet ='Start-MinecraftServer'},
                @{Cmdlet ='Stop-MinecraftServer'},
                @{Cmdlet ='Backup-MinecraftServer'}
            )
        }

        It "Get-Module returns a value" {
            $GetModule | Should -Not -BeNullOrEmpty
        }

        It "Get-Module should contain cmdlets" -ForEach $Cmdlets {
            $GetModule.ExportedCommands.Keys | Should -Contain $Cmdlet
        }
    }

    Context "Install-Minecraft" {
        It "Should install vanilla"{
            Install-MinecraftServer -ServerName 'IntegrationTest' -InstallationPath $FolderPath
        }
    }
}