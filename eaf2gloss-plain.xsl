<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">   <xsl:output method="text" omit-xml-declaration="yes" />
    <xsl:variable name="nl" select="'&#xa;'"></xsl:variable>
    <xsl:template match="/">
        <xsl:for-each select="ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='wordT']/ANNOTATION/REF_ANNOTATION/ANNOTATION_VALUE"> 
            <xsl:value-of select=".,$nl"/>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>