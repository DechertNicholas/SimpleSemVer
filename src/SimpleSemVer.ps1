[CmdletBinding()]

Param(
    [Parameter(Mandatory = $true)]
    [String]
    $Path,

    [Parameter(ParameterSetName = "Major")]
    [Switch]
    $IncrementMajor,

    [Parameter(ParameterSetName = "Minor")]
    [Switch]
    $IncrementMinor,

    [Parameter(ParameterSetName = "Patch")]
    [Switch]
    $IncrementPatch#,

    # [Parameter()]
    # [String]
    # $Special
)

function GenerateXmlTemplate {
    # get an XMLTextWriter to create the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($Path,$Null)
    
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
    $XmlWriter.WriteElementString('Version', '-SpecialText')
    $XmlWriter.WriteEndElement()

    # finalize the document:
    $XmlWriter.WriteEndDocument()
    $XmlWriter.Flush()
    $XmlWriter.Close()
}

function IncrementMajor {
    $xml = New-Object -TypeName XML
    $xml.Load($Path)

    $currentMajorNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Major'
    $currentMinorNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Minor'
    $currentPatchNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Patch'
    $currentMajorNode.Node.Version = [string]([int]$currentMajorNode.Node.Version + 1)
    $currentMinorNode.Node.Version = "0"
    $currentPatchNode.Node.Version = "0"
    $xml.Save($Path)
}

function IncrementMinor {
    $xml = New-Object -TypeName XML
    $xml.Load($Path)

    $currentMinorNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Minor'
    $currentPatchNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Patch'
    $currentMinorNode.Node.Version = [string]([int]$currentMinorNode.Node.Version + 1)
    $currentPatchNode.Node.Version = "0"
    $xml.Save($Path)
}

function IncrementPatch {
    $xml = New-Object -TypeName XML
    $xml.Load($Path)

    $currentPatchNode = Select-Xml -Xml $xml -XPath '/VersionInfo/Patch'
    $currentPatchNode.Node.Version = [string]([int]$currentPatchNode.Node.Version + 1)
    $xml.Save($Path)
}

Write-Host "Testing path"
if (!(Test-Path $Path)) {
    Write-Host "File not found, generating an empty xml"
    GenerateXmlTemplate
}

switch ($PSCmdlet.ParameterSetName) {
    'Major' {
        IncrementMajor
    }

    'Minor' {
        IncrementMinor
    }

    'Patch' {
        IncrementPatch
    }
}