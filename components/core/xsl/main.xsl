<?xml version="1.0" encoding="UTF-8"?>
<!-- component:core -->
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="#all">

    <!-- includes -->
    <xsl:include href="core.ContentGroup.xsl"/>
    <xsl:include href="core.FileContent.xsl"/>
    <xsl:include href="core.FilterContent.xsl"/>
    <xsl:include href="core.content.attachments.xsl"/>

    <xsl:include href="core.authentication.xsl"/>
    <xsl:include href="core.sign.up.xsl"/>
    <xsl:include href="core.user.self.edit.xsl"/>

    <xsl:include href="core.menu.xsl"/>
    <xsl:include href="core.sitemap.xsl"/>

    <xsl:include href="core.search.advanced.xsl"/>
    <xsl:include href="core.search.box.xsl"/>
    <xsl:include href="core.search.result.xsl"/>

    <!-- add core related stuff to head -->
    <xsl:template match="result" mode="head.core">
        <!-- the current result of the Core bundle (i.e. for retrieving commands) -->
        <xsl:param name="core.result" select="result[@bundle='Core']"/>

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>core:main.xsl</xsl:comment>
        </xsl:if>

        <!-- search suggestions -->
        <xsl:variable name="search.suggest.URL"
            select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.CommandGeneratorResult']/command[@name='searchSuggestions']/text()"/>
        <xsl:if test="boolean($search.suggest.URL != '')">

            <!-- include suggest css -->
            <link href="{$path.libjs}/jquery/suggest/jquery.suggest.css" rel="stylesheet"
                type="text/css"/>

            <!-- include suggest javascript -->
            <script type="text/javascript" src="{$path.libjs}/jquery/suggest/suggest.js"/>

            <!-- initialise suggest for search inputs (ui) -->
            <script type="text/javascript">
                $(document).ready( function() {
                
                    <!-- default search box (sidebar) -->
                    searchBoxSelector = <xsl:text disable-output-escaping="yes">'#searchBoxContainer &gt; form &gt; input'</xsl:text>;
                    $(searchBoxSelector).suggest('<xsl:value-of select="$search.suggest.URL"/>',{
                        minchars: 2,
                        resultsClass: 'ac_results_box'
                    });
                    
                    <!-- advanced search -->
                    advancedSearchSelector = <xsl:text disable-output-escaping="yes">'#advancedSearchContainer &gt; form &gt; input'</xsl:text>;
                    advancedInput = $(advancedSearchSelector);
                    if (typeof(advancedInput) != 'undefined') {
                        advancedInput.suggest('<xsl:value-of select="$search.suggest.URL"/>',{
                            minchars: 2,
                            resultsClass: 'ac_results_advanced'
                        });
                    }
                    
                }); 
            </script>

        </xsl:if>

        <!-- initialise FilterContentUI -->
        <xsl:apply-templates
            select="result[@bundle='Core']/descendant::result[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayerResult']"
            mode="head.core"/>

    </xsl:template>

    <!-- 
        match CoreContentDisplayerResult
            @see: core.ContentGroup.xsl
            @see: core.FileContent.xsl
    -->
    <xsl:template
        match="result[@class='org.torweg.pulse.component.core.site.content.CoreContentDisplayerResult']">
        <xsl:apply-templates select="Content" mode="core"/>
    </xsl:template>

</xsl:stylesheet>
