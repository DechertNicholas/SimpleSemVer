Write-Host "Checking if repo is registered..."
$repos = Get-PsRepository
foreach ($repo in $repos) {
    Write-Host $repo
}
if (!($repos.Name -eq "LabPsRepo")) {
    Write-Host "Not found. Registering..."
    Register-PSRepository -Name LabPsRepo -SourceLocation '\\vega\LabPsRepo' -InstallationPolicy Trusted -Verbose
}
Write-Host "Checking if module is installed..."
$installed = Get-Module -ListAvailable -Name SimpleSemVer
if ($installed.Name -ne "SimpleSemVer") {
    Write-Host "Not found. Installing..."
    Install-Module -Name SimpleSemVer -Repository LabPsRepo -AllowPrerelease
}
Write-Host "Importing module..."
Import-Module SimpleSemVer
Set-SimpleSemVer -File $env:SYSTEM_DEFAULTWORKINGDIRECTORY/version.xml -Special "$("-alpha" + $env:BUILDNUM)"
Get-SimpleSemVer -File $env:SYSTEM_DEFAULTWORKINGDIRECTORY/version.xml -GetVersionValueWithSpecial
Update-ModuleManifest -Path "$env:SYSTEM_DEFAULTWORKINGDIRECTORY/src/SimpleSemVer.psd1" -Prerelease "$("-alpha" + $env:BUILDNUM)"
Test-ModuleManifest -Path "$env:SYSTEM_DEFAULTWORKINGDIRECTORY/src/SimpleSemVer.psd1"
Remove-Module SimpleSemVer -Force -ErrorAction Ignore