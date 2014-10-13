<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <!-- first key to look up slot elements by their id -->
    <xsl:key name="slotById" match="TIME_SLOT" use="@TIME_SLOT_ID" />
    <!-- second key to look up normalized word annotations by the value of their slots -->
    <xsl:key name="annotationBySlots" match="TIER[@LINGUISTIC_TYPE_REF='normalized word']/ANNOTATION"
        use="concat(key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF1)/@TIME_VALUE, '|',
        key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF2)/@TIME_VALUE)" />
    <xsl:template match="/ANNOTATION_DOCUMENT">
        <xsl:text>original&#x9;normalized&#xA;</xsl:text>
        <xsl:apply-templates select="TIER[@LINGUISTIC_TYPE_REF = 'original word']/ANNOTATION" />
    </xsl:template>
    <xsl:template match="ANNOTATION">
        <xsl:value-of select="ALIGNABLE_ANNOTATION/ANNOTATION_VALUE" />
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="
            key('annotationBySlots',
            concat(key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF1)/@TIME_VALUE, '|',
            key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF2)/@TIME_VALUE)
            )/ALIGNABLE_ANNOTATION/ANNOTATION_VALUE" />
        <xsl:text>&#xA;</xsl:text>
    </xsl:template>
</xsl:stylesheet>