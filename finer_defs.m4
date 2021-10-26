! -*- coding: utf-8 -*-

! Do not require matching complete words
set need-separators off
! Use unicode classes
set use-character-classes on

!======================================================================
!==== Auxiliary definitions
!======================================================================

! Word separator and field delimiters

Define WSep "\n" ;
Define NoWSep [ ? - WSep ] ;
Define Word NoWSep+ ;
Define FSep "\t" ;
Define NoFSep [ ? - [ WSep | FSep ] ] ;
Define Field NoFSep* ;

!======================================================================

! Alphabetic characters not covered by built-in Alpha sets

Define AlphaUp UppercaseAlpha ;

Define AlphaDown LowercaseAlpha ;

Define AlphaAny Alpha;

!======================================================================

! Puncutation & Misc

Define Comma "," ;
Define LPar  "(" ;
Define RPar  ")" ;
Define LBrac "[" ;
Define RBrac "]" ;

Define Apostr      [ "'" | "´" | "’" | "ʻ" | "ʿ" ] ;
Define DoubleQuote [ "\x22" | "”" | "“" | "„" | "»" | "«" ] ;
Define Quote       [ Apostr | DoubleQuote ] ;
Define Dash 	   [ "-" ("-") | "–" | "—" | "—" | "−" ] ;

