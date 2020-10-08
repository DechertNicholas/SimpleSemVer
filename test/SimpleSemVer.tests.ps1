$ErrorActionPreference = "Stop"
$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$script:testXmlPath = $here + "\Version.xml"
Write-Host "Current location is $here"
Write-Host "Xml path should be $script:testXmlPath"
Write-Host "SimpleSemVer path should be $(Resolve-Path "$here\..\src\SimpleSemVer.ps1")"

function Script:GetXmlValue ([string]$Identifier) {
    $xml = New-Object -TypeName XML
    $xml.Load($script:testXmlPath)

    $currentNode = Select-Xml -Xml $xml -XPath "/VersionInfo/$Identifier"
    return $currentNode.Node.Version
}

Describe "SimpleSemVer.ps1"{
    Context "File Creation" {
        It "Creates the Version file if it does not exist" {
            try {
                &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementPatch
                $exists = Test-Path "$script:testXmlPath"
                $exists | Should -Be $true
            }
            catch {
                Write-Error $_
            }
            finally {
                # need to delete after every test
                Remove-Item -Path $script:testXmlPath
            }

        }
    }
    Context "Only Patch" {
        It "Increments only the Patch version" {
            try {
                &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementPatch
                $version = Script:GetXmlValue -Identifier "Patch"
                $version | Should -Be "1"
            }
            catch {
                Write-Error $_
            }
            finally {
                # need to delete after every test
                Remove-Item -Path $script:testXmlPath
            }
        }
    }
    Context "Only Minor" {
        It "Increments only the Minor version" {
            try {
                &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementMinor
                $version = Script:GetXmlValue -Identifier "Minor"
                $version | Should -Be "1"
            }
            catch {
                Write-Error $_
            }
            finally {
                # need to delete after every test
                Remove-Item -Path $script:testXmlPath
            }
        }
    }
    Context "Only Major" {
        It "Increments only the Major version" {
            try {
                &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementMajor
                $version = Script:GetXmlValue -Identifier "Major"
                $version | Should -Be "1"
            }
            catch {
                Write-Error $_
            }
            finally {
                # need to delete after every test
                Remove-Item -Path $script:testXmlPath
            }
        }
    }
    Context "Minor and Patch" {
        $firstMinor = ""
        $firstPatch = ""
        It "Sets the Patch version first" {
            # pester 5 is weird, so we have to generate and gather data in an "It" block
            # we also don't want to delete the file here, as we're chaning it later
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementPatch
            $firstPatch = Script:GetXmlValue -Identifier "Patch"

            # actual test
            $firstPatch | Should -Be "1"
        }
        It "Sets the Minor version second" {
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementMinor
            $firstMinor = Script:GetXmlValue -Identifier "Minor"
            $firstMinor | Should -Be "1"
        }
        It "Resets the Patch version when Minor increments" {
            $secondPatch = Script:GetXmlValue -Identifier "Patch"
            $secondPatch | Should -Be "0"
        }
        It "Utility: Deletes file (needs to be last test in context)" {
            Remove-Item -Path $script:testXmlPath
            $exists = Test-Path $script:testXmlPath
            $exists | Should -BeFalse
        }
    }
}
