<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dav="DAV:" xmlns:oc="http://owncloud.org/ns">
  <xsl:output method="html" indent="yes" doctype-system="about:legacy-compat"/>

  <xsl:variable name="currDirWslash" select="string(substring-after(dav:multistatus/dav:response[1]/dav:href, '/public.php/webdav/data/'))"/>
  <xsl:variable name="baseDir" select="string(concat('/public.php/webdav/data/', $currDirWslash))"/>
  <xsl:variable name="currDir" select="substring-before($currDirWslash, '/')"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <xsl:apply-templates select="dav:multistatus/dav:response[1]" mode="head" />
        <link href="style.css" rel="stylesheet" />
      </head>
      <body>
        <xsl:apply-templates select="dav:multistatus/dav:response[1]" />
        <p>This is the data dump of opensensemap.org. Please make yourself familiar with the <a href="README">README</a> and the <a href="LICENSE">LICENSE</a>.</p>
        <table border="0" cellspacing="0" cellpadding="0">
          <tbody>
            <tr>
              <th>Name</th>
              <th>Last modified</th>
              <th>Size</th>
              <th>Zip</th>
            </tr>
            <tr><th colspan="4"><hr /></th></tr>
            <xsl:apply-templates select="dav:multistatus/dav:response[position() > 1]" >
              <xsl:sort select="dav:href" data-type="text" order="descending" />
            </xsl:apply-templates>
          </tbody>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="dav:multistatus/dav:response[descendant::dav:collection]">
    <tr>
      <td>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="substring-after(dav:href, $baseDir)"/>
          </xsl:attribute>
          <xsl:value-of select="substring-after(dav:href, $baseDir)"/>
        </xsl:element>
      </td>
      <xsl:element name="td">
        <xsl:value-of select="dav:propstat/dav:prop/dav:getlastmodified"/>
      </xsl:element>
      <xsl:element name="td">
        <xsl:value-of select="dav:propstat/dav:prop/oc:size"/>
      </xsl:element>
      <td>
        <xsl:element name="a">
          <xsl:attribute name="href">
            <xsl:value-of select="concat(concat('https://uni-muenster.sciebo.de/index.php/s/HyTbguBP4EkqBcp/download?path=/data/', $currDirWslash), substring-after(dav:href, $baseDir))"/>
          </xsl:attribute>
          <xsl:value-of select="concat(substring-before(concat(substring-after(dav:href, $baseDir), $currDir), '/'), '.zip')"/>
        </xsl:element>
      </td>
    </tr>
  </xsl:template>

  <xsl:template match="dav:multistatus/dav:response[1]">
    <xsl:element name="h1">
      <xsl:value-of select="concat('Index of archive.opensensemap.org/', $currDirWslash)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="dav:multistatus/dav:response[1]" mode="head">
    <xsl:element name="title">
      <xsl:value-of select="concat('Index of archive.opensensemap.org/', $currDirWslash)"/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
