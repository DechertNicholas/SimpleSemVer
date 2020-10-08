$ErrorActionPreference = "Stop"
$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$testDir = Resolve-Path "$here\..\test"
Write-Host "Tests in $testDir"
Import-Module Pester
Get-Module Pester
if ($env:TF_BUILD) {
    Invoke-Pester -Script "$testDir\*" -OutputFile "$($env:Common_TestResultsDirectory)/TestResults.xml" -OutputFormat "XUnitXml" -
}
else {
    Invoke-Pester -Script "$testDir\*"
}

Remove-Module Pester -ErrorAction SilentlyContinue