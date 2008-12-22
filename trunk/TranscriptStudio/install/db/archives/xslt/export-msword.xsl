<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml"/>


<xsl:variable name="reference" select="document('reference.xml')/reference"/>


  <xsl:template match="/">
    <w:document>
            <w:body>

<!--
INDEX
<xsl:for-each select="//superSegment">
  <xsl:value-of select="./tag[@type='markupType']/@value"/>
  <xsl:variable name="markupCategory" select="./tag[@type='markupCategory']/@value"/> 
  <xsl:value-of select="$reference/categories/categoryId[@id=$markupCategory]/@name"/>
</xsl:for-each>
-->



    <xsl:for-each select="//segment[@type='paragraph']">
      <w:p>
                        <xsl:for-each select=".//content">
          <w:r>
                                <xsl:if test="@emphasis | @spokenLanguage">
              <w:rPr>
                                        <xsl:if test="@emphasis='true'">
                  <w:i/>
                </xsl:if>
                <xsl:if test="@spokenLanguage='tamil'">
                  <w:color w:val="00B0F0"/>
                </xsl:if>
              </w:rPr>
            </xsl:if>
            <w:t>
                                    <xsl:value-of select="."/>
              <xsl:if test="position() &lt; last()">
                <xsl:text> </xsl:text>  
              </xsl:if> 
            </w:t>
          </w:r>
        </xsl:for-each> 
      </w:p>
      <w:p/>
    </xsl:for-each>


      </w:body>
    </w:document>
  </xsl:template>

</xsl:stylesheet>