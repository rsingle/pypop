<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet PUBLIC "-//Thomson Lab//DTD Unofficial XSL//EN"  
                         "xsl.dtd">  
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

 <xsl:import href="http://db2latex.sourceforge.net/docbook.xsl"/>

 <xsl:output method="text" encoding="ISO-8859-1" indent="yes"/>

 <!-- set default language to English (en) -->
 <xsl:param name="l10n.gentext.language" select="'en'"/>

 <!-- standard one col article -->
 <xsl:variable name="latex.standard.1col">
% -------------------------------------------- 
% Autogenerated LaTeX file for articles        
% -------------------------------------------- 
\ifx\pdfoutput\undefined 
\documentclass[spanish,french,english,letter,10pt,twoside]{article} 
\else
\documentclass[pdftex, spanish,french,english,letter,10pt,twoside]{article}
\fi
\usepackage{amsmath,amsthm, amsfonts, amssymb, amsxtra,amsopn}
\usepackage{graphicx}
\usepackage{float}
\usepackage{algorithmic}
\usepackage[dvips]{hyperref}
 </xsl:variable>

 <!-- "World Scientific" style -->
 <xsl:variable name="latex.world-scientific">
% --------------------------------------------  
% Autogenerated LaTeX  using ws-p8-50x6-00.cls 
% --------------------------------------------  
\ifx\pdfoutput\undefined
\documentclass{ws-p8-50x6-00}       
\else
\documentclass[pdftex]{ws-p8-50x6-00}       
\fi
\usepackage{amsmath,amsthm,amsfonts,amssymb,amsxtra,amsopn}
\usepackage{graphicx}
%\usepackage{epsfig}
\usepackage{float}
\usepackage{algorithmic}
%\usepackage[dvips]{hyperref}
%\DeclareGraphicsExtensions{.eps}
 </xsl:variable>

 <xsl:variable name="latex.mapping.xml" select="document('ws.latex.mapping.xml')"/>

 <xsl:variable name="latex.biblio.output">cited</xsl:variable>
 <xsl:variable name="latex.dont.label">1</xsl:variable>
 <xsl:variable name="latex.dont.hypertarget">1</xsl:variable>
 <xsl:variable name="latex.use.hyperref">0</xsl:variable>

 <xsl:variable name="latex.override">
  <xsl:value-of select="$latex.world-scientific"/> 
 </xsl:variable>

 <xsl:template match="ulink">
  <xsl:variable name="url">
   <xsl:text>{\tt </xsl:text>   
   <xsl:value-of select="@url"/> 
   <xsl:text>}</xsl:text>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test=".!=@url">
    <xsl:apply-templates mode="slash.hyphen"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="$url"/>
    <xsl:text>)</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$url"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- ARTICLE TEMPLATE -->
 <xsl:template match="article">
  <!-- Output LaTeX preamble -->
  <xsl:call-template name="generate.latex.article.preamble"/>
  <!-- Get and output article title -->
  <xsl:variable name="article.title">
   <xsl:choose>
    <xsl:when test="./title"> <xsl:value-of select="./title"/> </xsl:when>
    <xsl:when test="./articleinfo/title"> <xsl:value-of select="./articleinfo/title"/> </xsl:when>
    <xsl:otherwise> <xsl:value-of select="./artheader/title"/> </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:text>\title{</xsl:text>
  <xsl:call-template name="normalize-scape"> 
   <xsl:with-param name="string" select="$article.title"/>
  </xsl:call-template>
  <xsl:text>}&#10;</xsl:text>

  <xsl:choose>
   <xsl:when test="artheader/author">		
    <xsl:apply-templates select="artheader/author"/>	
   </xsl:when>
   <xsl:when test="artheader/authorgroup">	
    <xsl:apply-templates select="artheader/authorgroup"/>	
   </xsl:when>
   <xsl:when test="articleinfo/author">	
    <xsl:apply-templates select="articleinfo/author"/>	
   </xsl:when>
   <xsl:when test="articleinfo/authorgroup">	
    <xsl:apply-templates select="articleinfo/authorgroup"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates select="author"/>
   </xsl:otherwise>
  </xsl:choose>

  <!-- Display  begindocument command -->
  <xsl:value-of select="$latex.article.begindocument"/>
  <xsl:value-of select="$latex.article.maketitle"/>
  <xsl:apply-templates/>
  <xsl:value-of select="$latex.article.end"/>
 </xsl:template>

 <xsl:template match="authorgroup">

  <xsl:variable name="uniq-affil" select="author[not(@role=preceding-sibling::author/@role)]/@role"/>

  <xsl:variable name="allauthors" select="author"/>

  <xsl:for-each select="$uniq-affil">
   <xsl:variable name="curr" select="."/>

   <xsl:text>\author{</xsl:text>
   <xsl:apply-templates select="$allauthors[@role=$curr]"
    mode="authorgroup"/>
   <xsl:text>}&#10;</xsl:text>

   <xsl:apply-templates select="$allauthors[@role=$curr]/affiliation"/>
   
  </xsl:for-each>

 </xsl:template>

 <xsl:template match="author" mode="authorgroup">

  <xsl:choose>
    <xsl:when test="position()=last() and position()!=1">
    <xsl:text> and </xsl:text>
   </xsl:when>
   <xsl:when test="position()!=1">
    <xsl:text>, </xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text></xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <!-- Display author information --> 
  <xsl:value-of select="firstname"/>
  <xsl:text> </xsl:text>
  <xsl:if test="othername">
   <xsl:value-of select="othername"/>
   <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:value-of select="surname"/>

 </xsl:template>

 <xsl:template match="author">
  <xsl:text>\author{</xsl:text>
  <!-- Display author information --> 
  <xsl:value-of select="firstname"/>
  <xsl:text> </xsl:text>
  <xsl:if test="othername">
   <xsl:value-of select="othername"/>
   <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:value-of select="surname"/>
  <xsl:text>}&#10;</xsl:text>
  
  <xsl:apply-templates select="affiliation"/>

 </xsl:template>

 <xsl:template match="affiliation">
   <xsl:text>\address{</xsl:text>

  <xsl:for-each select="*[not(self::address)]">
   <xsl:if test="position()!=1">
    <xsl:text>, </xsl:text>
   </xsl:if>
   <xsl:value-of select="."/>
  </xsl:for-each>

  <xsl:if test="address">
   <xsl:text>, </xsl:text>
   <xsl:apply-templates select="address" mode="header"/>
  </xsl:if>
  <xsl:text>}&#10;</xsl:text>
 </xsl:template>

 <xsl:template match="address" mode="header">
  <xsl:for-each select="*[not(self::email)]">
   <xsl:if test="position()!=1">
    <xsl:text>, </xsl:text>
   </xsl:if>
   <xsl:value-of select="."/>
  </xsl:for-each>

  <xsl:if test="email">
   <xsl:apply-templates select="email" mode="header"/>
  </xsl:if>

 </xsl:template>

 <xsl:template match="email" mode="header">
  <xsl:call-template name="map.begin"/>
  <xsl:value-of select="."/>
  <xsl:call-template name="map.end"/>
 </xsl:template>

 <xsl:template name="biblioentry.output">
  
  <xsl:variable name="biblioentry.tag.label">
   <xsl:choose>
   <xsl:when test="$latex.dont.label!=1">
    <xsl:text>[</xsl:text>
    <xsl:choose>
     <xsl:when test="@xreflabel">
      <xsl:value-of select="normalize-space(@xreflabel)"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>UNKNOWN</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]</xsl:text>
   </xsl:when>
    <xsl:otherwise><xsl:text></xsl:text></xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="biblioentry.tag.id">
   <xsl:text>{</xsl:text>
   <xsl:choose>
    <xsl:when test="abbrev">
     <xsl:apply-templates select="abbrev" mode="bibliography.mode"/>
    </xsl:when>
    <xsl:when test="@id">
     <xsl:value-of select="normalize-space(@id)"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>UNKNOWN</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:text>}</xsl:text>
  </xsl:variable>
  
  <xsl:text>&#10;</xsl:text>
  <xsl:text>% -------------- biblioentry &#10;</xsl:text>
  <xsl:text>\bibitem</xsl:text><xsl:value-of select="$biblioentry.tag.label"/><xsl:value-of select="$biblioentry.tag.id"/>

  <xsl:if test="author|authorgroup">
   <xsl:apply-templates select="author|authorgroup" mode="bibliography.mode"/>
   <xsl:value-of select="$biblioentry.item.separator"/>
  </xsl:if>

  <xsl:if test="pubdate">
   <xsl:apply-templates select="pubdate" mode="bibliography.mode"/> 
   <xsl:value-of select="$biblioentry.item.separator"/>
  </xsl:if>

  <xsl:apply-templates select="citetitle[@pubwork='refentry']" mode="bibliography.mode"/>  

  <xsl:apply-templates select="citetitle[@pubwork='article']" mode="bibliography.mode"/>
  
  <xsl:apply-templates select="citetitle[@pubwork='journal']" mode="bibliography.mode"/>
  
  <xsl:for-each select="copyright|publisher|isbn">
   <xsl:value-of select="$biblioentry.item.separator"/>
   <xsl:apply-templates select="." mode="bibliography.mode"/> 
  </xsl:for-each>
  <xsl:text>. </xsl:text>
  
  <xsl:call-template name="label.id"/> 
  <xsl:text>&#10;&#10;</xsl:text>

 </xsl:template>

 <xsl:template match="citetitle" mode="bibliography.mode">
