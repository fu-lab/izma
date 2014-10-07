<?xml version="1.0" encoding="UTF-8"?>
<!-- working with EOPAS 2.0 Schema -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <!-- first key to look up slot elements by their id -->
    <xsl:key name="wordById" match="TIER/ANNOTATION/REF_ANNOTATION" use="@ANNOTATION_ID" />
    <!-- second key to look up normalized word annotations by the value of their slots -->
    <xsl:key name="glossById" match="TIER[@LINGUISTIC_TYPE_REF='normalized word']/ANNOTATION"
        use="concat(key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF1)/@TIME_VALUE, '|',
        key('wordById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF2)/@TIME_VALUE)" />
<xsl:template match="/ANNOTATION_DOCUMENT">
        <xsl:text>\documentclass[12pt]{article}
\usepackage{expex}
\usepackage{xltxtra,fontspec,xunicode,graphicx,graphics,geometry,setspace,multicol,multirow}
\usepackage{float} % formatting
\usepackage[english]{babel}
\usepackage{background}
\sloppy
\setromanfont{Charis SIL}
\begin{document}
%--------------------------------------------------------------------

\bigskip

\filbreak\hrule\medskip

\begingroup
\ex[glftpos=right,glhangstyle=none]
\let\\=\textsc
\begingl</xsl:text>
    </xsl:template>
        <xsl:template match="ANNOTATION">
            <xsl:value-of select="ALIGNABLE_ANNOTATION/ANNOTATION_VALUE" />
            <xsl:value-of select="
                key('annotationBySlots',
                concat(key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF1)/@TIME_VALUE, '|',
                key('slotById', ALIGNABLE_ANNOTATION/@TIME_SLOT_REF2)/@TIME_VALUE)
                )/ALIGNABLE_ANNOTATION/ANNOTATION_VALUE" />
            <xsl:text>&#xA;</xsl:text>
        </xsl:template>
</xsl:stylesheet>