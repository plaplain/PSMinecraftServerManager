function Update-Manifest {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification='Not required for workflow')] 
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModulePath,
        
        [Parameter(Mandatory=$true)]
        [string]$ModuleManifestPath,
        
        [Parameter(Mandatory=$true)]
        [string]$Version
    )
    
    # Validation
    if (-not (Test-Path $ModulePath)) {
        throw "ModulePath '$ModulePath' does not exist."
    }
    
    if (-not (Test-Path $ModuleManifestPath)) {
        throw "ModuleManifestPath '$ModuleManifestPath' does not exist."
    }

    # Get private functions
    $PrivateFunctions = Get-ChildItem -Path "$ModulePath\private" -Filter "*.ps1" -Recurse -ErrorAction Stop
    $NestedModules = @()

    foreach($Function in $PrivateFunctions){
        $NestedModules += ".$($Function.FullName.Replace($ModulePath,'').Replace('\','/'))"
    }

    # Get public cmdlets
    $PublicCmdlets = Get-ChildItem -Path "$ModulePath\public" -Filter "*.ps1" -Recurse -ErrorAction Stop

    foreach($Cmdlet in $PublicCmdlets){
        $NestedModules += ".$($Cmdlet.FullName.Replace($ModulePath,'').Replace('\','/'))"
    }

    Update-ModuleManifest -Path $ModuleManifestPath -NestedModules $NestedModules -CmdletsToExport $PublicCmdlets.BaseName -ModuleVersion $Version -ErrorAction Stop
}
