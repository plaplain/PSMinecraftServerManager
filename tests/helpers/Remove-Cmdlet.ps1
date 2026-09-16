function Remove-Cmdlet {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)][string]$CmdletName
    )

    if($PSCmdlet.ShouldProcess("Remove cmdlet $CmdletName")) {
        Remove-Module -Name "TestPs1Module_$CmdletName"
    }    
}