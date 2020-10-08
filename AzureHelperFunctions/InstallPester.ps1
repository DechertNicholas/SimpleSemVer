$modules = Get-Module -ListAvailable
if ($modules.Name -notcontains 'pester') {
    Install-Module -Name Pester -Force -SkipPublisherCheck
}
$modules = Get-Module -ListAvailable
if ($modules.Name -notcontains 'pester') {
    throw "Unable to install Pester`n$($modules.Name)"
}