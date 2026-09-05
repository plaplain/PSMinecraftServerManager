<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER TestFilePath
Parameter description

.PARAMETER CmdletName
Parameter description

.PARAMETER FunctionsToMock
Parameter description

.PARAMETER ClassesToMock
[PSCustomObject]@{
    ClassName = ''
    Constructors = @(
        [string],
        [string];[int],
        [string];[int];[string]
    )
    Methods = @(
        [PSCustomObject]@{
            Name = 'HelloWorld'
            Inputs = [string];[int]
            OutputType = 'void'
            Output = 'HelloWorld'
        }
    )
}

.EXAMPLE
An example

.NOTES
General notes
#>
function Import-Cmdlet {
    param (
        [Parameter(Mandatory = $true)][string]$TestFilePath,
        [Parameter(Mandatory = $true)][string]$CmdletName,
        [Parameter(Mandatory = $false)][string[]]$FunctionsToMock,
        [Parameter(Mandatory = $false)][array]$ClassesToMock,
        [Parameter(Mandatory = $false)][switch]$OutputScriptBlockOnly
    )

    # Clean up
    $ModuleName = "TestPs1Module_$CmdletName"

    $FilePath = ($TestFilePath.Replace('.Tests', '')).Replace('tests', 'src')

    $ExistingModule = Get-Module -Name $ModuleName

    if ($ExistingModule) {
        $ExistingModule | Remove-Module -Force
    }

    
    $Dependencies = ""

    #Classes
    $Dependencies += New-ImportCmdletClassRawCode -ClassesToMock $ClassesToMock

    # Functions
    foreach ($Function in $FunctionsToMock) {
        $Dependencies += "function $Function {}" + [System.Environment]::NewLine
    }

    $Script = Get-Content -Path $FilePath -Raw

    $ScriptBlockCode = $Dependencies + $Script

    if ($OutputScriptBlockOnly) {
        $ScriptBlockCodeCleaned = ($ScriptBlockCode -split "`n" | Where-Object { $_ -notmatch "Export-ModuleMember" } | Join-String -Separator "`n")

        [ScriptBlock]::Create($ScriptBlockCodeCleaned)
    }
    else {
        $CmdletCode = [ScriptBlock]::Create($ScriptBlockCode)
        $Module = New-Module -Name $ModuleName -ScriptBlock $CmdletCode -ErrorAction Stop
        $Module | Import-Module -ErrorAction Stop
        $Module
    }
}