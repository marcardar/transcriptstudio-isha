<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:output method="xml"/>
	<xsl:strip-space elements="*"/>
 	<xsl:param name="eventPath"/>
	<xsl:variable name="reference" select="doc('/db/archives/reference/reference.xml')/reference"/>
	<xsl:variable name="eventId" select="substring(/session/@id,1,14)"/>
	<xsl:variable name="event" select="doc($eventPath)/event"/>
	
	<xsl:template match="/">
		<w:document>
            <w:body>
                <w:tbl>
                    <w:tblPr>
                        <w:tblW w:w="0" w:type="auto"/>
						<w:tblCellSpacing w:w="20" w:type="dxa"/>
						<w:tblBorders>
                            <w:top w:val="outset" w:sz="6" w:space="0" w:color="auto"/>
							<w:left w:val="outset" w:sz="6" w:space="0" w:color="auto"/>
							<w:bottom w:val="outset" w:sz="6" w:space="0" w:color="auto"/>
							<w:right w:val="outset" w:sz="6" w:space="0" w:color="auto"/>
							<w:insideH w:val="outset" w:sz="6" w:space="0" w:color="auto"/>
							<w:insideV w:val="outset" w:sz="6" w:space="0" w:color="auto"/>
						</w:tblBorders>
						<w:tblLook w:val="01E0"/>
					</w:tblPr>
					<w:tblGrid>
                        <w:gridCol w:w="8936"/>
					</w:tblGrid>
					<w:tr w:rsidR="00BD70D3" w:rsidRPr="00914051">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="003451D2" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:pPr>
                                    <w:pStyle w:val="Heading1"/>
									<w:jc w:val="center"/>
									<w:rPr>
                                        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>
									</w:rPr>
								</w:pPr>
								<w:r w:rsidRPr="003451D2">
									<w:rPr>
                                        <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman"/>
									</w:rPr>
									<w:t>Isha Foundation Transcription</w:t>
								</w:r>
							</w:p>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="00914051" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63"/>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3" w:rsidRPr="00914051">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:r>
                                    <w:t>MEDIA SOURCE: Audio File</w:t>
								</w:r>
							</w:p>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="00914051" w:rsidRDefault="00BD70D3" w:rsidP="00021F27">
								<w:r>
                                    <w:t>MEDIA CODE: <xsl:value-of select="upper-case(string-join(//source/@id, ', '))"/>
									</w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3" w:rsidRPr="00914051">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="004646A4" w:rsidRDefault="00BD70D3" w:rsidP="00ED43A8">
								<w:pPr>
                                    <w:tabs>
                                        <w:tab w:val="left" w:pos="1553"/>
									</w:tabs>
									<w:rPr>
                                        <w:sz w:val="28"/>
										<w:szCs w:val="28"/>
									</w:rPr>
								</w:pPr>
								<w:r>
                                    <w:t>EVENT: <xsl:value-of select="$eventPath"/>
                                        <xsl:value-of select="$reference/eventTypes/eventType[@id=$event/@type]/@name"/>
                                    </w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3" w:rsidRPr="00914051">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="00914051" w:rsidRDefault="00BD70D3" w:rsidP="00021F27">
								<w:r>
                                    <w:t>LOCATION: <xsl:value-of select="string-join(($event/@venue, $event/@location, $event/@country), ', ')"/>  
                                    </w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3" w:rsidRPr="00914051">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="00914051" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:r>
                                    <w:t>AUDIO CLARITY (E G F P): G</w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3" w:rsidRPr="00914051">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRPr="00914051" w:rsidRDefault="00BD70D3" w:rsidP="00021F27">
								<w:r>
                                    <w:t>DATE: <xsl:value-of select="$event/@startAt"/>
                                    </w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3">
						<w:trPr>
                            <w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:r>
                                    <w:t>LANGUAGE: English</w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
					<w:tr w:rsidR="00BD70D3">
						<w:trPr>
                            <w:trHeight w:val="865"/>
							<w:tblCellSpacing w:w="20" w:type="dxa"/>
						</w:trPr>
						<w:tc>
                            <w:tcPr>
                                <w:tcW w:w="8856" w:type="dxa"/>
							</w:tcPr>
							<w:p w:rsidR="00BD70D3" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:r>
                                    <w:t>TRANSCRIBED BY: Baha (23-Jul-08)</w:t>
								</w:r>
							</w:p>
							<w:p w:rsidR="00BD70D3" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:r>
                                    <w:t>PROOFED BY: Amit (29-Jul-08), Chitra (30-Jul-08)</w:t>
								</w:r>
							</w:p>
							<w:p w:rsidR="00BD70D3" w:rsidRDefault="00BD70D3" w:rsidP="00CB5E63">
								<w:r>
                                    <w:t xml:space="preserve">NOTES: <xsl:value-of select="/session/@comment"/>
									</w:t>
								</w:r>
							</w:p>
						</w:tc>
					</w:tr>
				</w:tbl>
				
				<w:p/>
				
				<w:p>
                    <w:r>
                        <w:t>INDEX</w:t>
					</w:r>
				</w:p>
				<w:p/>
