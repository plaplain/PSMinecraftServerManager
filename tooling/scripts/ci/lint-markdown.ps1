param(
    [string]$MarkdownDirectory,
    [string]$OutputDirectory
)

#Test Markdown Directory exists
if (-Not (Test-Path -Path $MarkdownDirectory -PathType Container)) {
    Write-Error "Markdown directory '$MarkdownDirectory' does not exist."
    exit 1
}

Write-Output "Installing markdownlint gem and dependencies. This may take a few minutes..."
gem install rake --no-document
gem install bundler --no-document

Write-Output "Cloning markdownlint repository and installing dependencies..."
Set-Location $OutputDirectory
git clone https://github.com/markdownlint/markdownlint
Set-Location "$OutputDirectory/markdownlint"
rake install

Write-Output "Running markdownlint on '$MarkdownDirectory' and saving output to '$OutputDirectory/lint-output/mdl.txt'"
New-Item -Path "$OutputDirectory/lint-output" -ItemType Directory -Force | Out-Null
mdl $MarkdownDirectory > "$OutputDirectory/lint-output/mdl.txt" 2>&1 || true

$FilePath = "$OutputDirectory/lint-output/mdl.txt"

Write-Output "Importing: '$FilePath'"
$TextFile = Get-Content -Path $FilePath

Write-Output "Generated XML Object"
$TestSuitesXml = New-Object System.Xml.XmlDocument
$Declaration = $TestSuitesXml.CreateXmlDeclaration("1.0", "utf-8", $null)
$TestSuitesXml.AppendChild($Declaration) | Out-Null

$XmlRoot = $TestSuitesXml.CreateElement("testsuites")
$TestSuitesXml.AppendChild($XmlRoot) | Out-Null

$TestSuite = $TestSuitesXml.CreateElement("testsuite")
$TestSuite.SetAttribute("name", "markdownlint")
$TestSuite.SetAttribute("tests", $TextFile.count)
$TestSuite.SetAttribute("failures", $TextFile.count)
$TestSuite.SetAttribute("errors", "0")
$TestSuite.SetAttribute("skipped", "0")
$XmlRoot.AppendChild($testsuite) | Out-Null

Write-Output "Iterating the text file."
foreach ($Line in $TextFile) {
    if ($Line -like "") {
        Write-Output "Empty line on text file. Breaking loop."
        break
    }
    $Object = [PSCustomObject]@{
        ClassName                 = ''
        Name                      = ''
        'Failure Message'         = ''
        'Failure Message Content' = ''
    }

    $SplitBySpace = $Line.Split(' ')

    $Object.ClassName = $SplitBySpace[0].Split(':')[0]
    $Object.Name = $SplitBySpace[0].TrimEnd(':')
    $Object.'Failure Message Content' = "Rule: $($SplitBySpace[1])"
    $Object.'Failure Message' = $SplitBySpace[1..($SplitBySpace.count - 1)] -join ' '

    $TestCase = $TestSuitesXml.CreateElement("testcase")
    $TestCase.SetAttribute("classname", $Object.ClassName)
    $TestCase.SetAttribute("name", $Object.Name)
    $TestSuite.AppendChild($TestCase) | Out-Null

    $Failure = $TestSuitesXml.CreateElement("failure")
    $Failure.SetAttribute("message", $Object.'Failure Message')
    $Failure.InnerText = $Object.'Failure Message Content'
    $TestCase.AppendChild($Failure) | Out-Null
}

$SavePath = "$(Agent.TempDirectory)/lint-output/mdl-junit.xml"

Write-Output "Saving to: '$SavePath'"
$TestSuitesXml.Save($SavePath)