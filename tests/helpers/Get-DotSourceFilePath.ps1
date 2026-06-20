function Get-DotSourceFilePath {
    param(
        [Parameter(Mandatory=$True)][string]$TestFilePath
    )

    $DotSourceFiles = [PSCustomObject]@{
        SourceFilePath = ''
        FilesToDotSource = @()
    }

    $ParentPath = Split-Path -Path $TestFilePath -Parent
    $ParentSrcPath = $ParentPath.Replace('tests','src')

    $FileName = Split-Path -Path $TestFilePath -LeafBase
    $SrcFileName = $FileName.Replace('.Tests','.ps1')

    $SrcFilePath = Join-Path -Path $ParentSrcPath -ChildPath $SrcFileName

    $DotSourceFiles.SourceFilePath = $SrcFilePath
    $DotSourceFiles.FilesToDotSource += $SrcFilePath

    #################

    $SplitTestFilePath = $TestFilePath -split '[\/\\]+'

    $Index = [Array]::IndexOf($SplitTestFilePath,'tests')

    $RootPath = $SplitTestFilePath[0..$Index] -join [IO.Path]::DirectorySeparatorChar

    $HelperPath = Join-Path -Path $RootPath -ChildPath 'helpers'

    $DotSourceFiles.FilesToDotSource += (Get-ChildItem -Path $HelperPath -Recurse -Filter "*.ps1" -ErrorAction Stop).FullName

    $DotSourceFiles
}