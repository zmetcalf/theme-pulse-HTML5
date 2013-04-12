<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">

    <!-- imports -->
    <xsl:import href="../../../xsl/globals.xsl"/>

    <!-- mein menu indent (used for indenting tree) -->
    <xsl:variable name="menu.indent" select="14"/>

    <!-- match MenuResult, mode tree.menu -->
    <xsl:template match="result[@class='org.torweg.pulse.component.core.site.map.MenuResult']"
        mode="tree.menu">
        <nav>

            <!-- debug -->
            <xsl:if test="$debug.site='true'">
                <xsl:comment>core:core.menu.xsl</xsl:comment>
            </xsl:if>

            <!-- build menu -->
            <xsl:apply-templates select="menuitem" mode="tree.menu"/>

        </nav>
    </xsl:template>

    <!-- tree menu - list -->
    <xsl:template match="menuitem" mode="tree.menu">
        <xsl:param name="level">
            <!-- default -->
            <xsl:value-of select="number(-1)"/>
        </xsl:param>
        <xsl:variable name="menu.level" select="number($level)+1"/>

        <!-- the menu -->
        <ul>
            <li>
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="$menu.level &gt; 0">
                            <xsl:text>link subLevel</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>link</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <!-- add indent -->
                <xsl:attribute name="style">
                    <xsl:text>margin:0 0 0 </xsl:text>
                    <xsl:value-of select="number($menu.level * $menu.indent)"/>
                    <xsl:text>px;</xsl:text>
                    <xsl:if test="$menu.level = 0">
                        <xsl:text>vertical-align:bottom;</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:if test="$menu.level = 0">
                    <img src="{$path.resources.components}/core/demo-layout/16x16/home.png"
                        width="16" height="16" alt="icon"/>
                </xsl:if>
                <a href="{text()}">
                    <xsl:value-of select="@name"/>
                </a>
            </li>
            <xsl:if test="boolean(child::menuitem)">
                <li class="levelWrapper">
                    <xsl:if test="$menu.level = 0">
                        <xsl:attribute name="style">
                            <xsl:text>padding: 0 0 0 5px;</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <!-- recurse through the menu tree -->
                    <xsl:apply-templates select="child::menuitem" mode="tree.menu">
                        <xsl:with-param name="level" select="$menu.level"/>
                    </xsl:apply-templates>
                </li>
            </xsl:if>
        </ul>

    </xsl:template>

    <!-- match MenuResult, mode bread.crumb -->
    <xsl:template match="result[@class='org.torweg.pulse.component.core.site.map.MenuResult']"
        mode="bread.crumb">
        <div id="breadCrumbContainer">

            <!-- debug -->
            <xsl:if test="$debug.site='true'">
                <xsl:comment>core:core.menu.xsl</xsl:comment>
            </xsl:if>

            <xsl:if test="boolean(bread-crumb/menuitem)">
                <xsl:text>&#187;&#160;&#160;</xsl:text>
            </xsl:if>

            <!-- build bread crumb -->
            <xsl:for-each select="bread-crumb/menuitem">
                <xsl:if test="@visible='true'">
                    <a href="{text()}" title="{@name}">
                        <xsl:value-of select="@name"/>
                    </a>
                    <xsl:if test="boolean(following-sibling::node())">
                        <xsl:text>&#160;&#160;&#187;&#160;&#160;</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
        </div>
    </xsl:template>

</xsl:stylesheet>
