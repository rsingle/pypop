<xsl:stylesheet 
 version='1.0'
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:data="any-uri">

 <xsl:import href="lib.xsl"/>

 <xsl:import href="hardyweinberg.xsl"/>
 <xsl:import href="homozygosity.xsl"/>
 <xsl:import href="emhaplofreq.xsl"/>

 <!-- lookup table to translate population metadata XML tag names back
 to human-readable output -->
 <data:pop-col-headers>
  <text col="popname">Population Name</text>
  <text col="labcode">Lab code</text>
  <text col="method">Typing method</text>
  <text col="ethnic">Ethnicity</text>
  <text col="contin">Continent</text>
  <text col="collect">Collection site</text>
  <text col="latit">Latitude</text>
  <text col="longit">Longitude</text>
 </data:pop-col-headers>

 <xsl:param name="hardyweinberg-col-width" select="12"/>
 <xsl:param name="hardyweinberg-first-col-width"
 select="$hardyweinberg-col-width + 6"/>

 <xsl:param name="page-width" select="80"/>

 <xsl:template match="/">
  <xsl:apply-templates/> 
 </xsl:template>
 
 <!-- suppress output of random text -->
 <xsl:template match="text()">
  <!--  <xsl:value-of select="."/>  -->
 </xsl:template>
 
 <!-- BEGIN NAMED TEMPLATE FUNCTIONS -->

 <xsl:template name="get-significance">
  <xsl:param name="pvalue"/>
  <xsl:choose>
   <xsl:when test="$pvalue &lt;= 0.00001">5</xsl:when>
   <xsl:when test="$pvalue &lt;= 0.0001">4</xsl:when>
   <xsl:when test="$pvalue &lt;= 0.001">3</xsl:when>
   <xsl:when test="$pvalue &lt;= 0.01">2</xsl:when>
   <xsl:when test="$pvalue &lt;= 0.05">1</xsl:when>
   <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>

 </xsl:template>

 <!-- get significance for two-tailed test -->
 <xsl:template name="get-significance-two-tailed">
  <xsl:param name="lower"/>
  <xsl:param name="upper"/>

   <!-- 
   a two tailed test implies testing both end of distribution:

   5%:    0.005 < p <= 0.025 OR 0.975 <= p < 0.995        (*)
   1%:    0.0005 < p <= 0.005 OR 0.995 <= p < 0.9995      (**)
   0.1%:  0.00005 < p <= 0.0005 OR 0.9995 <= p < 0.99995  (***)
   0.01%: p <= 0.00005 OR p >= 0.99995                    (****)
   -->

  <xsl:choose>

  <xsl:when test="($upper &lt;= 0.00005) or ($lower &gt;= 0.99995)">4</xsl:when>
   <xsl:when test="($upper &lt;= 0.0005) or ($lower &gt;= 0.9995)">3</xsl:when>

   <xsl:when test="($upper &lt;= 0.005) or ($lower &gt;= 0.995)">2</xsl:when>

   <xsl:when test="($upper &lt;= 0.025) or ($lower &gt;= 0.975)">1</xsl:when>

<!-- more strict test, that assumes we have an exact value, rather 
     a than range

  <xsl:when test="($upper &lt;= 0.00005)
    or ($lower &gt;= 0.99995)">4</xsl:when>

   <xsl:when test="($upper &lt;= 0.0005 and $lower &gt; 0.00005)
    or ($upper &lt;= 0.99995 and $lower &gt; 0.9995)">3</xsl:when>
   <xsl:when test="($upper &lt;= 0.005 and $lower &gt; 0.0005)
    or ($upper &lt;= 0.9995 and $lower &gt; 0.995)">2</xsl:when>

   <xsl:when test="($upper &lt;= 0.025 and $lower &gt; 0.005)
    or ($upper &lt;= 0.995 and $lower &gt; 0.975)">1</xsl:when>
