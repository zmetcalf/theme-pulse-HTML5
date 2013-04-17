<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="2.0" exclude-result-prefixes="#all">

    <!-- import -->
    <xsl:import href="../../../xsl/globals.xsl"/>

    <!-- org.torweg.pulse.site.content.FileContent -->
    <xsl:template match="Content[@class='org.torweg.pulse.site.content.FileContent']" mode="core">

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:apply-templates select="self::node()" mode="debug"/>
            <xsl:comment>core:core.FileContent.xsl</xsl:comment>
        </xsl:if>

        <!-- attachments -->
        <xsl:apply-templates select="self::node()" mode="attachments"/>

        <!-- headline -->
        <h1>
            <xsl:value-of select="name/text()"/>
        </h1>

        <!-- summary -->
        <xsl:if test="fn:matches(fn:string-join(summary/body/descendant::*/text(),''), '\w+')">
            <xsl:apply-templates select="summary/body/*" mode="xhtml"/>
        </xsl:if>

        <!-- file download -->
        <xsl:if test="boolean(VirtualFile)">
            <h2>
                <a href="{VirtualFile/http-uri/text()}?download">
                    <xsl:value-of select="VirtualFile/@name"/>
                    <xsl:text>&#160;-&#160;</xsl:text>
                    <xsl:value-of select="VirtualFile/file-size/text()"/>
                    <xsl:text>b</xsl:text>
                </a>
            </h2>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
