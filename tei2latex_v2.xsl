<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:tex="placeholder.uri"
  exclude-result-prefixes="tex">

  <xsl:output method="text"/>

  <!-- ============================================================
       TEI XML → LaTeX (reledmac)
       Based on original script by Marjorie Burghart (2017)
       Refactored and extended
       ============================================================ -->


  <!-- ============================================================
       PARAMETERS
       ============================================================ -->

  <!-- Apparatus labels -->
  <xsl:param name="varOm">om.</xsl:param>
  <xsl:param name="varAdd">add.</xsl:param>
  <xsl:param name="varDel">del.</xsl:param>
  <xsl:param name="varAc">a.c.</xsl:param>
  <xsl:param name="varPc">p.c.</xsl:param>

  <!-- Shorten lemma in footnote if longer than N words (0 = no shortening) -->
  <xsl:param name="shortenLem">15</xsl:param>

  <!-- Lemma separator (leave empty for default) -->
  <xsl:param name="lemSep"/>

  <!-- Display tei:quote in italics? 1 = yes -->
  <xsl:param name="italQuote">0</xsl:param>

  <!-- Display witness sigla in italics in apparatus? 1 = yes -->
  <xsl:param name="italWit">1</xsl:param>

  <!-- Page layout -->
  <xsl:param name="pageSize">a4paper</xsl:param>
  <xsl:param name="facingLayout">0</xsl:param>
  <xsl:param name="marginInner"/>
  <xsl:param name="marginOuter"/>
  <xsl:param name="marginTop"/>
  <xsl:param name="marginBottom"/>
  <xsl:param name="marginBinding"/>

  <!-- Languages -->
  <xsl:param name="lang1">latin</xsl:param>
  <xsl:param name="lang2">english</xsl:param>

  <!-- Running titles -->
  <xsl:param name="rTitleOdd">\textsc{Caesarius Heisterbachensis}</xsl:param>
  <xsl:param name="rTitleEven">\textsc{Homiliae de infantia}</xsl:param>
  <xsl:param name="rTitleOddPos">C</xsl:param>
  <xsl:param name="rTitleEvenPos">C</xsl:param>
  <xsl:param name="rTitleOddSize"/>
  <xsl:param name="rTitleEvenSize"/>

  <!-- Quotation marks -->
  <xsl:param name="qmQuote">0</xsl:param>
  <xsl:param name="qmQuoteStyle">«|»</xsl:param>
  <xsl:param name="qmQuoteNoBr">1</xsl:param>

  <!-- Pagination -->
  <xsl:param name="fromPage">0</xsl:param>
  <xsl:param name="pageNumFirstPage">0</xsl:param>
  <xsl:param name="pageNumberingStyle">arabic</xsl:param>
  <xsl:param name="pageNumPlace">head</xsl:param>
  <xsl:param name="pageNumPosition">LE,RO</xsl:param>
  <xsl:param name="pageNumSize"/>

  <!-- Line numbering -->
  <xsl:param name="lineationStyle">page</xsl:param>
  <xsl:param name="lineationStart">5</xsl:param>
  <xsl:param name="lineationStep">5</xsl:param>

  <!-- Font size -->
  <xsl:param name="baseFontSize">12</xsl:param>

  <!-- Title -->
  <xsl:param name="printTitle">1</xsl:param>
  <xsl:param name="printTitleSize"/>
  <xsl:param name="printTitleStyle"/>

<!-- Apparatus spacing -->
  <xsl:param name="separatorAppEntries"/>
  <xsl:param name="spaceBeforeNotesA">18</xsl:param>
  <xsl:param name="spaceBeforeNotesB">18</xsl:param>

  <!-- Section heads -->
  <xsl:param name="headStyle">1</xsl:param>
  <xsl:param name="headStylevSpaceBefore">0.5</xsl:param>
  <xsl:param name="headStylevSpaceAfter">0.3</xsl:param>
  <xsl:param name="headSize">large</xsl:param>
  <xsl:param name="headAlign"/>

  <!-- Paragraph spacing -->
  <xsl:param name="parStylevSpace">0</xsl:param>

  <!-- Folio side notes -->
  <xsl:param name="folioNotes">1</xsl:param>
  <xsl:param name="sideNoteLocation">inner</xsl:param>
  <xsl:param name="folioInTextMarker"> ||</xsl:param>
  <xsl:param name="folioNotesMs">0</xsl:param>
  <xsl:param name="folioNotesAll">0</xsl:param>
  <xsl:param name="folioNoteAttribute">ed</xsl:param>
  <xsl:param name="folioNoteAttributeValue">T1</xsl:param>

  <!-- Indexes -->
  <xsl:param name="idxNom">1</xsl:param>
  <xsl:param name="idxNomPrologue"/>
  <xsl:param name="idxNomTitle">Index Nominum</xsl:param>
  <xsl:param name="idxLoc">1</xsl:param>
  <xsl:param name="idxLocPrologue"/>
  <xsl:param name="idxLocTitle">Index locorum</xsl:param>


  <!-- ============================================================
       CHARACTER REPLACEMENT MAP
       ============================================================ -->

  <tex:replace-map>
    <entry key="&gt;">⟩</entry>
    <entry key="&lt;">⟨</entry>
    <entry key="&amp;">\&amp;</entry>
    <entry key="_">\_</entry>
    <entry key="%">\%</entry>
    <entry key="#">\#</entry>
    <entry key="$">\$</entry>
    <entry key="\">\textbackslash{}</entry>
    <entry key="^">\^{}</entry>
    <entry key="{">\{</entry>
    <entry key="}">\}</entry>
    <entry key="~">\~{}</entry>
  </tex:replace-map>


  <!-- ============================================================
       ROOT TEMPLATE — LaTeX preamble and document structure
       ============================================================ -->

  <xsl:template match="/">
    <xsl:text>\documentclass[</xsl:text>
    <xsl:value-of select="$pageSize"/>
    <xsl:if test="$facingLayout = '1'">,twoside</xsl:if>
    <xsl:text>]{article}