-->
 
   <xsl:otherwise>0</xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- formats a header: a "title" underlined with equals-signs (`=') -->
 <xsl:template name="header">
  <xsl:param name="title"/>
  <xsl:param name="underline" select="'='"/>

  <xsl:value-of select="$title"/>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="append-pad">
   <xsl:with-param name="padChar" select="$underline"/>
   <xsl:with-param name="length" select="string-length($title)"/>
  </xsl:call-template>
  <xsl:call-template name="newline">
  </xsl:call-template>
 </xsl:template>

 <!-- formats a "locus" header, given a title and then gets the -->
 <!-- locus name from the "name" attribute in the parent context node -->
 <xsl:template name="locus-header">
  <xsl:param name="title"/>
  <xsl:value-of select="count(preceding::locus) + 1"/><xsl:text>.</xsl:text>
  <xsl:value-of select="position()"/><xsl:text>. </xsl:text>
  <xsl:value-of select="$title"/><xsl:text> [</xsl:text><xsl:value-of select="../@name"/><xsl:text>]</xsl:text>
 </xsl:template>

 <!-- generates section (title w/ spacing designed to be overriden -->
 <xsl:template name="section">
  <xsl:param name="level"/>
  <xsl:param name="title"/>
  <xsl:param name="text"/>
  <xsl:param name="number"/>

  <xsl:variable name="underline">
   <xsl:choose>
    <xsl:when test="$level=1">=</xsl:when>
    <xsl:when test="$level=2">_</xsl:when>
    <xsl:otherwise>-</xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="newline"/>

  <xsl:call-template name="header">
   <xsl:with-param name="title">
    <xsl:if test="$number">
     <xsl:value-of select="$number"/>
     <xsl:text>. </xsl:text>
    </xsl:if>
    <xsl:value-of select="$title"/>
   </xsl:with-param>
   <xsl:with-param name="underline" select="$underline"/>
  </xsl:call-template>
  
  <xsl:if test="$text!=''">
   <!-- <xsl:call-template name="newline"/>  -->
   <xsl:copy-of select="$text"/>
   <xsl:call-template name="newline"/> 
  </xsl:if>

 </xsl:template>

 <!-- formats a list of nodes which are fields in name: value format
 separated by newlines -->
 <xsl:template name="linesep-fields">
  <xsl:param name="nodes" select="*"/>
  <xsl:for-each select="$nodes">
   <xsl:text></xsl:text>
   <xsl:value-of select="name(.)"/>
   <xsl:text>: </xsl:text>

   <xsl:choose>
    <xsl:when test="name(.)='pvalue'">
     <xsl:apply-templates select="."/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="."/> 
    </xsl:otherwise>
   </xsl:choose>

 
  <!-- if field has any attribute, print them out in brackets
   separated by commas -->
   
   <xsl:if test="@*!=''">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="@*">
     <xsl:value-of select="."/>
     <xsl:if test="position()!=last()">
      <xsl:text>, </xsl:text>
     </xsl:if>
     </xsl:for-each>
    <xsl:text>)</xsl:text>
   </xsl:if>
   
   <xsl:call-template name="newline"/>

  </xsl:for-each>
 </xsl:template> 

 <!-- END NAMED TEMPLATE FUNCTIONS -->
 
 <!-- BEGIN MATCH TEMPLATE FUNCTIONS -->
 

 <!-- ####################  METADATA OUTPUT ###################### -->  

 <!-- TOP-LEVEL XML ELEMENT -->

 <xsl:template match="dataanalysis">
  <xsl:text>Results of data analysis</xsl:text>
  <xsl:call-template name="newline" />
  <xsl:text>Performed on the '</xsl:text><xsl:value-of select="filename"/><xsl:text>' file at: </xsl:text><xsl:value-of select="@date"/>
  <xsl:call-template name="newline"/>
  <xsl:call-template name="newline"/>

 <!-- ####################  END METADATA OUTPUT ###################### -->  

 <!-- ####################  POPULATION OUTPUT ######################## -->  
  
  <!-- print out population-level statistics and information -->
  <xsl:apply-templates select="filename|populationdata"/>

  <xsl:call-template name="section">
   <xsl:with-param name="title">Legend for all analyses</xsl:with-param>
   <xsl:with-param name="level" select="2"/>
   <xsl:with-param name="text">
    * = significant at the 5% level
   ** = significant at the 1% level
  *** = significant at the 0.1% level
 **** = significant at the 0.01% level
***** = significant at the 0.001% level
   </xsl:with-param>
  </xsl:call-template>

  <xsl:call-template name="section">
   <xsl:with-param name="title">Single Locus Analyses</xsl:with-param>
   <xsl:with-param name="level" select="1"/>
   <xsl:with-param name="number" select="'I'"/>
   <xsl:with-param name="text">

    <!-- loop through each locus in turn -->
    <xsl:for-each select="locus">
     
     <!-- print each locus name -->
     <xsl:call-template name="section">
      <xsl:with-param name="title">Locus: <xsl:value-of select="@name"/></xsl:with-param>
      <xsl:with-param name="level" select="2"/>
      <xsl:with-param name="number" select="position()"/>
      <xsl:with-param name="text">
       <xsl:choose>
	<!-- if allele data is present output the subnodes -->
	<xsl:when test="allelecounts/@role!='no-data'">
	 <xsl:apply-templates select="*"/>
	</xsl:when>
	<!-- if no allele data is present supress processing and print message -->
	<xsl:otherwise>
	 <xsl:text> No data for this locus!</xsl:text>
	</xsl:otherwise>
       </xsl:choose>
       
      </xsl:with-param>
     </xsl:call-template>
    </xsl:for-each>

   </xsl:with-param>
  </xsl:call-template>

  <!-- Print out multi-locus population-levels stats, such as --> 
  <!-- estimation of haplotypes and LD -->
  
  <xsl:call-template name="section">
   <xsl:with-param name="title">Multi-locus Analyses</xsl:with-param>
   <xsl:with-param name="level" select="1"/>
   <xsl:with-param name="number" select="'II'"/>
   <xsl:with-param name="text">
    <xsl:apply-templates select="emhaplofreq"/>
   </xsl:with-param>
  </xsl:call-template>

 </xsl:template>
 
 <!-- leave filename blank, this is output in a different context  -->
 <xsl:template match="filename"/>
 
 <!-- metadata `header' block -->
 <xsl:template match="populationdata">
  <xsl:call-template name="section">
   <xsl:with-param name="title">Population Summary</xsl:with-param>
   <xsl:with-param name="level" select="1"/>
   <xsl:with-param name="text">

    <!-- specify order of metadata field output -->
    <!-- ensure that popname is generated *first* -->

    <xsl:apply-templates select="popname"/>
    <xsl:apply-templates select="*[not(self::popname)]"/>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <!-- pre-calculate the maximum length of the metadata text
 length to use in padding for the population summary -->
 <xsl:param name="metadata-max-len">
  <xsl:call-template name="max-string-len">
   <xsl:with-param name="path" 
    select="document('')//data:pop-col-headers/text"/>
  </xsl:call-template>
 </xsl:param>

 <xsl:template match="popname|longit|latit|ethnic|collect|method|contin|labcode">
  <!-- store the current node name for the lookup-table -->
  <xsl:variable name="node-name" select="name(.)"/>

  <!-- use the lookup-table to get the verbose (human-readable)
  version of the metadata element -->
  <xsl:call-template name="prepend-pad">
   <xsl:with-param name="padVar">
    <xsl:value-of 
     select="document('')//data:pop-col-headers/text[@col=$node-name]"/>  
   </xsl:with-param>
   <xsl:with-param name="length" select="$metadata-max-len"/>
  </xsl:call-template>
  <xsl:text>: </xsl:text>
  <xsl:value-of select="."/>
  <xsl:call-template name="newline"/>
 </xsl:template>
 
 <!-- metadata totals -->
 <xsl:template match="populationdata/totals">
  <xsl:call-template name="section">
   <xsl:with-param name="title">Population Totals</xsl:with-param>
   <xsl:with-param name="level" select="2"/>
   <xsl:with-param name="text">
    <xsl:apply-templates/>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>
 
 <!-- these next 3 templates print out the same data which can be used
 in different contexts: both for population-level stats and individual
 loci -->

 <xsl:template match="indivcount">
  <xsl:text>Sample Size (n): </xsl:text>
  <xsl:value-of select="."/>
  <xsl:call-template name="newline"/>
 </xsl:template>
 
 <xsl:template match="allelecount">
  <xsl:text>Allele Count (2n): </xsl:text>
  <xsl:value-of select="."/>
  <xsl:call-template name="newline"/>
 </xsl:template>
 
 <xsl:template match="locuscount">
  <xsl:text>Total loci in file: </xsl:text>
  <xsl:value-of select="."/>
  <xsl:text> [</xsl:text>
  <xsl:for-each select="/dataanalysis/locus/@name">
   <xsl:value-of select="."/>
   <xsl:if test="position()!=last()">
    <xsl:text>, </xsl:text>
   </xsl:if>
  </xsl:for-each>
  <xsl:text>]</xsl:text>

  <xsl:call-template name="newline"/>
 </xsl:template>

 <xsl:template match="lociWithDataCount">
  <xsl:text>Total loci with data: </xsl:text>
  <xsl:value-of select="."/>
  <xsl:text> [</xsl:text>
  <xsl:for-each select="/dataanalysis/locus[allelecounts/@role!='no-data']/@name">
   <xsl:value-of select="."/>
   <xsl:if test="position()!=last()">
    <xsl:text>, </xsl:text>
   </xsl:if>
  </xsl:for-each>
  <xsl:text>]</xsl:text>
  <xsl:call-template name="newline"/>
 </xsl:template>

 <xsl:template match="untypedindividuals">
  <xsl:text>Untyped individuals: </xsl:text>
  <xsl:value-of select="."/>
  <xsl:call-template name="newline"/>
 </xsl:template>

 <xsl:template match="distinctalleles">
  <xsl:text>Distinct alleles (k): </xsl:text>
  <xsl:value-of select="."/>
  <xsl:call-template name="newline"/>
 </xsl:template>

 <!-- ####################  END POPULATION OUTPUT ##################### -->  

 <!-- #################  ALLELE COUNT STATISTICS ###################### --> 
 
 <xsl:template match="allelecounts">
  <xsl:call-template name="section">
   <xsl:with-param name="title">
    <xsl:call-template name="locus-header">
     <xsl:with-param name="title">Allele Counts</xsl:with-param>
    </xsl:call-template>
   </xsl:with-param>
   <xsl:with-param name="level" select="3"/>
   <xsl:with-param name="text">

    <xsl:choose>
     
     <!-- if there's no data, don't do anything -->
     <xsl:when test="@role='no-data'">
      <xsl:text>No allele data!</xsl:text>
      <xsl:call-template name="newline"/>
   </xsl:when>
     
     <xsl:otherwise>
      
      <!-- do all the non-allelecount templates -->
      <xsl:apply-templates select="*[not(self::allele)]"/>
      
      <xsl:call-template name="newline"/>

      <!-- save header as a string to go at end of both tables -->
      <xsl:variable name="header-as-string">
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="'Name'"/>
	<xsl:with-param name="length">10</xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="'Frequency'"/>
	<xsl:with-param name="length">10</xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="'(Count)'"/>
	<xsl:with-param name="length">10</xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="newline"/>
      </xsl:variable>

      <!-- save the totals as a string to go at end of both tables -->
      <xsl:variable name="totals-as-string">
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar">Total</xsl:with-param>
	<xsl:with-param name="length" select="10"/>
       </xsl:call-template>
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="totalfrequency"/>
	<xsl:with-param name="length" select="10"/>
       </xsl:call-template>
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="totalcount"/>
	<xsl:with-param name="length" select="10"/>
       </xsl:call-template>
       <xsl:call-template name="newline"/>
      </xsl:variable>

      <!-- create the allele count outputs in strings -->
      
      <!-- hold allele counts ordered by frequency in string -->
      <xsl:variable name="allelecounts-by-frequency">
       
       <!-- create a header for table -->
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="'Counts ordered by frequency'"/>
	<xsl:with-param name="length">30</xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="newline"/>
       
       <xsl:value-of select="$header-as-string"/>
       
       <!-- loop through each allele by count/frequency -->
       <xsl:for-each select="allele">
	<xsl:sort select="count" data-type="number" order="descending"/>
	<xsl:for-each select="frequency|count|@name">
	 <xsl:call-template name="append-pad">
	  <xsl:with-param name="padVar" select="."/>
	  <xsl:with-param name="length">10</xsl:with-param>
	 </xsl:call-template>
	</xsl:for-each>
	<xsl:call-template name="newline"/>
       </xsl:for-each>

       <!-- print out the totals at end of table -->
       <xsl:value-of select="$totals-as-string"/>
      </xsl:variable>      
       
      
      <!-- hold allele counts ordered by name in string -->
      <xsl:variable name="allelecounts-by-name">
       
       <!-- create a header for table -->
       <xsl:call-template name="append-pad">
	<xsl:with-param name="padVar" select="'Counts ordered by name'"/>
	<xsl:with-param name="length">30</xsl:with-param>
       </xsl:call-template>
       
       <xsl:call-template name="newline"/>

       <xsl:value-of select="$header-as-string"/>
       
       <!-- loop through each allele by name-->
       <xsl:for-each select="allele">
	<xsl:sort select="@name" data-type="text" order="ascending"/>
	<xsl:for-each select="frequency|count|@name">
	 <xsl:call-template name="append-pad">
	  <xsl:with-param name="padVar" select="."/>
	  <xsl:with-param name="length">10</xsl:with-param>
	 </xsl:call-template>
	</xsl:for-each>
	<xsl:call-template name="newline"/>
       </xsl:for-each>

       <!-- print out the totals at end of table -->
       <xsl:value-of select="$totals-as-string"/>

      </xsl:variable>
      
      <!-- paste the allelecounts ordered by frequency and name side-by-side -->
      <xsl:call-template name="paste-columns">
       <xsl:with-param name="col1" select="$allelecounts-by-frequency"/>
       <xsl:with-param name="col2" select="$allelecounts-by-name"/>
       <xsl:with-param name="delim" select="'| '"/>
      </xsl:call-template>
      
     </xsl:otherwise>
    </xsl:choose>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <!-- ############### END ALLELE COUNT STATISTICS ###################### --> 

 <!-- standard pvalue output, common to other modules -->
 <xsl:template match="pvalue" name="pvalue-func">
  <xsl:param name="val" select="."/>
  <!-- default to one-tailed test -->
  <xsl:param name="type" select="'one-tailed'"/>

  <!-- round to 4 decimal places -->
  <xsl:call-template name="round-to">
   <xsl:with-param name="node" select="$val"/>
   <xsl:with-param name="places" select="4"/>
  </xsl:call-template>

  <xsl:call-template name="append-pad">
   <xsl:with-param name="padChar">*</xsl:with-param>
   <xsl:with-param name="length">
    <xsl:choose>
     <xsl:when test="$type='two-tailed'">
      <xsl:call-template name="get-significance-two-tailed">
       <xsl:with-param name="lower" select="$val"/>
       <xsl:with-param name="upper" select="$val"/>
      </xsl:call-template>
     </xsl:when>
     <xsl:otherwise>
      <xsl:call-template name="get-significance">
       <xsl:with-param name="pvalue" select="$val"/>
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <xsl:template match="pvalue" mode="bounded" name="pvalue-bounded-func">
  <xsl:param name="lower" select="lower"/>
  <xsl:param name="upper" select="upper"/>

  <xsl:value-of select="$lower"/><xsl:text disable-output-escaping="yes"> &lt; p &lt;= </xsl:text><xsl:value-of select="$upper"/>
  <xsl:text> </xsl:text> 

  <xsl:call-template name="append-pad">
   <xsl:with-param name="padChar">*</xsl:with-param>
   <xsl:with-param name="length">
    <xsl:call-template name="get-significance-two-tailed">
     <xsl:with-param name="lower" select="$lower"/>
     <xsl:with-param name="upper" select="$upper"/>
    </xsl:call-template>
   </xsl:with-param>
  </xsl:call-template>

  </xsl:template>

 <!-- END MATCH TEMPLATE FUNCTIONS -->
 
</xsl:stylesheet>

<!-- 
Local variables:
mode: xml
sgml-default-dtd-file: "xsl.ced"
sgml-indent-step: 1
sgml-indent-data: 1
End:
-->
