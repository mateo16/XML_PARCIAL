<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:template match="/data">
        <xsl:element name="{local-name()}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <!-- Pointing to your schema location -->
            <xsl:attribute name="xsi:noNamespaceSchemaLocation">../schemas/congress_data.xsd</xsl:attribute>
            <xsl:copy-of select="node()"/>
        </xsl:element>
    </xsl:template>

    <!-- Other templates to process the document if necessary -->

</xsl:stylesheet>
