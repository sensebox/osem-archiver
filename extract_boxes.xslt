<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dav="DAV:" xmlns:oc="http://owncloud.org/ns">
  <xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

  <xsl:variable name="currDirWslash" select="string(substring-after(dav:multistatus/dav:response[1]/dav:href, '/public.php/webdav/data/'))"/>
  <xsl:variable name="baseDir" select="string(concat('/public.php/webdav/data/', $currDirWslash))"/>
  <xsl:variable name="currDir" select="substring-before($currDirWslash, '/')"/>

  <xsl:template match="dav:multistatus/dav:response[position() > 1]">
    <xsl:value-of select="substring-after(dav:href, $baseDir)" />
  </xsl:template>
  <xsl:template match="text()"><xsl:value-of select="normalize-space(.)"/></xsl:template>

  <xsl:template match="dav:multistatus/dav:response[1]" />
</xsl:stylesheet>
