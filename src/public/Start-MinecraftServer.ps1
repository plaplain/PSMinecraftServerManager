<#
 .SYNOPSIS
     Starts a Minecraft server.
 .DESCRIPTION
     This function starts a Minecraft server in the specified directory.
 .PARAMETER ServerDirectory
     The directory where the Minecraft server is located.
 .EXAMPLE
     Start-MinecraftServer -ServerDirectory "C:\Minecraft\Server" 
#>
Function Start-MinecraftServer {
    [CmdletBinding(SupportsShouldProcess = $true)]

    param(
        [Parameter(Mandatory = $true)][string]$ServerDirectory
    )

    #Change

    Start-Job
}

Export-ModuleMember 'Start-MinecraftServer'