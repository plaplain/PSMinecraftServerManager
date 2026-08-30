<#
.SYNOPSIS
Starts a configured Minecraft server.

.DESCRIPTION
Starts a Minecraft server using the configured server name.

.PARAMETER ServerName
The server name you used when running Install-MinecraftServer

.PARAMETER InterativeMode
Run in an interactive mode where you can see the server console.

.EXAMPLE
Start-MinecraftServer -ServerName 'MyServer'
#>
function Start-MinecraftServer {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)][string]$ServerName,
        [Parameter(Mandatory = $false)][switch]$InterativeMode
    )

    $InstallationConfigurationPath = Get-InstallationConfigurationPath

    if(!(Test-Path -Path $InstallationConfigurationPath)){
        throw("No installation detected. Please run Install-MinecraftServer")
    }

    $Configuration = [InstallationConfiguration]::new($InstallationConfigurationPath)

    $ServerConfig = $Configuration.GetServer($ServerName)

    if($null -eq $ServerConfig){
        throw("No configuration for server '$ServerName'.")
    }

    $FolderStructure = Get-FolderStructure -InstallationPath $ServerConfig.InstallationFolder
    $LivePath = $FolderStructure['Live']

    # How do we get the live folder path?
    $MinecraftServerJar = Join-Path -Path $LivePath -ChildPath 'minecraft_server.jar'

    if($IsLinux){
        $LaunchScriptBlock = {java -Xmx1024M -Xms1024M -jar $MinecraftServerjar nogui}
    }
    else {
        $LaunchScriptBlock = {java -Xmx1024M -Xms1024M -jar $MinecraftServerjar nogui}
    }

    $EulaFilePath = Join-Path -Path $LivePath -ChildPath "eula.txt"
    if (!(Test-Path -Path $EulaFilePath) -and $PSCmdlet.ShouldProcess("Generate EULA for '$ServerName'")) {
        Write-Output "First run detected. Starting the server to generate the eula file. The server will stop, this is expected."

        $Job = Start-Job -Name $ServerName -ScriptBlock $LaunchScriptBlock

        $RunTime = 0
        while($Job.State -eq 'Running'){
            if($RunTime -ge 600){
                throw("EULA generation took too long.")
            }
            Start-Sleep -Seconds 1
            $RunTime = 1
        }

        Write-Output "Accepting the Eula file"
        $EulaFile = Get-Content -Path $EulaFilePath -Raw
        $EulaFile = $EulaFile.replace("false", "true")
        $EulaFile | Out-File -FilePath $EulaFilePath -Encoding ([System.Text.Encoding]::UTF8)
    }

    if($InterativeMode -and $PSCmdlet.ShouldProcess($ServerName)){
        Invoke-Command -ScriptBlock $LaunchScriptBlock
    }
    else {
        $Job = Start-Job -Name $ServerName -ScriptBlock $LaunchScriptBlock
    }    
}

Export-ModuleMember 'Start-MinecraftServer'