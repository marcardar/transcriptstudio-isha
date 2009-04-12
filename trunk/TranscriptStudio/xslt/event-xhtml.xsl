<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xhtml"/>
	<xsl:strip-space elements="*"/>
	<xsl:variable name="event" select="/event"/>
	<xsl:variable name="reference" select="doc('/db/ts4isha/reference/reference.xml')/reference"/>
	
	<xsl:template match="/event">
		<div>
            <table style="font-size:20;">
				<tr>
                    <td width="100" align="right">Type:</td>
                    <td>
                        <xsl:value-of select="@type"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Title:</td>
                    <td>
                        <xsl:value-of select="$reference/eventTypes/eventType[@id=$event/@type]/@name"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Sub Title:</td>
                    <td>
                        <xsl:value-of select="(metadata/@subTitle, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Start:</td>
                    <td>
                        <xsl:value-of select="(metadata/@startAt, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">End:</td>
                    <td>
                        <xsl:value-of select="(metadata/@endAt, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Country:</td>
                    <td>
                        <xsl:value-of select="(metadata/@country, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Location:</td>
                    <td>
                        <xsl:value-of select="(metadata/@location, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Venue:</td>
                    <td>
                        <xsl:value-of select="(metadata/@venue, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Language:</td>
                    <td>
                        <xsl:value-of select="(metadata/@language, '&lt;default&gt;')[1]"/>
                    </td>
                </tr>
				<tr>
                    <td align="right">Notes:</td>
                    <td>
                        <xsl:value-of select="(metadata/@notes, '&lt;not set&gt;')[1]"/>
                    </td>
                </tr>
			</table>
		</div>
		<!--div style="font-size:20;margin-bottom:100px;width:750px;margin-left:auto;margin-right:auto;text-align:left;">
			<h2 style="text-align:center;font-size:22;">
				<xsl:value-of select="string-join(//media/@id, ', ')"/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="/session/@subTitle"/>
				<xsl:value-of select="concat(' (',/session/@startAt,')')"/>
			</h2>
			<br/>
			<xsl:apply-templates select="//transcript"/>
		</div-->
	</xsl:template>
</xsl:stylesheet>