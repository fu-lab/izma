<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/ANNOTATION_DOCUMENT">
        <xsl:text>original&#x9;normalized
</xsl:text>
            <xsl:for-each select="TIER[@LINGUISTIC_TYPE_REF='original word']/ANNOTATION/ALIGNABLE_ANNOTATION">
                <xsl:sort select="substring-after(@TIME_SLOT_REF1, 'ts')" data-type="number"/>
                <xsl:variable name="startTimeId" select="@TIME_SLOT_REF1"/>
                <xsl:variable name="endTimeId" select="@TIME_SLOT_REF2"/>
                <xsl:variable name="startTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$startTimeId]/@TIME_VALUE"/>
                <xsl:variable name="endTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$endTimeId]/@TIME_VALUE"/>
                        <xsl:value-of select="ANNOTATION_VALUE"/>
                <xsl:text>&#x9;</xsl:text>    
                    <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='normalized word']/ANNOTATION/ALIGNABLE_ANNOTATION">
                        <xsl:variable name="wordStartTime" select="@TIME_SLOT_REF1"/>
                        <xsl:variable name="wordEndTime" select="@TIME_SLOT_REF2"/>
                        <xsl:variable name="word_startTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$wordStartTime]/@TIME_VALUE"/>
                        <xsl:variable name="word_endTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$wordEndTime]/@TIME_VALUE"/>
                        <xsl:if test="($word_startTime_VALUE = $startTime_VALUE) and ($word_endTime_VALUE = $endTime_VALUE)">
                                <xsl:value-of select="ANNOTATION_VALUE"/>    
                        </xsl:if>
                    </xsl:for-each>
                <xsl:text>
</xsl:text>
            </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>