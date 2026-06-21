BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '\..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -TestFile -HelperFiles

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'Get-MinecraftDownloadUrl Tests' {
    BeforeAll {
        Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json' } -MockWith {
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

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Test 'Get-MinecraftDownloadUrl'"{
        BeforeAll{
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'DownloadUrls', Justification = 'False positive due to how Pester works.')]
            $DownloadUrls = Get-MinecraftDownloadUrl
        }

        It 'Get-MinecraftDownloadUrl should contain an expected URL'{
            $DownloadUrls | Should -Contain 'https://piston-meta.mojang.com/v1/packages/e3510ae9ff09fba9410cbbb8a02bfd819632155d/26.1.2.json'
        }

        It  'Get-MinecraftDownloadUrl should not be null or empty.' {
            $DownloadUrls | Should -Not -BeNullOrEmpty
        }

        It  'Get-MinecraftDownloadUrl should return an array' {
            $DownloadUrls.GetType().BaseType.Name | Should -Be 'Array'
        }

        It  'Get-MinecraftDownloadUrl should return an array' {
            $DownloadUrls.count | Should -BeGreaterThan 1
        }

        It  'Get-MinecraftDownloadUrl throw with 404' {
            Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -eq 'https://launchermeta.mojang.com/mc/game/version_manifest_v2.json' } -MockWith { throw('Error') }
            { Get-MinecraftDownloadUrl } | Should -Throw
        }
    }

    Context "Test 'Get-MinecraftDownloadUrl -Latest"{
        BeforeAll{
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'DownloadUrls', Justification = 'False positive due to how Pester works.')]
            $DownloadUrls = Get-MinecraftDownloadUrl -Latest
        }

        It  'Get-MinecraftDownloadUrl -Latest should return a string' {
            $DownloadUrls | Should -BeOfType [string]
        }

        It 'Get-MinecraftDownloadUrl -Latest should contain an expected URL'{
            $DownloadUrls | Should -Contain 'https://piston-meta.mojang.com/v1/packages/4c3cd3500ce8b9ea104c358a784634fedb2a610f/26.2.json'
            $DownloadUrls | Should -Not -Contain 'https://piston-meta.mojang.com/v1/packages/020b103ce898979439db892c0c259d76936f559d/26.2-pre-6.json'
        }
    }

    Context "Test 'Get-MinecraftDownloadUrl -Type snapshot'"{
        BeforeAll {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'DownloadUrls', Justification = 'False positive due to how Pester works.')]
            $DownloadUrls = Get-MinecraftDownloadUrl -Type snapshot
        }

        It 'Get-MinecraftDownloadUrl response should contain expected URLs' {
            $DownloadUrls | Should -Contain 'https://piston-meta.mojang.com/v1/packages/f7053b943901bf8734b73723f43b31a9a8b6b776/26.2-rc-1.json'
            $DownloadUrls | Should -Not -Contain 'https://piston-meta.mojang.com/v1/packages/4c3cd3500ce8b9ea104c358a784634fedb2a610f/26.2.json'
        }
    }

    Context "Test 'Get-MinecraftDownloadUrl -Type 'snapshot' -Latest'"{
        BeforeAll {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'DownloadUrls', Justification = 'False positive due to how Pester works.')]
            $DownloadUrls = Get-MinecraftDownloadUrl -Type snapshot
        }
        
        It  'Get-MinecraftDownloadUrl should return a string' {
            $DownloadUrls | Should -BeOfType [string]
        }        
    }
}