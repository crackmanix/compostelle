<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:g="http://www.topografix.com/GPX/1/1">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- Dimensions du schéma SVG -->
  <xsl:variable name="W" select="320"/>
  <xsl:variable name="H" select="200"/>
  <xsl:variable name="M" select="12"/>

  <!-- Bornes lat/lon via tri (XSLT 1.0 n'a pas de min/max) -->
  <xsl:variable name="minLat">
    <xsl:for-each select="//g:trkpt">
      <xsl:sort select="@lat" data-type="number" order="ascending"/>
      <xsl:if test="position()=1"><xsl:value-of select="@lat"/></xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="maxLat">
    <xsl:for-each select="//g:trkpt">
      <xsl:sort select="@lat" data-type="number" order="descending"/>
      <xsl:if test="position()=1"><xsl:value-of select="@lat"/></xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="minLon">
    <xsl:for-each select="//g:trkpt">
      <xsl:sort select="@lon" data-type="number" order="ascending"/>
      <xsl:if test="position()=1"><xsl:value-of select="@lon"/></xsl:if>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="maxLon">
    <xsl:for-each select="//g:trkpt">
      <xsl:sort select="@lon" data-type="number" order="descending"/>
      <xsl:if test="position()=1"><xsl:value-of select="@lon"/></xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- Étendues, avec garde contre la division par zéro -->
  <xsl:variable name="dLat">
    <xsl:choose>
      <xsl:when test="$maxLat - $minLat &gt; 0.0001"><xsl:value-of select="$maxLat - $minLat"/></xsl:when>
      <xsl:otherwise>0.0001</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="dLon">
    <xsl:choose>
      <xsl:when test="$maxLon - $minLon &gt; 0.0001"><xsl:value-of select="$maxLon - $minLon"/></xsl:when>
      <xsl:otherwise>0.0001</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/g:gpx">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title><xsl:value-of select="g:metadata/g:name"/></title>
        <style>
          :root { --bg:#fff; --fg:#1a1a1a; --muted:#666; --accent:#d4a000; }
          @media (prefers-color-scheme: dark) {
            :root { --bg:#111; --fg:#eee; --muted:#999; }
          }
          body { font-family: system-ui, sans-serif; background:var(--bg); color:var(--fg);
                 margin:0 auto; padding:16px; max-width:480px; }
          h1 { font-size:1.4rem; margin:0 0 4px; }
          .muted { color:var(--muted); font-size:.9rem; }
          svg { width:100%; height:auto; margin:16px 0; }
          ul { list-style:none; padding:0; }
          li { padding:8px 0; border-bottom:1px solid var(--muted); }
          li small { display:block; color:var(--muted); }
        </style>
      </head>
      <body>
        <h1>🐚 <xsl:value-of select="g:metadata/g:name"/></h1>
        <div class="muted"><xsl:value-of select="g:metadata/g:desc"/></div>

        <svg viewBox="0 0 {$W} {$H}" role="img" aria-label="Tracé schématique">
          <polyline fill="none" stroke="#d4a000" stroke-width="3"
                    stroke-linecap="round" stroke-linejoin="round">
            <xsl:attribute name="points">
              <xsl:for-each select="g:trk/g:trkseg/g:trkpt">
                <xsl:value-of select="$M + (@lon - $minLon) div $dLon * ($W - 2*$M)"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$H - $M - (@lat - $minLat) div $dLat * ($H - 2*$M)"/>
                <xsl:text> </xsl:text>
              </xsl:for-each>
            </xsl:attribute>
          </polyline>
          <xsl:for-each select="g:wpt">
            <circle r="5" fill="currentColor">
              <xsl:attribute name="cx"><xsl:value-of select="$M + (@lon - $minLon) div $dLon * ($W - 2*$M)"/></xsl:attribute>
              <xsl:attribute name="cy"><xsl:value-of select="$H - $M - (@lat - $minLat) div $dLat * ($H - 2*$M)"/></xsl:attribute>
            </circle>
          </xsl:for-each>
        </svg>

        <ul>
          <xsl:for-each select="g:wpt">
            <li>
              <xsl:value-of select="g:name"/>
              <small><xsl:value-of select="g:desc"/></small>
            </li>
          </xsl:for-each>
        </ul>

        <div class="muted">
          Début : <xsl:value-of select="substring(g:trk/g:trkseg/g:trkpt[1]/g:time, 1, 10)"/>
          · <xsl:value-of select="count(g:trk/g:trkseg/g:trkpt)"/> points
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
