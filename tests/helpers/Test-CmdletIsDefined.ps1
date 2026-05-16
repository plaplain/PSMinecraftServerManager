function Test-CmdletIsDefined {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$CmdletName
    )

    try {
        $Module = Import-Cmdlet -FilePath $FilePath -CmdletName $CmdletName
        Get-Command -Name $CmdletName -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
    finally {
        $Module | Remove-Module
    }
}


