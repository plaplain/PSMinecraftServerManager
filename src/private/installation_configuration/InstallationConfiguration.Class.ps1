class InstallationConfiguration {
    [hashtable]$Servers = @{}

    # Constructor
    InstallationConfiguration() {

    }

    InstallationConfiguration([string]$ConfigurationFilePath){
        $this.LoadConfiguration($ConfigurationFilePath)
    }

    [void]LoadConfiguration($Path) {
        if(!(Test-Path $Path)){
            throw('Invalid path')
        }

        $Configuration = Get-Content -Path $Path | ConvertFrom-Json

        $this.Servers = $Configuration.Servers
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

    [void]SetServer($ServerName,$ServerObject) {
        $this.Servers[$ServerName] = $ServerObject

        if($null -eq $this.Servers[$ServerName] ){

        }

        if($ServerName -ne $ServerObject.Name){
            $this.RemoveServer($ServerName)
        }        
    }

    ExportConfigurationToFile($Path) {

    }
}