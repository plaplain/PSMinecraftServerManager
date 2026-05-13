function Test-CmdletThrowWithNoParameters {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$CmdletName
    )

    try {
        $Module = Import-Cmdlet -FilePath $FilePath -CmdletName $CmdletName

        $AllParameters = (Get-Command $CmdletName).Parameters

        $MandatoryParameters = $false

        foreach($Parameter in $AllParameters.GetEnumerator()) {
            if($Parameter.Value.Attributes.Mandatory){
                $MandatoryParameters = $true
                break
            }
        }

        $MandatoryParameters | Should -Be $true
    }
    finally {
        $Module | Remove-Module
    }
}