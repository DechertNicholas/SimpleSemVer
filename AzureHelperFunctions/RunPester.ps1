$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$testDir = Resolve-Path "$here\..\test"
Write-Host "Tests in $testDir"
Invoke-Pester -Script "$testDir\*"