\usepackage[oldstyle,proportional]{libertine}
\usepackage{fontspec}
\usepackage{microtype}
\usepackage{polyglossia}
\usepackage{bookmark}
\hypersetup{pdftitle={</xsl:text>
    <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    <xsl:text>},
            pdfauthor={</xsl:text>
    <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
    <xsl:text>},
            pdfborder={0 0 0}}
</xsl:text>

    <xsl:if test="$parStylevSpace != '0'">
      <xsl:text>\setlength{\parskip}{</xsl:text>
      <xsl:value-of select="$parStylevSpace"/>
      <xsl:text>cm}
</xsl:text>
    </xsl:if>

    <!-- Indexes -->
    <xsl:if test="$idxNom = '1' or $idxLoc = '1'">
      <xsl:text>\usepackage[innote]{indextools}
</xsl:text>
      <xsl:if test="$idxNom = '1'">
        <xsl:text>\makeindex[title={</xsl:text>
        <xsl:value-of select="$idxNomTitle"/>
        <xsl:text>},name=nominum]
</xsl:text>
      </xsl:if>
      <xsl:if test="$idxLoc = '1'">
        <xsl:text>\makeindex[title={</xsl:text>
        <xsl:value-of select="$idxLocTitle"/>
        <xsl:text>},name=locorum]
</xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:text>\usepackage[</xsl:text>
    <xsl:value-of select="$baseFontSize"/>
    <xsl:text>pt]{extsizes}
</xsl:text>

    <!-- Margins -->
    <xsl:if test="$marginBinding != '' or $marginInner != '' or $marginOuter != '' or $marginTop != '' or $marginBottom != ''">
      <xsl:text>\usepackage[</xsl:text>
      <xsl:if test="$marginBinding != ''">bindingoffset=<xsl:value-of select="$marginBinding"/>cm,</xsl:if>
      <xsl:if test="$marginInner != ''">inner=<xsl:value-of select="$marginInner"/>cm,</xsl:if>
      <xsl:if test="$marginOuter != ''">outer=<xsl:value-of select="$marginOuter"/>cm,</xsl:if>
      <xsl:if test="$marginTop != ''">top=<xsl:value-of select="$marginTop"/>cm,</xsl:if>
      <xsl:if test="$marginBottom != ''">bottom=<xsl:value-of select="$marginBottom"/>cm</xsl:if>
      <xsl:text>]{geometry}
</xsl:text>
    </xsl:if>

    <!-- Headers/footers -->
    <xsl:text>\usepackage{fancyhdr}
\fancyfoot{}
\renewcommand{\headrulewidth}{0pt}
\pagestyle{fancy}
</xsl:text>
    <xsl:choose>
      <xsl:when test="$pageNumPlace = 'head'">
        <xsl:text>\fancyhead[</xsl:text><xsl:value-of select="$pageNumPosition"/>
        <xsl:text>]{</xsl:text><xsl:value-of select="$pageNumSize"/><xsl:text>\thepage}
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\fancyfoot[</xsl:text><xsl:value-of select="$pageNumPosition"/>
        <xsl:text>]{</xsl:text><xsl:value-of select="$pageNumSize"/><xsl:text>\thepage}
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$rTitleEven != ''">
      <xsl:text>\fancyhead[</xsl:text><xsl:value-of select="$rTitleEvenPos"/>
      <xsl:text>E]{</xsl:text><xsl:value-of select="$rTitleEvenSize"/>
      <xsl:value-of select="$rTitleEven"/><xsl:text>}
</xsl:text>
    </xsl:if>
    <xsl:if test="$rTitleOdd != ''">
      <xsl:text>\fancyhead[</xsl:text><xsl:value-of select="$rTitleOddPos"/>
      <xsl:text>O]{</xsl:text><xsl:value-of select="$rTitleOddSize"/>
      <xsl:value-of select="$rTitleOdd"/><xsl:text>}
</xsl:text>
    </xsl:if>

    <!-- Languages -->
    <xsl:choose>
      <xsl:when test="$lang1 = 'ancientGreek'">\setmainlanguage[variant=ancient]{greek}</xsl:when>
      <xsl:otherwise>
        <xsl:text>\setmainlanguage{</xsl:text><xsl:value-of select="$lang1"/><xsl:text>}
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$lang2 = 'ancientGreek'">\setotherlanguage[variant=ancient]{greek}</xsl:when>
      <xsl:otherwise>
        <xsl:text>\setotherlanguage{</xsl:text><xsl:value-of select="$lang2"/><xsl:text>}
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <!-- reledmac -->
    <xsl:text>\usepackage[series={A,B},noend,nofamiliar,noeledsec,noledgroup]{reledmac}
