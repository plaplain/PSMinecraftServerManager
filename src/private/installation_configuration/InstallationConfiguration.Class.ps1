class InstallationConfiguration {
    [hashtable]$Servers = @{}

    # Constructor
    InstallationConfiguration() {

    }

    InstallationConfiguration([string]$ConfigurationFilePath) {
        $this.LoadConfiguration($ConfigurationFilePath)
    }

    [void]LoadConfiguration($Path) {
        if (!(Test-Path $Path)) {
            throw('Invalid path')
        }

        $Configuration = Get-Content -Path $Path | ConvertFrom-Json

        $ConfigurationMembers = $Configuration.Servers | Get-Member -MemberType NoteProperty

        $ConfigurationHashtable =@{}

        foreach($Member in $ConfigurationMembers){
            $ConfigurationHashtable[$Member.Name] = $Configuration.Servers.($Member.Name)
        }

        $this.Servers = $ConfigurationHashtable
    }

    [PSCustomObject]GetServer([string]$ServerName) {
        return $this.Servers[$ServerName]
    }

    [PSCustomObject]GetAllServers() {
        return $this.Servers
    }

    # Add server
    [void]AddServer($ServerName, $InstallationFolder) {
        if ($null -ne $this.Servers[$ServerName]) {
            throw("A server by the name '$ServerName' already exists.")
        }
        
        $ServerConfiguration = [PSCustomObject]@{
            Name               = $ServerName
            InstallationFolder = $InstallationFolder
        }

        $this.Servers.Add($ServerName, $ServerConfiguration)
    }

    # Remove Server
    [void]RemoveServer($ServerName) {
        $this.Servers.Remove($ServerName)
    }

    [void]SetServer($ServerName, $ServerObject) {
        if ($null -eq $this.Servers[$ServerName] -and $null -eq $this.Servers[$ServerObject.Name]) {
            throw("No configuration for server name '$ServerName' or '$($ServerObject.Name)'")
        }

        if ($ServerName -ne $ServerObject.Name) {
            $this.Servers[$ServerObject.Name] = $ServerObject
            $this.RemoveServer($ServerName)
        }
        else {
            $this.Server[$ServerName]
        }
    }

    ExportConfigurationToFile($Path) {

    }
}