<!--
<xsl:for-each select="//superSegment">
  <xsl:value-of select="./tag[@type='markupType']/@value"/>
  <xsl:variable name="markupCategory" select="./tag[@type='markupCategory']/@value"/> 
  <xsl:value-of select="$reference/categories/categoryId[@id=$markupCategory]/@name"/>
</xsl:for-each>
-->
				<xsl:for-each select="//superSegment | //superContent">
					<xsl:variable name="markupType" select="tag[@type='markupType']/@value"/>
					<xsl:variable name="markupId" select="@id"/>
					<w:p>
                        <w:hyperlink w:history="1">
							<xsl:attribute name="w:anchor">
								<xsl:value-of select="$markupId"/>
							</xsl:attribute>
							<w:r>
                                <w:rPr>
                                    <w:rStyle w:val="Hyperlink"/>
								</w:rPr>
								<w:t>
                                    <xsl:value-of select="concat(upper-case(substring($markupType,1,1)), substring($markupType,2))"/>
									<xsl:text>: </xsl:text>
								</w:t>
							</w:r>
						</w:hyperlink>
					</w:p>
				</xsl:for-each>
				
				<w:p/>
				
				<xsl:for-each select="//segment[@type='paragraph']">
					<xsl:variable name="syncPoint" select="content[1]/@startSyncPointId"/>
					<xsl:if test="$syncPoint and not(preceding::segment[position() &lt; 3]/content[1]/@startSyncPointId)">
						<xsl:variable name="time" select="/session/source/syncPoint[@idRef = $syncPoint]/@timecode"/>
						<w:p>
                            <w:r>
                                <w:t>Time <xsl:number format="1" value="floor($time div 60)"/>
									<xsl:text>:</xsl:text>
									<xsl:number format="01" value="$time mod 60"/>
								</w:t>
							</w:r>
						</w:p>
						<w:p/>
					</xsl:if>
					<w:p>
                        <xsl:if test="(position() = 1) or (preceding::segment[1]/@speaker and not(@speaker)) or (not(preceding::segment[1]/@speaker) and @speaker) or (preceding::segment[1]/@speaker != @speaker)">
							<w:r>
                                <w:rPr>
                                    <w:b/>
								</w:rPr>
								<w:t>
                                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
									<xsl:choose>
                                        <xsl:when test="@speaker">
											<xsl:value-of select="normalize-space(concat(upper-case(substring(@speaker,1,1)), substring(@speaker,2)))"/>
											<xsl:text>: </xsl:text>
										</xsl:when>
										<xsl:otherwise>
                                            <xsl:text>Sadhguru: </xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</w:t>
							</w:r>
						</xsl:if>
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
                                    <xsl:attribute name="xml:space">preserve</xsl:attribute>
									<xsl:value-of select="normalize-space(.)"/>
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
	<!--xsl:apply-templates/-->
	</xsl:template>
	
	<xsl:template match="//superSegment">
		<w:moog/>
	</xsl:template>

</xsl:stylesheet>