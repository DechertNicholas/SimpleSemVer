$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$testXmlPath = $here + "\Version.xml"
Write-Host "Xml path should be $testXmlPath"
Write-Host "SimpleSemVer path should be $(Resolve-Path "$here\..\src\SimpleSemVer.ps1")"

function GetXmlValue ([string]$Identifier) {
    Write-Host "Xml path to load should be $testXmlPath"
    $xml = New-Object -TypeName XML
    $xml.Load($testXmlPath)

    $currentNode = Select-Xml -Xml $xml -XPath "/VersionInfo/$Identifier"
    return $currentNode.Node.Version
}

Describe "SimpleSemVer.ps1"{
    Context "File Creation" {
        It "Creates the Version file if it does not exist" {
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementPatch
            Write-Host "Does the file exist? $(Test-Path $testXmlpath)"
            Get-ChildItem $here
        }
    }
    # Context "Only Patch" {
    #     try {
    #         $debugText = Resolve-Path "$here\..\src\SimpleSemVer.ps1"
    #         Write-Host "Should still be $debugText"
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementPatch
    #         $version = GetXmlValue -Identifier "Patch"
    #         It "Increments only the Patch version" {
    #             $version | Should -Be "1"
    #         }
    #     }
    #     catch {
    #         Write-Error $_
    #     }
    #     finally {
    #         # need to delete after every test
    #         Remove-Item -Path $testXmlPath
    #     }
    # }
    # Context "Only Minor" {
    #     try {
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementMinor
    #         $version = GetXmlValue -Identifier "Minor"
    #         It "Increments only the Minor version" {
    #             $version | Should -Be "1"
    #         }
    #     }
    #     catch {
    #         Write-Error $_
    #     }
    #     finally {
    #         # need to delete after every test
    #         Remove-Item -Path $testXmlPath
    #     }
    # }
    # Context "Only Major" {
    #     try {
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementMajor
    #         $version = GetXmlValue -Identifier "Major"
    #         It "Increments only the Major version" {
    #             $version | Should -Be "1"
    #         }
    #     }
    #     catch {
    #         Write-Error $_
    #     }
    #     finally {
    #         # need to delete after every test
    #         Remove-Item -Path $testXmlPath
    #     }
    # }
    # Context "Minor and Patch" {
    #     try {
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementPatch
    #         $firstPatch = GetXmlValue -Identifier "Patch"
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementMinor
    #         $firstMinor = GetXmlValue -Identifier "Minor"
    #         $secondPatch = GetXmlValue -Identifier "Patch"
    #         It "Sets the Patch version first" {
    #             $firstPatch | Should -Be "1"
    #         }
    #         It "Sets the Minor version second" {
    #             $firstMinor | Should -Be "1"
    #         }
    #         It "Resets the Patch version when Minor increments" {
    #             $secondPatch | Should -Be "0"
    #         }
    #     }
    #     catch {
    #         Write-Error $_
    #     }
    #     finally {
    #         # need to delete after every test
    #         Remove-Item -Path $testXmlPath
    #     }
    # }
}