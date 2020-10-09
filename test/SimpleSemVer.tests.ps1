BeforeAll {
    $ErrorActionPreference = "Stop"
    $testXmlPath = Join-Path -Path $PSScriptRoot -ChildPath "Version.xml"
    $srcDir = Resolve-Path "$PSScriptRoot\..\src"
    Remove-Module -Name SimpleSemVer -Force -ErrorAction Ignore
    Import-Module "$srcDir\SimpleSemVer.psd1"

    # debug output
    Write-Host "Current location is $PSScriptRoot"
    Write-Host "Xml path should be $testXmlPath"
    Write-Host "SimpleSemVer path should be $(Resolve-Path "$srcDir\SimpleSemVer.psd1")"

    # helper function (basically Get-SimpleSemVer)
    function GetXmlValue ([string]$Identifier) {
        $xml = New-Object -TypeName XML
        $xml.Load($testXmlPath)

        $currentNode = Select-Xml -Xml $xml -XPath "/VersionInfo/$Identifier"
        return $currentNode.Node.Version
    }
}
Describe "SimpleSemVer.ps1"{
    Context "File Creation" {
        It "Creates the Version file if it does not exist" {
            try {
                Set-SimpleSemVer -File $testXmlPath -IncrementPatch
                $exists = Test-Path "$testXmlPath"
                $exists | Should -Be $true
            }
            catch {
                Write-Error $_
            }
            finally {
                # need to delete after every test
                Remove-Item -Path $testXmlPath
            }

        }
    }
    # Context "Only Patch" {
    #     It "Increments only the Patch version" {
    #         try {
    #             &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementPatch
    #             $version = ScriptGetXmlValue -Identifier "Patch"
    #             $version | Should -Be "1"
    #         }
    #         catch {
    #             Write-Error $_
    #         }
    #         finally {
    #             # need to delete after every test
    #             Remove-Item -Path $testXmlPath
    #         }
    #     }
    # }
    # Context "Only Minor" {
    #     It "Increments only the Minor version" {
    #         try {
    #             &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementMinor
    #             $version = GetXmlValue -Identifier "Minor"
    #             $version | Should -Be "1"
    #         }
    #         catch {
    #             Write-Error $_
    #         }
    #         finally {
    #             # need to delete after every test
    #             Remove-Item -Path $testXmlPath
    #         }
    #     }
    # }
    # Context "Only Major" {
    #     It "Increments only the Major version" {
    #         try {
    #             &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementMajor
    #             $version = GetXmlValue -Identifier "Major"
    #             $version | Should -Be "1"
    #         }
    #         catch {
    #             Write-Error $_
    #         }
    #         finally {
    #             # need to delete after every test
    #             Remove-Item -Path $testXmlPath
    #         }
    #     }
    # }
    # Context "Minor and Patch" {
    #     $firstMinor = ""
    #     $firstPatch = ""
    #     It "Sets the Patch version first" {
    #         # pester 5 is weird, so we have to generate and gather data in an "It" block
    #         # we also don't want to delete the file here, as we're chaning it later
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementPatch
    #         $firstPatch = GetXmlValue -Identifier "Patch"

    #         # actual test
    #         $firstPatch | Should -Be "1"
    #     }
    #     It "Sets the Minor version second" {
    #         &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $testXmlPath -IncrementMinor
    #         $firstMinor = GetXmlValue -Identifier "Minor"
    #         $firstMinor | Should -Be "1"
    #     }
    #     It "Resets the Patch version when Minor increments" {
    #         $secondPatch = GetXmlValue -Identifier "Patch"
    #         $secondPatch | Should -Be "0"
    #     }
    #     It "Utility Deletes file (needs to be last test in context)" {
    #         Remove-Item -Path $testXmlPath
    #         $exists = Test-Path $testXmlPath
    #         $exists | Should -BeFalse
    #     }
    # }
    AfterAll {
        Remove-Module SimpleSemVer -Force -ErrorAction Ignore
    }
}