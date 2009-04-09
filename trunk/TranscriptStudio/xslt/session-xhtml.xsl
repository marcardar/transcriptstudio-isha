<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xhtml"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<div style="font-size:20;margin-bottom:100px;width:750px;margin-left:auto;margin-right:auto;text-align:left;">
			<h2 style="text-align:center;font-size:22;">
				<xsl:value-of select="/session/@subTitle"/>
				<xsl:if test="exists(/session/@startAt)">
					<xsl:value-of select="concat(' (',/session/@startAt,')')"/>
				</xsl:if>
				<xsl:if test="exists(//device/audio/@id)">
					<p>Audio IDs: <xsl:value-of select="string-join(//device/audio/@id, ', ')"/>
                    </p>
				</xsl:if>
				<xsl:if test="exists(//device/video/@id)">
					<p>Video IDs: <xsl:value-of select="string-join(//device/video/@id, ', ')"/>
                    </p>
				</xsl:if>
			</h2>
			<xsl:apply-templates select="//transcript"/>
		</div>
	</xsl:template>

	<xsl:template match="transcript">
		<xsl:apply-templates select="segment|superSegment"/>
	</xsl:template>
			
	<xsl:template match="superSegment">
		<div class="superSegement" id="{@id}">
			<xsl:apply-templates select="segment|superSegment"/>
		</div>
	</xsl:template>
	
	<xsl:template match="segment">
		<div class="segment" id="{@id}">				 
			<xsl:if test="(preceding::segment[1]/@speaker and not(@speaker)) or (not(preceding::segment[1]/@speaker) and @speaker) or (preceding::segment[1]/@speaker != @speaker)">
				<span style="font-weight:bold; text-transform:capitalize;">
				<xsl:choose>
                        <xsl:when test="@speaker">
					<xsl:value-of select="@speaker"/>
					<xsl:text>:</xsl:text>
				</xsl:when>
				</xsl:choose>				
				</span>
			</xsl:if>	
			<xsl:apply-templates select="content|superContent"/>
		</div>
		<p/>
	</xsl:template>
	
	<xsl:template match="superContent">
		<span class="superContent" id="{@id}">
			<xsl:apply-templates select="content|superContent"/>
		</span>
	</xsl:template>
	
	<xsl:template match="content">
		<span class="content" id="{@id}">
			<xsl:choose>
                <xsl:when test="@emphasis='true' and @spokenLanguage='tamil'">
					<xsl:attribute name="style">font-style:italic;color:blue;</xsl:attribute>
				</xsl:when>
				<xsl:when test="@emphasis='true'">
					<xsl:attribute name="style">font-style:italic;</xsl:attribute> 
				</xsl:when>
				<xsl:when test="@spokenLanguage='tamil'">
					<xsl:attribute name="style">color:blue;</xsl:attribute> 
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="normalize-space(.)"/>
		</span>
		<!--xsl:if test="position() != last()">
			<xsl:text> </xsl:text> 
		</xsl:if-->		
	</xsl:template>
</xsl:stylesheet>