<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html" indent="yes"/>

    <!-- Template for the root element -->
    <xsl:template match="/data">
        <html>
            <head>
                <title><xsl:value-of select="congress/name"/></title>
            </head>
            <body>
                <h1 align="center"><xsl:value-of select="congress/name"/></h1>
                <h3 align="center">
                    From <xsl:value-of select="congress/period/@from"/> to <xsl:value-of select="congress/period/@to"/>
                </h3>
                <hr/>
                <xsl:for-each select="congress/chambers/chamber">
                    <h2 align="center"><xsl:value-of select="name"/></h2>
                    <h4 align="center">Members</h4>
                    <table border="1" frame="1" align="center">
                        <thead bgcolor="grey">
                            <tr>
                                <th>Image</th>
                                <th>Name</th>
                                <th>State</th>
                                <th>Party</th>
                                <th>Period</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="members/member">
                                <tr>
                                    <td>
                                        <img height="50" width="50" crossorigin="anonymous" src="{normalize-space(image_url)}"/>
                                    </td>
                                    <td><xsl:value-of select="name"/></td>
                                    <td><xsl:value-of select="state"/></td>
                                    <td><xsl:value-of select="party"/></td>
                                    <td><xsl:value-of select="period/@from"/> to <xsl:value-of select="period/@to"/></td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                    <h4 align="center">Sessions</h4>
                    <table border="1" frame="1" align="center">
                        <thead bgcolor="grey">
                            <tr>
                                <th>Session Number</th>
                                <th>Session Type</th>
                                <th>Session Period</th>
                            </tr>
                        </thead>
                        <tbody>
                            <xsl:for-each select="sessions/session">
                                <tr>
                                    <td><xsl:value-of select="number"/></td>
                                    <td><xsl:value-of select="type"/></td>
                                    <td><xsl:value-of select="period/@from"/> to <xsl:value-of select="period/@to"/></td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>