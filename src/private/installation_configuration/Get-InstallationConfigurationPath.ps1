function Get-InstallationConfigurationPath {

    if($IsLinux){
        $ConfigurationLocation = Join-Path -Path $Env:HOME -ChildPath ".MinecraftServerManager"
    }
    else{
        $ConfigurationLocation = Join-Path -Path $Env:APPDATA -ChildPath "MinecraftServerManager"
    }

    @{
        FullPath = Join-Path -Path $ConfigurationLocation -ChildPath 'Install.json'
        ParentPath = $ConfigurationLocation
    }
}