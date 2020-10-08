Write-Output "Checking if pester is installed..."
$modules = Get-Module -ListAvailable
if ($modules.Name -notcontains 'pester') {
    Write-Output "Not found, installing pester"
    Install-Module -Name Pester -Force -SkipPublisherCheck

    Write-Output "Verifying installation..."
    $modules = Get-Module -ListAvailable
    if ($modules.Name -notcontains 'pester') {
        throw "Unable to install Pester`n$($modules.Name)"
    }
}
Write-Output "$(Get-Module 'Pester')"