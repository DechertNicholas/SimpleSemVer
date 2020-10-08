$ErrorActionPreference = "Stop"
$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$testDir = Resolve-Path "$here\..\test"
Write-Host "Tests in $testDir"
Import-Module Pester
Get-Module Pester
Invoke-Pester -Script "$testDir\*"
Remove-Module Pester -ErrorAction SilentlyContinue