[CmdletBinding()]

Param(
    [Parameter(Mandatory = $true)]
    [String]
    $File,

    [Parameter(ParameterSetName = "GetValueWithoutSpecial")]
    [Switch]
    $GetVersionValue,

    [Parameter(ParameterSetName = "GetValueWithSpecial")]
    [Switch]
    $GetVersionValueWithSpecial,

    [Parameter(ParameterSetName = "Major")]
    [Switch]
    $IncrementMajor,

    [Parameter(ParameterSetName = "Minor")]
    [Switch]
    $IncrementMinor,

    [Parameter(ParameterSetName = "Patch")]
    [Switch]
    $IncrementPatch,

    [Parameter(ParameterSetName = "Special")]
    [String]
    $Special
)

function GenerateXmlTemplate {
    # get an XMLTextWriter to create the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($File,$Null)

    # choose a pretty formatting:
    $XmlWriter.Formatting = 'Indented'
    $XmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"

    # write the header
    $XmlWriter.WriteStartDocument()

    # set XSL statements
    $XmlWriter.WriteProcessingInstruction("xml-stylesheet", "type='text/xsl' href='style.xsl'")

    # start elements
    $XmlWriter.WriteComment('This file should be incremented with SimpleSemVer, do not manually edit unless you know what you are doing')
    $XmlWriter.WriteStartElement('VersionInfo')

    $XmlWriter.WriteStartElement('Major')
    $XmlWriter.WriteElementString('Version', '0')
    $XmlWriter.WriteEndElement()

    $XmlWriter.WriteStartElement('Minor')
    $XmlWriter.WriteElementString('Version', '0')
    $XmlWriter.WriteEndElement()

    $XmlWriter.WriteStartElement('Patch')
    $XmlWriter.WriteElementString('Version', '0')
    $XmlWriter.WriteEndElement()

    $XmlWriter.WriteStartElement('Special')
    $XmlWriter.WriteElementString('Version', '')
    $XmlWriter.WriteEndElement()

    # finalize the document:
    $XmlWriter.WriteEndDocument()
    $XmlWriter.Flush()
    $XmlWriter.Close()
}

function IncrementMajor {
    $xml = New-Object -TypeName XML
    $xml.Load($File)

    $currentMajorNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Major'
    $currentMinorNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Minor'
    $currentPatchNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Patch'
    $currentMajorNode.Node.Version = [string]([int]$currentMajorNode.Node.Version + 1)
    $currentMinorNode.Node.Version = "0"
    $currentPatchNode.Node.Version = "0"
    $xml.Save($File)
}

function IncrementMinor {
    $xml = New-Object -TypeName XML
    $xml.Load($File)

    $currentMinorNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Minor'
    $currentPatchNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Patch'
    $currentMinorNode.Node.Version = [string]([int]$currentMinorNode.Node.Version + 1)
    $currentPatchNode.Node.Version = "0"
    $xml.Save($File)
}

function IncrementPatch {
    $xml = New-Object -TypeName XML
    $xml.Load($File)

    $currentPatchNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Patch'
    $currentPatchNode.Node.Version = [string]([int]$currentPatchNode.Node.Version + 1)
    $xml.Save($File)
}

function SetSpecial {
    $xml = New-Object -TypeName XML
    $xml.Load($File)

    $currentSpecialNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Special'
    $currentSpecialNode.Node.Version = $Special
    $xml.Save($File)
}

function GetXmlValueWithoutSpecial([string]$File) {
    $xml = New-Object -TypeName XML
    $xml.Load($File)

    $currentMajor = (Select-Xml -Xml $xml -XPath "/VersionInfo/Major").Node.Version
    $currentMinor = (Select-Xml -Xml $xml -XPath "/VersionInfo/Minor").Node.Version
    $currentPatch = (Select-Xml -Xml $xml -XPath "/VersionInfo/Patch").Node.Version
    #
    return "$($currentMajor).$($currentMinor).$($currentPatch)" #$($currentSpecial)"
}

function GetXmlValueWithSpecial([String]$File) {
    $xml = New-Object -TypeName XML
    $xml.Load($File)

    $nonSpecialVersion = GetXmlValueWithoutSpecial($File)
    $currentSpecial = (Select-Xml -Xml $xml -XPath "/VersionInfo/Special").Node.Version
    return "$nonSpecialVersion" + "$currentSpecial"
}

# path resolution
if ($File -notlike "*:*") {
    # user has not provided the full path, need to interpret relative path
    $File = Join-Path -Path (Convert-Path .) -ChildPath $File
}

Write-Verbose "Testing path"
if (!(Test-Path $File)) {
    Write-Verbose "File not found, generating an empty xml"
    GenerateXmlTemplate
}

switch ($PSCmdlet.ParameterSetName) {
    'GetValueWithoutSpecial' {
        GetXmlValueWithoutSpecial($File)
    }
    'GetValueWithSpecial' {
        GetXmlValueWithSpecial($File)
    }
    'Major' {
        IncrementMajor
    }

    'Minor' {
        IncrementMinor
    }

    'Patch' {
        IncrementPatch
    }

    'Special' {
        SetSpecial
    }
}