<!--  <xsl:value-of select="$biblioentry.item.separator"/> -->
  <xsl:choose>
   <xsl:when test="@pubwork='journal'">
    <xsl:text> {\em </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>} {\bf </xsl:text>
    <xsl:value-of select="../volumenum"/>
    <xsl:text>}, </xsl:text>
    <xsl:value-of select="../issuenum"/>
    <xsl:text> (</xsl:text>
    <xsl:value-of select="../pagenums"/>
    <xsl:text>)</xsl:text>
   </xsl:when>
   <xsl:when test="@pubwork='article'">
    <xsl:call-template name="gentext.nestedstartquote"/>
    <xsl:apply-templates/>
    <xsl:call-template name="gentext.nestedendquote"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:apply-templates/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
 
 <xsl:template match="figure[programlisting]">
  <xsl:call-template name="map.begin"/>
  <xsl:apply-templates />
  <xsl:call-template name="map.end"/>
 </xsl:template>
 
 <xsl:template match="programlisting">
  <xsl:text>\begin{scriptsize}&#10;</xsl:text>
  <xsl:text>\begin{verbatim}&#10;</xsl:text>
  <xsl:apply-templates mode="latex.programlisting"/>
  <xsl:text>\end{verbatim}&#10;</xsl:text>
  <xsl:text>\end{scriptsize}&#10;</xsl:text>
 </xsl:template>

 <xsl:template match="ackno">
  <xsl:call-template name="map.begin"/>
  <xsl:apply-templates/>
  <xsl:call-template name="map.end"/>
 </xsl:template>


 <xsl:template match="citation">
  <!-- todo: biblio-citation-check -->
  <xsl:text>~\cite{</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>}</xsl:text>
 </xsl:template>
 
 <xsl:template match="biblioentry" mode="bibliography.cited">
  <xsl:param name="bibid" select="@id"/>
  <xsl:param name="ab" select="abbrev"/>
  <xsl:variable name="nx" select="//xref[@linkend=$bibid]"/>
  <xsl:variable name="nc" select="//citation[text()=$ab]"/>
  <xsl:variable name="ni" select="//citation[text()=$bibid]"/>
  <xsl:if test="count($nx) &gt; 0 or count($nc) &gt; 0 or count($ni) &gt; 0">
   <xsl:call-template name="biblioentry.output"/>
  </xsl:if>
 </xsl:template>
 
 <xsl:template match="application">
  <xsl:call-template name="map.begin"/>
  <xsl:apply-templates />
  <xsl:call-template name="map.end"/>
 </xsl:template>

 <!-- override these templates, because default ones put extra whitespace
 where we don't want it in the output and where it is significant to LaTeX -->

 <xsl:template name="inline.italicseq">
  <xsl:param name="content"> <xsl:apply-templates/> </xsl:param>
  <xsl:text>{\em </xsl:text>
  <xsl:copy-of select="$content"/> <xsl:text>}</xsl:text>
 </xsl:template>

 <xsl:template name="number.xref">
  <xsl:text> \ref{</xsl:text><xsl:value-of
   select="@id"/><xsl:text>}</xsl:text>
 </xsl:template>

</xsl:stylesheet>

<!--
Local variables:
sgml-local-catalogs: ("catalog")
sgml-default-dtd-file: "../../src/xslt/xsl.ced"
End:
-->
