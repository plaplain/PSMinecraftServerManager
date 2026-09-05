function Get-InstallationConfigurationPath {

    if($IsLinux){
        Join-Path -Path $Env:HOME -ChildPath ".MinecraftServerManager"
    }
    else{
        Join-Path -Path $Env:APPDATA -ChildPath "MinecraftServerManager"
    }
}