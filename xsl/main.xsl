<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:container="http://pulse.torweg.org/container"
    xmlns:core="http://pulse.torweg.org/component/core"
    xmlns:shop="http://pulse.torweg.org/component/shop"
    xmlns:checkout2="http://pulse.torweg.org/component/shop/checkout2" version="2.0"
    exclude-result-prefixes="#all">

    <!-- imports -->
    <xsl:import href="globals.xsl"/>
    <xsl:import href="error-templates.xsl"/>
    <xsl:import href="debug.xsl"/>

    <xsl:import href="../components/core/xsl/main.xsl"/>
    <xsl:import href="../components/cms/xsl/main.xsl"/>
    <xsl:import href="../components/shop/xsl/main.xsl"/>
    <xsl:import href="../components/store/xsl/main.xsl"/>
    <xsl:import href="../components/statistics/xsl/main.xsl"/>

    <!-- ouput encoding -->
    <xsl:output encoding="UTF-8" indent="yes" method="xhtml" omit-xml-declaration="yes"
        doctype-system="about:legacy-compat"
        doctype-public=""/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="pre textarea script style"/>

    <!-- include global XSLs -->


    <!-- include component XSLs -->


    <!-- main template -->
    <xsl:template match="/*">
        <!-- the current result of the bundle which executed the action -->
        <xsl:param name="action.result" select="result[@hadAction='true']"/>
        <!-- the current result of the Core bundle (i.e. for retrieving commands) -->
        <xsl:param name="core.result" select="result[@bundle='Core']"/>

        <html>
            <head>
                <xsl:apply-templates select="self::node()" mode="head">
                    <xsl:with-param name="action.result" select="$action.result"/>
                    <xsl:with-param name="core.result" select="$core.result"/>
                </xsl:apply-templates>
                <xsl:apply-templates select="self::node()" mode="head.core"/>
                <xsl:apply-templates select="self::node()" mode="head.shop"/>
                <xsl:apply-templates select="self::node()" mode="head.statistics"/>
            </head>
            <body>

                <!-- debug -->
                <xsl:if test="$debug.site='true'">
                    <xsl:comment>main.xsl</xsl:comment>
                </xsl:if>

                <!-- display theme (as provided by ThemesController) -->
                <xsl:variable name="theme"
                    select="$core.result/descendant-or-self::result[@controller='org.torweg.pulse.component.core.site.ThemesController']/selected-theme/theme/image/text()"/>
                <div id="themeContainer">
                    <xsl:if test="$theme != ''">
                        <xsl:attribute name="style">
                            <xsl:text>background:transparent url(</xsl:text>
                            <xsl:value-of select="$path.webapp"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="$theme"/>
                            <xsl:text>) no-repeat top;</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                </div>

                <!-- main content container -->
                <div id="container">

                    <!-- header area -->
                    <div id="headerContainer">
                        <xsl:apply-templates select="self::node()" mode="header">
                            <xsl:with-param name="core.result" select="$core.result"/>
                        </xsl:apply-templates>
                    </div>

                    <!-- bread crumb -->
                    <xsl:apply-templates
                        select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.site.map.MenuResult']"
                        mode="bread.crumb"/>

                    <!-- page sidebar -->
                    <div id="sidebarContainer">
                        <xsl:apply-templates select="self::node()" mode="sidebar">
                            <xsl:with-param name="action.result" select="$action.result"/>
                            <xsl:with-param name="core.result" select="$core.result"/>
                        </xsl:apply-templates>
                    </div>

                    <!-- content -->
                    <div id="contentContainer">
                        <xsl:apply-templates select="self::node()" mode="content">
                            <xsl:with-param name="action.result" select="$action.result"/>
                        </xsl:apply-templates>
                    </div>

                    <!-- page footer -->
                    <div id="footerContainer">
                        <xsl:apply-templates select="self::node()" mode="footer">
                            <xsl:with-param name="core.result" select="$core.result"/>
                        </xsl:apply-templates>
                    </div>

                </div>

                <!-- debug area [@see: debug.xsl] -->
                <xsl:apply-templates select="self::node()" mode="debug.area"/>

            </body>
        </html>
    </xsl:template>

    <!-- head -->
    <xsl:template match="result" mode="head">
        <!-- the current result of the bundle which executed the action -->
        <xsl:param name="action.result"/>
        <!-- the current result of the Core bundle (i.e. for retrieving commands) -->
        <xsl:param name="core.result"/>

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>main.xsl</xsl:comment>
        </xsl:if>

        <!-- title -->
        <title>
            <xsl:choose>

                <!-- title from content -->
                <xsl:when test="$action.result/controller/result/Content/title/text()!=''">
                    <xsl:value-of select="$action.result/controller/result/Content/title/text()"/>
                </xsl:when>

                <!-- default title -->
                <xsl:otherwise>Pulse demo layout</xsl:otherwise>

            </xsl:choose>
        </title>

        <!-- content meta information: keywords -->
        <xsl:if test="$action.result/controller/result/Content/meta-keywords/text()!=''">
            <meta name="keywords"
                content="{$action.result/controller/result/Content/meta-keywords/text()}"/>
        </xsl:if>

        <!-- content meta information: description -->
        <xsl:if test="$action.result/controller/result/Content/meta-description/text()!=''">
            <meta name="description"
                content="{$action.result/controller/result/Content/meta-description/text()}"/>
        </xsl:if>

        <!-- 
            include main stylesheet as settable via admistration 
            for demo-layout:
                - demo-layout.blue.css
                - demo-layout.grey.css
        -->
        <xsl:variable name="main.stylesheet">
            <xsl:choose>
                <xsl:when
                    test="$core.result/descendant::result[@class='org.torweg.pulse.component.core.site.StyleControllerResult']/styles/style[@active='true']">
                    <xsl:value-of
                        select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.site.StyleControllerResult']
                        /styles/style[@active='true']/@internalName"
                    />
                </xsl:when>
                <xsl:when
                    test="$core.result/descendant::result[@class='org.torweg.pulse.component.core.site.StyleControllerResult']
                    /styles/style[@default='true']">
                    <xsl:value-of
                        select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.site.StyleControllerResult']
                        /styles/style[@default='true']/@internalName"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>css/demo-layout.blue.css</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <link href="{$path.webapp}/{$main.stylesheet}" rel="stylesheet" type="text/css"/>

        <!-- include jquery (e.g. search, shop...) -->
        <script type="text/javascript" src="{$path.jquery}"/>

        <!-- ui utility scripts -->
        <script type="text/javascript" src="{$path.resources.components}/core/ui/ui.utility.js"/>

    </xsl:template>

    <!-- header -->
    <xsl:template match="result" mode="header">
        <!-- the current result of the Core bundle (i.e. for retrieving commands) -->
        <xsl:param name="core.result"/>
        <!-- switch locale URL-->
        <xsl:variable name="switch.locale.URL"
            select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.CommandGeneratorResult']/command[@name='findLocalization']/text()"/>

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>main.xsl</xsl:comment>
        </xsl:if>

        <!-- locale switch -->
        <xsl:if test="boolean($switch.locale.URL != '')">
            <form action="{$switch.locale.URL}" name="switchlocaleform"
                enctype="application/x-www-form-urlencoded" method="post">
                <select name="targetLocale" onchange="document.switchlocaleform.submit()">
                    <xsl:for-each select="meta-data/locales/locale">
                        <xsl:if test="@active='true'">
                            <option value="{text()}">
                                <xsl:if test="boolean(text()=$locale)">
                                    <xsl:attribute name="selected">
                                        <xsl:text>selected</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="text()"/>
                            </option>
                        </xsl:if>
                    </xsl:for-each>
                </select>
                <noscript>
                    <button type="submit">
                        <img src="{$path.resources.components}/core/demo-layout/arrow.right.png"
                            width="10" height="10" align="middle" alt="switch locale"/>
                    </button>
                </noscript>
            </form>
        </xsl:if>

        <!-- pulse demo logo -->
        <img src="{$path.resources.components}/core/demo-layout/logo.png" width="400" height="30"
            alt="Pulse Demo Layout" class="logo"/>

    </xsl:template>

    <!-- sidebar -->
    <xsl:template match="result" mode="sidebar">
        <!-- the current result of the bundle which executed the action -->
        <xsl:param name="action.result"/>
        <!-- the current result of the Core bundle (i.e. for retrieving commands) -->
        <xsl:param name="core.result"/>

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>main.xsl</xsl:comment>
        </xsl:if>

        <!-- search site -->
        <xsl:if test="boolean($core.result/descendant::command[@name='searchSite']/text())">
            <xsl:call-template name="site.search.box">
                <xsl:with-param name="search.URL"
                    select="$core.result/descendant::command[@name='searchSite']/text()"
                    tunnel="yes"/>
                <xsl:with-param name="search.advanced.URL"
                    select="$core.result/descendant::command[@name='initAdvancedSearch']/text()"
                    tunnel="yes"/>
            </xsl:call-template>
        </xsl:if>

        <!-- show filter content panel [if available] -->
        <xsl:if
            test="$action.result/descendant::result[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayerResult']">
            <xsl:apply-templates
                select="$action.result/descendant::result[@class='org.torweg.pulse.component.core.site.content.filter.FilterContentDisplayerResult']"
                mode="filter.panel"/>
        </xsl:if>

        <!-- main menu -->
        <xsl:apply-templates
            select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.site.map.MenuResult']"
            mode="tree.menu"/>

        <!-- shopping cart compact [if available] -->
        <xsl:if
            test="(//result[@class='org.torweg.pulse.component.shop.ShoppingCartResult']/descendant::position or meta-data/command/@bundle='Shop') 
            and not(meta-data/command[@action='executeCheckoutController'] or meta-data/command[@action='displayCart'])">
            <xsl:apply-templates
                select="//result[@class='org.torweg.pulse.component.shop.ShoppingCartResult']"
                mode="compact"/>
        </xsl:if>

        <!-- authentication -->
        <xsl:call-template name="login.box"/>

        <!-- pulse statistics pixel -->
        <xsl:if test="$pulse.stats = 'true'">
            <xsl:call-template name="pulse.statistics.pixel"/>
        </xsl:if>

    </xsl:template>

    <!-- content -->
    <xsl:template match="result" mode="content">
        <!-- the current result of the bundle which executed the action -->
        <xsl:param name="action.result"/>

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>main.xsl</xsl:comment>
        </xsl:if>

        <xsl:choose>

            <!-- 500: internal server error [@see: error-templates.xsl] -->
            <xsl:when test="meta-data/exceptions/exception">
                <xsl:apply-templates select="meta-data/exceptions" mode="internal-server-error"/>
            </xsl:when>

            <!-- 403: forbidden [@see: error-templates.xsl] -->
            <xsl:when
                test="meta-data/events/event[@class='org.torweg.pulse.service.event.ForbiddenEvent']">
                <xsl:apply-templates
                    select="meta-data/events/event[@class='org.torweg.pulse.service.event.ForbiddenEvent']"
                />
            </xsl:when>

            <!-- 404: not found [@see: error-templates.xsl] -->
            <xsl:when
                test="meta-data/events/event[@class='org.torweg.pulse.service.event.NotFoundEvent']">
                <xsl:apply-templates
                    select="meta-data/events/event[@class='org.torweg.pulse.service.event.NotFoundEvent']"
                />
            </xsl:when>

            <!-- the very new checkout screen -->
            <xsl:when test="$action.result/descendant::checkout2:checkout-controller-result">
                <xsl:apply-templates
                    select="$action.result/descendant::checkout2:checkout-controller-result"
                    mode="shop.main.xsl"/>
            </xsl:when>

            <!-- user self edit (i.e. change password if  user islogged in) -->
            <xsl:when
                test="$action.result/descendant::result[@class='org.torweg.pulse.component.core.accesscontrol.UserSelfEditControllerResult']">
                <xsl:apply-templates
                    select="$action.result/descendant::result[@class='org.torweg.pulse.component.core.accesscontrol.UserSelfEditControllerResult']"
                />
            </xsl:when>

            <!-- advanced search -->
            <xsl:when test="$action.result/descendant::core:advanced-search-result">
                <xsl:apply-templates select="$action.result/descendant::core:advanced-search-result"/>
            </xsl:when>

            <!-- display search results -->
            <xsl:when
                test="$action.result/descendant::result[@class='org.torweg.pulse.component.core.site.search.SearchSiteResult']">
                <xsl:apply-templates
                    select="$action.result/descendant::result[@class='org.torweg.pulse.component.core.site.search.SearchSiteResult']"
                />
            </xsl:when>

            <!-- display sign up / sign up reset password (recover password) -->
            <xsl:when
                test="$action.result/descendant::result[@class='org.torweg.pulse.component.core.accesscontrol.SignUpControllerResult']">
                <xsl:apply-templates
                    select="$action.result/descendant::result[@class='org.torweg.pulse.component.core.accesscontrol.SignUpControllerResult']"
                />
            </xsl:when>

            <!-- full sitemap -->
            <xsl:when
                test="$action.result/descendant::result[@class='org.torweg.pulse.component.core.site.map.GetFullSitemapResult']">
                <xsl:apply-templates
                    select="$action.result/descendant::result[@class='org.torweg.pulse.component.core.site.map.GetFullSitemapResult']"
                />
            </xsl:when>

            <!-- default processing of results of action result (i.e. display contents, ...) -->
            <xsl:otherwise>
                <xsl:apply-templates select="$action.result/descendant::result"/>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <!-- footer -->
    <xsl:template match="result" mode="footer">
        <!-- the current result of the bundle which executed the action -->
        <!--<xsl:param name="action.result"/>-->
        <!-- the current result of the Core bundle (i.e. for retrieving commands) -->
        <xsl:param name="core.result"/>
        <!-- get full sitemap URL -->
        <xsl:variable name="get.full.sitemapURL"
            select="$core.result/descendant::result[@class='org.torweg.pulse.component.core.CommandGeneratorResult']/command[@name='getFullSitemap']/text()"/>

        <!-- debug -->
        <xsl:if test="$debug.site='true'">
            <xsl:comment>main.xsl</xsl:comment>
        </xsl:if>

        <!-- full sitemap link -->
        <xsl:if test="boolean($get.full.sitemapURL != '')">
            <a href="{$get.full.sitemapURL}">
                <xsl:call-template name="core.babelfish">
                    <xsl:with-param name="id" tunnel="yes">
                        <xsl:text>sitemap</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </a>
        </xsl:if>

        <xsl:text>© :torweg free software group</xsl:text>
    </xsl:template>

    <!-- default template being applied if no other template matches -->
    <xsl:template match="command"/>
    <xsl:template match="image"/>
    <xsl:template match="menuitem"/> 


</xsl:stylesheet>
