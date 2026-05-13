Function Start-MinecraftServer {
    param(
        [Parameter(Mandatory = $true)][string]$ServerDirectory
    )
}

Export-ModuleMember 'Start-MinecraftServer'