\Xarrangement[A]{paragraph}
\Xarrangement[B]{paragraph}
\Xbeforenotes[A]{</xsl:text><xsl:value-of select="$spaceBeforeNotesA"/><xsl:text>pt}
\Xbeforenotes[B]{</xsl:text><xsl:value-of select="$spaceBeforeNotesB"/><xsl:text>pt}
\Xlemmadisablefontselection[A]
\Xnotenumfont{\normalfont\bfseries}
</xsl:text>
    <xsl:if test="$lemSep != ''">
      <xsl:text>\Xlemmaseparator[]{\,</xsl:text><xsl:value-of select="$lemSep"/><xsl:text>}
</xsl:text>
    </xsl:if>
    <xsl:text>\lineation{</xsl:text><xsl:value-of select="$lineationStyle"/><xsl:text>}
\setlength{\stanzaindentbase}{20pt}
\setstanzaindents{1,1}
\setcounter{stanzaindentsrepetition}{1}
\firstlinenum{</xsl:text><xsl:value-of select="$lineationStart"/><xsl:text>}
\linenumincrement{</xsl:text><xsl:value-of select="$lineationStep"/><xsl:text>}
\linenummargin{outer}
\Xnumberonlyfirstinline[]
\Xnumberonlyfirstintwolines[]
\Xsymlinenum{</xsl:text><xsl:value-of select="$separatorAppEntries"/><xsl:text>}
\fnpos{critical-familiar}
</xsl:text>

    <!-- Title and author -->
    <xsl:text>\title{</xsl:text>
    <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
    <xsl:text>}
\author{</xsl:text>
    <xsl:value-of select="//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author"/>
    <xsl:text>}
\date{}
</xsl:text>

    <!-- Title styling -->
    <xsl:if test="$printTitleStyle != '' or $printTitleSize != ''">
      <xsl:text>\usepackage{titling}
\pretitle{\begin{center}</xsl:text>
      <xsl:choose>
        <xsl:when test="$printTitleSize != ''">\<xsl:value-of select="$printTitleSize"/></xsl:when>
        <xsl:otherwise>\Large</xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$printTitleStyle = 'smallcaps'">\scshape</xsl:when>
        <xsl:when test="$printTitleStyle = 'caps'">\MakeUppercase</xsl:when>
      </xsl:choose>
      <xsl:text>}
</xsl:text>
    </xsl:if>

    <!-- Section heading command -->
    <xsl:text>% Workaround for \section in reledmac
\makeatletter
\newcommand{\TEIsection}[1]{\vspace{</xsl:text>
    <xsl:value-of select="$headStylevSpaceBefore"/>
    <xsl:text>cm}\noindent</xsl:text>
    <xsl:if test="$headAlign = 'center'">\centering</xsl:if>
    <xsl:if test="$headSize != '0'">\<xsl:value-of select="$headSize"/></xsl:if>
    <xsl:text>\text</xsl:text>
    <xsl:choose>
      <xsl:when test="$headStyle = '1'">it</xsl:when>
      <xsl:when test="$headStyle = '2'">bf</xsl:when>
      <xsl:when test="$headStyle = '3'">sc</xsl:when>
    </xsl:choose>
    <xsl:text>{#1}\vspace{</xsl:text>
    <xsl:value-of select="$headStylevSpaceAfter"/>
    <xsl:text>cm}}\par\nobreak\vspace{-\parskip}\@afterheading\noindent
\makeatother

\begin{document}
\raggedbottom
\sidenotemargin{</xsl:text>
    <xsl:value-of select="$sideNoteLocation"/>
    <xsl:text>}
\pagenumbering{</xsl:text>
    <xsl:value-of select="$pageNumberingStyle"/>
    <xsl:text>}
</xsl:text>
    <xsl:if test="$fromPage != '0'">
      <xsl:text>\setcounter{page}{</xsl:text><xsl:value-of select="$fromPage"/><xsl:text>}
</xsl:text>
    </xsl:if>

    <xsl:if test="$printTitle != '0'">\maketitle
</xsl:if>
    <xsl:if test="$pageNumFirstPage = '0'">
      <xsl:text>\thispagestyle{empty}
</xsl:text>
    </xsl:if>



    <xsl:text>\beginnumbering
</xsl:text>
    <xsl:apply-templates select="/tei:TEI/tei:text/tei:body"/>
    <xsl:text>
\endnumbering
</xsl:text>

    <!-- Print indexes -->
    <xsl:if test="$idxNom = '1'">
      <xsl:if test="$idxNomPrologue != ''">
        <xsl:text>\indexprologue{\small </xsl:text>
        <xsl:value-of select="$idxNomPrologue"/>
        <xsl:text>}
</xsl:text>
      </xsl:if>
      <xsl:text>\printindex[nominum]
</xsl:text>
    </xsl:if>
    <xsl:if test="$idxLoc = '1'">
      <xsl:if test="$idxLocPrologue != ''">
        <xsl:text>\indexprologue{\small </xsl:text>
        <xsl:value-of select="$idxLocPrologue"/>
        <xsl:text>}
</xsl:text>
      </xsl:if>
      <xsl:text>\printindex[locorum]
</xsl:text>
    </xsl:if>

    <xsl:text>\end{document}</xsl:text>
  </xsl:template>


  <!-- ============================================================
       DOCUMENT STRUCTURE
       ============================================================ -->

  <xsl:template match="tei:div">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Section heading -->
  <xsl:template match="tei:head[parent::tei:div or parent::tei:body]">
    <xsl:choose>
      <xsl:when test="not(ancestor::tei:rdg)">
        <xsl:text>
