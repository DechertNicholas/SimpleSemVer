$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$testXmlPath = $here + "\Version.xml"
Write-Host "Xml path should be $testXmlPath"

function GetXmlValue ([string]$Identifier) {
    $xml = New-Object -TypeName XML
    $xml.Load($testXmlPath)

    $currentNode = Select-Xml -Xml $xml -XPath "/VersionInfo/$Identifier"
    return $currentNode.Node.Version
}

Describe "SimpleSemVer.ps1"{
    Context "Only Patch" {
        try {
            ..\src\SimpleSemVer.ps1 -Path $testXmlPath -IncrementPatch
            $version = GetXmlValue -Identifier "Patch"
            It "Increments only the Patch version" {
                $version | Should -Be "1"
            }
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $testXmlPath
        }
    }
    Context "Only Minor" {
        try {
            ..\src\SimpleSemVer.ps1 -Path $testXmlPath -IncrementMinor
            $version = GetXmlValue -Identifier "Minor"
            It "Increments only the Minor version" {
                $version | Should -Be "1"
            }
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $testXmlPath
        }
    }
    Context "Only Major" {
        try {
            ..\src\SimpleSemVer.ps1 -Path $testXmlPath -IncrementMajor
            $version = GetXmlValue -Identifier "Major"
            It "Increments only the Major version" {
                $version | Should -Be "1"
            }
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $testXmlPath
        }
    }
    Context "Minor and Patch" {
        try {
            ..\src\SimpleSemVer.ps1 -Path $testXmlPath -IncrementPatch
            $firstPatch = GetXmlValue -Identifier "Patch"
            ..\src\SimpleSemVer.ps1 -Path $testXmlPath -IncrementMinor
            $firstMinor = GetXmlValue -Identifier "Minor"
            $secondPatch = GetXmlValue -Identifier "Patch"
            It "Sets the Patch version first" {
                $firstPatch | Should -Be "1"
            }
            It "Sets the Minor version second" {
                $firstMinor | Should -Be "1"
            }
            It "Resets the Patch version when Minor increments" {
                $secondPatch | Should -Be "0"
            }
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $testXmlPath
        }
    }
}