Function Start-MinecraftServer {
    [CmdletBinding(SupportsShouldProcess = $true)]

    param(
        [Parameter(Mandatory = $true)][string]$ServerDirectory
    )

    #Change

    Start-Job
}

#Export-ModuleMember 'Start-MinecraftServer'