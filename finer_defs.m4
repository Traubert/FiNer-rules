! -*- coding: utf-8 -*-

! Do not require matching complete words
set need-separators off

!======================================================================
!==== Auxiliary definitions
!======================================================================

! Word separator
Define WSep "\n" ;
Define NoWSep [ ? - WSep ] ;
Define Word NoWSep+ ;
Define WordBoundary [ WSep | # ];
! Field (word feature) separator
Define FSep "\t" ;
Define NoFSep [ ? - [ WSep | FSep ] ] ;
Define Field NoFSep* ;
! Lemma variant separator (not needed when lemma disambiguator is in use)
Define VarSep ", " ;

Define AlphaUp   [ UppercaseAlpha | "Ă"|"Ắ"|"Ặ"|"Ẫ"|"Ã"|"Ȧ"|"Ā"|"Ć"|"Ĉ"|"Č"|"Ď"|"Đ"|"Ɖ"|"Ĕ"|"Ě"|"Ề"|"Ệ"|"Ė"|"Ę"|"Ē"|"Ğ"|"Ĝ"|"Ǧ"|"Ĥ"|"Ȟ"|"Ħ"|"Ĭ"|"Ī"|"I"|"Ǩ"|"Ł"|"Ń"|"Ŋ"|"Ŏ"|"Ộ"|"Ő"|"Ȯ"|"Ǫ"|"Ō"|"Ợ"|"Œ"|"Ř"|"Ŕ"|"Ś"|"Š"|"Ş"|"Ṣ"|"Ť"|"Ŧ"|"Ț"|"Ŭ"|"Ů"|"Ű"|"Ū"|"Ụ"|"Ữ"|"Ŵ"|"Ẏ"|"Ȳ"|"Ź"|"Ž"|"Ż"|"Ʒ"|"Ǯ"|"Ə" ] ;

Define AlphaDown [ LowercaseAlpha | "ă"|"ắ"|"ặ"|"ẫ"|"ã"|"ȧ"|"ā"|"ć"|"ĉ"|"č"|"ď"|"đ"|"ɖ"|"ĕ"|"ě"|"ề"|"ệ"|"ė"|"ę"|"ē"|"ğ"|"ĝ"|"ǧ"|"ĥ"|"ȟ"|"ḥ"|"ħ"|"ĭ"|"ī"|"ı"|"ǰ"|"ǩ"|"ł"|"ń"|"ŋ"|"ŏ"|"ộ"|"ő"|"ȯ"|"ǫ"|"ō"|"ợ"|"ơ"|"œ"|"ř"|"ś"|"š"|"ş"|"ṣ"|"ť"|"ŧ"|"ț"|"ŭ"|"ů"|"ű"|"ū"|"ụ"|"ữ"|"ư"|"ŵ"|"ẙ"|"ẏ"|"ȳ"|"ỳ"|"ź"|"ž"|"ż"|"ʒ"|"ǯ"|"ə" ] ;

Define Comma "," ;
Define LPar  "(" ;
Define RPar  ")" ;
Define LBrac "[" ;
Define RBrac "]" ;
Define Apostr      [ "'" | "´" | "’" | "ʻ" | "ʿ" ] ;
Define DoubleQuote [ "\x22" | "”" | "“" | "„" | "»" | "«" ] ;
Define Quote       [ Apostr | DoubleQuote ] ;
Define Dash [ "-" ("-") | "–" | "—" | "—" | "−" ] ;
Define SS "#" ;

Define 1To9 [ "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ] ;
Define 0To9 [ "0" | 1To9 ] ;

Define ParagraphTag [ {<p>} | {</p>} | {<p/>} ] ;

Define SentBoundary [ # | ".#." ( WSep [ Quote | Dash ] FSep Word ) | [ WSep [ "." | "!" | "?" ] FSep Word ] ] ;
Define NoSentBoundary WordBoundary [ [ [ AlphaUp | AlphaDown | Comma | 0To9 | LPar | RPar | "&" | "@" ] Word ] -
       		      		   [ [ 0To9 (0To9) (0To9) "." | ParagraphTag ] FSep Word ] ] WSep ;

!-----

!Define these for lemma_cheat -> improves recall for foreign names
!NB: these definitions are not exhaustive nor waterproof!
!

Define FinVowel   [ "a" | "e" | "i" | "o" | "u" | "y" | "ä" | "ö" | Apostr ] ;
Define Vowel 	  [ FinVowel | "á" | "é" | "í" | "ó" | "ú" | "ā" | "ē" | "ī" | "ō" | "ū" ] ;
!Define FinPhoneme [ "p" | "t" | "k" | "s" | "n" | "m" | "l" | "j" | "h" | FinVowel ] ;
Define SuffSep ( "'" | "’" | ":" | "i" ) ;
Define Clitic ( {han} | {hän} | {kin} | {kaan} | {kään} ) ;

Define NomSuff ( SuffSep Ins(Clitic) ) ;
Define GenSuff SuffSep "n" ( Ins(Clitic) ) ;
Define ParSuff SuffSep ("t")["ä"|"a"] ( Ins(Clitic) ) ;
Define LocIntSuff SuffSep [ {iin} | ("h") FinVowel "n" | "s"["s"|"t"]["a"|"ä"] ] ( Ins(Clitic) ) ;
Define LocExtSuff SuffSep [ "l"["l"|"t"]["a"|"ä"] | {lle} ] ( Ins(Clitic) ) ;
!Define MiscSuff [ {ksi} | {kse} ] ( Ins(Clitic) ) ;

!Define FinSuff [ NomSuff | GenSuff | ParSuff | LocIntSuff | LocExtSuff | MiscSuff ] ; 
Define FinSuff ( SuffSep [ Ins(Clitic) | [ ( "n" | (["t"|{st}|{ss}|{lt}|{ll}])["ä"|"a"] | {lle} | {iin} | ("h") FinVowel "n" | {ks}["e"|"i"] | {na} | {nä} ) ] ( Ins(Clitic) ) ] ) ;

!-----

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
m4_define(`lemma_exact_morph', `[ Field FSep [$1] FSep Field [$2] Field FSep Field FSep ]')
m4_define(`wordform_morph', `[ [$1] FSep Field FSep Field [$2] Field FSep Field FSep ]')

m4_define(`whole_word', `LC(WordBoundary)  [$1]  RC(WordBoundary)')
m4_divert(0)

!------------------------------
Define plural(W) lemma_exact_morph( W, {NUM=PL} ) ;
Define lemma_exact_sg(W) lemma_exact_morph( W, {NUM=SG} ) ;
Define lemma_exact_pl(W) lemma_exact_morph( W, {NUM=PL} ) ;

Define CaseSfx [ "n" | {sta} | {stä} | {ssa} | {ssä} | {lta} | {ltä} | {lla} | {llä} | {lle} | {ksi} | {na} | {nä} ] ;

!------------------------------
! Name inflector
! (intended for foreign names)
!------------------------------

Define Stem0 @bin"infl_stem0.hfst" ; ! Nominative stem
Define Stem1 @bin"infl_stem1.hfst" ; ! Genitive stem
Define Stem2 @bin"infl_stem2.hfst" ; ! Partitive stem
Define Stem3 @bin"infl_stem3.hfst" ; ! Inessive plural stem

Define infl_sg_nom(W) wordform_exact( [ W .o. Stem0 ].l Ins(Clitic) | W ) ;
Define infl_sg_gen(W) wordform_exact( [ W .o. Stem1 ].l "n" Ins(Clitic) ) ;
Define infl_sg_par(W) wordform_exact( [ W .o. Stem2 ].l [ "ä" | "a" ] Ins(Clitic) ) ;
Define infl_sg_ill(W) wordform_exact( [ W .o. @bin"infl_illat.hfst" ].l Ins(Clitic) ) ;
Define infl_sg_ine(W) wordform_exact( [ W .o. Stem1 ].l [{ssa}|{ssä}] Ins(Clitic) ) ;

Define infl_sg_locint(W) wordform_exact( [ W .o. Stem1 ].l [ {sta} | {stä} | {ssa} | {ssä} ] Ins(Clitic) ) ;
Define infl_sg_locext(W) wordform_exact( [ W .o. Stem1 ].l [ {lta} | {ltä} | {lla} | {llä} | {lle} ] Ins(Clitic) ) ;

Define inflect_sg(W)  wordform_exact( [ W .o. Stem1 ].l [ CaseSfx ] Ins(Clitic) ) |
       		      infl_sg_nom(W) | infl_sg_par(W) | infl_sg_ill(W) ;

Define inflect_pl(W)  wordform_exact( [ W .o. Stem1 ].l "t" Ins(Clitic) ) |
       		      wordform_exact( [ W .o. Stem3 ].l [ CaseSfx | {hin} ] Ins(Clitic) ) |
		      wordform_exact( [ W .o. [ @bin"infl_pl_gen.hfst" | @bin"infl_pl_par.hfst" ] ].l Ins(Clitic) ) ;

!------------------------------

Define wordform_x2(W1, W2)	wordform_exact(W1) WSep wordform_exact(W2) ;
Define wordform_x3(W1, W2, W3) 	wordform_exact(W1) WSep	wordform_exact(W2) WSep wordform_exact(W3) ;
Define inflect_x2(W1, W2)    	wordform_exact(W1) WSep inflect_sg(W2) ;
Define inflect_x3(W1, W2, W3)   wordform_exact(W1) WSep wordform_exact(W2) WSep inflect_sg(W3) ;
Define wf_lemma_x2(W1, W2) 	wordform_exact(W1) WSep lemma_exact(W2) ;
Define wf_lemma_x3(W1, W2, W3) 	wordform_exact(W1) WSep wordform_exact(W2) WSep lemma_exact(W3) ;
Define lemma_sg_x2(W1, W2)	lemma_exact_sg(W1) WSep lemma_exact_sg(W2) ;

!------------------------------
! General lemma/wordform types

Define Slash wordform_exact("/") ;

Define LowerWord wordform_exact( AlphaDown Field ) ;

Define CapWord wordform_exact( Ins(AlphaUp) Field ) ;
Define CapWordPart AlphaUp Word ;
Define CapWordNSB LC( NoSentBoundary ) AlphaUp Word ;

Define AndOfTheStr [ {for} | {by} | {of} | {the} | {and} | "&" | {to} | {with} | {against} | {at} | {in} | {de} | {för} | {vid} | {och}
       		   | {i} | {till} | {für} | {degli} | {della} | {delle} | {und} | {an} | {no} | {et} | {dei} | {di} | {des}
		   | {la} | {y} | {e} | {est} | {non} | {pas} | {el} | {av} | ( "d" Apostr ) {un}("e") ] ;

Define AndOfThe wordform_exact( AndOfTheStr ) ;

Define NumWord wordform_ends( 0To9 Field ) ;
Define CapNum wordform_ends( [ Ins(AlphaUp) | 0To9 ] ) ;
Define CapNameStr ( Alpha Apostr | [{al}|{el}] Dash ) AlphaUp AlphaDown+ ( Dash AlphaUp AlphaDown+ ) ( Apostr AlphaDown+ ) ;

Define AcrNom AlphaUp+ FSep Word ;
Define NumRoman ("X") ("X") [ ("V") "I" ("I")("I") | ("I") ["V"|"X"] ] ;
Define CamelCase AlphaUp AlphaDown+ AlphaUp Field ;
Define WebDomain Alpha+ LowercaseAlpha+ "." [ LowercaseAlpha ]^{2,3} ;

Define SPunct [ "." | "?" | "!" | ":" | Dash | Quote | ParagraphTag ] ;
Define SentencePunct lemma_exact( SPunct ) ;

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

!Define FSTR1
!       [ "C" | "Q" | "W" | "X" | "Z" | "Å" | "Ø" ] AlphaDown^{1,7} ;

!Define FSTR2
!       Ins(AlphaUp) AlphaDown^{0,6} [ "c" | "q" | "w" | "x" | "z" | "å" | "ø" ] AlphaDown^{0,6} ;

Define ADashA
       Field [
       "a" Dash "a" |
       "e" Dash	"e" |
       "i" Dash	"i" | 
       "o" Dash	"o" |
       "u" Dash	"u" |
       "y" Dash	"y" |
       "ä" Dash	"ä" |
       "ö" Dash "ö" ]
       Field ;

!------------------------------
! Morphologic/semantic

Define AdjPcp [ {ADJECTIVE} | {PCP=} ] ;

Define PosAdv morphtag([{POS=ADVERB}|{POS=PARTICLE}]) ;
Define PosAdj morphtag(AdjPcp) ;    !! adjectives + adjectival verb forms recognized from comparation tag
Define PosAdjNom morphtag({POS=ADJECTIVE} Field {CASE=NOM}) ;
Define PosAdjGen morphtag({POS=ADJECTIVE} Field {CASE=GEN}) ;

Define PosNum morphtag({POS=NUMERAL}) ;
Define PosNumCard [ morphtag({[POS=NUMERAL][SUBCAT=CARD]}) | morphtag_exact({[POS=NUMERAL]} ({NUM=} Field) ) ] ;
Define PosNumOrd morphtag({[POS=NUMERAL][SUBCAT=ORD]}) ;
Define NumNom wordform_exact( 0To9+ [ " " 0To9 0To9 0To9 ]* ) ;

Define CaseNom morphtag({CASE=NOM}) ;
Define CaseGen morphtag({CASE=GEN}) ;
Define CasePar morphtag({CASE=PAR}) ;
!Define CaseEss morphtag({CASE=ESS}) ;
!Define CaseNomGen morphtag({CASE=}[{NOM}|{GEN}]) ;
!Define CaseGenSg morphtag({NUM=SG][CASE=GEN}) ;

Define PosNoun morphtag({POS=NOUN}) ;
Define NounNom morphtag({POS=NOUN} Field {CASE=NOM}) ;
Define NounGen morphtag({POS=NOUN} Field {CASE=GEN}) ;
Define NounGenPl morphtag({POS=NOUN} Field {NUM=SG} Field {CASE=GEN}) ;
Define AdjNom morphtag(AdjPcp Field {CASE=NOM}) ;
Define AdjGen morphtag(AdjPcp Field {CASE=GEN}) ;
!Define AdjParPl morphtag(AdjPcp Field {[NUM=PL][CASE=PAR]}) ;
!Define NumAdjGen morphtag([{NUMERAL} | AdjPcp] Field {CASE=GEN}) ;
!Define PronAdjEss morphtag([{PRONOUN} | AdjPcp] Field {CASE=ESS}) ;
!Define PronAdjAde morphtag([{PRONOUN} | AdjPcp] Field {CASE=ADE}) ;
!Define PronAdjIne morphtag([{PRONOUN} | AdjPcp] Field {CASE=INE}) ;
!Define PronAdjGen morphtag([{PRONOUN} | AdjPcp] Field {CASE=GEN}) ;
!Define PronAdjPar morphtag([{PRONOUN} | AdjPcp] Field {CASE=PAR}) ;
!Define PronAdjIll morphtag([{PRONOUN} | AdjPcp] Field {CASE=ILL}) ;
!Define PronNumAdjGen morphtag([{POS=} [{PRONOUN} | {NUMERAL} | {ADJECTIVE}] | {VERB} Field {PCP=} ] Field {CASE=GEN}) ;

!Define PronOAdjEss [[Field FSep [{edel}|{seura}|{kulu}] Word AdjPcp] | Word {POS=PRONOUN}] Field {CASE=ESS} Word ;
!Define PronOAdjAde [[Field FSep [{edel}|{seura}|{kulu}] Word AdjPcp] | Word {POS=PRONOUN}] Field {CASE=ADE} Word ;
!Define PronOAdjIne [[Field FSep [{edel}|{seura}|{kulu}] Word AdjPcp] | Word {POS=PRONOUN}] Field {CASE=INE} Word ;
!Define PronOAdjGen [[Field FSep [{edel}|{seura}|{kulu}] Word AdjPcp] | Word {POS=PRONOUN}] Field {CASE=GEN} Word ;
!Define PronOAdjPar [[Field FSep [{edel}|{seura}|{kulu}] Word AdjPcp] | Word {POS=PRONOUN}] Field {CASE=PAR} Word ;
!Define PronOAdjIll [[Field FSep [{edel}|{seura}|{kulu}] Word AdjPcp] | Word {POS=PRONOUN}] Field {CASE=ILL} Word ;

Define CoordConj morphtag({[SUBCAT=CONJUNCTION][CONJ=COORD]}) ;
Define NotConj [ wordform_exact( [ Ins(AlphaUp) | Ins(AlphaDown) | 0To9 ] Field ) - CoordConj ] ;

Define Prop morphtag({PROPER}) ;
Define PropNom morphtag({PROPER} Field {[NUM=SG][CASE=NOM]}) ;
Define PropGen morphtag({PROPER} Field {[NUM=SG][CASE=GEN]}) ;

Define PropGeo semtag({PROP=GEO}) ;
Define PropGeoNom morphtag_semtag({CASE=NOM}, {PROP=GEO}) ;
Define PropGeoGen morphtag_semtag({CASE=GEN}, {PROP=GEO}) ;
Define PropGeoPar morphtag_semtag({CASE=PAR}, {PROP=GEO}) ;
Define PropGeoIne morphtag_semtag({CASE=INE}, {PROP=GEO}) ;
Define PropGeoAde morphtag_semtag({CASE=ADE}, {PROP=GEO}) ;
Define PropGeoLocInt morphtag_semtag({NUM=SG} Field {CASE=}[{INE}|{ILL}|{ELA}], {PROP=GEO}) ;

Define PropFirst semtag({PROP=FIRST}) ;
Define PropFirstNom morphtag_semtag({CASE=NOM}, {PROP=FIRST}) ;
Define PropFirstGen morphtag_semtag({CASE=GEN}, {PROP=FIRST}) ;
Define PropLast semtag({PROP=LAST}) ;
Define PropLastNom morphtag_semtag({CASE=NOM}, {PROP=LAST}) ;
Define PropLastGen morphtag_semtag({CASE=GEN}, {PROP=LAST}) ;
Define PropFirstLast [ PropFirst | PropLast ] ;
Define PropFirstLastNom [ PropFirstNom | PropLastNom ] ;
Define PropFirstLastGen [ PropFirstGen | PropLastGen ] ;

Define PropOrg semtag({PROP=ORG}) ;
Define PropOrgNom morphtag_semtag({CASE=NOM}, {PROP=ORG}) ;
Define PropOrgGen morphtag_semtag({CASE=GEN}, {PROP=ORG}) ;
Define PropOrgPar morphtag_semtag({CASE=PAR}, {PROP=ORG}) ;

!Define PropUnspec morphtag_semtag({SUBCAT=PROPER}, "-") ;

!------------------------------

Define AuxVerb lemma_exact( {ei} | {olla} ) ;

!------------------------------

Define PunctWord morphtag({POS=PUNCTUATION}) ;

Define Abbr morphtag({ABBREVIATION}) ;
Define AbbrNom [ morphtag({ABBREVIATION} Field {[NUM=SG][CASE=NOM]})
       	       | morphtag_exact({[POS=PARTICLE][SUBCAT=ABBREVIATION]})
	       | wordform_exact( AlphaUp+ [ 1To9+ | AlphaUp+ ]+ )
	       ] ;

Define CapWordNom whole_word(`CapWordPart {[CASE=NOM]} Word') ;
Define CapWordGen whole_word(`CapWordPart {[CASE=GEN]} Word') ;
Define CapWordNomGen whole_word(`CapWordPart {[CASE=} [{NOM}|{GEN}] "]" Word') ;
!Define CapWordNomSg whole_word(`CapWordPart {[NUM=SG][CASE=NOM]} Word') ;
!Define CapWordGenPar whole_word(`CapWordPart {[CASE=} [{GEN}|{PAR}] "]" Word') ;
!Define CapWordGenSg whole_word(`CapWordPart {[NUM=SG][CASE=GEN]} Word') ;
!Define CapWordNomGenSg whole_word(`CapWordPart {[NUM=SG][CASE=} [{NOM}|{GEN}] "]" Word') ;
Define CapWordNomOrEt [ CapWordNom | wordform_exact("&" | {and}) ] ;

Define CapNounNom AlphaUp morphtag({POS=NOUN} Field {[NUM=SG][CASE=NOM]}) ;
Define CapNounGen AlphaUp morphtag({POS=NOUN} Field {[NUM=SG][CASE=GEN]}) ;

Define CapNounNSB LC( NoSentBoundary ) Ins(AlphaUp) morphtag({POS=NOUN}) ; ! <--- New!
Define CapNounNomNSB LC( NoSentBoundary ) Ins(AlphaUp) morphtag({CASE=NOM}) ;
Define CapNounGenNSB LC( NoSentBoundary ) Ins(AlphaUp) morphtag({CASE=GEN}) ;
Define CapNounIneNSB LC( NoSentBoundary ) Ins(AlphaUp) morphtag({CASE=INE}) ;
Define CapNounAdeNSB LC( NoSentBoundary ) Ins(AlphaUp) morphtag({CASE=ADE}) ;

Define CapName wordform_exact( CapNameStr ) ;
Define CapNameNom [ CapNameStr - [ Field [ FinVowel ["n"|{ssä}|{ssa}|{llä}|{lla}|{lle}|{ltä}|{lta}|{sta}|{stä}] | {iin} | {aan} | {ään} ]]] FSep Word ;
Define CapNameGen [ [ CapNameStr [ Vowel ] "n" FSep Word ] - [ LowercaseAlpha LowercaseAlpha LowercaseAlpha {inen} FSep Word ] ] ;

Define CapNameNSB LC( NoSentBoundary ) CapName ;
Define CapNameNomNSB LC( NoSentBoundary ) CapNameNom ;
Define CapNameGenNSB LC( NoSentBoundary ) CapNameGen ;

Define TruncPfx wordform_ends( AlphaDown Dash ) ;

Define CapNomWithN
       wordform_exact(
		[ {Domain} | {Open} | {European} | {American} | {African} | {Asian} | {Main} | {Syrian} | {London} | {Station} | {San}
		| {Union} | {Western} | {Falcon} | {Debian} | {Captain} | {Human} | {Emotion} | {Pan} | {Education} | {Canon} | {Christian}
		| {Women} | {Men} | {Nation} | {Motion} | {Time} | {Queen} | {Champion} | {Indian} | {Norwegian} | {Australian} | {Ten}
		| {An} | {Milton} | {Hilton} | {Titan} | {Aryan} | {Austrian} | {German} | {Silicon} | {Icon} | {Falcon} | {Recon}
		| {Lexicon} | {In} | {Teen} | {Canadian} | {Min} | {Don} | {Photon} | {Neutron} | {Hadron} | {Un} | {Den} | {Great}
		| {Independent} | {Ålands} | {Malaysian} | {Golden} | {Japan} | {Golden} | {Collection} | {Operation}
		| AlphaUp AlphaDown* [ AlphaDown - "a" ] {ation} ]
		) ;

Define CapForeign [ Ins(AlphaUp) morphtag({SUBCAT=FOREIGN}) ] ;
Define CapSpec	  [ Ins(AlphaUp) lemma_morph( AlphaDown, {PROPER} Field {[NUM=SG][CASE=NOM]}) | CapForeign ] ;
Define CapMisc	  [ CapSpec | CapNameNomNSB | CapNomWithN ] ;
Define CapMiscFirst [ CapNameNomNSB | CapForeign | PropFirstNom ] ;

!------------------------------

Define USpl [{Yhdysvalt}[{ain}|{ojen}]|{USA:n}] FSep Word ;

! XXX -(työ)nimellä tunnettu/kulkeva/kehitetty
Define DashName1
       Dash wordform_ends({nimellä}) WSep morphtag({PCP=}) WSep ;

! XXX -niminen/merkkinen
Define DashName2
       [ (Dash) lemma_exact((Dash)[{niminen}|{merkkinen}]) | wordform_exact( Dash {nimistä} ) ] WSep ;

! XXX -nimeä kantava
Define DashName3
       Dash wordform_ends({nimeä}) WSep morphtag({PCP=VA}) WSep ;

Define DashName4
       Dash AlphaDown+ Word WSep lemma_exact( {ja} | {sekä} ) WSep ( Dash ) ;

Define DashExt [ Dash (FSep Word WSep) | DashName1 | DashName2 | DashName3 | DashName4 ] ;
