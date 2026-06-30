function Import-Cmdlet {
    param (
        [Parameter(Mandatory = $true)][string]$TestFilePath,
        [Parameter(Mandatory = $true)][string]$CmdletName,
        [Parameter(Mandatory = $false)][string[]]$FunctionsToMock
    )

    # Clean up
    $ModuleName = "TestPs1Module_$CmdletName"

    $FilePath = ($TestFilePath.Replace('.Tests','')).Replace('tests','src')

    $ExistingModule = Get-Module -Name $ModuleName

    if($ExistingModule){
        $ExistingModule | Remove-Module -Force
    }

    # Functions
    $Dependencies = ""

    foreach($Function in $FunctionsToMock){
        $Dependencies += "function $Function {}" + [System.Environment]::NewLine
    }

	$Script = Get-Content -Path $FilePath -Raw

    $ScriptBlockCode = $Dependencies + $Script
	$CmdletCode = [ScriptBlock]::Create($ScriptBlockCode)
	New-Module -Name $ModuleName -ScriptBlock $CmdletCode -ErrorAction Stop | Import-Module -ErrorAction Stop
}