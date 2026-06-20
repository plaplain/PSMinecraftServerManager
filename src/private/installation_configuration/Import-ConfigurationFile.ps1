function Import-InstallationConfigurationFile {
    $ConfigurationFilePath = (Get-InstallationConfigurationPath).FullPath

    if(!(Test-Paith -Path $ConfigurationFilePath)){
        throw("Invalid configuration file path '$ConfigurationFilePath'")
    }

    Get-Content -Path $ConfigurationFilePath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
}