list 1To9 [ "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ] ;
Define 0To9 [ "0" | 1To9 ] ;

Define SentBreakTag [ {<p} | {<paragraph} | {<sentence} | {<text} | {<body} ] (" " NoFSep+) {>} ;

!======================================================================

! Sentence and word boundaries

Define WordBoundary [ WSep | # ] ;
Define SentBoundary [ [ ".#." ( WSep [ Quote | Dash ] FSep Word ) WSep ] |
		      [ WSep [ "." | "!" | "?" | ":" | Dash | SentBreakTag ] FSep Word WSep ] |
		      # ] ;

Define NoSentBoundary WordBoundary [ [ [ AlphaUp | AlphaDown | Comma | 0To9 | LPar | RPar | "&" | "@" | "/" ] Word ] -
                                   [ [ 0To9 (0To9) (0To9) "." | SentBreakTag ] FSep Word ] ] WSep ;

!======================================================================

m4_divert(-1)
# Define M4 macros for referring to individual features of a word
m4_define(`wordform_ends', `[ Field [$1] FSep Field FSep Field FSep Field FSep ]')
m4_define(`wordform_exact', `[ [$1] FSep Field FSep Field FSep Field FSep ]')
m4_define(`lemma_ends', `[ Field FSep Field [$1] FSep Field FSep Field FSep ]')
m4_define(`lemma_exact', `[ Field FSep [$1] FSep Field FSep Field FSep ]')
m4_define(`morphtag', `[ Field FSep Field FSep Field [$1] Field FSep Field FSep ]')
m4_define(`morphtag_exact', `[ Field FSep Field FSep [$1] FSep Field FSep ]')
m4_define(`semtag', `[ Field FSep Field FSep Field FSep Field [$1] Field FSep ]')
m4_define(`semtag_exact', `[ Field FSep Field FSep Field FSep [$1] FSep ]')
m4_define(`morphtag_semtag', `[ Field FSep Field FSep Field [$1] Field FSep Field [$2] Field FSep ]')
m4_define(`morphtag_semtag_exact', `[ Field FSep Field FSep Field [$1] Field FSep [$2] FSep ]')
m4_define(`morphorsemtag', `[ Field FSep Field FSep NoWSep* [$1] NoWSep* FSep ]')
m4_define(`lemma_morph', `[ Field FSep Field [$1] FSep Field [$2] Field FSep Field FSep ]')
m4_define(`lemma_semtag', `[ Field FSep Field [$1] FSep Field FSep Field [$2] Field FSep ]')
m4_define(`lemma_exact_morph', `[ Field FSep [$1] FSep Field [$2] Field FSep Field FSep ]')
m4_define(`wordform_morph', `[ [$1] FSep Field FSep Field [$2] Field FSep Field FSep ]')

m4_define(`whole_word', `LC(WordBoundary)  [$1]  RC(WordBoundary)')
m4_divert(0)

!======================================================================

!======================================================================
! Name inflector for foreign names
!----------------------------------------------------------------------
list FinVowel   [ "a" | "e" | "i" | "o" | "u" | "y" | "ä" | "ö" | Apostr ] ;
list Vowel      [ "á" | "é" | "í" | "ó" | "ú" | "ý" | "ü" | "ű" | "ā" | "ē" | "ī" | "ō" | "ū" | "ã" | FinVowel ] ;
list CapVowel   [ "A" | "E" | "I" | "O" | "U" | "Y" | "Ä" | "Ö" | "Ü" ] ;
Define Cons	Lst({BCDFGHJKLMNPQRSTVWXZÇÐÑÞẞbcdfghjklmnpqrstvwxzçðñþß}); ! Cons doesn't appear in subtractions so can be a Lst()

list SuffSep    ( "'" | "’" | ":" | "i" ) ;
list Silent     [ "s" | "z" | "t" | "x" | "r" | "h" | "w" | "j" | "ł" ] ;

Define StemVs  @re"infl/stem_Vs.regex" ;
Define expand_stems(W) [ W .o. StemVs ].l ;

Define CaseSfx 	[ "n" | {sta} | {stä} | {ssa} | {ssä} | {lta} | {ltä} | {lla} | {llä} | {lle} | {ksi} | {na} | {nä} ] ;
Define Clitic  	[ {han} | {hän} | {kin} | {kaan} | {kään} ] ;

Define SmartSep [ LC( Lst(Vowel) | Lst(CapVowel) | ":" ) (":") |
		  LC( Cons ) "i" |
       		  LC( Lst(Silent) ) ( Apostr | "i" ) |
		  ":" ] ;

Define AddI	  LC( Cons ) "i" ;

Define SmartSfx	[ SmartSep Ins(CaseSfx) ] ;
Define NomSuff	( ( SmartSep ) Ins(Clitic) ) ;
Define GenSuff	[ SmartSep "n" ] ;

Define ParSuff  [ LC( Lst(Vowel) ) [ "a" | "ä" ] |
       		  LC( Lst(Vowel) Lst(Vowel) ) "t" [ "a" | "ä" ] |
       		  LC( Cons ) "i" [ "a" | "ä" ] |
		  LC( "s" ) "t" [ "a" | "ä" ] |
		  LC( Lst(Silent) | AlphaUp Lst(Vowel) ) [ (Apostr) "t" ] [ "a" | "ä" ] |
		  LC( ":" ) [ ("t") [ "a" | "ä" ] | {aa} | {ää} ] |
		  LC( [? - AlphaDown] ) ":" [ ("t") [ "a" | "ä" ] | {aa} | {ää} ]
		  ];
		  
Define IllSuff  [ LC( {ks} ) {een} |
       		  LC( Lst(Silent) | AlphaUp Lst(Vowel) ) Apostr "h" Lst(Vowel) "n" |
		  LC( "a" | "A" | "á" | "à" | "â" | "ă" ) (":") ("h") {an} |
		  LC( "e" | "E" | "é" | "è" | "ê" | "ë" | "ě" | {ai} ) (":") ("h") {en} |
		  LC( "i" | "I" | "í" | "ì" | "î" | "ï" | "y" | "j" | "ĳ" | {eu} | {äu} | {ee} ) (":") ("h") {in} |
		  LC( "u" | "U" | "ú" | "ù" | "û" | {ew} | {oo} | {oe} ) (":") ("h") {un} |
		  LC( "y" | "Y" | "ü" | "Ü" | "u" | {ue} ) (":") ("h") {yn} |
		  LC( "o" | "O" | "ó" | "ò" | "ô" | {au} | {aw} ) (":") ("h") {on} |
		  LC( "ä" | "Ä" | "æ" | {ae} | "á" ) (":") ("h") {än} |
		  LC( "ö" | "Ö" | "œ" | "ø" | {oe} | {eu} ) (":") ("h") {ön} |
		  NLC( Vowel ) [ {iin} | {:h} Lst(Vowel) "n" | ":" [ {aa} | {ee} | {ii} | {oo} | {uu} | {yy} | {ää} | {öö} ] "n" ]
		  ] ;

Define IneSuff	[ SmartSep [{ssa}|{ssä}] ] ;
Define ElaSuff  [ SmartSep [{sta}|{stä}] ] ;

Define inflect_sg(W)  wordform_exact( W ( [ Ins(SmartSfx) | Ins(ParSuff) | Ins(IllSuff) ] ( Ins(Clitic) ) |
       		      		      	  ( SmartSep ) Ins(Clitic) ) ) ;

Define infl_sg_nom(W) wordform_exact( W ( ( SmartSep ) Ins(Clitic) ) ) ;
Define infl_sg_gen(W) wordform_exact( W Ins(GenSuff) ( Ins(Clitic) ) ) ;
Define infl_sg_par(W) wordform_exact( W Ins(ParSuff) ( Ins(Clitic) ) ) ;
Define infl_sg_ill(W) wordform_exact( W Ins(IllSuff) ( Ins(Clitic) ) ) ;
Define infl_sg_ine(W) wordform_exact( W Ins(IneSuff) ( Ins(Clitic) ) ) ;

Define infl_sg_locint(W) wordform_exact( W SmartSep [ {sta} | {stä} | {ssa} | {ssä} ] ( Ins(Clitic) ) |
       			 		 W Ins(IllSuff) ( Ins(Clitic) ) ) ;
Define infl_sg_locext(W) wordform_exact( W SmartSep [ {lta} | {ltä} | {lla} | {llä} | {lle} ] ( Ins(Clitic) ) ) ;

Define inflect_pl(W)  wordform_exact([ W .o. [ @re"infl/pl_nom.regex" ] ].l "t" ( Ins(Clitic) )) |
       		      wordform_exact([ W .o. [ @re"infl/pl_ill.regex" ] ].l [ CaseSfx | {hin} ] ( Ins(Clitic) )) |
		      wordform_exact([ W .o. [ @re"infl/pl_gen.regex" | @re"infl/pl_par.regex" ] ].l ( Ins(Clitic) )) ;

!======================================================================

Define lemma_exact_sg(W) lemma_exact_morph( W, {NUM=SG} ) ;
Define lemma_exact_pl(W) lemma_exact_morph( W, {NUM=PL} ) ;

Define wordform_x2(W1, W2)	wordform_exact(W1) WSep wordform_exact(W2) ;
Define wordform_x3(W1, W2, W3) 	wordform_exact(W1) WSep	wordform_exact(W2) WSep wordform_exact(W3) ;
Define inflect_x2(W1, W2)    	wordform_exact(W1) WSep inflect_sg(W2) ;
Define inflect_x3(W1, W2, W3)   wordform_exact(W1) WSep wordform_exact(W2) WSep inflect_sg(W3) ;
Define wf_lemma_x2(W1, W2) 	wordform_exact(W1) WSep lemma_exact(W2) ;
Define wf_lemma_x3(W1, W2, W3) 	wordform_exact(W1) WSep wordform_exact(W2) WSep lemma_exact(W3) ;
Define lemma_sg_x2(W1, W2)	lemma_exact_sg(W1) WSep lemma_exact_sg(W2) ;

!======================================================================
! General lemma/wordform types
!-----------------------------------------------------------------------

Define Slash wordform_exact("/") ;

Define LowerWord wordform_exact( AlphaDown Field ) ;
Define CapWord wordform_exact( AlphaUp Field ) ;
Define CapWordPart AlphaUp Word ;
Define CapWordNSB LC( NoSentBoundary ) AlphaUp Word ;

Define AndOfTheStr [ {for} | {by} | {of} | {the} | {and} | "&" | {to} | {with} | {against} | {at} | {in} | {de} | {för} | {vid} | {och}
       		   | {i} | {till} | {für} | {degli} | {della} | {delle} | {und} | {an} | {no} | {et} | {dei} | {di} | {do} | {da} | {des} | {zu} | {zum}
		   | {la} | {y} | {e} | {est} | {non} | {pas} | {para} | {el} | {av} | {os} | {as} | ( "d" Apostr ) {un}("e") ] ;

Define AndOfThe wordform_exact( AndOfTheStr ) ;
Define DeLa 	wordform_exact( "d" ( Apostr ) AlphaDown* ) ( WSep wordform_exact(Apostr) ) ( WSep LowerWord ) ;

Define NumWord wordform_ends( 0To9 Field ) ;
Define CapNum wordform_ends( [ AlphaUp | 0To9 ] ) ;
Define CapNameStr ( Alpha Apostr | [{al}|{el}] Dash | AlphaUp AlphaDown ) AlphaUp AlphaDown+ ( Dash AlphaUp AlphaDown+ ) ( Apostr AlphaDown+ ) ;
Define CapNameNomStr [ CapNameStr - [ Field [ Vowel ["n"|{ssä}|{ssa}|{llä}|{lla}|{lle}|{ltä}|{lta}|{sta}|{stä}] |{iin}|{aan}|{ään}|{aa}|{ää}] ]] | [ AlphaUp [ {in} | {an} | {en} ] ] ;

Define AcrNom AlphaUp+ FSep Word ;
Define NumRoman ("X") ("X") [ ("V") "I" ("I")("I") | ("I") ["V"|"X"] ] ;
Define CamelCase AlphaUp AlphaDown+ AlphaUp Field ;
Define WebDomain Alpha+ LowercaseAlpha+ "." [ LowercaseAlpha ]^{2,3} ;

Define SentencePunct lemma_exact( "." | "?" | "!" | ":" | Dash | Quote | SentBreakTag ) ;

!======================================================================

Define SetQuotes(W)
       [ wordform_exact(Apostr) WSep W WSep wordform_exact(Apostr) ] |
       [ wordform_exact(DoubleQuote) WSep W WSep wordform_exact(DoubleQuote) ] ;

Define Italics(W)
       wordform_exact({<i>}) WSep W WSep wordform_exact({</i>}) ;

Define OptQuotes(W)
       [ W | SetQuotes(W) ] ;

Define OptItalics(W)
       [ W | Italics(W) ] ;

Define InQuotes
       SetQuotes( [ AlphaUp | 0To9 Field Alpha ] Word [ WSep [ ? - Quote ] Word ]* ) ;

Define ADashA
       "a" Dash "a" | "e" Dash "e" | "i" Dash "i" | "o" Dash "o" |
       "u" Dash "u" | "y" Dash "y" | "ä" Dash "ä" | "ö" Dash "ö" ;

Define ADashAField
       Field ADashA Field ;

!------------------------------
! Morphologic/semantic

Define PosNum morphtag({POS=NUMERAL}) ;
Define PosNumOrd [ morphtag({[SUBCAT=ORD]}) | lemma_exact_sg({toinen}) ] ;
Define PosNumCard [ morphtag({[SUBCAT=CARD]}|{[SUBCAT=DECIMAL]}) ] ;
Define PosNumCardPar morphtag({[SUBCAT=CARD]} Field {CASE=PAR}) ;
Define NumNom wordform_exact( 0To9+ [ " " 0To9 0To9 0To9 ]* ) ;

Define AdjPcp [ {ADJECTIVE} | {PCP=} ] ;

Define PosAdv 	 morphtag([{POS=ADVERB}|{POS=PARTICLE}]) ;
Define PosAdj	 morphtag(AdjPcp) ;    !! adjectives + adjectival verb forms recognized from comparation tag
Define PosAdjNom morphtag(AdjPcp Field {CASE=NOM}) ;
Define PosAdjGen morphtag(AdjPcp Field {CASE=GEN}) ;
Define PosAdjSg  morphtag(AdjPcp Field {NUM=SG}) ;
Define PosAdjCmp morphtag({CMP=SUP}|{CMP=CMP}) ;
Define PosAdjSup morphtag({CMP=SUP}) ;

Define PosAdjOrd [ PosAdj | Alpha morphtag({SUBCAT=ORD} Field {CASE=}) ] ;

Define CaseNom morphtag({CASE=NOM}) ;
Define CaseGen morphtag({CASE=GEN}) ;
Define CasePar morphtag({CASE=PAR}) ;

Define PosNoun morphtag({POS=NOUN}) ;
Define NounNom morphtag({POS=NOUN} Field {CASE=NOM}) ;
Define NounGen morphtag({POS=NOUN} Field {CASE=GEN}) ;
Define NounGenSg morphtag({POS=NOUN} Field {NUM=SG} Field {CASE=GEN}) ;
Define NounGenPl morphtag({POS=NOUN} Field {NUM=PL} Field {CASE=GEN}) ;
Define NounPl morphtag({POS=NOUN} Field {NUM=PL}) ;

Define CoordConj morphtag({[SUBCAT=CONJUNCTION][CONJ=COORD]}) ;
Define NotConj [ wordform_exact( [ AlphaUp | AlphaDown | 0To9 ] Field ) - CoordConj ] ;
Define Coord   [ lemma_exact( {ja} | Comma ) ] ;

Define Prop morphtag({PROPER}) ;
Define PropNom morphtag({PROPER} Field {[NUM=SG][CASE=NOM]}) ;
Define PropGen morphtag({PROPER} Field {[NUM=SG][CASE=GEN]}) ;
Define PropPar morphtag({PROPER} Field {[NUM=SG][CASE=PAR]}) ;

Define PropGeo semtag({PROP=GEO}) ;
Define PropGeoNom morphtag_semtag({CASE=NOM}, {PROP=GEO}) ;
Define PropGeoGen morphtag_semtag({CASE=GEN}, {PROP=GEO}) ;
Define PropGeoPar morphtag_semtag({CASE=PAR}, {PROP=GEO}) ;
Define PropGeoIne morphtag_semtag({CASE=INE}, {PROP=GEO}) ;
Define PropGeoAde morphtag_semtag({CASE=ADE}, {PROP=GEO}) ;
Define PropGeoLocInt morphtag_semtag({NUM=SG} Field {CASE=}[{INE}|{ILL}|{ELA}], {PROP=GEO}) ;
Define PropGeoLocExt morphtag_semtag({NUM=SG} Field {CASE=}[{ADE}|{ALL}|{ABL}], {PROP=GEO}) ;

Define PropFirst semtag({PROP=FIRST}) ;
Define PropFirstNom morphtag_semtag({CASE=NOM}, {PROP=FIRST}) - lemma_exact({le}) ;
Define PropFirstGen morphtag_semtag({CASE=GEN}, {PROP=FIRST}) ;
Define PropFirstPar morphtag_semtag({CASE=PAR}, {PROP=FIRST}) ;

Define PropLast semtag({PROP=LAST}) ;
Define PropLastNom morphtag_semtag({CASE=NOM}, {PROP=LAST}) ;
Define PropLastGen morphtag_semtag({CASE=GEN}, {PROP=LAST}) ;
Define PropLastPar morphtag_semtag({CASE=PAR}, {PROP=LAST}) ;

Define PropFirstLast [ PropFirst | PropLast ] ;
Define PropFirstLastNom [ PropFirstNom | PropLastNom ] - lemma_exact({le}) ;
Define PropFirstLastGen [ PropFirstGen | PropLastGen ] ;
Define PropFirstLastPar [ PropFirstPar | PropLastPar ] ;

Define PropOrg semtag({PROP=ORG}) ;
Define PropOrgNom morphtag_semtag({CASE=NOM}, {PROP=ORG}) ;
Define PropOrgGen morphtag_semtag({CASE=GEN}, {PROP=ORG}) ;
Define PropOrgPar morphtag_semtag({CASE=PAR}, {PROP=ORG}) ;

Define PropCountry	morphtag({[PROP=GEO][SEM=COUNTRY]}) ;

!------------------------------

Define AuxVerb lemma_exact( {ei} | {olla} ) ;

!------------------------------

Define PunctWord morphtag({POS=PUNCTUATION}) ;

Define AbbrStr [ Alpha [ 0To9 | UppercaseAlpha ]^{1,4} ] ;
Define Abbr    inflect_sg( Ins(AbbrStr) ) ;
Define AbbrNom wordform_exact( Ins(AbbrStr) | {St.} ) ;
Define AbbrGen wordform_exact( Ins(AbbrStr) ( ":" | "i" ) "n" ) ;
Define AbbrPar wordform_exact( Ins(AbbrStr) ( ":" ("t") | "i" ) ["a"|"ä"] ) ;

Define CapWordNom whole_word(`CapWordPart {[CASE=NOM]} Word') ;
Define CapWordGen whole_word(`CapWordPart {[CASE=GEN]} Word') ;
Define CapWordNomGen whole_word(`CapWordPart {[CASE=} [{NOM}|{GEN}] "]" Word') ;
Define CapWordNomOrEt [ CapWordNom | wordform_exact("&" | {and}) ] ;

Define CapWordNomNSB LC( NoSentBoundary ) CapWordNom ;

Define CapNounNom AlphaUp morphtag({POS=NOUN} Field {[NUM=SG][CASE=NOM]}) ;
Define CapNounGen AlphaUp morphtag({POS=NOUN} Field {[NUM=SG][CASE=GEN]}) ;
Define CapNounPar AlphaUp morphtag({POS=NOUN} Field {[NUM=SG][CASE=PAR]}) ;

Define CapNounNSB    LC( NoSentBoundary ) AlphaUp morphtag({POS=NOUN}) ;
Define CapNounNomNSB LC( NoSentBoundary ) AlphaUp morphtag({CASE=NOM}) ;
Define CapNounGenNSB LC( NoSentBoundary ) AlphaUp morphtag({CASE=GEN}) ;
Define CapNounIneNSB LC( NoSentBoundary ) AlphaUp morphtag({CASE=INE}) ;
Define CapNounAdeNSB LC( NoSentBoundary ) AlphaUp morphtag({CASE=ADE}) ;

Define CapName wordform_exact( CapNameStr ) ;
Define CapNameNom wordform_exact( CapNameNomStr ) ;
Define CapNameGen [ [ CapNameStr [ Vowel ] "n" FSep Word ] - [ LowercaseAlpha LowercaseAlpha LowercaseAlpha {inen} FSep Word ] ] ;
Define CapNamePar [ CapNameStr Ins(ParSuff) FSep Word ] ;

Define CapNameNSB LC( NoSentBoundary ) CapName ;
Define CapNameNomNSB LC( NoSentBoundary ) CapNameNom ;
Define CapNameGenNSB LC( NoSentBoundary ) CapNameGen ;
Define CapNameParNSB LC( NoSentBoundary ) CapNamePar ;

Define TruncPfx wordform_ends( [ Alpha | 0To9 ] Dash ) ;

Define CapForeignForm
       wordform_exact( AlphaUp AlphaDown* [{nt}|{lt}|{ic}|{cs}|{ll}|{ss}|{ts}|{dt}|{tt}] |
       		       AlphaUp AlphaDown+ ["b"|"c"|"d"|"f"|"g"|"h"|"j"|"k"|"m"|"p"|"q"|"v"|"w"|"x"|"z"|"å"] ) ;

Define CapNomWithN
		[ {Domain} | {Open} | {European} | {American} | {African} | {Asian} | {Main} | {Syrian} | {London} | {Station} | {San}
		| {Union} | {Western} | {Falcon} | {Debian} | {Captain} | {Human} | {Emotion} | {Pan} | {Education} | {Canon} | {Christian}
		| {Women} | {Men} | {Nation} | {Motion} | {Time} | {Queen} | {Champion} | {Indian} | {Norwegian} | {Australian} | {Ten}
		| {An} | {Milton} | {Hilton} | {Titan} | {Aryan} | {Austrian} | {German} | {Silicon} | {Icon} | {Falcon} | {Recon}
		| {Lexicon} | {In} | {Teen} | {Canadian} | {Min} | {Don} | {Photon} | {Proton} | {Neutron} | {Electron}
		| {Hadron} | {Un} | {Den} | {Great} | {Invasion} | {Within} | {Revolution} | {Pen} | {Can} | {Ten} | {Electronic}
		| {Independent} | {Malaysian} | {Golden} | {Japan} | {Collection} | {Operation} | {Dragon} | {Action}
		| {Edition} | {Fusion} | {Mission} | {Commission} | {Horizon} | {Caravan} | {Titan} | {Mr.} | {Dr.} | {Million} | {Billion} 
		| {Marathon} | {Virgin} | {Norden} | {Ben} | {Johnson} | {Morgan} | {Equation} | {Taiwan} | {International} | {Global}
		| {Dolphin} | {In} | AlphaUp {an} | {Typhoon} | {Mountain} | {Russian} | {Hidden} | {Green}
		| AlphaUp AlphaDown* [ AlphaDown - "a" ] {ation} | AlphaUp AlphaDown* {lution} | AlphaUp AlphaDown+ {ción}
		| AlphaUp AlphaDown* Apostr "s" | AlphaUp AlphaDown* {ction} ] ;

Define CapNameProp  [ wordform_morph( CapNameStr, [{FOREIGN}|{PUNCTUATION}|{[POS=PARTICLE][SUBCAT=ABBREVIATION]}|{PROPER} Field {[NUM=SG][CASE=NOM]}] ) ] | CapNameNom {PROPER} Field {NUM=SG} Word ;
Define CapMisc	    [ CapNameNomNSB | CapNameProp | CapForeignForm ] ;

!Define CapMiscExt   wordform_ends( 0To9 Alpha | Alpha [ 0To9 | AlphaUp ] | [ Alpha | 0To9 ] Field CapNameNomStr |
!       		    		   CapNomWithN | AlphaUp "." ) | Field CapMisc ;

Define CapMiscExt   [ [ Alpha | 0To9 ] Field CapNameNom | CapMisc | Field wordform_exact(CapNomWithN) |
       		      Field CapForeignForm | Field AbbrNom |
       		      wordform_exact( UppercaseAlpha "." ) ] ;

Define Serial [ wordform_exact( Field AlphaUp | Field Alpha Field 0To9 | Field 0To9 Alpha (Alpha) ) |
       	      	[ Alpha | 0To9 ] Field CapNameNom ] ;

Define WordsNom [ ( CapName WSep ) Ins(AndOfThe) WSep | CapMisc WSep ]+ ;

!------------------------------

! XXX -(työ)nimellä tunnettu/kulkeva/kehitetty
Define DashName1
       Dash wordform_ends({nimellä}) WSep morphtag({PCP=}) WSep ;

! XXX -niminen/merkkinen
Define DashName2
       [ (Dash) lemma_exact( (Dash) [{niminen}|{merkkinen}] ) | wordform_exact( Dash {nimistä} ) ] WSep ;

! XXX -nimeä kantava
Define DashName3
       Dash wordform_ends({nimeä}) WSep [ lemma_morph([{ava}|{ävä}|{eva}|{evä}], {POS=ADJECTIVE}) | morphtag({PCP=VA}) ] WSep ;

Define DashName4
       Dash LowerWord WSep lemma_exact( {ja} | {sekä} ) WSep Dash ;

Define DashExt [ Dash | DashName1 | DashName2 | DashName3 | DashName4 ] [ Ins(PosAdj) WSep ]* ;

