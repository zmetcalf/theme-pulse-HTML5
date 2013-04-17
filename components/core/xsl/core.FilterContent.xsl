<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:container="http://pulse.torweg.org/container" version="2.0" exclude-result-prefixes="#all">

    <!-- imports -->
    <xsl:import href="i18n/core.babelfish.xsl"/>
    <xsl:import href="core.content.attachments.xsl"/>

    <!-- ouput encoding -->
    <xsl:output encoding="UTF-8" indent="yes" method="xhtml" omit-xml-declaration="yes"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="pre textarea script style"/>

    <!-- the max. no. of contents to be displayed at once -->
    <xsl:variable name="max.filter.contents" select="6"/>

    <!-- main AJAX reload template -->
    <xsl:template match="/*">
        <!-- the current controller result of the FilterContentDisplayer -->
        <xsl:variable name="controller.result"
            select="/result/result[@bundle='Core']/descendant::controller[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayer']"/>

        <!-- content filtering / calendar paging -->
        <xsl:choose>

            <!-- content filtering -->
            <xsl:when test="boolean($controller.result/result)">
                <xsl:apply-templates select="$controller.result/result"/>
            </xsl:when>

            <!-- calendar paging -->
            <xsl:when test="boolean($controller.result/container:calendar-sheet)">
                <xsl:apply-templates select="$controller.result/container:calendar-sheet"
                    mode="filter.panel.reference.duration"/>
            </xsl:when>

            <!-- error -->
            <xsl:otherwise>
                <div class="error">
                    <!-- debug -->
                    <xsl:if test="$debug.site='true'">
                        <xsl:comment>core:core.FilterContent.xsl</xsl:comment>
                    </xsl:if>
                    <xsl:text>xsl:choose NO TEMPLATE MATCH</xsl:text>
                </div>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- main template matching FilterContentDisplayerResult -->
    <xsl:template
        match="result[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayerResult']">
        <xsl:apply-templates
            select="Content[@class='org.torweg.pulse.site.content.filter.FilterContent']"
            mode="core"/>
    </xsl:template>

    <!-- org.torweg.pulse.site.content.filter.FilterContent -->
    <xsl:template match="Content[@class='org.torweg.pulse.site.content.filter.FilterContent']"
        mode="core">

        <!-- wrapper div@id="FilterContentAjaxWrapper" required for ajax reload in filter content ui -->
        <div id="FilterContentAjaxWrapper">

            <!-- debug -->
            <xsl:if test="$debug.site='true'">
                <xsl:comment>core:core.FilterContent.xsl</xsl:comment>
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

            <!-- wrapper div@id="FilterContentFilteredContents" used for animation in filter content ui -->
            <div id="FilterContentFilteredContents">

                <!-- results / no results -->
                <xsl:choose>

                    <!-- results -->
                    <xsl:when test="number(../@total) &gt; 0">
                        <!-- paging -->
                        <xsl:apply-templates select="self::node()" mode="filtered.contents.paging"/>
                        <!-- contents -->
                        <xsl:for-each select="filtered-contents/Content">
                            <xsl:if test="(position() &lt;= number($max.filter.contents))">
                                <!-- headline -->
                                <h2>
                                    <a href="{details-view/text()}">
                                        <xsl:value-of select="name/text()"/>
                                    </a>
                                </h2>
                                <!-- summary -->
                                <xsl:if
                                    test="fn:matches(fn:string-join(summary/body/descendant::*/text(),''), '\w+')">
                                    <xsl:apply-templates select="summary/body/*" mode="xhtml"/>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                        <!-- paging -->
                        <xsl:apply-templates select="self::node()" mode="filtered.contents.paging"/>
                    </xsl:when>

                    <!-- no results -->
                    <xsl:otherwise>
                        <h2>
                            <xsl:call-template name="core.babelfish">
                                <xsl:with-param name="id" tunnel="yes">
                                    <xsl:text>filter.no.matches.headline</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </h2>
                        <xsl:call-template name="core.babelfish">
                            <xsl:with-param name="id" tunnel="yes">
                                <xsl:text>filter.no.matches.description</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>

                </xsl:choose>

            </div>

        </div>

    </xsl:template>

    <!-- paging -->
    <xsl:template match="Content[@class='org.torweg.pulse.site.content.filter.FilterContent']"
        mode="filtered.contents.paging">
        <!-- total of results -->
        <xsl:param name="total" select="number(../@total)"/>
        <!-- current offset -->
        <xsl:param name="offset">
            <xsl:choose>
                <xsl:when test="/result/meta-data/command/descendant::Parameter[@name='offset']">
                    <xsl:value-of
                        select="number(/result/meta-data/command/descendant::Parameter[@name='offset']/value/text())"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="number(1)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <!-- previous label -->
        <xsl:param name="previous.label">
            <xsl:text>&lt;&lt;&#160;</xsl:text>
            <xsl:call-template name="misc.babelfish">
                <xsl:with-param name="id" tunnel="yes">
                    <xsl:text>previous</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:param>
        <!-- next label -->
        <xsl:param name="next.label">
            <xsl:call-template name="misc.babelfish">
                <xsl:with-param name="id" tunnel="yes">
                    <xsl:text>next</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:text>&#160;&gt;&gt;</xsl:text>
        </xsl:param>

        <!-- retrieve name for javascript ui controller -->
        <xsl:variable name="ui.js.controller.name">
            <xsl:apply-templates select="self::node()" mode="ui.js.controller.name"/>
        </xsl:variable>

        <!-- base uri (for noscript) -->
        <xsl:variable name="base.URI">
            <xsl:value-of select="../base-uri/text()"/>
        </xsl:variable>

        <!-- paging bar -->
        <xsl:if test="($total &gt; number($max.filter.contents)) or ($offset &gt; 1)">
            <div class="pagingBar">

                <!-- previous -->
                <xsl:choose>
                    <xsl:when test="$offset &gt; 1">
                        <xsl:choose>
                            <xsl:when test="$offset &lt; count(filtered-contents/Content)">
                                <a href="{$base.URI}"
                                    onclick="{$ui.js.controller.name}.request();return false;">
                                    <xsl:value-of select="$previous.label"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <a
                                    onclick="{$ui.js.controller.name}.request({$offset - number($max.filter.contents)});return false;">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="$base.URI"/>
                                        <xsl:choose>
                                            <xsl:when test="fn:contains($base.URI,'?')">
                                                <xsl:text disable-output-escaping="yes">&amp;offset=</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>?offset=</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:value-of
                                            select="$offset - number($max.filter.contents)"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="$previous.label"/>
                                </a>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:value-of select="$previous.label"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- spacer -->
                <span>&#160;&#160;&#160;&#160;&#160;&#160;</span>

                <!-- info -->
                <span>
                    <xsl:value-of select="$offset"/>
                    <xsl:text>-</xsl:text>
                    <xsl:choose>
                        <xsl:when test="($offset + number($max.filter.contents) - 1 &lt;= $total)">
                            <xsl:value-of select="($offset + number($max.filter.contents) - 1)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$total"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>&#160;/&#160;</xsl:text>
                    <xsl:value-of select="$total"/>
                </span>

                <!-- spacer -->
                <span>&#160;&#160;&#160;&#160;&#160;&#160;</span>

                <!-- next -->
                <xsl:choose>
                    <xsl:when test="($offset + number($max.filter.contents)) &lt;= $total">
                        <a
                            onclick="{$ui.js.controller.name}.request({$offset + number($max.filter.contents)});return false;">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$base.URI"/>
                                <xsl:choose>
                                    <xsl:when test="fn:contains($base.URI,'?')">
                                        <xsl:text disable-output-escaping="yes">&amp;offset=</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>?offset=</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="$offset + number($max.filter.contents)"/>
                            </xsl:attribute>
                            <xsl:value-of select="$next.label"/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:value-of select="$next.label"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>

            </div>
        </xsl:if>
    </xsl:template>

    <!-- match FilterContentDisplayerResult, mode head.core -->
    <xsl:template
        match="result[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayerResult']"
        mode="head.core">

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>core:core.FilterContent.xsl</xsl:comment>
        </xsl:if>

        <xsl:if test="../../../meta-data/command/@action='displayFilter'">

            <!-- the URL to be used for filter AJAX reloads -->
            <xsl:variable name="filter.AJAX.URL"
                select="/result/result[@bundle='Core']/descendant::command[@name='displayFilterAJAX']/text()"/>

            <!-- retrieve name for javascript ui controller -->
            <xsl:variable name="ui.js.controller.name">
                <xsl:apply-templates select="Content" mode="ui.js.controller.name"/>
            </xsl:variable>

            <!-- include FilterContentUIController JavaScript -->
            <script type="text/javascript" src="{$path.resources.components}/core/ui/FilterContentUIController.js"/>

            <!-- include CalendarPagingUIController JavaScript -->
            <xsl:if test="boolean(Content/Filter[@is-reference-duration-filter='true'])">
                <script type="text/javascript" src="{$path.resources.components}/core/ui/CalendarScrollUIController.js"/>
            </xsl:if>

            <!-- initialise filter ui controllers -->
            <script type="text/javascript">
                $(document).ready(function() {
                
                    <!-- initialises the filter ui controller  -->
                    <xsl:value-of select="$ui.js.controller.name"/> = new FilterContentUIController({
                        url : '<xsl:value-of select="$filter.AJAX.URL"/>',
                        contentId : <xsl:value-of select="Content/@id"/>
                    });
                    
                    <!-- provides debug information for js ui controller -->
                    <!--<xsl:value-of select="$ui.js.controller.name"/>.debug();-->
                
                    <!-- initialise calendar sheet paging ui controller -->
                    <xsl:if test="boolean(Content/Filter[@is-reference-duration-filter='true'])">
                        
                        <xsl:value-of select="$ui.js.controller.name"/>_calendar = new CalendarScrollUIController({
                        
                            <!-- url for ajax filter paging -->
                            url : '<xsl:value-of select="/result/result[@bundle='Core']/descendant::command[@name='filterGetCalendarSheetAJAX']/text()"/>',
                            
                            <!-- callback to be executed after calendar selection -->
                            callback : function(success, params) {
                            
                                if (false === success) {
                                    return;
                                }
                                
                                <!-- 
                                    appliy new reference duration start/end to hidden input fields
                                    (unless calendar is being scrolled to another page)
                                -->
                                if (params.scrollDirection === 'CURRENT' || params.scrollDirection === 'SELECTED') {
                                        $('#FilterContentDurationStart').val(params.durationStart);
                                        $('#FilterContentDurationEnd').val(params.durationEnd);
                                }
                                
                                <!-- reload filter -->
                                <xsl:value-of select="$ui.js.controller.name"/>.update({
                                    data : {
                                        controller: <xsl:value-of select="$ui.js.controller.name"/>
                                    }
                                });
                                
                            }
                            
                        });
                        
                        <!-- provides debug information for js ui controller -->
                        <!--<xsl:value-of select="$ui.js.controller.name"/>_calendar.debug();-->
                        
                    </xsl:if>
                
                });
            </script>

        </xsl:if>

    </xsl:template>

    <!-- builds name for javascript ui controller -->
    <xsl:template match="Content[@class='org.torweg.pulse.site.content.filter.FilterContent']"
        mode="ui.js.controller.name">
        <xsl:value-of select="fn:replace(@class,'\.','')"/>
        <xsl:text>_</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>_ui_controller</xsl:text>
    </xsl:template>

    <!-- match FilterContentDisplayerResult, mode filter.panel-->
    <xsl:template
        match="result[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayerResult']"
        mode="filter.panel">
        <!-- filter noscript URL -->
        <xsl:variable name="filter.noscript.URL">
            <xsl:choose>
                <xsl:when test="fn:contains(base-uri/text(),'?')">
                    <xsl:value-of select="fn:substring-before(base-uri/text(),'?')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="base-uri/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div id="FilterContentFilterPanel" class="filterPanelContainer">

            <!-- debug -->
            <xsl:if test="$debug.site='true'">
                <xsl:comment>core:core.FilterContent.xsl</xsl:comment>
            </xsl:if>

            <!-- form (for noscript) -->
            <form action="{$filter.noscript.URL}" method="post"
                enctype="application/x-www-form-urlencoded">

                <!-- calendar sheet (if filter with reference duration filtering) -->
                <xsl:if test="boolean(Content/Filter[@is-reference-duration-filter='true'])">
                    <xsl:apply-templates select="calendar-sheet/container:calendar-sheet"
                        mode="filter.panel.reference.duration"/>
                </xsl:if>

                <!-- (localised) filter rule -->
                <xsl:for-each
                    select="Content/Filter/rules/FilterRule[localizations/locale/@lang=$language 
                and properties/FilterRuleProperty/localizations/locale/@lang=$language]">
                    <div class="clearBoth">

                        <h3>
                            <xsl:value-of select="localizations/locale[@lang=$language]/text()"/>
                        </h3>

                        <!--  filter rule (localised) properties -->
                        <xsl:for-each
                            select="properties/FilterRuleProperty[localizations/locale/@lang=$language]">
                            <xsl:variable name="property.parameter.name">
                                <xsl:text>prop_</xsl:text>
                                <xsl:value-of select="ancestor::FilterRule/@id"/>
                            </xsl:variable>
                            <div class="left" style="vertical-align:middle;">
                                <!-- @class=productfinder required for ui javascript -->
                                <input type="checkbox" id="filterruleproperty_{@id}"
                                    name="{$property.parameter.name}" value="{@id}"
                                    class="filterproperty" style="vertical-align:middle;"
                                    autocomplete="off">
                                    <xsl:if
                                        test="boolean(/result/meta-data/command/descendant::Parameter[@name=$property.parameter.name]/descendant::value/text() = @id)">
                                        <xsl:attribute name="checked">
                                            <xsl:text>checked</xsl:text>
                                        </xsl:attribute>
                                    </xsl:if>
                                </input>
                                <label for="filterruleproperty_{@id}" style="vertical-align:middle;">
                                    <xsl:value-of
                                        select="localizations/locale[@lang=$language]/text()"/>
                                </label>
                            </div>
                        </xsl:for-each>

                    </div>
                </xsl:for-each>

                <!-- input@id="FilterContentOffset" required for ajax reload in filter content ui -->
                <input type="hidden" id="FilterContentOffset" name="offset" autocomplete="off">
                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when
                                test="boolean(/result/meta-data/command/descendant::Parameter[@name='offset']/value/text())">
                                <xsl:value-of
                                    select="/result/meta-data/command/descendant::Parameter[@name='offset']/value/text()"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>1</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </input>

                <!-- noscript -> show submit button -->
                <noscript>
                    <button type="submit" class="clearBoth right">
                        <span>
                            <xsl:call-template name="misc.babelfish">
                                <xsl:with-param name="id" tunnel="yes">
                                    <xsl:text>submit</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </span>
                    </button>
                </noscript>

            </form>

        </div>

    </xsl:template>

    <!-- match container:calendar-sheet, mode filter.panel.reference.duration -->
    <xsl:template match="container:calendar-sheet" mode="filter.panel.reference.duration">
        <!-- the currently selected day -->
        <xsl:variable name="selected.day"
            select="calendar-sheet-days/calendar-sheet-day[selection-mode/text()='SELECTED']"/>

        <!-- div@id used for ui controller AJAX refresh/paging -->
        <div id="FilterContentReferenceDurationCalendarAJAXWrapper">
            <!-- the calendar ui table -->
            <table border="0" cellpadding="0" cellspacing="0">
                <thead>
                    <xsl:apply-templates select="calendar-sheet-days"
                        mode="filter.panel.reference.duration.thead">
                        <xsl:with-param name="selected.day" select="$selected.day"/>
                        <!-- build base noscript URL -->
                        <xsl:with-param name="base.noscript.calendar.URL" tunnel="yes">
                            <xsl:call-template name="base.noscript.calendar.URL"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </thead>
                <tbody>
                    <xsl:apply-templates select="calendar-sheet-days"
                        mode="filter.panel.reference.duration.tbody">
                        <xsl:with-param name="row" select="1"/>
                        <!-- build base noscript URL -->
                        <xsl:with-param name="base.noscript.calendar.URL" tunnel="yes">
                            <xsl:call-template name="base.noscript.calendar.URL"/>
                        </xsl:with-param>
                    </xsl:apply-templates>
                </tbody>
            </table>
            <!-- hidden input fields durationStart/durationEnd -->
            <input type="hidden" id="FilterContentDurationStart" name="durationStart"
                value="{$selected.day/duration/start-millis/text()}" autocomplete="off"/>
            <input type="hidden" id="FilterContentDurationEnd" name="durationEnd"
                value="{$selected.day/duration/end-millis/text()}" autocomplete="off"/>
        </div>

    </xsl:template>

    <!-- match calendar-sheet-days, mode filter.panel.reference.duration.thead -->
    <xsl:template match="calendar-sheet-days" mode="filter.panel.reference.duration.thead">
        <!-- the currently selected day -->
        <xsl:param name="selected.day"/>

        <!-- month / paging -->
        <tr>
            <!-- page previous month -->
            <td class="scrollPREVIOUS">
                <a href="#">
                    <!-- build href (noscript) -->
                    <xsl:attribute name="href">
                        <xsl:apply-templates select="$selected.day" mode="noscript.calendar.URL">
                            <xsl:with-param name="scroll.direction">
                                <xsl:text>previous</xsl:text>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:attribute>
                    <xsl:text>&#171;</xsl:text>
                    <input type="hidden" class="params">
                        <xsl:attribute name="value">
                            <xsl:text>{</xsl:text>
                            <xsl:text>"scrollDirection":"previous"</xsl:text>
                            <xsl:text>,"durationStart":</xsl:text>
                            <xsl:value-of select="$selected.day/duration/start-millis/text()"/>
                            <xsl:text>,"durationEnd":</xsl:text>
                            <xsl:value-of select="$selected.day/duration/end-millis/text()"/>
                            <xsl:text>}</xsl:text>
                        </xsl:attribute>
                    </input>
                </a>
            </td>
            <!-- current month info -->
            <td class="monthOfYear" colspan="5">
                <xsl:call-template name="misc.babelfish">
                    <xsl:with-param name="id" tunnel="yes">
                        <xsl:text>month.of.year.</xsl:text>
                        <xsl:value-of select="$selected.day/calendar-jaxb-output-wrapper/month"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:text>&#160;</xsl:text>
                <xsl:value-of select="$selected.day/calendar-jaxb-output-wrapper/year"/>
            </td>
            <!-- page next month -->
            <td class="scrollPOST">
                <a href="#">
                    <!-- build href (noscript) -->
                    <xsl:attribute name="href">
                        <xsl:apply-templates select="$selected.day" mode="noscript.calendar.URL">
                            <xsl:with-param name="scroll.direction">
                                <xsl:text>next</xsl:text>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:attribute>
                    <xsl:text>&#187;</xsl:text>
                    <input type="hidden" class="params">
                        <xsl:attribute name="value">
                            <xsl:text>{</xsl:text>
                            <xsl:text>"scrollDirection":"next"</xsl:text>
                            <xsl:text>,"durationStart":</xsl:text>
                            <xsl:value-of select="$selected.day/duration/start-millis/text()"/>
                            <xsl:text>,"durationEnd":</xsl:text>
                            <xsl:value-of select="$selected.day/duration/end-millis/text()"/>
                            <xsl:text>}</xsl:text>
                        </xsl:attribute>
                    </input>
                </a>
            </td>
        </tr>

        <!-- days of week -->
        <tr>
            <xsl:for-each select="calendar-sheet-day[position() &gt; 0 and position() &lt;= 7]">
                <td class="dayOfWeek">
                    <xsl:variable name="day.name">
                        <xsl:call-template name="misc.babelfish">
                            <xsl:with-param name="id" tunnel="yes">
                                <xsl:text>day.of.week.</xsl:text>
                                <xsl:value-of select="calendar-jaxb-output-wrapper/day-of-week"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="fn:substring($day.name, 0, 2)"/>
                </td>
            </xsl:for-each>
        </tr>

    </xsl:template>

    <!-- match calendar-sheet-days, mode filter.panel.reference.duration.tbody -->
    <xsl:template match="calendar-sheet-days" mode="filter.panel.reference.duration.tbody">
        <!-- the current "row" number (a row matchces one week) -->
        <xsl:param name="row"/>

        <xsl:variable name="max" select="number($row) * 7"/>
        <xsl:variable name="min" select="$max - 7"/>

        <tr>
            <xsl:for-each
                select="calendar-sheet-day[position() &gt; $min and position() &lt;= $max]">
                <td class="month{selection-mode/text()}">
                    <a href="#">
                        <!-- build href (noscript) -->
                        <xsl:attribute name="href">
                            <xsl:apply-templates select="self::node()" mode="noscript.calendar.URL"
                            />
                        </xsl:attribute>
                        <xsl:value-of select="calendar-jaxb-output-wrapper/day/text()"/>
                        <input type="hidden" class="params">
                            <xsl:attribute name="value">
                                <xsl:text>{</xsl:text>
                                <xsl:text>"scrollDirection":"</xsl:text>
                                <xsl:value-of select="selection-mode/text()"/>
                                <xsl:text>","durationStart":</xsl:text>
                                <xsl:value-of select="duration/start-millis/text()"/>
                                <xsl:text>,"durationEnd":</xsl:text>
                                <xsl:value-of select="duration/end-millis/text()"/>
                                <xsl:text>}</xsl:text>
                            </xsl:attribute>
                        </input>
                    </a>
                </td>
            </xsl:for-each>
        </tr>
        <xsl:if test="boolean(calendar-sheet-day[position() = ($max + 1)])">
            <xsl:apply-templates select="self::node()" mode="filter.panel.reference.duration.tbody">
                <xsl:with-param name="row" select="number($row) + 1"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <!-- builds base noscript URL for calendar-->
    <xsl:template name="base.noscript.calendar.URL">
        <!-- retrieve URL -->
        <xsl:choose>
            <xsl:when test="fn:contains(/result/meta-data/url/plain/text(),'?')">
                <xsl:value-of select="fn:substring-before(/result/meta-data/url/plain/text(),'?')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="/result/meta-data/url/plain/text()"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- params (offset & properties) -->
        <xsl:apply-templates select="/result/meta-data/command/descendant::Parameter[1]"
            mode="base.noscript.calendar.URL.parameter">
            <xsl:with-param name="first" select="true()"/>
        </xsl:apply-templates>

    </xsl:template>

    <!-- append parameters to noscript base URL for calendar -->
    <xsl:template match="Parameter" mode="base.noscript.calendar.URL.parameter">
        <!-- flag for check whether to append parameter with '?' or '&' -->
        <xsl:param name="first"/>
        <!-- the parameter name -->
        <xsl:variable name="parameter.name" select="@name"/>

        <!-- append / don't append parameter -->
        <xsl:choose>

            <!-- append parameter -->
            <xsl:when
                test="boolean($parameter.name = 'offset') or fn:starts-with($parameter.name,'prop_')">

                <!-- check whether to append parameter with '?' or '&' -->
                <xsl:choose>
                    <xsl:when test="$first = true()">
                        <xsl:text>?</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>

                <!-- add parameter values -->
                <xsl:for-each select="descendant::value">
                    <xsl:value-of select="$parameter.name"/>
                    <xsl:text>=</xsl:text>
                    <xsl:value-of select="text()"/>
                    <xsl:if test="boolean(following-sibling::node())">
                        <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
                    </xsl:if>
                </xsl:for-each>

                <!-- process next parameter -->
                <xsl:apply-templates select="following-sibling::Parameter[1]"
                    mode="base.noscript.calendar.URL.parameter">
                    <xsl:with-param name="first" select="false()"/>
                </xsl:apply-templates>

            </xsl:when>

            <!-- no append > process next parameter -->
            <xsl:otherwise>
                <xsl:apply-templates select="following-sibling::Parameter[1]"
                    mode="base.noscript.calendar.URL.parameter">
                    <xsl:with-param name="first" select="$first"/>
                </xsl:apply-templates>
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

    <!-- builds noscript URLs for calendar -->
    <xsl:template match="calendar-sheet-day" mode="noscript.calendar.URL">
        <!-- base URL -->
        <xsl:param name="base.noscript.calendar.URL" tunnel="yes"/>
        <!-- scroll direction -->
        <xsl:param name="scroll.direction"/>

        <!-- append '?' or '&' base URL -->
        <xsl:value-of select="$base.noscript.calendar.URL"/>
        <xsl:choose>
            <xsl:when test="fn:contains($base.noscript.calendar.URL,'?')">
                <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <!-- append duration start -->
        <xsl:text>durationStart=</xsl:text>
        <xsl:value-of select="self::node()/duration/start-millis/text()"/>
        <!-- append duration end -->
        <xsl:text disable-output-escaping="yes">&amp;durationEnd=</xsl:text>
        <xsl:value-of select="self::node()/duration/end-millis/text()"/>
        <!-- append scroll direction -->
        <xsl:if test="boolean($scroll.direction) and not($scroll.direction = '')">
            <xsl:text disable-output-escaping="yes">&amp;scrollDirection=</xsl:text>
            <xsl:value-of select="$scroll.direction"/>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>
