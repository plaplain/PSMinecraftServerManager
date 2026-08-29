<#
    .SYNOPSIS
    This class is responsible for managing the installation configuration file.
#>
class InstallationConfiguration {
    hidden [string]$ConfigurationFileName = 'configuration.json'

    hidden $Configuration = [PSCustomObject]@{
        Servers = @{}
    }

    # Constructor
    InstallationConfiguration() {

    }

    InstallationConfiguration([string]$ConfigurationFolderPath) {
        $this.LoadConfiguration($ConfigurationFolderPath)
    }

    <#
        .SYNOPSIS
        Loads configuration.json from the passed path.

        .INPUTS
        [string]$Path - The folder path where the configuration file exists.
    #>
    [void]LoadConfiguration([string]$Path) {
        if (!(Test-Path $Path)) {
            throw('Invalid path')
        }

        $FilePath = Join-Path -Path $Path -ChildPath $this.ConfigurationFileName

        $ConfigurationFile = Get-Content -Path $FilePath | ConvertFrom-Json -ErrorAction Stop

        $ConfigurationFileMembers = $ConfigurationFile | Get-Member -MemberType NoteProperty

        if($ConfigurationFileMembers.Name -notcontains 'Servers'){
            throw('Invalid configuration file. Servers property missing.')
        }

        $ConfigurationServerMembers = $ConfigurationFile.Servers | Get-Member -MemberType NoteProperty

        $ConfigurationHashtable =@{}

        foreach($Member in $ConfigurationServerMembers){
            $ConfigurationHashtable[$Member.Name] = $ConfigurationFile.Servers.($Member.Name)
        }

        $this.Configuration.Servers = $ConfigurationHashtable
    }

    <#
        .SYNOPSIS
        Returns a server configuration using the server name

        .INPUTS
        [string]$ServerName - The name of the server.

        .OUTPUTS
        [PSCustomObject] - Contains the details of the server such as name, installation location.
    #>
    [PSCustomObject]GetServer([string]$ServerName) {
        return $this.Configuration.Servers[$ServerName]
    }

    <#
        .SYNOPSIS
        Returns aall server configurations.

        .OUTPUTS
        [PSCustomObject] - The configuration of all the servers.
    #>
    [PSCustomObject]GetAllServers() {
        return $this.Configuration.Servers
    }

    <#
        .SYNOPSIS
        Adds a server to the configuration

        .INPUTS
        [string]$ServerName         - The name of the server to add.
        [string]$InstallationFolder - The folder where the server is installed.
        [switch]$PaperMc            - If the server runs PaperMc
    #>
    [void]AddServer([string]$ServerName, [string]$InstallationFolder, [boolean]$PaperMc) {
        if ($null -ne $this.Configuration.Servers[$ServerName]) {
            throw("A server by the name '$ServerName' already exists.")
        }

        if($PaperMc){
            $ServerType = 'PaperMc'
        }
        else{
            $ServerType = 'Vanilla'
        }
        
        $ServerConfiguration = [PSCustomObject]@{
            Name               = $ServerName
            InstallationFolder = $InstallationFolder
            ServerType         = $ServerType
        }

        $this.Configuration.Servers.Add($ServerName, $ServerConfiguration)
    }

    <#
        .SYNOPSIS
        Removes a server from the configuration

        .INPUTS
        [string]$ServerName         - The name of the server to remove.
    #>
    [void]RemoveServer($ServerName) {
        $this.Configuration.Servers.Remove($ServerName)
    }

    <#
        .SYNOPSIS
        Sets an existing server to the configuration

        .INPUTS
        [string]$ServerName           - The name of the server to update.
        [PSCustomObject]$ServerObject - A server object generated from GetServer or GetAllServers
    #>
    [void]SetServer([string]$ServerName, [PSCustomObject]$ServerObject) {
        if ($null -eq $this.Configuration.Servers[$ServerName] -and $null -eq $this.Configuration.Servers[$ServerObject.Name]) {
            throw("No configuration for server name '$ServerName' or '$($ServerObject.Name)'")
        }

        if ($ServerName -ne $ServerObject.Name) {
            $this.Configuration.Servers[$ServerObject.Name] = $ServerObject
            $this.RemoveServer($ServerName)
        }
        else {
            $this.Configuration.Server[$ServerName]
        }
    }

    <#
        .SYNOPSIS
        Exports the configuration to a configuration.json file to the passed path.

        .INPUTS
        [string]$Path       - The folder path where the server should be exported to.
    #>
    [void]ExportConfigurationToFile([string]$Path){
        $this._ExportConfigurationToFile($Path,$False)
    }

    <#
        .SYNOPSIS
        Exports the configuration to a configuration.json file to the passed path.

        .INPUTS
        [string]$Path       - The folder path where the server should be exported to.
        [boolean]$Overwrite - Set to true to overwrite an existing configuration file.
    #>
    [void]ExportConfigurationToFile([string]$Path,[boolean]$Overwrite = $false) {
        $this._ExportConfigurationToFile($Path,$Overwrite)
    }

    <#
        .SYNOPSIS
        A "private" function which exports the configuration to a configuration.json file to the passed path.

        .INPUTS
        [string]$Path       - The folder path where the server should be exported to.
    #>
    [void]_ExportConfigurationToFile([string]$Path,[boolean]$Overwrite){
        if (!(Test-Path -Path $Path)) {
            throw('Invalid path')
        }

        $FilePath = Join-Path -Path $Path -ChildPath $this.ConfigurationFileName

        if((Test-Path -Path $FilePath) -and $Overwrite -eq $false){
            throw('Configuration file already exists.')
        }

        $this.Configuration | ConvertTo-Json -Depth 10 | Out-File -FilePath $FilePath
    }
}