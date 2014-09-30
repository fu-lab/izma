<?xml version="1.0" encoding="UTF-8"?>
<!-- working with EOPAS 2.0 Schema -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0">
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="nl" select="'&#xa;'"></xsl:variable>
    
    <xsl:template match="/eaf">
        <xsl:text>
\documentclass[12pt]{article}
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
\begingl

</xsl:text>
        <xsl:for-each select="/eaf/utterance/wordlist">
            <xsl:value-of select="concat('\gla ',/token/lemma/text(),$nl,'\glb ',/token/gloss,$nl,'\glft ',/token/context,'',$nl,$nl)"/>
        </xsl:for-each>
<xsl:text>\end{document}</xsl:text>
    
</xsl:template>
</xsl:stylesheet>