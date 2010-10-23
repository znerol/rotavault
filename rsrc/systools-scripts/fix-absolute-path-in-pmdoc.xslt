<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
    Author: Lorenz Schori <lo@znerol.ch>
    License: Public Domain
    
    This xslt stylesheet attempts to fix the path to the root directory in PackageMaker's pmdoc files in order to allow
    automated packaging with determined permission settings.
-->

<xsl:param name="PKG_ROOT"/>

<!-- inject absolute path to root directory in contents files (NNrootdir-contents.xml) -->
<xsl:template match="/pkg-contents/f/@pt">
    <xsl:attribute name="pt"><xsl:value-of select="$PKG_ROOT"/></xsl:attribute>
</xsl:template>

<!-- inject absolute path to root directory in package files (NNrootdir.xml) -->
<xsl:template match="/pkgref/config/installFrom">
    <installFrom><xsl:value-of select="$PKG_ROOT"/></installFrom>
</xsl:template>

<!-- copy over everything else -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>
</xsl:stylesheet>
