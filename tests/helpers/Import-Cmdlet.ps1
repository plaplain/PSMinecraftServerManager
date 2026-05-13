function Import-Cmdlet {
    param (
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$CmdletName
    )

    $ModuleName = "TestPs1Module_$CmdletName"
	$Script = Get-Content -Path $FilePath -Raw
	$CmdletCode = [ScriptBlock]::Create($script)
	New-Module -Name $ModuleName -ScriptBlock $CmdletCode -ErrorAction Stop | Out-Null
}