<?xml version="1.0" encoding="UTF-8"?>
<!-- working with EOPAS 2.0 Schema -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="mediafile" select="/ANNOTATION_DOCUMENT/HEADER/MEDIA_DESCRIPTOR/@EXTRACTED_FROM"/>
    <xsl:param name="type" select="/ANNOTATION_DOCUMENT/HEADER/MEDIA_DESCRIPTOR/@MIME_TYPE"/>
    <xsl:param name="creator" select="/ANNOTATION_DOCUMENT/@AUTHOR"/>
    <xsl:param name="language_code" select="/ANNOTATION_DOCUMENT/LOCALE/@LANGUAGE_CODE"/>
    <xsl:param name="country_code" select="/ANNOTATION_DOCUMENT/LOCALE/@COUNTRY_CODE"/>
    <xsl:param name="lang_code" select="concat($language_code, '-', $country_code)"/>
    <xsl:param name="date" select="/ANNOTATION_DOCUMENT/@DATE"/>
    <xsl:template match="/">
        <xsl:if test="not(/ANNOTATION_DOCUMENT)">
            <xsl:message terminate="yes">ERROR: Not an ELAN document</xsl:message>
        </xsl:if>
        <xsl:if test="not(/ANNOTATION_DOCUMENT/HEADER/@TIME_UNITS='milliseconds')">
            <xsl:message terminate="yes">ERROR: I only understand milliseconds as TIME_UNITS</xsl:message>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="/ANNOTATION_DOCUMENT">
        <eaf>
            <header>
                <meta>
                    <!-- MIME Type -->
                    <xsl:attribute name="name">dc:type</xsl:attribute>
                    <xsl:attribute name="value">text/xml</xsl:attribute>
                </meta>
                <meta>
                    <!-- media resource URI -->
                    <xsl:attribute name="name">dc:source</xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$mediafile"/>
                    </xsl:attribute>
                </meta>
                <meta>
                    <!-- Dublin Core "creator" -->
                    <xsl:attribute name="name">dc:creator</xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$creator"/>
                    </xsl:attribute>
                </meta>
                <meta>
                    <!-- language code -->
                    <xsl:attribute name="name">dc:language</xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$lang_code"/>
                    </xsl:attribute>
                </meta>
                <meta>
                    <!-- Date -->
                    <xsl:attribute name="name">dc:date</xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$date"/>
                    </xsl:attribute>
                </meta>
            </header>
                    <!-- FIRST CASE: utterance and word tiers -->
                    <!-- write a transcription if there are utterances -->
                        <!-- Get Phrases from utterances and sort them on their number -->
                        <xsl:for-each select="TIER[@LINGUISTIC_TYPE_REF='ref(spoken)T']/ANNOTATION/ALIGNABLE_ANNOTATION">
                            <xsl:sort select="substring-after(@TIME_SLOT_REF1, 'ts')" data-type="number"/>
                            <!-- grab phrase timing -->
                            <xsl:variable name="startTimeId" select="@TIME_SLOT_REF1"/>
                            <xsl:variable name="endTimeId" select="@TIME_SLOT_REF2"/>
                            <xsl:variable name="startTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$startTimeId]/@TIME_VALUE"/>
                            <xsl:variable name="endTime_VALUE" select="/ANNOTATION_DOCUMENT/TIME_ORDER/TIME_SLOT[@TIME_SLOT_ID=$endTimeId]/@TIME_VALUE"/>
                            <xsl:variable name="Milliseconds_CONST" select="1000"/>
                            <xsl:variable name="startTime_Seconds" select="$startTime_VALUE div $Milliseconds_CONST"/>
                            <xsl:variable name="endTime_Seconds" select="$endTime_VALUE div $Milliseconds_CONST"/>
                            <!-- write phrase -->
                            <utterance>
                                <xsl:attribute name="ref_id">
                                    <xsl:value-of select="@ANNOTATION_ID"/>
                                </xsl:attribute>
                                <xsl:attribute name="startTime">
                                    <xsl:value-of select="$startTime_Seconds"/>
                                </xsl:attribute>
                                <xsl:attribute name="endTime">
                                    <xsl:value-of select="$endTime_Seconds"/>
                                </xsl:attribute>
                                <xsl:attribute name="ref_value">
                                    <xsl:value-of select="."/>
                                </xsl:attribute>
                                        <xsl:variable name="annotationId" select="@ANNOTATION_ID"/>
                                        <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='orthT']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $annotationId]">
                                                <orthography>
                                                    <xsl:attribute name="participant">
                                                        <xsl:value-of select="../../@PARTICIPANT"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="."/>
                                                </orthography>
                                                <xsl:variable name="wordId" select="@ANNOTATION_ID"/>
                                                <!-- grab morphemes and gloss -->
                                                <wordlist>
                                                    <xsl:for-each select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='wordT']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $wordId]">
                                                        <xsl:variable name="morphemeId" select="@ANNOTATION_ID"/>
                                                        <token>
                                                            <lemma>
                                                                <xsl:attribute name="kind">form</xsl:attribute>
                                                                <xsl:value-of select="."/>
                                                            </lemma>
                                                            <gloss>
                                                                <xsl:attribute name="kind">gloss</xsl:attribute>
                                                                <xsl:value-of select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='morphT']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $morphemeId]"/>
                                                            </gloss>
                                                            <pos>
                                                                <xsl:attribute name="kind">pos</xsl:attribute>
                                                                <xsl:value-of select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='posT']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $morphemeId]"/>
                                                            </pos>
                                                            <context>
                                                                <xsl:attribute name="kind">context</xsl:attribute>
                                                                <xsl:value-of select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='orthT']/ANNOTATION/REF_ANNOTATION[@ANNOTATION_REF = $annotationId]"/>
                                                            </context>
                                                        </token>
                                                    </xsl:for-each>
                                                </wordlist>
                                        </xsl:for-each>
                            </utterance>
                        </xsl:for-each>
        </eaf>
    </xsl:template>
</xsl:stylesheet>