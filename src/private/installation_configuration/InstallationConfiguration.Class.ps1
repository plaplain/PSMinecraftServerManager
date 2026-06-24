class InstallationConfiguration {
    hidden [string]$ConfigurationFileName = 'configuration.json'

    hidden $Configuration = [PSCustomObject]@{
        Servers = @{}
    }

    # Constructor
    InstallationConfiguration() {

    }

    InstallationConfiguration([string]$ConfigurationFilePath) {
        $this.LoadConfiguration($ConfigurationFilePath)
    }

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

    [PSCustomObject]GetServer([string]$ServerName) {
        return $this.Configuration.Servers[$ServerName]
    }

    [PSCustomObject]GetAllServers() {
        return $this.Configuration.Servers
    }

    # Add server
    [void]AddServer([string]$ServerName, [string]$InstallationFolder) {
        if ($null -ne $this.Configuration.Servers[$ServerName]) {
            throw("A server by the name '$ServerName' already exists.")
        }
        
        $ServerConfiguration = [PSCustomObject]@{
            Name               = $ServerName
            InstallationFolder = $InstallationFolder
        }

        $this.Configuration.Servers.Add($ServerName, $ServerConfiguration)
    }

    # Remove Server
    [void]RemoveServer($ServerName) {
        $this.Configuration.Servers.Remove($ServerName)
    }

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

    [void]ExportConfigurationToFile([string]$Path,[boolean]$Overwrite = $false) {
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