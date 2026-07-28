BeforeAll {
    . (Join-Path -Path $PSScriptRoot -ChildPath '..\helpers' -AdditionalChildPath 'Get-DotSourceFilePath.ps1')

    $DotSourceFiles = Get-DotSourceFilePath -TestFilePath $PSCommandPath -TestFile -HelperFiles

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptRelativePath', Justification = 'False positive due to how Pester works.')]
    $ScriptRelativePath = $DotSourceFiles.SourceFilePath

    foreach ($File in $DotSourceFiles.FilesToDotSource) {
        Write-Output "Importing '$File'"
        . $File
    }
}

Describe 'Get-PaperMcDownloadUrl Tests' {
    BeforeAll {
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

        Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -eq 'https://fill.papermc.io/v3/projects/paper' } -MockWith {
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

        Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://fill.papermc.io/v3/projects/paper/versions/26.2-rc-2/builds" } -MockWith {
            $MockVersionResponses['26.2-rc-2']
        }

        Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://fill.papermc.io/v3/projects/paper/versions/26.1.2/builds" } -MockWith {
            $MockVersionResponses['26.1.2']
        }

        Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "https://fill.papermc.io/v3/projects/paper/versions/26.1.1/builds" } -MockWith {
            $MockVersionResponses['26.1.1']
        }
    }

    Context "Core Tests" {
        It 'Script file exists' {
            Test-Path $ScriptRelativePath | Should -Be $true
        }
    }

    Context "Test 'Get-PaperMcDownloadUrl'" {
        BeforeAll {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'DownloadUrl', Justification = 'False positive due to how Pester works.')]
            $DownloadUrls = Get-PaperMcDownloadUrl
        }

        It 'Get-PaperMcDownloadUrl should contain a sha https://fakeUrl.com/26.1/Stable' {
            $DownloadUrls | Should -Contain 'https://fakeUrl.com/26.1/Stable'
        }

        It  'Get-PaperMcDownloadUrl should not be null or empty.' {
            $DownloadUrls | Should -Not -BeNullOrEmpty
        }

        It  'Get-PaperMcDownloadUrl should return an array' {
            $DownloadUrls.GetType().BaseType.Name | Should -Be 'Array'
        }

        It  'Get-PaperMcDownloadUrl should return an array' {
            $DownloadUrls.count | Should -BeGreaterThan 1
        }

        It  'Get-PaperMcDownloadUrl throw with 404' {
            Mock -CommandName Invoke-RestMethod -ParameterFilter { $Uri -eq 'https://fill.papermc.io/v3/projects/paper' } -MockWith { throw('Error') }
            { Get-PaperMcDownloadUrl } | Should -Throw
        }
    }

    Context "Test 'Get-PaperMcDownloadUrl -Latest'" -Tag "Unit" {
        It  'Get-PaperMcDownloadUrl -Latest should return a string' {
            Get-PaperMcDownloadUrl -Latest | Should -BeOfType [string]
        }
    }

    Context "Test 'Get-PaperMcDownloadUrl -Channel BETA'" {
        BeforeAll {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'DownloadUrl', Justification = 'False positive due to how Pester works.')]
            $DownloadUrls = Get-PaperMcDownloadUrl -Channel Beta
        }

        It 'Get-PaperMcDownloadUrl response should contain https://fakeUrl.com/26.1/Beta' {
            $DownloadUrls | Should -Contain 'https://fakeUrl.com/26.1/Beta'
        }
    }
}

