function bad-powershell {
    param(
        $Hello,
        $World
    )

    if($Hello -and $World)
    {
        Write-Host "Hello, World!"
    } else 
    {
        Write-Host "Missing parameters."
    }
}