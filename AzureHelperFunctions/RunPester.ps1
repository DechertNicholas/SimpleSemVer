$ErrorActionPreference = "Stop"
$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$testDir = Resolve-Path "$here\..\test"
$srcDir = Resolve-Path "$here\..\src"
Write-Host "Tests in $testDir"
Import-Module Pester
Get-Module Pester
if ($env:TF_BUILD) {
    Invoke-Pester -Script "$testDir\*" -OutputFile "$($env:Common_TestResultsDirectory)/TestResults.xml" -OutputFormat NUnitXml -CodeCoverage $srcDir\SimpleSemVer.psm1 -CodeCoverageOutputFile "$($env:Common_TestResultsDirectory)/CodeCov.xml" -CodeCoverageOutputFileFormat JaCoCo
}
else {
    Invoke-Pester -Script "$testDir\*"
}

Remove-Module Pester -ErrorAction SilentlyContinue