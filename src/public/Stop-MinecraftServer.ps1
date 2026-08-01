<#
.SYNOPSIS
Stop a configured Minecraft server.

.DESCRIPTION
Stops a Minecraft server using the configured server name.

.PARAMETER ServerName
The server name you used when running Install-MinecraftServer

.EXAMPLE
Stop-MinecraftServer -ServerName 'MyServer'
#>
function Stop-MinecraftServer {
    param(
        [Parameter(Mandatory = $true)][string]$ServerName
    )

    $Job = Get-Job -Name $ServerName

    if($null -eq $Job){
        return "No Minecraft server detected. Is it running?"
    }

    if($Job.State -eq 'Running'){
        Stop-Job -Id $Job.Id -ErrorAction Stop | Out-Null
        return "Server stopped."
    }
    else{
        return "Server no longer running in a stable state."
    }
}

Export-ModuleMember 'Stop-MinecraftServer'