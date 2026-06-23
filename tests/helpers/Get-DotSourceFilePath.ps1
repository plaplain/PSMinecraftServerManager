function Get-DotSourceFilePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$TestFilePath,
        [Parameter(Mandatory = $false)][switch]$TestFile,
        [Parameter(Mandatory = $false)][switch]$HelperFiles
    )

    $DotSourceFiles = [PSCustomObject]@{
        SourceFilePath   = ''
        FilesToDotSource = @()
    }

    $ParentPath = Split-Path -Path $TestFilePath -Parent
    $ParentSrcPath = $ParentPath.Replace('tests', 'src')

    $FileName = Split-Path -Path $TestFilePath -LeafBase
    $SrcFileName = $FileName.Replace('.Tests', '.ps1')

    $SrcFilePath = Join-Path -Path $ParentSrcPath -ChildPath $SrcFileName

    $DotSourceFiles.SourceFilePath = $SrcFilePath

    switch ($PSBoundParameters.Keys) {
        'TestFile' {
            Write-Verbose 'Adding test file to FilesToDotSource'
            $DotSourceFiles.FilesToDotSource += $SrcFilePath
        }

        'HelperFiles' {
            Write-Verbose 'Adding helper files to FilesToDotSource'
            $SplitTestFilePath = $TestFilePath -split '[\/\\]+'

            $Index = [Array]::IndexOf($SplitTestFilePath, 'tests')

            $RootPath = $SplitTestFilePath[0..$Index] -join [IO.Path]::DirectorySeparatorChar

            $HelperPath = Join-Path -Path $RootPath -ChildPath 'helpers'

            $DotSourceFiles.FilesToDotSource += (Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop).FullName           
        }
    }
    $DotSourceFiles
}