<?xml version="1.0" encoding="UTF-8"?>
<!--
   The Contents of this file are made available subject to the terms of
   of the following license

          - GNU Lesser General Public License Version 2.1

   System Concept GmbH, April, 2005

   GNU Lesser General Public License Version 2.1
   =============================================
   Copyright 2005 by System Concept GmbH
   Freiheitstrasse 124-126, 15745 Wildau, Germany

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License version 2.1, as published by the Free Software Foundation.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston,
   MA  02111-1307  USA

   Copyright (c) 2005 by System Concept GmbH

   All Rights Reserved.

   Contributor(s): Holger Hees hhees ( at ) systemconcept.de
   
 -->
<xsl:stylesheet version="1.0"
		xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"  
		xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"  
    	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
		xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
		xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"

		xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
		xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"

		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

		xmlns:fop="http://www.w3.org/1999/XSL/Format"

		xmlns:xt="http://www.jclark.com/xt"
		xmlns:common="http://exslt.org/common"
		xmlns:xalan="http://xml.apache.org/xalan"

		exclude-result-prefixes="office style table draw xlink fo xsl xalan common xt svg">

    <!-- Es wird zunächst XSL-FO erzeugt, dass dann zu PDF weiterverarbeitet wird -->	
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<xsl:variable name="officeDoc" select="/office:document"/>

	<xsl:param name="styleName"/>
	<xsl:param name="styleNode"/>

	<!-- Basis Template, dass für das Seitenlayout zuständig ist -->
    <xsl:template match="/office:document">
		<fop:root xmlns:fop="http://www.w3.org/1999/XSL/Format" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0">
    		<xsl:variable name="pageMaster" select="$officeDoc/office:automatic-styles/style:page-layout[1]"/>
	     	<xsl:variable name="styleMaster" select="$officeDoc/office:master-styles/style:master-page[1]"/>

    		<fop:layout-master-set>	<!-- XSL-FO funtioniert wie ein DTP-Programm, zuerst werden die Page Master definiert, anschließend kommen die Inhalte -->
				<fop:simple-page-master master-name="{$pageMaster/@style:name}"
										margin-top="{$pageMaster/style:page-layout-properties/@fo:margin-top}"  
										margin-bottom="{$pageMaster/style:page-layout-properties/@fo:margin-bottom}"
										margin-left="{$pageMaster/style:page-layout-properties/@fo:margin-left}"  
										margin-right="{$pageMaster/style:page-layout-properties/@fo:margin-right}"
										page-width="{$pageMaster/style:page-layout-properties/@fo:page-width}" 
										page-height="{$pageMaster/style:page-layout-properties/@fo:page-height}"
										border="{$pageMaster/style:page-layout-properties/@fo:border}">
	
				<fop:region-body>
					<xsl:if test="$pageMaster/style:header-style/child::*">
						<xsl:attribute name="margin-top">
							<xsl:value-of select="$pageMaster/style:header-style/style:header-footer-properties/@fo:margin-bottom"/>
							<xsl:if test="$pageMaster/style:header-style/style:header-footer-properties/@style:dynamic-spacing='false'">*2</xsl:if>
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="$pageMaster/style:footer-style/child::*">
						<xsl:attribute name="margin-bottom">
							<xsl:value-of select="$pageMaster/style:footer-style/style:header-footer-properties/@fo:margin-top"/>
							<xsl:if test="$pageMaster/style:footer-style/style:header-footer-properties/@style:dynamic-spacing='false'">*2</xsl:if>
						</xsl:attribute>
					</xsl:if>
				</fop:region-body>

				<xsl:if test="$pageMaster/style:header-style/child::*">
					<fop:region-before display-align="before">
						<xsl:call-template name="applyStyle">
							<xsl:with-param name="styleNode" select="$pageMaster/style:header-style"/>
							<xsl:with-param name="styleType" select="'header:footer'"/>
						</xsl:call-template>
					</fop:region-before>
				</xsl:if>

				<xsl:if test="$pageMaster/style:footer-style/child::*">
					<fop:region-after display-align="after">
						<xsl:call-template name="applyStyle">
							<xsl:with-param name="styleNode" select="$pageMaster/style:footer-style"/>
							<xsl:with-param name="styleType" select="'header:footer'"/>
						</xsl:call-template>
					</fop:region-after>
				</xsl:if>

				</fop:simple-page-master>
      		</fop:layout-master-set>

		     <fop:page-sequence master-reference="{$pageMaster/@style:name}">	<!-- Den Page Master mit Inhalten fülle -->
				<!-- Die Kopfzeile einfügen. Static content erscheint auf jeder Seite -->
		     	<xsl:if test="$styleMaster/style:header">
	     		<fop:static-content flow-name="xsl-region-before">
     				<xsl:apply-templates select="$styleMaster/style:header/child::*"/>
				</fop:static-content>
	     		</xsl:if>

				<!-- Die Fußzeile einfügen. Static content erscheint auf jeder Seite -->
		     	<xsl:if test="$styleMaster/style:footer">
	     		<fop:static-content flow-name="xsl-region-after">
    				<xsl:apply-templates select="$styleMaster/style:footer/child::*"/>
				</fop:static-content>
	     		</xsl:if>

				<fop:static-content flow-name="xsl-footnote-separator">
					<fop:block>
						<fop:leader leader-pattern="rule" leader-length="100%" rule-style="solid" rule-thickness="0.5pt"/>
					</fop:block>
				</fop:static-content>

				<!-- Die übrigen Inhalte einfügen -->
				<fop:flow flow-name="xsl-region-body">
					<fop:block><xsl:for-each select="office:body/child::*">
						<xsl:apply-templates select="."/>
					</xsl:for-each>
					</fop:block>
					<fop:block id="last-page"/>
				</fop:flow>
			</fop:page-sequence>

	    </fop:root>
	</xsl:template>

	<!-- Tabulatoren -->
	<xsl:template name="text:tab">
		<xsl:param name="styleName"/>
		<xsl:param name="aktNode"/>
		<xsl:param name="styleNodes"/>
		<xsl:param name="styleType"/>
		<xsl:param name="stylePosition"/>

		<xsl:variable name="tabStyle">
			<text:tab>
			<xsl:call-template name="applyStyle">
				<xsl:with-param name="styleName" select="ancestor-or-self::*[@text:style-name]/@text:style-name"/>
				<xsl:with-param name="styleType" select="'text:tab'"/>
				<xsl:with-param name="stylePosition" select="count(preceding-sibling::text:tab)"/>
			</xsl:call-template>
			</text:tab>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="function-available('xalan:nodeset')">
				<xsl:call-template name="getTabStyleValues">
					<xsl:with-param name="styleNode" select="xalan:nodeset($tabStyle)" />
					<xsl:with-param name="aktNode" select="." />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="function-available('xt:node-set')">
				<xsl:call-template name="getTabStyleValues">
					<xsl:with-param name="styleNode" select="xt:node-set($tabStyle)" />
					<xsl:with-param name="aktNode" select="." />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="function-available('common:node-set')">
				<xsl:call-template name="getTabStyleValues">
					<xsl:with-param name="styleNode" select="common:node-set($tabStyle)" />
					<xsl:with-param name="aktNode" select="." />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes">ERROR: Function not found: nodeset</xsl:message>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template name="getTabStyleValues">
		<xsl:param name="styleNode"/>
		<xsl:param name="aktNode"/>
		
		<xsl:for-each select="$styleNode/child::*">
			<xsl:choose>		
				<xsl:when test="./@type and normalize-space($aktNode/preceding-sibling::text())=''">
					<xsl:attribute name="text-align"><xsl:value-of select="./@type"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="./@type and ./@leader-style">
					<fop:leader>
						<xsl:choose>
							<xsl:when test="./@leader-style='dotted'">
								<xsl:attribute name="leader-pattern">dots</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="leader-pattern">space</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>				
					</fop:leader>
				</xsl:when>
				<xsl:otherwise>
					<fop:leader leader-pattern="space">
						<xsl:attribute name="leader-length"><xsl:value-of select="./@tab-stop-distance"/></xsl:attribute>
					</fop:leader>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Bilder -->
	<xsl:template match="draw:image">
		<fop:block>
			<fop:external-graphic src="url({translate(./@xlink:href, '#', '')})"/>
		</fop:block>
	</xsl:template>

	<!-- Textbox -->
	<xsl:template match="draw:text-box">
		<fop:block>
			<xsl:if test="./@fo:min-height">
				<xsl:attribute name="min-height"><xsl:value-of select="./@fo:min-height"/></xsl:attribute>
			</xsl:if>
	
			<xsl:call-template name="applyStyle"><xsl:with-param name="styleName" select="./@text:style-name"/></xsl:call-template>
			<xsl:for-each select="./child::*">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</fop:block>
	</xsl:template>

	<!-- Floatelement -->
	<xsl:template match="draw:frame">
		<!--<fop:float>-->
		<fop:block-container>
			<xsl:choose>
				<xsl:when test="./@text:anchor-type='char'">
					<xsl:attribute name="position">absolute</xsl:attribute>
					<xsl:if test="./@svg:x or ./@svg:y">
						<xsl:attribute name="margin-left"><xsl:value-of select="number(substring-before(./@svg:x,'cm'))-2"/>cm</xsl:attribute>
						<xsl:attribute name="margin-right">0cm</xsl:attribute>
						<!--<xsl:attribute name="margin-top"><xsl:value-of select="./@svg:y"/></xsl:attribute>-->
					</xsl:if>
					<xsl:attribute name="width"><xsl:value-of select="./@svg:width"/></xsl:attribute>
				</xsl:when>
			</xsl:choose>				

			<xsl:call-template name="applyStyle"><xsl:with-param name="styleName" select="./@draw:style-name"/></xsl:call-template>

			<fop:block>
				<xsl:choose>
					<xsl:when test="./@text:anchor-type='char'">
						<xsl:attribute name="margin-left">-<xsl:value-of select="number(substring-before(./@svg:x,'cm'))-2"/>cm</xsl:attribute>
					</xsl:when>
				</xsl:choose>				

				<xsl:for-each select="./child::*">
					<xsl:apply-templates select="."/>
				</xsl:for-each>
			</fop:block>
		</fop:block-container>
 		<!--</fop:float>-->
	</xsl:template>

	<!-- Text ausgeben und eventuelle Unterelemente weiterverfolgen -->
	<xsl:template name="processText">
		<xsl:choose>		
			<xsl:when test="node()">
				<xsl:for-each select="node()">
					<xsl:choose>
						<xsl:when test="name(.)='text:tab'">
							<xsl:call-template name="text:tab"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- without leeding whitespace -->
							<xsl:if test="string-length(.)>1 or normalize-space(string(.))!='' or normalize-space(preceding-sibling::text())!='' or name(.)!=''">
								<xsl:apply-templates select="."/>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise><fop:leader/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>







	<!-- TABLE -->
	<xsl:template name="calcTableColumn">
		<xsl:param name="columnStyle"/>
		<xsl:param name="columnRepeated"/>
		<fop:table-column column-width="{$columnStyle/style:table-column-properties/@style:column-width}"/>
		<xsl:if test="$columnRepeated>1">
			<xsl:call-template name="calcTableColumn">
				<xsl:with-param name="columnStyle" select="$columnStyle"/>
				<xsl:with-param name="columnRepeated" select="$columnRepeated - 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Tabellen -->
	<xsl:template match="table:table">
		<fop:table>
			<!--<xsl:variable name="tableStyleName" select="@table:style-name"/>
			<xsl:variable name="tableStyle" select="$officeDoc/office:automatic-styles/style:style[@style:name=$tableStyleName]"/>-->
			<!--<xsl:variable name="columnStyle" select="$officeDoc/office:automatic-styles/style:style[@style:name=$columnStyleName]"/>-->
			
			<xsl:call-template name="applyStyle">
				<xsl:with-param name="styleName" select="ancestor-or-self::table:table[@table:style-name][1]/@table:style-name"/>
			</xsl:call-template>

			<!-- Spaltenbreiten feststellen -->
			<xsl:for-each select="table:table-column">
				<xsl:variable name="columnStyleName" select="@table:style-name"/>
				<xsl:call-template name="calcTableColumn">
					<xsl:with-param name="columnStyle" select="$officeDoc/office:automatic-styles/style:style[@style:name=$columnStyleName]"/>
					<xsl:with-param name="columnRepeated" select="@table:number-columns-repeated"/>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:choose>
				<xsl:when test="table:table-header-rows and table:table-row">
					<fop:table-header>	<!-- Der Header ist in OO explizit ausgewiesen -->
						<xsl:call-template name="tableRow">
							<xsl:with-param name="row" select="table:table-header-rows/table:table-row"/>
						</xsl:call-template>
					</fop:table-header>
					<fop:table-body>
						<xsl:call-template name="tableRow">
							<xsl:with-param name="row" select="table:table-row"/>
						</xsl:call-template>
					</fop:table-body>
				</xsl:when>
				<xsl:when test="table:table-row">
					<fop:table-body>
						<xsl:call-template name="tableRow">
							<xsl:with-param name="row" select="table:table-row"/>
						</xsl:call-template>
					</fop:table-body>
				</xsl:when>
				<xsl:otherwise>
					<fop:table-body>	<!-- Der Header ist in OO explizit ausgewiesen -->
						<xsl:call-template name="tableRow">
							<xsl:with-param name="row" select="table:table-header-rows/table:table-row"/>
						</xsl:call-template>
					</fop:table-body>
				</xsl:otherwise>
			</xsl:choose>

		</fop:table>
	</xsl:template>

	<xsl:template name="tableRow">
		<xsl:param name="row"/>

		<xsl:for-each select="$row">	<!-- Die restlichen Zeilen, der Einfachheit halber mit festen Font und Abstandsgrößen -->
			<fop:table-row keep-together.within-column="always">
				<!--<xsl:if test="./@table:number-rows-spanned">
					<xsl:attribute name="number-rows-spanned"><xsl:value-of select="./@table:number-rows-spanned"/></xsl:attribute>
				</xsl:if>-->

				<xsl:call-template name="applyStyle">
					<xsl:with-param name="styleName" select="ancestor-or-self::table:table-row[1][@table:style-name]/@table:style-name"/>
				</xsl:call-template>
				<xsl:for-each select="./table:table-cell">
					<fop:table-cell>

						<!--<xsl:if test="./@table:number-columns-spanned">
							<xsl:attribute name="number-columns-spanned"><xsl:value-of select="./@table:number-columns-spanned"/></xsl:attribute>
						</xsl:if>-->

						<xsl:call-template name="applyStyle">
							<xsl:with-param name="styleName" select="ancestor-or-self::table:table-cell[1][@table:style-name]/@table:style-name"/>
						</xsl:call-template>
						<xsl:for-each select="node()"><xsl:apply-templates select="."/></xsl:for-each>
					</fop:table-cell>
				</xsl:for-each>
			</fop:table-row>
		</xsl:for-each>
	</xsl:template>



	<!-- TEXT -->
	<!-- dynamische Platzhalter -->
	<xsl:template match="text:placeholder">
		<text:placeholder><xsl:copy-of select="./text()"/></text:placeholder>
	</xsl:template>

	<!-- Seitennummer -->
	<xsl:template match="text:page-number">
		<fop:page-number/>
	</xsl:template>

	<!-- Seitennummer -->
	<xsl:template match="text:page-count">
		<!--<xsl:value-of select="."/>-->
		<fop:page-number-citation ref-id="last-page"/>
	</xsl:template>

	<!-- Zeilenumbruch -->
	<xsl:template match="text:line-break">
		<fop:block/>
	</xsl:template>

	<!-- Fussnoten -->
	<!--<text:note text:id="ftn2" text:note-class="footnote">
	<text:note-citation>2</text:note-citation>
	<text:note-body>
	<text:p text:style-name="P48">
	<text:a xlink:type="simple" xlink:href="http://www.microsoft.com/myservices/services/userexperiences.asp">URL: http://www.microsoft.com/myservices/services/userexperiences.asp</text:a>
	</text:p>
	</text:note-body>
	</text:note>-->
	<xsl:template match="text:note">
		<fop:footnote>
			<xsl:variable name="noteClass" select="./@text:note-class"/>
			<xsl:variable name="noteConfig" select ="$officeDoc/office:styles/text:notes-configuration[@text:note-class=$noteClass]"/>

			<fop:inline>
				<xsl:call-template name="applyStyle">
					<xsl:with-param name="styleName" select="$noteConfig/@text:default-style-name"/>
				</xsl:call-template>
				<xsl:call-template name="applyStyle">
					<xsl:with-param name="styleName" select="$noteConfig/@text:citation-style-name"/>
				</xsl:call-template>
				<xsl:value-of select="./text:note-citation"/>
			</fop:inline>
			<fop:footnote-body>
				<xsl:call-template name="applyStyle">
					<xsl:with-param name="styleName" select="$noteConfig/@text:citation-body-style-name"/>
				</xsl:call-template>
				<xsl:apply-templates select="./text:note-body"/>
			</fop:footnote-body>
		</fop:footnote>
	</xsl:template>

	<!-- Beschriftungen -->
	<xsl:template match="text:sequence">
		<fop:inline>
			<xsl:variable name="format" select="./@style:num-format"/>
			<xsl:call-template name="applyStyle">
				<xsl:with-param name="styleNode" select="$officeDoc/office:styles/text:notes-configuration[@style:num-format=$format]"/>
			</xsl:call-template>
			<xsl:call-template name="processText"/>
		</fop:inline>
	</xsl:template>

	<!-- Inline-Formatierungen -->
	<xsl:template match="text:span">
		<fop:inline>
			<xsl:call-template name="applyStyle"><xsl:with-param name="styleName" select="./@text:style-name"/></xsl:call-template>
			<xsl:call-template name="processText"/>
		</fop:inline>
	</xsl:template>

	<!-- Kapitelnummerierung -->
	<xsl:template name="calcOutlineStyle">
		<xsl:param name="levelStyle"/>
		<xsl:param name="endLevel"/>
		<xsl:param name="startLevel"/>

		<xsl:choose>
			<xsl:when test="$endLevel >= $startLevel">
				<xsl:choose>
					<xsl:when test="$levelStyle[@text:level=$startLevel]/@style:num-format!='' and ($levelStyle[@text:level=$startLevel]/@text:display-levels!='' or $startLevel=1)">
						<xsl:choose>
							<xsl:when test="$startLevel > 1 ">.</xsl:when>
							<xsl:otherwise><xsl:value-of select="$levelStyle[@text:level=$endLevel]/@style:num-prefix"/></xsl:otherwise>
						</xsl:choose>
		
						<xsl:number format="{$levelStyle[@text:level=$startLevel]/@style:num-format}" level="any" count="text:h[@text:outline-level=$startLevel]"/>
					</xsl:when>
					<xsl:when test="$levelStyle[@text:level=$startLevel]/@text:bullet-char">
						<xsl:value-of select="$levelStyle/@text:bullet-char"/>
					</xsl:when>
				</xsl:choose>
	
				<xsl:call-template name="calcOutlineStyle">
					<xsl:with-param name="levelStyle" select="$levelStyle"/>
					<xsl:with-param name="endLevel" select="$endLevel"/>
					<xsl:with-param name="startLevel" select="$startLevel + 1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$levelStyle[@text:level=$endLevel]/@style:num-suffix"/>
				<xsl:if test="name(.)!='text:list-item'">
					<fop:leader leader-pattern="space">
						<xsl:choose>
							<xsl:when test="$levelStyle[@text:level=$endLevel]/style:list-level-properties/@text:min-label-distance">
								<xsl:attribute name="leader-length"><xsl:value-of select="$levelStyle[@text:level=$endLevel]/style:list-level-properties/@text:min-label-distance"/></xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="leader-length">0.3cm</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</fop:leader>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Texte, Überschriften, Bereiche -->
	<xsl:template match="text:p|text:h|text:section">
		<fop:block>
			<xsl:call-template name="applyStyle"><xsl:with-param name="styleName" select="./@text:style-name"/></xsl:call-template>

			<xsl:variable name="endLevel" select="./@text:outline-level"/>
			<xsl:if test="$endLevel">
				<xsl:variable name="levelStyle" select="$officeDoc/office:styles/text:outline-style/text:outline-level-style"/>
				<xsl:if test="$levelStyle[@text:level=$endLevel] and ($levelStyle[@text:level=$endLevel]/@style:num-format!='' or $levelStyle[@text:level=$endLevel]/@text:bullet-char)">

					<xsl:choose>
						<xsl:when test="$levelStyle[@text:level=$endLevel]/@text:bullet-char">
							<xsl:call-template name="calcOutlineStyle">
								<xsl:with-param name="levelStyle" select="$levelStyle"/>
								<xsl:with-param name="endLevel" select="$endLevel"/>
								<xsl:with-param name="startLevel" select="$endLevel"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="calcOutlineStyle">
								<xsl:with-param name="levelStyle" select="$levelStyle"/>
								<xsl:with-param name="endLevel" select="$endLevel"/>
								<xsl:with-param name="startLevel" select="1"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
			</xsl:if>
			<xsl:call-template name="processText"/>
		</fop:block>
	</xsl:template>

	<!-- Aufzählung -->
	<xsl:template match="text:list">
		<xsl:variable name="listStyleID" select="ancestor-or-self::text:list[@text:style-name][1]/@text:style-name" />
		<xsl:variable name="endLevel" select="count(ancestor-or-self::text:list)"/>

		<xsl:variable name="levelStyle" select="$officeDoc/office:automatic-styles/text:list-style[@style:name=$listStyleID]/text:list-level-style-number|$officeDoc/office:automatic-styles/text:list-style[@style:name=$listStyleID]/text:list-level-style-bullet|$officeDoc/office:automatic-styles/text:list-style[@style:name=$listStyleID]/text:list-level-style-image"/>

		<xsl:if test="./text:list-item">
			<fop:list-block provisional-label-separation="1cm">
				<xsl:choose>
					<xsl:when test="$levelStyle[@text:level=$endLevel]/style:list-level-properties/@text:space-before">
						<xsl:attribute name="start-indent"><xsl:value-of select="$levelStyle[@text:level=$endLevel]/style:list-level-properties/@text:space-before"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="start-indent">0cm</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			
				<!--$pStyle/@text:style-name-->
				<xsl:for-each select = "./text:list-item">
					<fop:list-item>
						<fop:list-item-label end-indent="label-end()">
							<fop:block>
								<xsl:call-template name="applyStyle"><xsl:with-param name="styleName" select="./text:p/@text:style-name"/></xsl:call-template>

								<xsl:if test="$levelStyle[@text:level=$endLevel] and ($levelStyle[@text:level=$endLevel]/@style:num-format!='' or $levelStyle[@text:level=$endLevel]/@text:bullet-char)">

									<xsl:choose>		
										<xsl:when test="$levelStyle[@text:level=$endLevel]/@text:bullet-char">
											<xsl:value-of select="$levelStyle[@text:level=$endLevel]/@text:bullet-char"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$levelStyle[@text:level=$endLevel]/@style:num-prefix"/>
											
											<xsl:choose>
												<xsl:when test="$levelStyle[@text:level=$endLevel]/@text:display-levels!=''">
													<xsl:number format="{$levelStyle[@text:level=$endLevel]/@style:num-format}" level="multiple" count="text:list-item"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:number format="{$levelStyle[@text:level=$endLevel]/@style:num-format}" level="single" count="text:list-item"/>
												</xsl:otherwise>
											</xsl:choose>
											
											<xsl:value-of select="$levelStyle[@text:level=$endLevel]/@style:num-suffix"/>
										</xsl:otherwise>
									</xsl:choose>

								</xsl:if>
							</fop:block>
						</fop:list-item-label>
						<fop:list-item-body>
							<xsl:choose>
								<xsl:when test="$levelStyle[@text:level=$endLevel]/@text:display-levels!=''">
									<xsl:attribute name="start-indent">body-start()-0.4cm+<xsl:value-of select="$endLevel*0.2"/>cm</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="start-indent">body-start()-0.2cm</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:apply-templates select="."/>
						</fop:list-item-body>
					</fop:list-item>
				</xsl:for-each>
	
			</fop:list-block>
		</xsl:if>
	</xsl:template>

	<!-- Inhaltsverzeichnis, Tabellenverzeichnis -->
	<xsl:template match="text:table-of-content|text:user-index">
		<xsl:apply-templates select="./text:index-body/text:index-title"/>

		<xsl:for-each select="./text:index-body/text:p">
			<fop:block text-align-last="justify">
				<xsl:call-template name="applyStyle"><xsl:with-param name="styleName" select="./@text:style-name"/></xsl:call-template>
				<xsl:call-template name="processText"/>
			</fop:block>
		</xsl:for-each>
	</xsl:template>	

	

	<!-- STYLE -->
	<!-- Die Formatierungen aus dem Stylesheet zusammensuchen -->
	<xsl:template name="interpretStyle">
		<xsl:param name="styleNode"/>
		<xsl:param name="styleType"/>
		<xsl:param name="stylePosition"/>

		<xsl:if test="$styleNode/@style:name">
			<xsl:if test="$styleNode/@style:next-style-name">
				<xsl:variable name="parent" select="$styleNode/@style:next-style-name"/>
				<xsl:call-template name="interpretStyle">
					<xsl:with-param name="styleNode" select="$officeDoc/office:styles/style:style[@style:name=$parent]"/>
					<xsl:with-param name="styleType" select="$styleType"/>
					<xsl:with-param name="stylePosition" select="$stylePosition"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$styleNode/@style:family">
				<xsl:variable name="family" select="$styleNode/@style:family"/>	<!-- rekursiver Aufruf des Templates -->
				<xsl:call-template name="interpretStyle">
					<xsl:with-param name="styleNode" select="$officeDoc/office:styles/style:default-style[@style:family=$family]"/>
					<xsl:with-param name="styleType" select="$styleType"/>
					<xsl:with-param name="stylePosition" select="$stylePosition"/>
				</xsl:call-template>
			</xsl:if>

			<xsl:if test="$styleNode/@style:parent-style-name">
				<xsl:variable name="parent" select="$styleNode/@style:parent-style-name"/>	<!-- rekursiver Aufruf des Templates -->
				<xsl:call-template name="interpretStyle">
					<xsl:with-param name="styleNode" select="$officeDoc/office:styles/style:style[@style:name=$parent]"/>
					<xsl:with-param name="styleType" select="$styleType"/>
					<xsl:with-param name="stylePosition" select="$stylePosition"/>
				</xsl:call-template>
			</xsl:if>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="$styleType='text:tab'">
				<xsl:if test="$styleNode/style:paragraph-properties/@style:tab-stop-distance">
					<xsl:attribute name="tab-stop-distance"><xsl:value-of select="$styleNode/style:paragraph-properties/@style:tab-stop-distance"/></xsl:attribute>
				</xsl:if>
		
				<xsl:if test="$styleNode/style:paragraph-properties/style:tab-stops/style:tab-stop[$stylePosition+1]">
					<xsl:if test="$styleNode/style:paragraph-properties/style:tab-stops/style:tab-stop[$stylePosition+1]/@style:type">
						<xsl:attribute name="type"><xsl:value-of select="$styleNode/style:paragraph-properties/style:tab-stops/style:tab-stop[$stylePosition+1]/@style:type"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:paragraph-properties/style:tab-stops/style:tab-stop[$stylePosition+1]/@style:leader-style">
						<xsl:attribute name="leader-style"><xsl:value-of select="$styleNode/style:paragraph-properties/style:tab-stops/style:tab-stop[$stylePosition+1]/@style:leader-style"/></xsl:attribute>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$styleType='header:footer'">
				<xsl:if test="$styleNode/style:header-footer-properties/@fo:min-height">
					<xsl:attribute name="min-height"><xsl:value-of select="$styleNode/style:header-footer-properties/@fo:min-height"/></xsl:attribute>
				</xsl:if>
				<!--<xsl:if test="$styleNode/style:header-footer-properties/@svg:height">
					<xsl:attribute name="min-height"><xsl:value-of select="$styleNode/style:header-footer-properties/@svg:height"/></xsl:attribute>
				</xsl:if>-->

				<xsl:if test="$styleNode/style:header-footer-properties">	
					<xsl:call-template name="interpetBoxStyle"><xsl:with-param name="styleNode" select="$styleNode/style:header-footer-properties"/></xsl:call-template>
				</xsl:if>
				<xsl:choose>	
					<xsl:when test="$styleNode/style:header-footer-properties/@svg:height and $styleNode/style:header-footer-properties/@fo:margin-bottom">
						<xsl:attribute name="extent"><xsl:value-of select="$styleNode/style:header-footer-properties/@svg:height"/> - <xsl:value-of select="$styleNode/style:header-footer-properties/@fo:margin-bottom"/></xsl:attribute>
					</xsl:when>
					<xsl:when test="$styleNode/style:header-footer-properties/@svg:height and $styleNode/style:header-footer-properties/@fo:margin-top">
						<xsl:attribute name="extent"><xsl:value-of select="$styleNode/style:header-footer-properties/@svg:height"/> - <xsl:value-of select="$styleNode/style:header-footer-properties/@fo:margin-top"/></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="extent">0.55cm</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name(.)='table:table'">
				<xsl:if test="$styleNode/style:table-properties">	
					<xsl:call-template name="interpetBoxStyle"><xsl:with-param name="styleNode" select="$styleNode/style:table-properties"/></xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="name(.)='table:table-row'">
				<xsl:if test="$styleNode/style:table-row-properties">	
					<xsl:call-template name="interpetBoxStyle"><xsl:with-param name="styleNode" select="$styleNode/style:table-row-properties"/></xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="name(.)='table:table-cell'">
				<xsl:if test="$styleNode/style:table-cell-properties">	
					<xsl:call-template name="interpetBoxStyle"><xsl:with-param name="styleNode" select="$styleNode/style:table-cell-properties"/></xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$styleNode/style:paragraph-properties">		
					<xsl:call-template name="interpetBoxStyle"><xsl:with-param name="styleNode" select="$styleNode/style:paragraph-properties"/></xsl:call-template>
			
					<xsl:if test="$styleNode/style:paragraph-properties/@fo:text-indent">
						<xsl:attribute name="text-indent"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:text-indent"/></xsl:attribute>
					</xsl:if>
				
					<xsl:if test="$styleNode/style:paragraph-properties/@fo:keep-with-next">
						<xsl:attribute name="keep-with-next"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:keep-with-next"/></xsl:attribute>
					</xsl:if>
			
					<xsl:if test="$styleNode/style:paragraph-properties/@fo:text-align">
						<xsl:attribute name="text-align"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:text-align"/></xsl:attribute>
					</xsl:if>
		
					<xsl:choose>		
						<xsl:when test="$styleNode/style:paragraph-properties/@fo:line-height">
							<xsl:attribute name="line-height"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:line-height"/></xsl:attribute>
						</xsl:when>
						<xsl:when test="$styleNode/style:paragraph-properties/@style:line-height-at-least">
							<xsl:attribute name="line-height"><xsl:value-of select="$styleNode/style:paragraph-properties/@style:line-height-at-least"/></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="line-height">110%</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>		

		

					<xsl:if test="$styleNode/style:paragraph-properties/@fo:break-before">
						<xsl:attribute name="break-before"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:break-before"/></xsl:attribute>
					</xsl:if>
		
					<xsl:if test="$styleNode/style:paragraph-properties/@fo:hyphenation-ladder-count">
						<xsl:attribute name="hyphenation-ladder-count"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:hyphenation-ladder-count"/></xsl:attribute>
					</xsl:if>
				</xsl:if>
		
				<xsl:if test="$styleNode/style:text-properties">
					<xsl:if test="$styleNode/style:text-properties/@fo:hyphenate">
						<xsl:attribute name="hyphenate"><xsl:value-of select="$styleNode/style:text-properties/@fo:hyphenate"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:hyphenation-remain-char-count">
						<!--<xsl:attribute name="hyphenation-remain-char-count"><xsl:value-of select="$styleNode/style:text-properties/@fo:hyphenation-remain-char-count"/></xsl:attribute>-->
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:hyphenation-push-char-count">
						<!--<xsl:attribute name="hyphenation-push-char-count"><xsl:value-of select="$styleNode/style:text-properties/@fo:hyphenation-push-char-count"/></xsl:attribute>-->
					</xsl:if>
			
					<xsl:if test="$styleNode/style:text-properties/@fo:language">
						<xsl:attribute name="language"><xsl:value-of select="$styleNode/style:text-properties/@fo:language"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:country">
						<xsl:attribute name="country"><xsl:value-of select="$styleNode/style:text-properties/@fo:country"/></xsl:attribute>
					</xsl:if>
			
					<xsl:if test="$styleNode/style:text-properties/@fo:color">
						<xsl:attribute name="color"><xsl:value-of select="$styleNode/style:text-properties/@fo:color"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:background-color">
						<xsl:attribute name="background-color"><xsl:value-of select="$styleNode/style:text-properties/@fo:background-color"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:font-size">
						<xsl:attribute name="font-size"><xsl:value-of select="$styleNode/style:text-properties/@fo:font-size"/></xsl:attribute>
					</xsl:if>
		
					<xsl:if test="$styleNode/style:text-properties/@fo:font-style">
						<xsl:attribute name="font-style"><xsl:value-of select="$styleNode/style:text-properties/@fo:font-style"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:font-weight">
						<xsl:attribute name="font-weight"><xsl:value-of select="$styleNode/style:text-properties/@fo:font-weight"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@fo:text-align">
						<xsl:attribute name="text-align"><xsl:value-of select="$styleNode/style:text-properties/@fo:text-align"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@style:font-name">
						<xsl:variable name="font" select="$styleNode/style:text-properties/@style:font-name"/>
						<xsl:variable name="font-family" select="$officeDoc/office:font-face-decls/style:font-face[@style:name=$font]/@svg:font-family"/>
						<xsl:variable name="font-family-generic" select="$officeDoc/office:font-face-decls/style:font-face[@style:name=$font]/@style:font-family-generic"/>
						
						<xsl:choose>
						 <xsl:when test="$font-family-generic = 'roman'">
						  <xsl:attribute name="font-family"><xsl:value-of select="concat($font-family,',serif')"/></xsl:attribute>
						 </xsl:when>
						 <xsl:when test="$font-family-generic = 'sans-serif' or $font-family-generic = 'serif' or $font-family-generic = 'monospace' or $font-family-generic = 'cursive' or $font-family-generic = 'fantasy'">
						  <xsl:attribute name="font-family"><xsl:value-of select="concat($font-family,',',$font-family-generic)"/></xsl:attribute>
						 </xsl:when>
						 <xsl:when test="contains($font-family,'Times') or contains($font-family,'Minion') or contains($font-family,'Garamond')">
						  <xsl:attribute name="font-family"><xsl:value-of select="concat($font-family,',serif')"/></xsl:attribute>
						 </xsl:when>
						 <xsl:when test="contains($font-family,'Courier')">
						  <xsl:attribute name="font-family"><xsl:value-of select="concat($font-family,',monospace')"/></xsl:attribute>
						 </xsl:when>
						 <xsl:otherwise>
						  <xsl:attribute name="font-family"><xsl:value-of select="concat($font-family,',sans-serif')"/></xsl:attribute>
						 </xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="$styleNode/style:text-properties/@style:text-underline='single'">
						<xsl:attribute name="text-decoration">underline</xsl:attribute>
					</xsl:if>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="interpetBoxStyle">
		<xsl:param name="styleNode"/>

		<xsl:if test="$styleNode/@fo:margin">
			<xsl:attribute name="margin"><xsl:value-of select="$styleNode/@fo:margin"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:margin-top">
			<!--<xsl:attribute name="margin-top"><xsl:value-of select="$styleNode/@fo:margin-top"/></xsl:attribute>-->
			<xsl:attribute name="space-before"><xsl:value-of select="$styleNode/@fo:margin-top"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:margin-bottom">
			<xsl:attribute name="space-after"><xsl:value-of select="$styleNode/@fo:margin-bottom"/></xsl:attribute>
			<!--<xsl:attribute name="margin-bottom"><xsl:value-of select="$styleNode/@fo:margin-bottom"/></xsl:attribute>-->
		</xsl:if>
		<xsl:if test="$styleNode/@fo:margin-left">
			<xsl:attribute name="margin-left"><xsl:value-of select="$styleNode/@fo:margin-left"/></xsl:attribute>
			<!--<xsl:attribute name="margin-left"><xsl:value-of select="$styleNode/@fo:margin-left"/></xsl:attribute>-->
		</xsl:if>
		<xsl:if test="$styleNode/@fo:margin-right">
			<xsl:attribute name="margin-right"><xsl:value-of select="$styleNode/@fo:margin-right"/></xsl:attribute>
			<!--<xsl:attribute name="margin-right"><xsl:value-of select="$styleNode/style:paragraph-properties/@fo:margin-right"/></xsl:attribute>-->
		</xsl:if>

		<xsl:if test="$styleNode/@fo:padding">
			<xsl:attribute name="padding"><xsl:value-of select="$styleNode/@fo:padding"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:padding-left">
			<xsl:attribute name="padding-left"><xsl:value-of select="$styleNode/@fo:padding-left"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:padding-right">
			<xsl:attribute name="padding-right"><xsl:value-of select="$styleNode/@fo:padding-right"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:padding-top">
			<xsl:attribute name="padding-top"><xsl:value-of select="$styleNode/@fo:padding-top"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:padding-bottom">
			<xsl:attribute name="padding-bottom"><xsl:value-of select="$styleNode/@fo:padding-bottom"/></xsl:attribute>
		</xsl:if>

		<xsl:if test="$styleNode/@fo:border">
			<xsl:attribute name="border"><xsl:value-of select="$styleNode/@fo:border"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:border-left">
			<xsl:attribute name="border-left"><xsl:value-of select="$styleNode/@fo:border-left"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:border-right">
			<xsl:attribute name="border-right"><xsl:value-of select="$styleNode/@fo:border-right"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:border-top">
			<xsl:attribute name="border-top"><xsl:value-of select="$styleNode/@fo:border-top"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="$styleNode/@fo:border-bottom">
			<xsl:attribute name="border-bottom"><xsl:value-of select="$styleNode/@fo:border-bottom"/></xsl:attribute>
		</xsl:if>

		<xsl:if test="$styleNode/@fo:background-color">
			<xsl:attribute name="background-color"><xsl:value-of select="$styleNode/@fo:background-color"/></xsl:attribute>
		</xsl:if>

		<xsl:if test="$styleNode/@style:vertical-align">
			<xsl:attribute name="display-align">end</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="applyStyle">
		<xsl:param name="styleNode"/>
		<xsl:param name="styleName"/>
		<xsl:param name="styleType"/>
		<xsl:param name="stylePosition"/>

		<xsl:choose>		
			<xsl:when test="$styleNode">
				<xsl:call-template name="interpretStyle">
					<xsl:with-param name="styleNode" select="$styleNode"/>
					<xsl:with-param name="styleType" select="$styleType"/>
					<xsl:with-param name="stylePosition" select="$stylePosition"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="styleNodeNeu" select="$officeDoc/office:styles/style:style[@style:name=$styleName]"/>
				<xsl:choose>		
					<xsl:when test="$styleNodeNeu">
						<xsl:call-template name="interpretStyle">
							<xsl:with-param name="styleNode" select="$styleNodeNeu"/>
							<xsl:with-param name="styleType" select="$styleType"/>
							<xsl:with-param name="stylePosition" select="$stylePosition"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="interpretStyle">
							<xsl:with-param name="styleNode" select="$officeDoc/office:automatic-styles/style:style[@style:name=$styleName]"/>
							<xsl:with-param name="styleType" select="$styleType"/>
							<xsl:with-param name="stylePosition" select="$stylePosition"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
