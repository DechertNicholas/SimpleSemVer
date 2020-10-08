$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
$script:testXmlPath = $here + "\Version.xml"
Write-Host "Xml path should be $script:testXmlPath"
Write-Host "SimpleSemVer path should be $(Resolve-Path "$here\..\src\SimpleSemVer.ps1")"

function GetXmlValue ([string]$Identifier) {
    Write-Host "Xml path to load should be $script:testXmlPath"
    $xml = New-Object -TypeName XML
    $xml.Load($script:testXmlPath)

    $currentNode = Select-Xml -Xml $xml -XPath "/VersionInfo/$Identifier"
    return $currentNode.Node.Version
}

Describe "SimpleSemVer.ps1"{
    Context "File Creation" {
        try {
            It "Creates the Version file if it does not exist" {
                Write-Host "Xml Path should still be $script:testXmlPath"
                Write-Host "Here is $here"
                &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementPatch
                $exists = Test-Path $script:testXmlPath
                $exists | Should -Be $true
            }
        }
        catch {
            Write-Error $_
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $script:testXmlPath -ErrorAction Continue
        }
    }
    Context "Only Patch" {
        try {
            $debugText = Resolve-Path "$here\..\src\SimpleSemVer.ps1"
            Write-Host "Should still be $debugText"
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementPatch
            $version = GetXmlValue -Identifier "Patch"
            It "Increments only the Patch version" {
                $version | Should -Be "1"
            }
        }
        catch {
            Write-Error $_
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $script:testXmlPath -ErrorAction Continue
        }
    }
    Context "Only Minor" {
        try {
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementMinor
            $version = GetXmlValue -Identifier "Minor"
            It "Increments only the Minor version" {
                $version | Should -Be "1"
            }
        }
        catch {
            Write-Error $_
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $script:testXmlPath -ErrorAction Continue
        }
    }
    Context "Only Major" {
        try {
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementMajor
            $version = GetXmlValue -Identifier "Major"
            It "Increments only the Major version" {
                $version | Should -Be "1"
            }
        }
        catch {
            Write-Error $_
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $script:testXmlPath -ErrorAction Continue
        }
    }
    Context "Minor and Patch" {
        try {
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementPatch
            $firstPatch = GetXmlValue -Identifier "Patch"
            &(Resolve-Path "$here\..\src\SimpleSemVer.ps1") -Path $script:testXmlPath -IncrementMinor
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
        catch {
            Write-Error $_
        }
        finally {
            # need to delete after every test
            Remove-Item -Path $script:testXmlPath -ErrorAction Continue
        }
    }
}