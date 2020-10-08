Write-Host "Checking if pester is installed..."
$modules = Get-Module -ListAvailable
if ($modules.Name -notcontains 'pester') {
    Write-Host "Not found, installing pester"
    Install-Module -Name Pester -Force -SkipPublisherCheck

    Write-Host "Verifying installation..."
    $modules = Get-Module -ListAvailable
    if ($modules.Name -notcontains 'pester') {
        throw "Unable to install Pester`n$($modules.Name)"
    }
}
Write-Host "Pester is installed. Version info:"