\pstart
\TEIsection{</xsl:text>
        <xsl:variable name="depthOfLem" select="count(ancestor::tei:lem)"/>
        <xsl:call-template name="whileStartLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="whileEndLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:text>}
\pend
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Paragraph -->
  <xsl:template match="tei:p|tei:ab">
    <xsl:choose>
      <xsl:when test="not(ancestor::tei:rdg)">
        <xsl:text>
\pstart </xsl:text>
        <xsl:variable name="depthOfLem" select="count(ancestor::tei:lem)"/>
        <xsl:call-template name="whileStartLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="whileEndLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:text>
\pend
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- tei:listWit and tei:witness: ignored, handled separately -->
  <xsl:template match="tei:listWit"/>
  <xsl:template match="tei:witness"/>


  <!-- ============================================================
       PAGE BREAKS AND LINE BREAKS
       ============================================================ -->

  <xsl:template match="tei:lb"/>

  <xsl:template match="tei:pb">
    <xsl:if test="$folioNotes = '1'">
      <xsl:variable name="printThis">
        <xsl:choose>
          <xsl:when test="$folioNotesAll = '1'">yes</xsl:when>
          <xsl:when test="$folioNoteAttribute = 'ed' and translate(@ed,'#','') = $folioNoteAttributeValue">yes</xsl:when>
          <xsl:when test="$folioNoteAttribute = 'edRef' and translate(@edRef,'#','') = $folioNoteAttributeValue">yes</xsl:when>
          <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$printThis = 'yes'">
        <xsl:value-of select="$folioInTextMarker"/>
        <xsl:text>\ledsidenote{</xsl:text>
        <xsl:if test="$folioNotesMs = '1' and (@ed or @edRef)">
          <xsl:text>\emph{</xsl:text>
          <xsl:choose>
            <xsl:when test="@ed and @edRef"><xsl:value-of select="translate(@edRef,'#','')"/></xsl:when>
            <xsl:when test="@ed"><xsl:value-of select="translate(@ed,'#','')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="translate(@edRef,'#','')"/></xsl:otherwise>
          </xsl:choose>
          <xsl:text>} </xsl:text>
        </xsl:if>
        <xsl:value-of select="@n"/>
        <xsl:text>} </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <!-- ============================================================
       INDEXES
       ============================================================ -->

  <xsl:template match="tei:persName">
    <xsl:apply-templates/>
    <xsl:if test="$idxNom = '1'">
      <xsl:choose>
        <xsl:when test="@key">
          <xsl:text>\sindex[nominum]{</xsl:text>
          <xsl:value-of select="@key"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:when test="@ref">
          <xsl:variable name="ref" select="translate(@ref,'#','')"/>
          <xsl:text>\sindex[nominum]{</xsl:text>
          <xsl:value-of select="//tei:person[@xml:id=$ref]/tei:persName"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:placeName">
    <xsl:apply-templates/>
    <xsl:if test="$idxLoc = '1'">
      <xsl:choose>
        <xsl:when test="@key">
          <xsl:text>\sindex[locorum]{</xsl:text>
          <xsl:value-of select="@key"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:when test="@ref">
          <xsl:variable name="ref" select="translate(@ref,'#','')"/>
          <xsl:text>\sindex[locorum]{</xsl:text>
          <xsl:value-of select="//tei:place[@xml:id=$ref]/tei:placeName"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>


  <!-- ============================================================
       INLINE FORMATTING
       ============================================================ -->

  <xsl:template match="tei:emph">
    <xsl:text>\emph{</xsl:text><xsl:apply-templates/><xsl:text>} </xsl:text>
  </xsl:template>

  <xsl:template match="tei:hi">
    <xsl:choose>
      <xsl:when test="@rend='italic' or @rend='italics'"> \emph{<xsl:apply-templates/>} </xsl:when>
      <xsl:when test="@rend='bold'"> \textbf{<xsl:apply-templates/>} </xsl:when>
      <xsl:when test="@rend='sup'"> \textsuperscript{<xsl:apply-templates/>} </xsl:when>
      <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:ref">
    <xsl:text> \textsuperscript{</xsl:text><xsl:apply-templates/><xsl:text>} </xsl:text>
  </xsl:template>

  <xsl:template match="tei:title">
    <xsl:text>\emph{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
  </xsl:template>


  <!-- ============================================================
       QUOTATIONS
       ============================================================ -->

  <xsl:template match="tei:quote">
    <xsl:if test="$italQuote = '1'">\emph{</xsl:if>
    <xsl:if test="$qmQuote = '1'">
      <xsl:value-of select="substring-before($qmQuoteStyle,'|')"/>
      <xsl:if test="$qmQuoteNoBr = '1'">\,</xsl:if>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="$qmQuote = '1'">
      <xsl:if test="$qmQuoteNoBr = '1'">\,</xsl:if>
      <xsl:value-of select="substring-after($qmQuoteStyle,'|')"/>
    </xsl:if>
    <xsl:if test="$italQuote = '1'">}</xsl:if>
  </xsl:template>

  <xsl:template match="tei:bibl" mode="bibl">
    <xsl:text> ⟨</xsl:text><xsl:apply-templates/><xsl:text>⟩</xsl:text>
  </xsl:template>
  <xsl:template match="tei:bibl" mode="src">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:bibl"/>

  <xsl:template match="tei:cit">
    <xsl:choose>
      <xsl:when test="./tei:quote//tei:lg">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:when test="@next">
        <xsl:choose>
          <xsl:when test="@type='bible'">\emph{<xsl:apply-templates select="tei:quote"/>}</xsl:when>
          <xsl:otherwise>
            <xsl:text>\edlabel{</xsl:text><xsl:value-of select="translate(@xml:id,'#','')"/><xsl:text>}</xsl:text>
            <xsl:apply-templates select="tei:quote"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@prev">
        <xsl:choose>
          <xsl:when test="@type='bible'">
            <xsl:text>\emph{</xsl:text><xsl:apply-templates select="tei:quote"/><xsl:text>}</xsl:text>
            <xsl:apply-templates select="tei:bibl" mode="bibl"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\edtext{</xsl:text>
            <xsl:apply-templates select="tei:quote"/>
            <xsl:text>\edlabel{</xsl:text><xsl:value-of select="translate(@xml:id,'#','')"/><xsl:text>}}{\xxref{</xsl:text>
            <xsl:value-of select="translate(@prev,'#','')"/><xsl:text>}{</xsl:text>
            <xsl:value-of select="translate(@xml:id,'#','')"/><xsl:text>}\lemma{}{\Bfootnote[nosep]{</xsl:text>
            <xsl:apply-templates select="tei:bibl" mode="src"/>
            <xsl:text>}}}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="@type='bible'">
            <xsl:text>\emph{</xsl:text><xsl:apply-templates select="tei:quote"/><xsl:text>}</xsl:text>
            <xsl:apply-templates select="tei:bibl" mode="bibl"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\edtext{</xsl:text><xsl:apply-templates select="tei:quote"/>
            <xsl:text>}{\lemma{}{\Bfootnote[nosep]{</xsl:text>
            <xsl:apply-templates select="tei:bibl" mode="src"/>
            <xsl:text>}}}</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ============================================================
       VERSE (tei:lg / tei:l)
       ============================================================ -->

  <xsl:template match="tei:lg">
    <xsl:choose>
      <xsl:when test="not(ancestor::tei:rdg)">
        <xsl:if test="ancestor::tei:p and not(preceding-sibling::tei:lg)">
          <xsl:text>
\pend </xsl:text>
        </xsl:if>
        <xsl:text>
\stanza[ ] </xsl:text>
        <xsl:variable name="depthOfLem" select="count(ancestor::tei:lem)"/>
        <xsl:call-template name="whileStartLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="whileEndLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="not(following-sibling::tei:lg)">
            <xsl:text> \&amp;[ ]</xsl:text>
            <xsl:if test="ancestor::tei:p">
              <xsl:text>
\pstart </xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> \&amp; </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text><xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:l">
    <xsl:choose>
      <xsl:when test="parent::tei:lg">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::tei:l"> &amp;</xsl:if>
      </xsl:when>
      <xsl:when test="not(ancestor::tei:rdg)">
        <xsl:text> \\ \indent \textit{</xsl:text>
        <xsl:apply-templates/>
        <xsl:choose>
          <xsl:when test="not(following-sibling::tei:l) and not(parent::tei:lem)">
            <xsl:text>}
\\ </xsl:text>
          </xsl:when>
          <xsl:otherwise><xsl:text>} </xsl:text></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> \emph{</xsl:text><xsl:apply-templates/><xsl:text>} </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ============================================================
       LISTS
       ============================================================ -->

  <xsl:template match="tei:list">
    <xsl:choose>
      <xsl:when test="not(ancestor::tei:rdg)">
        <xsl:choose>
          <xsl:when test="ancestor::tei:p">
            <xsl:if test="preceding::text()/ancestor::tei:p[1] = ancestor::tei:p[1]">
              <xsl:text>
\\ \indent </xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>
\pstart </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="depthOfLem" select="count(ancestor::tei:lem)"/>
        <xsl:call-template name="whileStartLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="whileEndLem">
          <xsl:with-param name="depth" select="$depthOfLem"/>
        </xsl:call-template>
        <xsl:if test="not(ancestor::tei:p)">
          <xsl:text>
\pend
</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> </xsl:text><xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:item">
    <xsl:apply-templates/>
    <xsl:if test="not(ancestor::tei:rdg) and following-sibling::tei:item">
      <xsl:text>
\\ \indent </xsl:text>
    </xsl:if>
  </xsl:template>


  <!-- ============================================================
       TABLES
       ============================================================ -->

  <xsl:template match="tei:table">
    <xsl:text> \begin{tabular}{c|c|c|c} </xsl:text>
    <xsl:apply-templates/>
    <xsl:text> \end{tabular} </xsl:text>
  </xsl:template>

  <xsl:template match="tei:row">
    <xsl:apply-templates/><xsl:text> \\ </xsl:text>
  </xsl:template>

  <xsl:template match="tei:cell">
    <xsl:apply-templates/><xsl:text> &amp; </xsl:text>
  </xsl:template>


  <!-- ============================================================
       NOTES
       ============================================================ -->

  <xsl:template match="tei:note[not(ancestor::tei:app)]">
    <xsl:text>\footnoteA{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="tei:note[ancestor::tei:app][@type != 'altLem']">
    <xsl:text>\emph{</xsl:text><xsl:apply-templates/><xsl:text>} </xsl:text>
  </xsl:template>


  <!-- ============================================================
       CRITICAL APPARATUS — tei:app
       
       Strategy:
       - Compute the lemma text (for \edtext{} first argument)
       - Compute the lemma label (for \lemma{} in the note)
       - Iterate over tei:rdg using the named template renderRdg
       - tei:app inside tei:lem are processed recursively via apply-templates
       ============================================================ -->

  <xsl:template match="tei:app">
    <!-- The rendered lemma (with any nested app expanded) -->
    <xsl:variable name="lemmaRendered">
      <xsl:apply-templates select="tei:lem"/>
    </xsl:variable>

    <!-- The plain text of the lemma (for the \lemma{} label, no markup) -->
    <xsl:variable name="lemmaPlainText">
      <xsl:value-of select="normalize-space(string-join(
        tei:lem/descendant-or-self::text()
          [not(ancestor::tei:rdg)]
          [not(ancestor::tei:note)]
          [not(ancestor::tei:bibl)],
        ''))"/>
    </xsl:variable>

    <xsl:choose>
      <!-- ── Simple case: no block-level descendants in lem ── -->
      <xsl:when test="not(tei:lem/descendant::tei:p)
                  and not(tei:lem/descendant::tei:head)
                  and not(tei:lem/descendant::tei:lg)
                  and not(tei:lem/descendant::tei:list)">

        <xsl:text>\edtext{</xsl:text>
        <xsl:value-of select="$lemmaRendered"/>
        <xsl:text>}{</xsl:text>

        <!-- \lemma{} -->
        <xsl:call-template name="buildLemmaLabel">
          <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
          <xsl:with-param name="altLem" select="tei:note[@type='altLem']"/>
        </xsl:call-template>

        <!-- \Afootnote{} -->
        <xsl:text>\Afootnote{</xsl:text>
        <xsl:call-template name="buildApparatusNote">
          <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
        </xsl:call-template>
        <xsl:text>}}</xsl:text>

      </xsl:when>

      <!-- ── Complex case: block-level content in lem → just render lem ── -->
      <xsl:otherwise>
        <xsl:apply-templates select="tei:lem"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Build the \lemma{} content -->
  <xsl:template name="buildLemmaLabel">
    <xsl:param name="lemmaPlainText"/>
    <xsl:param name="altLem"/>

    <xsl:choose>
      <!-- altLem overrides everything -->
      <xsl:when test="$altLem">
        <xsl:text>\lemma{</xsl:text>
        <xsl:apply-templates select="$altLem"/>
        <xsl:text>} </xsl:text>
      </xsl:when>
      <!-- Normal lemma: shorten if needed -->
      <xsl:when test="$lemmaPlainText != ''">
        <xsl:text>\lemma{</xsl:text>
        <xsl:variable name="words"
          select="tokenize(normalize-space($lemmaPlainText), ' ')"/>
        <xsl:choose>
          <xsl:when test="$shortenLem != '0' and count($words) > $shortenLem">
            <xsl:value-of select="translate(lower-case($words[1]),',.!?:;)','')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate(lower-case($words[2]),',.!?:;)','')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate(lower-case($words[3]),',.!?:;)','')"/>
            <xsl:text> \ldots{} </xsl:text>
            <xsl:value-of select="translate(lower-case($words[last()-2]),',.!?:;)','')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate(lower-case($words[last()-1]),',.!?:;)','')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="translate(lower-case($words[last()]),',.!?:;)','')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="translate(lower-case($lemmaPlainText),',.!?:;)','')"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>} </xsl:text>
      </xsl:when>
      <!-- Empty lemma (addition): use last preceding word -->
      <xsl:otherwise>
        <xsl:text>\lemma{</xsl:text>
        <xsl:variable name="prevWords"
          select="tokenize(normalize-space(string-join(
            preceding::text()
              [not(ancestor::tei:rdg)]
              [not(ancestor::tei:note)]
              [not(ancestor::tei:bibl)],
            '')), ' ')"/>
        <xsl:variable name="lastWord" select="$prevWords[last()]"/>
        <xsl:choose>
          <xsl:when test="$lastWord = '.' or $lastWord = '!' or $lastWord = '?'
                       or $lastWord = ';' or $lastWord = ':' or $lastWord = ','">
            <xsl:value-of select="translate(lower-case($prevWords[last()-1]),',.!?:;)','')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="translate(lower-case($lastWord),',.!?:;)','')"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>} </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- Build the content of \Afootnote{}: iterate over rdg siblings -->
  <xsl:template name="buildApparatusNote">
    <xsl:param name="lemmaPlainText"/>
    <xsl:for-each select="tei:rdg">
      <xsl:variable name="rdgContent">
        <xsl:call-template name="renderRdg">
          <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
        </xsl:call-template>
      </xsl:variable>
      <!-- Only output if renderRdg produced something -->
      <xsl:if test="normalize-space($rdgContent) != ''">
        <xsl:value-of select="$rdgContent"/>
        <!-- Siglum -->
        <xsl:text> </xsl:text>
        <xsl:call-template name="renderWit">
          <xsl:with-param name="wit" select="@wit"/>
        </xsl:call-template>
        <!-- Separator before next rdg (if any has content) -->
        <xsl:if test="following-sibling::tei:rdg">
          <xsl:variable name="nextHasContent">
            <xsl:for-each select="following-sibling::tei:rdg[1]">
              <xsl:call-template name="renderRdg">
                <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="normalize-space($nextHasContent) != ''">, </xsl:if>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>


  <!-- ============================================================
       renderRdg: produce the text content for one <rdg>
       Returns empty string if nothing should be displayed.
       The siglum is NOT included here — it is added by buildApparatusNote.
       ============================================================ -->

  <xsl:template name="renderRdg">
    <xsl:param name="lemmaPlainText"/>

    <xsl:choose>

      <!-- ── 1. rdg contains tei:mod (with del+add) ── -->
      <xsl:when test="tei:mod or descendant::tei:mod">
        <xsl:call-template name="renderRdgWithMod">
          <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
        </xsl:call-template>
      </xsl:when>

      <!-- ── 2. rdg contains only tei:del (no add, no mod) ── -->
      <xsl:when test="tei:del and not(tei:add) and not(tei:mod)">
        <xsl:variable name="delText"
          select="normalize-space(string-join(tei:del//text(),''))"/>
        <xsl:if test="$delText != ''">
          <xsl:value-of select="lower-case($delText)"/>
          <xsl:text> \emph{</xsl:text>
          <xsl:value-of select="$varDel"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- ── 3. rdg contains only tei:add (no mod) ── -->
      <xsl:when test="tei:add and not(tei:mod)">
        <xsl:variable name="addText"
          select="normalize-space(string-join(tei:add//text(),''))"/>
        <xsl:choose>
          <!-- add == lem: confirmative addition, show only add. -->
          <xsl:when test="$addText = normalize-space($lemmaPlainText)">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="$varAdd"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
          <!-- add != lem: show text + add. -->
          <xsl:when test="$addText != ''">
            <xsl:value-of select="lower-case($addText)"/>
            <xsl:text> \emph{</xsl:text>
            <xsl:value-of select="$varAdd"/>
            <xsl:text>}</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>

      <!-- ── 4. Normal rdg with text content ── -->
      <xsl:when test="normalize-space(string-join(descendant-or-self::text(),'')) != ''">
        <xsl:variable name="rdgText">
          <xsl:apply-templates/>
        </xsl:variable>
        <xsl:if test="starts-with(normalize-space($rdgText),'plus')
                   or starts-with(normalize-space($rdgText),'minus')">
          <xsl:text>\,</xsl:text>
        </xsl:if>
        <xsl:value-of select="lower-case(normalize-space($rdgText))"/>
      </xsl:when>

      <!-- ── 5. Empty rdg = omission ── -->
      <xsl:otherwise>
        <xsl:text>\emph{</xsl:text>
        <xsl:value-of select="$varOm"/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>


  <!-- ============================================================
       renderRdgWithMod: handle mixed content rdg containing tei:mod
       e.g. "nec <mod><del>non</del><add>enim</add></mod>"
       ============================================================ -->

  <xsl:template name="renderRdgWithMod">
    <xsl:param name="lemmaPlainText"/>

    <!-- Process each child node of the rdg in order -->
    <xsl:for-each select="node()">
      <xsl:choose>

        <!-- Text nodes: output directly -->
        <xsl:when test="self::text()">
          <xsl:value-of select="lower-case(normalize-space(.))"/>
          <xsl:if test="normalize-space(.) != ''">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:when>

        <!-- tei:mod node -->
        <xsl:when test="self::tei:mod">
          <xsl:variable name="addText"
            select="normalize-space(string-join(tei:add//text(),''))"/>
          <xsl:variable name="delText"
            select="normalize-space(string-join(tei:del//text(),''))"/>
          <xsl:choose>
            <!-- add == lem → show del + a.c. -->
            <xsl:when test="$addText = normalize-space($lemmaPlainText)">
              <xsl:value-of select="lower-case($delText)"/>
              <xsl:text> \emph{</xsl:text>
              <xsl:value-of select="$varAc"/>
              <xsl:text>}</xsl:text>
            </xsl:when>
            <!-- add != lem → show add + p.c. -->
            <xsl:otherwise>
              <xsl:value-of select="lower-case($addText)"/>
              <xsl:text> \emph{</xsl:text>
              <xsl:value-of select="$varPc"/>
              <xsl:text>}</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- Any other inline element: just apply templates -->
        <xsl:otherwise>
          <xsl:apply-templates select="."/>
        </xsl:otherwise>

      </xsl:choose>
    </xsl:for-each>
  </xsl:template>


  <!-- ============================================================
       renderWit: format the witness siglum
       ============================================================ -->

  <xsl:template name="renderWit">
    <xsl:param name="wit"/>
    <xsl:variable name="clean" select="normalize-space(translate($wit,'#',''))"/>
    <xsl:choose>
      <xsl:when test="$italWit = '1'">
        <xsl:text>\emph{</xsl:text>
        <xsl:value-of select="$clean"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$clean"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ============================================================
       whileStartLem / whileEndLem
       For tei:app whose tei:lem spans multiple block elements (p, head,
       lg, list), we place \edlabel markers at the first and last block
       and use \xxref so reledmac can display the correct line range.
       ============================================================ -->

  <xsl:template name="whileStartLem">
    <xsl:param name="depth"/>
    <xsl:if test="$depth > 0">
      <xsl:if test="ancestor::tei:lem[position()=$depth]/
          descendant::node()[name()='p' or name()='head' or name()='lg' or name()='list']
          [position()=1] = self::node()">
        <xsl:text>\edlabel{lem_</xsl:text>
        <xsl:number select="ancestor::tei:lem[position()=$depth]" level="any"/>
        <xsl:text>_start}</xsl:text>
      </xsl:if>
      <xsl:call-template name="whileStartLem">
        <xsl:with-param name="depth" select="$depth - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="whileEndLem">
    <xsl:param name="depth"/>
    <xsl:if test="$depth > 0">
      <xsl:if test="ancestor::tei:lem[position()=$depth]/
          descendant::node()[name()='p' or name()='head' or name()='lg' or name()='list']
          [last()] = self::node()">
        <xsl:text>\edtext{\edlabel{lem_</xsl:text>
        <xsl:number select="ancestor::tei:lem[position()=$depth]" level="any"/>
        <xsl:text>_end}}{\xxref{lem_</xsl:text>
        <xsl:number select="ancestor::tei:lem[position()=$depth]" level="any"/>
        <xsl:text>_start}{lem_</xsl:text>
        <xsl:number select="ancestor::tei:lem[position()=$depth]" level="any"/>
        <xsl:text>_end}</xsl:text>
        <!-- Build the apparatus note for this multi-block app -->
        <xsl:variable name="appNode" select="ancestor::tei:app[position()=number($depth)]"/>
        <xsl:variable name="lemmaPlainText">
          <xsl:value-of select="normalize-space(string-join(
            $appNode/tei:lem/descendant-or-self::text()
              [not(ancestor::tei:rdg)]
              [not(ancestor::tei:note)]
              [not(ancestor::tei:bibl)], ''))"/>
        </xsl:variable>
        <xsl:for-each select="$appNode">
          <xsl:call-template name="buildLemmaLabel">
            <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
            <xsl:with-param name="altLem" select="tei:note[@type='altLem']"/>
          </xsl:call-template>
          <xsl:text>\Afootnote{</xsl:text>
          <xsl:call-template name="buildApparatusNote">
            <xsl:with-param name="lemmaPlainText" select="$lemmaPlainText"/>
          </xsl:call-template>
          <xsl:text>}</xsl:text>
        </xsl:for-each>
        <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:call-template name="whileEndLem">
        <xsl:with-param name="depth" select="$depth - 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <!-- ============================================================
       tei:subst in main text (outside apparatus)
       ============================================================ -->

  <xsl:template match="tei:subst[not(ancestor::tei:rdg)]">
    <xsl:text> \emph{subst.:} </xsl:text>
    <xsl:apply-templates select="tei:del"/>
    <xsl:text> \emph{del.,} </xsl:text>
    <xsl:apply-templates select="tei:add"/>
    <xsl:text> \emph{add.} </xsl:text>
  </xsl:template>

  <!-- tei:mod outside apparatus -->
  <xsl:template match="tei:mod[not(ancestor::tei:rdg)]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- tei:del outside apparatus: show struck text in brackets -->
  <xsl:template match="tei:del[not(ancestor::tei:rdg)]">
    <xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
  </xsl:template>

  <!-- tei:add outside apparatus -->
  <xsl:template match="tei:add[not(ancestor::tei:rdg)]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Inside rdg: handled by renderRdg/renderRdgWithMod, these are safety fallbacks -->
  <xsl:template match="tei:mod[ancestor::tei:rdg]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:del[ancestor::tei:rdg]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:add[ancestor::tei:rdg]">
    <xsl:apply-templates/>
  </xsl:template>


  <!-- ============================================================
       TEXT NODE — escape LaTeX special characters
       ============================================================ -->

  <xsl:template match="text()">
    <xsl:variable name="escaped">
      <xsl:call-template name="StringReplace">
        <xsl:with-param name="text" select="."/>
        <xsl:with-param name="chars" select="'&lt; &amp; % # $ \ * ^ { ~ } _ &gt; '"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
        <xsl:value-of select="$escaped"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="position()!=1 and matches($escaped,'^\s') and normalize-space()!=''">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space($escaped)"/>
        <xsl:choose>
          <xsl:when test="last()=1 and string-length()!=0 and normalize-space()=''">
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="position()!=1 and position()!=last() and matches($escaped,'\s$')">
            <xsl:text> </xsl:text>
          </xsl:when>
          <xsl:when test="position()=1 and matches($escaped,'\s$') and normalize-space()!=''">
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ============================================================
       STRING REPLACE — recursive character escaping
       ============================================================ -->

  <xsl:template name="StringReplace">
    <xsl:param name="text"/>
    <xsl:param name="chars"/>
    <xsl:choose>
      <xsl:when test="contains($chars,' ')">
        <xsl:variable name="char" select="substring-before($chars,' ')"/>
        <xsl:choose>
          <xsl:when test="contains($text,$char)">
            <xsl:variable name="left">
              <xsl:call-template name="StringReplace">
                <xsl:with-param name="text" select="substring-before($text,$char)"/>
                <xsl:with-param name="chars" select="$chars"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="right">
              <xsl:call-template name="StringReplace">
                <xsl:with-param name="text" select="substring-after($text,$char)"/>
                <xsl:with-param name="chars" select="$chars"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="concat($left,
              document('')/*/tex:replace-map/entry[@key=$char],
              $right)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="StringReplace">
              <xsl:with-param name="text" select="$text"/>
              <xsl:with-param name="chars" select="substring-after($chars,' ')"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
