function Remove-Cmdlet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$CmdletName
    )

    Remove-Module -Name "TestPs1Module_$CmdletName"
}