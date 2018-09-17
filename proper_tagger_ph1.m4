!-*- coding: utf-8 -*-

! HFST Pmatch rules for recognizing Finnish named entities.
! The rules assume that input words are one per line and have four fields,
! separated by tabs: 1) wordform 2) lemma 3) morphological tags 4) proper/semantic tags.

!======================================================================
!==== Auxiliary definitions
!======================================================================

m4_include(`finer_defs.m4')

Define VehicleBrand [ m4_include(`gProdVehicleBrandStr.m4') ] ;

Define CorpOrPro [ @txt"gStatORGxPRO.txt" | VehicleBrand ] ;
Define CorpOrLoc @txt"gStatLOCxORG.txt" ;
Define LocOrPer  @txt"gStatLOCxPER.txt" ;

Define VerbPer	 @txt"per-verbs.txt" ;
Define VerbOrg	 @txt"org-verbs.txt" ;

Define PartyMemberAbbr lemma_exact( [ {kok} | {sit} | {r} | {rkp} | {sdp} | {sd} | {kd} | {vihr} | {skp} | {sin} | {ps} | {kom} |
       		       		      {kesk} | {vas} | {p} | {skdl} | {lib} ] (".") ) ;

Define GeoAdj [ {pohjo} | {etelä} | {länt} | {itä} | {kesk} | {koill} | {kaakko} | {louna} | {luote} ] {inen} ;
Define GeoPfx [ {pohjois} | {etelä} | {itä} | {länsi} | {koillis} | {kaakkois} | {lounais} | {luoteis} |
                {manner} | {sisä} | {meri} | {vähä} | {suur} | {ylä} | {keski} ] ;

Define DayNum [ ( "0" ) 1To9 | [ "1" | "2" ] 0To9 | {30} | {31} ] ;
Define MonthNum [ ( "0" ) 1To9 | {10} | {11} | {12} ] ;
Define MonthPfx [ {tammi} | {helmi} | {maalis} | {huhti} | {touko} | {kesä} | {heinä} | {elo} | {syys} | {loka} | {marras} | {joulu} ] ;

Define GeoNameForeign [ {berg} | {strand} | {wick} | {øy} | {å} | {holm} | {lund} ] ;
Define CountryName @txt"gLocCountry.txt" ;
Define NameInitial wordform_exact( AlphaUp "." (AlphaUp ".") ) ;

!!----------------------------------------------------------------------
!! <EnamexPrsAux>
!!----------------------------------------------------------------------

Define PersTitleStr [ [ Field @txt"gPersTitle.txt" ] -
       		    [ Field [ {digiassistentti} | {verkkolaitetoimittaja} | AlphaDown+ {toimittaja} | {välittäjä} | {markkinajohtaja} ] ] ] ;

!* Do not use Ins() here!
Define PersTitle    lemma_exact( PersTitleStr ) ;
Define PersTitleNom lemma_exact_morph( PersTitleStr, {[NUM=SG][CASE=NOM]} ) ;

Define PersNameParticle wordform_exact( (AlphaUp AlphaDown AlphaDown+ Dash ) OptCap(
       					[ {av} | {af} | {von} | {van} | {de} | {di} | {da} | {del} | {della} | {ibn} ])
					| {der} | {bint} | "Ó" | {O} Apostr | {Vander} )::0.25 ;

Define SurnameSfxPatterns
       AlphaUp AlphaDown* [ @txt"gPersSurnameSuff.txt" ] ;

Define SurnamePfxPatterns
       [ [ {O} Apostr | {Fitz} | {Mc} | {Mac} |{bin-} | {al-} | {el-} | {ash-} | {Di} | {De} | {Le} ] AlphaUp
       | {Fitz} | {Vander} | {Adler} | {Öz} | {Rosen} | {Wester} | {Öster} | {Vester} | {Öfver} | {Silfver} ] AlphaDown+ ;

Define SurnameGuessed
       ( AlphaUp AlphaDown Field+ Dash ) [ SurnamePfxPatterns | SurnameSfxPatterns ] ( Dash AlphaUp AlphaDown Field ) ;

Define SurnameSuffixedFin
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact_morph( AlphaDown+
       [ {lainen} | {läinen} | {skanen} | {skinen} | {kainen} | {käinen}
       | {kkanen} | {kkonen} | {kkönen} | {pponen} | {ppönen} | {ttönen}
       | {ttinen} | {ttunen} | {kkinen} | {kangas} | {lenius} | {nheimo}
       | {nsalo} ]::0.05
       , {NUM=SG} ) ;

Define PersonMiscMultiPart [
       m4_include(`gPersMWord.m4')
       ] ;

!!----------------------------------------------------------------------
!! <EnamexPrsHum>: Human persons
!! 1) Last name, optionally preceded by a first name
!!    and capitalized words or name particle ("von" etc.)
!! 2) First name (and optional cap/particle words) followed by a proper noun
!!    of unspecified or geographical subtype in morphology
!! 3) Any string of capitalized words preceded by a personal title
!! 4) Any string of capitalized words followed by a number between commas or
!!    political party in parentheses
!! ...
!!----------------------------------------------------------------------

Define SurnameFinnishStr @txt"gPersSurnameFinnish.txt" ;

Define SurnameFinnish
       [ Ins(SurnameSuffixedFin) ] |
       [ AlphaUp lemma_exact(DownCase(SurnameFinnishStr)) ] |
       [ wordform_exact( Ins(SurnameFinnishStr) ) ] ;

Define SurnameMisc
       inflect_sg( ( AlphaUp AlphaDown+ Dash ) @txt"gPersSurnameMisc.txt" ) ;

Define FirstnameFinnishStr
       @txt"gPersFirstnameFinnish.txt" ;

Define FirstnameMiscStr
       @txt"gPersFirstnameMisc.txt" ;

Define WeightedPrefix
       AlphaUp AlphaDown+ Dash::0.20 ;

Define FirstnameStr
       ( Ins(WeightedPrefix) ) [ Ins(FirstnameMiscStr) | Ins(FirstnameFinnishStr) ] ;

Define PersonFirstname
       ( Ins(WeightedPrefix) ) inflect_sg( FirstnameMiscStr ) |
       [ ( Ins(WeightedPrefix) ) AlphaUp AlphaDown+ FSep ( AlphaDown+ Dash ) DownCase(FirstnameFinnishStr) FSep Field {NUM=SG} Word ] ;

Define PersonFirstnameNom
       wordform_exact( Ins(FirstnameStr) ) ;

Define JrSr lemma_exact({jr.}|{sr.}) ;

Define GuessedSurnameA
       [ ( Ins(PersNameParticle) WSep ) Ins(PersNameParticle) WSep CapWord ] |
       [ inflect_sg( SurnameGuessed ) ] ;

Define GuessedSurnameB
       [ inflect_sg( AlphaUp AlphaDown Field GeoNameForeign ) ] ;

Define PersonSurnameNom wordform_exact( @txt"gPersSurnameMisc.txt" ) ;

Define PersonSurname
       [ Ins(GuessedSurnameA) | Ins(GuessedSurnameB) | Ins(SurnameFinnish) | Ins(SurnameMisc) ] ;

Define PersonNickname SetQuotes( (AlphaDown) CapWord ( WSep CapWord ) ) ;

!------------------------------------------

Define PersonPrefixed1
       [ Ins(PersonFirstnameNom) WSep ]*
       Ins(PersonFirstnameNom)
       [ WSep NameInitial ]*
       ( WSep define( CapNameStr FinSuff Capture(PerCptS1) FSep Word ) )
       ( WSep JrSr )
       NRC( ( WSep Word ) WSep Dash AlphaDown ) ;

Define PersonPrefixed2
       [ Ins(PersonFirstnameNom) WSep ]+
       CapNameNom
       [ WSep PropFirstLastNom ]*
       ( WSep PropLast )
       ( WSep JrSr )
       NRC( WSep Dash AlphaDown ) ;

Define PersonPrefixed3
       [ [ PersonFirstnameNom ] WSep ]+
       [ PersonNickname ] WSep
       [ CapName - PropOrg ] ;

Define PersonPrefixed4
       [ wordform_exact( Ins(FirstnameMiscStr) ) WSep ]
       CapNameNom WSep
       wordform_exact( [ CapNameStr ] - [ [ {Microsoft} | {Google} | {Samsung} | {Nokia} | {Times} | {Solita} | {Digitoday} ] Field ] ) ;

Define PersonSuffixed1
       [ [ Ins(PersonFirstnameNom) | CapMisc ] WSep ]*
       [ NameInitial WSep ]*
       ( [ CapNameNom | CapMisc ] WSep PersonNickname WSep )
       ( Ins(PersonSurnameNom) WSep )
       Ins(PersonSurname)
       ( WSep JrSr )
       NRC( WSep Dash AlphaDown ) ;

Define PersonGazIsol
       [ Ins(PersonFirstname) | Ins(PersonSurname) ]
       NRC( WSep [ Dash | AlphaUp ] AlphaDown ) ;

Define OnlyPropFirstLastNom
       AlphaUp morphtag_semtag_exact({[NUM=SG][CASE=NOM]}, [{[PROP=FIRST]}|{[PROP=LAST]}]+ ) ;

Define PersonSemtag1
       [ PropFirstLastNom WSep ]+
       ( CapNameNom WSep )
       [ NameInitial WSep ]*
       ( CapNameNom WSep )
       PropFirstLast
       NRC( WSep Dash AlphaDown ) ;

Define PersonSemtag2
       LC( NoSentBoundary )
       [ PropFirstLastNom WSep ]
       [ NameInitial WSep ]*
       CapNameNom
       ( WSep [ PropFirst | PropLast ])
       NRC( WSep Dash AlphaDown ) ;

Define PersonSemtag3
       OnlyPropFirstLastNom
       [ WSep NameInitial ]*
       ( WSep CapName )
       ( WSep [ PropFirst | PropLast ])
       NRC( WSep Dash AlphaDown ) ;

Define PersonSemtag4
       [ [ NameInitial WSep ]+ | [ LC( NoSentBoundary ) AlphaUp::0.25 ] ]
       [ PropLast::0.60 | morphtag_semtag({CASE=}[{ALL}|{ADE}|{ABL}], {PROP=LAST})::0.40 ]
       NRC( WSep Dash AlphaDown ) ;

Define PersonSemtag5
       LC( NoSentBoundary )
       [ NameInitial WSep ]*
       PropFirst
       NRC( WSep Dash AlphaDown ) ;


! "Kaarle Suuri", "Aleksanteri II", "Johannes Paavali II"
Define PersonMonarch
       [ [ AlphaUp PropFirstNom WSep | Ins(PersonFirstnameNom) WSep ]+ |
       	 LC( lemma_exact( {kuningas} | {keisari} | {kuningatar} | {keisarinna} | {hallitsija} | {paavi} |
	     		  {piispa} | {ruhtinas} | {herttua} ) WSep ) CapName WSep ] 
       [ lemma_exact(DownCase(NumRoman)) |
       	 ( wordform_exact(NumRoman) WSep ) AlphaUp lemma_exact({suuri} | AlphaDown+ {npoika}) ] ;

! "Fransiskus Assisilainen", "Kaarle Suuri", "Iivana Julma", "Johannes Kastaja", "Vlad Seivästäjä"
! "Venceslaus Pyhä"
Define PersonEpithet
       ( "P" lemma_exact( {pyhä} ) WSep )
       [ AlphaUp PropFirstNom | Ins(PersonFirstnameNom) ] WSep
       AlphaUp [ morphtag({POS=ADJ} Field {NUM=SG}) | lemma_morph( ["a"|"i"]{ja} | ["ä"|"i"]{jä} | "l"["ä"|"a"]{inen} | {npoika} , {NUM=SG}) ] ;

Define PersonSaint
       "P" lemma_exact( {pyhä} ) WSep
       [ AlphaUp PropFirst | Ins(PersonFirstname) ] ;

!* "Kristus", "Jeesuksen", "Jeesuksen Kristuksen"
Define PersonChrist
       "K" lemma_exact({kristus}) | 
       "J" lemma_exact({jeesus}) ( WSep lemma_exact({kristus}) ) ;

Define PersonSurnameInitialism
       Ins(PersonFirstnameNom) WSep
       AlphaUp lemma_exact( AlphaDown (".") ) ;

Define PersonUsername
       LC( lemma_exact( ( Field Dash ) [ {nimimerkki} | {käyttäjä} ] ) WSep )
       [ wordform_exact( "@" [ Alpha | 0To9 ]+ Field ) | SetQuotes( Prop | NounNom ) | Prop | wordform_exact(CamelCase) ] ;

Define PersonGrecoRoman
       ( CapMisc WSep ( wordform_exact(NumRoman) WSep ) )
       inflect_sg( AlphaUp AlphaDown+ @txt"gPersGrecoRomanSfx.txt" ) ;

Define SurnameEastAsian
       wordform_exact( @txt"gPersSurnameEastAsian.txt" ) ;

!* Chinese, Korean and Vietnamese names of the form [Family Name] [Given Name]
Define PersonEastAsian1
       ( [ CapMisc | Ins(SurnameEastAsian) ] WSep )
       inflect_sg( AlphaUp AlphaDown+ Dash OptCap( @txt"gPersGivenNameEastAsianSfx.txt" ) ) ;

Define PersonEastAsian2
       [ Ins(SurnameEastAsian) WSep ]+
       ( CapMisc WSep )
       CapName ;

!* Spanish and Portuguese multi-part names
Define PersonHispanic
       [ wordform_exact( Ins(FirstnameMiscStr) ) WSep ]+
       [ PropFirstNom WSep ]*
       [ wordform_exact({de}) ( WSep wordform_exact( "l" Field )) WSep [ CapNameNom WSep ]* ]*
       [ [ CapNameNom | PropLastNom ] WSep ]*
       CapName
       ( WSep wordform_exact( {y} | {e} ) WSep CapName ) ;

!--------

Define PersonTitledNom1
       LC( PersTitleNom WSep )
       [ NameInitial WSep ]*
       [ define( AlphaUp AlphaDown Field Capture(PerCptF1) ) FSep Word::0.25 | AlphaUp lemma_exact( DownCase(LocOrPer) ) | PropFirstLast ]
       ( WSep CapWord [ WSep NameInitial ]+ WSep )
       ( WSep define( CapNameStr Capture(PerCptS2) ) FSep Word )
       ( WSep [ PropLast ] )
       ( WSep [ Ins(PersonSurname) ] ) ;

Define PersonTitledNom2
       LC( PersTitleNom WSep )
       wordform_exact( "@" Alpha+ ) ;

Define PersonHyphen1
       [ CapMisc WSep ]*
       [ NameInitial WSep ]*
       ( CapMisc WSep )
       AlphaUp Field ( Word WSep ) Dash lemma_ends({niminen}) WSep
       [ Ins(PersTitle) | lemma_exact( AlphaDown* [ {henkilö} | {asiakas} | {käyttäjä} | {nainen} | {mies} | {poika} | {tyttö} ]) ] ;

!---------

!* Rizzo[, 76, kertoo...]
Define PersonWithAge
       ( CapMisc WSep )
       wordform_exact( CapNameStr Capture(PerCptS3) )
       RC( WSep lemma_exact(Comma) WSep PosNum WSep lemma_exact(Comma) ) ;

Define PerCpt [ PerCptF1 | PerCptS1 | PerCptS2 | PerCptS3 ] ;

Define PersonCaptured
       [ [ wordform_exact([ PerCpt ]) | PropFirstNom | PropLastNom ] WSep ]*
       [ PerCpt ] ( FinSuff ) FSep Word ;

!* Ville Niinistö [(vihr.)]
Define PersonWithParty
       ( CapMisc WSep )
       CapName
       RC( WSep lemma_exact(LPar) WSep PartyMemberAbbr WSep lemma_exact(RPar) ) ;

Define HumanRelativeWord
       lemma_exact([ {puoliso} | {vaimo} | ({elämän}){kumppani} | {tytär} | {vauva} | {esikoinen} | 
       		     [{pojan}|{tyttären}|{siskon}|{sisaren}|{veljen}][{poika}|{tytär}|{tyttö}] |
       		     ({iso}){isä} ({puoli}) | ({iso}){äiti} ({puoli}) | ({iso}|{pikku}){veli} ({puoli}) | ({iso}|{pikku}){sisko} ({puoli}) |
		     {sisar} ({puoli}) | ({pikku}){serkku} | {täti} | {setä} | {eno} | {kummi} | {mumm}["i"|"o"|"u"] | {vaari} |
		     {pa} ("a") {ppa} | {sukulainen} | {perhe}({enjäsen}) | {rakastaja}({tar}) ]) ;

Define PersonIsRelative
       LC( wordform_ends(FinVowel "n") WSep ( PosAdj WSep ) HumanRelativeWord WSep )
       ( CapMisc WSep )
       CapName ;

Define PersonHyphen2
       LC( NoSentBoundary )
       AlphaUp AlphaDown AlphaDown+ Dash lemma_morph( {veli} | {sisko} | {täti} | {setä} | {vaari} | {ukki} | {mumm}["i"|"o"|"u"] | {mamma} | {pappa} | {poika} | {serkku} , {NUM=SG}) ;

! "Xxx [hengästyy]"
Define PersonAction1
       ( Ins(PersonFirstnameNom) WSep )
       ( [ CapNameNomNSB | PropFirstLastNom ] WSep )
       [ PropFirstLastNom - PropOrg ]
       RC( [ WSep AuxVerb ]^{0,4} WSep lemma_exact_morph(VerbPer, {VOICE=ACT}) ) ;

! "[huomauttaa] Xxx"
Define PersonAction2
       LC( lemma_exact(Comma) WSep
       lemma_exact_morph(
		{sanoa} |
      		{kertoa} |
       		{arvioida} |
       		{myöntää} |
		{huomauttaa} |
		{haastaa} |
		{virkkoa} |
		{virkkaa} |
       		{todeta} |
       		{mainita} |
       		{epäillä} |
       		{arvella} |
       		{ajatella} |
       		{miettiä} |
       		{kuva}[{ta}|{illa}] |
       		{puolust}[{autua}|{ella}],
       	{VOICE=ACT} ) WSep )
	( CapNameNom WSep ) [ PropFirstLastNom ] [ WSep [ PropFirstLastNom ] ]* ( WSep CapNounNom::1.00 ) ;

Define PersonAction3
       [ CapMisc WSep ]*
       [ CapNameNomNSB | AlphaUp AlphaDown PropNom ]
       RC( [ WSep AuxVerb ]^{0,4} WSep lemma_exact_morph( [ VerbPer | {sanoa} | {kertoa} | {väittää} | {kritisoida} | {pohtia} ], {VOICE=ACT}) ) ;

Define PersonWithRelative
       ( [ CapMiscFirst ] WSep )
       [ NameInitial WSep ]*
       [ AlphaUp AlphaDown PropGen | CapNameGenNSB ]
       RC( WSep [ HumanRelativeWord | lemma_exact_morph({vanhempi}|{vanhemmat}, {NUM=PL}) |
       	   	  lemma_exact_morph({vanha}, {CMP=CMP} Field {NUM=PL}) ]) ;

Define PersonWithPossession
       ( [ CapMiscFirst ] WSep )
       [ NameInitial WSep ]*
       [ PropFirstLastGen ]
       RC( WSep lemma_ends(
       	   	{sormi} | {kasvo} ("t") | {parta} | {hius} | {vatsa} | {elämä} | {luo}({kse}) | {luota} | {syntymäpäivä} | {hautakivi} |
       	   	{maalaus} | {sävellys} | {teos} | {romaani} | {novelli} | {runo} | {elokuva} | {kotona} | {luona} |
		{kuolinvuode} | {mausoleumi} | {kuolinpesä} | {työsopimus} | {työpanos} | {työsuhde} ) ) ;
		!! NB: excluded "käsi" and "kirja" due to frequent methaphorical usage

Define PersonWithPostposition
       ( CapMisc WSep )
       [ NameInitial WSep ]*
       [ LC( NoSentBoundary ) CapNameStr [ PropGen - PropOrg ] ]
       RC( WSep wordform_exact( {mielestä} | {seurassa} | {mukaan} )) ;

Define PersonWithOrigins
       ( CapMisc WSep )
       ( CapMisc WSep )
       [ NameInitial WSep ]*
       CapMisc
       RC( WSep lemma_exact({olla}) WSep ( PosAdv WSep ) wordform_ends( {syntynyt} | {syntyisin} | {kotoisin} ) ) ;

Define PersonWithAlias
       LC( [ lemma_exact( {o.s.} | {alias} ) | wordform_exact( {omaa} | {o.} ) WSep wordform_exact( {sukua}({an}|{nsa}) | {s.} ) ] WSep )
       ( [ CapNameNom | CapMisc ] WSep )
       [ CapName | Ins(PersonSurname) ] ;	      

Define PersonAliasPrefixed
       wordform_exact( {DJ} | {Mr.} | {Dr.} | {Dr} | {Mr} | {MC} ) WSep
       ( CapMisc WSep )
       CapWord ;

Define PersonMultiPart
       Ins(PersonMiscMultiPart) ;

!* Category HEAD
Define PersHuman
       [ Ins(PersonPrefixed1)::0.35
       | Ins(PersonPrefixed2)::0.35
       | Ins(PersonPrefixed3)::0.35
       | Ins(PersonPrefixed4)::0.35
       | Ins(PersonSuffixed1)::0.25
       | Ins(PersonGazIsol)::0.30
       | Ins(PersonSemtag1)::0.80
       | Ins(PersonSemtag2)::0.80
       | Ins(PersonSemtag3)::0.80
       | Ins(PersonSemtag4)::0.80
       | Ins(PersonSemtag5)::0.80
       | Ins(PersonEpithet)::0.25
       | Ins(PersonMonarch)::0.25
       | Ins(PersonSaint)::0.50
       | Ins(PersonChrist)::0.50
       | Ins(PersonAliasPrefixed)::0.30
       | Ins(PersonSurnameInitialism)::0.50
       | Ins(PersonUsername)::0.50
       | Ins(PersonGrecoRoman)::0.75
       | Ins(PersonEastAsian1)::0.75
       | Ins(PersonEastAsian2)::0.75
       | Ins(PersonHispanic)::0.50
       | Ins(PersonTitledNom1)::0.25
       | Ins(PersonTitledNom2)::0.00
       | Ins(PersonHyphen1)::0.50
       | Ins(PersonCaptured)::1.00
       | Ins(PersonWithAge)::0.50
       | Ins(PersonWithParty)::0.50
       | Ins(PersonIsRelative)::0.50
       | Ins(PersonHyphen2)::0.50
       | Ins(PersonAction1)::0.50
       | Ins(PersonAction2)::0.50
       | Ins(PersonAction3)::0.50
       | Ins(PersonWithRelative)::0.50
       | Ins(PersonWithPossession)::0.50
       | Ins(PersonWithPostposition)::0.50
       | Ins(PersonWithOrigins)::0.50
       | Ins(PersonWithAlias)::0.50
       | Ins(PersonMultiPart)::0.00
       ] EndTag(EnamexPrsHum) ;

!!----------------------------------------------------------------------
!! <EnamexPrsAnm>:
!! Animals, ?mythical beasts (see also below)
!!----------------------------------------------------------------------

Define AnimalNameColloc1
       [ PropFirstLastGen::0.20 | PropGen::0.60 | CapNameGenNSB::0.60 ]
       RC( WSep AlphaDown lemma_ends( {turkki} | {pyrstö} | {häntä} | {tassu} | {käpälä} | {sorkka} | {kavio} | {kuono} | {poikanen} |
       	   		  	      {pentu} | {haukunta} | {nau'unta} | {naukuminen} | {sarvi} | [{höyhen}|{sulka}] ({peite}) |
				      {sulkasato} | {juoksuaika} | {pesä} | {karsina} | {viserrys} | {poikue} ) ) ;

Define AnimalNameColloc2
       [ CapMisc::0.60 | PropFirstLast::0.20 ]
       RC( ( WSep PosAdv) [ WSep AuxVerb ( WSep PosAdv ) ]^{0,4}
       	     WSep lemma_exact_morph( {naukua} | {ammua} | {nelistää} | {naukaista} | {haukahtaa} | {luimistella} | {vinkaista} | {kehrätä} |
	     	  		     {murista} | {ulvahtaa} | {kiekua} | {kiekaista} | {poikia} | {varsoa}, {VOICE=ACT} ) ) ;

Define AnimalNameGaz1
       Ins(AlphaUp) lemma_exact_morph( DownCase( {Heluna} | {Mansikki} | {Musti} | {Fifi} | {Asteri} | {Tessu} | {Peni} | {Ressu} |
       		      		       		 {Rekku} | {Turre} | {Muppe} ), {NUM=SG} )::0.20 ;

Define AnimalNameGaz2
       LC( NoSentBoundary )
       Ins(AlphaUp) lemma_exact_morph( DownCase( {Musti} | {Ystävä} | {Ruusu} | {Omena} | {Kielo} | {Kirjo} | {Lemmikki} ), {NUM=SG} )::0.30 ;

Define AnimalName
       [ Ins(AnimalNameColloc1)
       | Ins(AnimalNameColloc2)
       | Ins(AnimalNameGaz1)
       | Ins(AnimalNameGaz2)
       ] EndTag(EnamexPrsAnm) ;

!!----------------------------------------------------------------------
!! <EnamexPrsMyt>:
!! Deities, fictional and mythical beings
!! NB: May be limited to deities and spirits in the future
!!----------------------------------------------------------------------

Define PersMythType [
       [ Field [ {jumala} | {jumalatar} | {kääpiö} | {hirviö} | {peikko} | {menninkäinen} | {maahinen} | {keiju} | {kääpiö} | {tonttu}
       | {lohikäärme} | {traakki} | {peto} | {olento} | {paholainen} | {velho} | {noita} | {velhotar} | {vetehinen} | {syöjätär}
       | {hengetär} | {satyyri} | {avaruusolio} | {kentauri} ] ]
       - [ Field [ {kapeikko} | {älykääpiö} | {sanahirviö} | {herrajumala} ] ]
       ] ;

!* "Xxx-jumala"
Define PersMythHyphen1
       [ [ LC(NoSentBoundary) AlphaUp AlphaDown Field ] ]
       Capture(PrsMytCpt1) [ Dash | lemma_ends(Dash {niminen}) WSep AlphaDown ] lemma_exact( Ins(PersMythType) ) ;

!* "Xxx Xxx -jumala"
Define PersMythHyphen2
       ( CapName WSep )
       wordform_exact( CapNameStr Capture(PrsMytCpt2) ) WSep
       DashExt lemma_exact( (Dash) Ins(PersMythType) ) ;

!* "[käärmejumala/sateenjumala] Xxx
Define PersMythColloc1A
       LC( lemma_exact( AlphaDown* [ {jumala} | {jumalatar} ]) WSep )
       ( CapMisc WSep )
       wordform_exact( CapNameStr Capture(PrsMytCpt3) ) ;

!* "[viisauden jumalatar] Xxx"
Define PersMythColloc1B
       LC( NounGen WSep lemma_exact( AlphaDown* {jumala} | {jumalatar} ) WSep )
       ( CapMisc WSep )
       wordform_exact( CapNameStr Capture(PrsMytCpt4) ) ;

Define PersMythColloc1 [ PersMythColloc1A | PersMythColloc1B ] ;

!* "Xxx:n [kultti/palvonta/ylipappi]"
Define PersMythColloc2
       ( CapMisc WSep )
       [ [ CapNameGenNSB | PropGen ] - lemma_exact({herra}|{järki}|{mammona}|{raha}|{materia}|{ulkonäkö}|{aurinko}|{epäjumala}|{vatsa}) ]
       RC( WSep lemma_exact( Field [ {kultti} | {temppeli} | {ylipappi} | {pappi} | {papitar} | {profeetta} | {palvonta} | {palvominen}
       	   		     	   | {palvontameno}("t") | {kulttipaikka} | {palvontapaikka} | {epiteetti}::0.10 | {kunniaksi}::0.10
				   | {symboli}::0.10 | {tunnuseläin}::0.10 | {alttari}::0.10 | {jumaluus}::0.10 | {jumalallinen}::0.10
				   ] ) ) ;

!* "[uhrata/pyhittää (xxx) ] Xxx:lle"
Define PersMythColloc3
       LC( lemma_exact( {uhrata} | {pyhittää} ) WSep
       ( [ CaseGen | CaseNom | CasePar ] WSep ) )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown wordform_ends( Capture(PrsMytCpt5) ("i"){lle}) ;

!* "[uhri] Xxx:lle"
Define PersMythColloc4
       LC( lemma_morph( {uhri}({lahja}) | {rukous}, {CASE=}[{NOM}|{GEN}|{PAR}|{ESS}|{TRA}]) WSep )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown wordform_ends({lle}) ;

!* "[rukoilla] Xxx:ää"
Define PersMythColloc5
       LC( lemma_exact( {rukoilla} | {palvoa} ) WSep )
       ( CapMisc WSep ) ( CapMisc WSep )
       AlphaUp AlphaDown wordform_ends( [FinVowel|{st}]["a"|"ä"] ) ;

Define PersMythCaptured
       inflect_sg( PrsMytCpt1 | PrsMytCpt2 | PrsMytCpt3 | PrsMytCpt4 | PrsMytCpt5 ) ;

!* Kaikki "Jumala"-sanan yksikölliset isolla alkukirjaimella kirjoitetut
! muodot tulkitaan erisnimiksi
Define PersMythAbrahamicGod
       "J" lemma_exact_morph({jumala}, {NUM=SG}) ;

Define PersMythGaz
       [ m4_include(`gPersFictional.m4') ] ;

Define PersFictional
       [ Ins(PersMythHyphen1)::0.20
       | Ins(PersMythHyphen2)::0.20
       | Ins(PersMythColloc1)::0.50
       | Ins(PersMythColloc2)::0.50
       | Ins(PersMythColloc3)::0.50
       | Ins(PersMythColloc4)::0.50
       | Ins(PersMythColloc5)::0.50
       | Ins(PersMythCaptured)::0.50
       | Ins(PersMythAbrahamicGod)::0.10
       | Ins(PersMythGaz)::0.10
       ] EndTag(EnamexPrsMyt) ;

!!----------------------------------------------------------------------
!! <HEAD>
!!----------------------------------------------------------------------

!* Category HEAD
Define Person
       [ Ins(PersHuman)
       | Ins(AnimalName)
       | Ins(PersFictional)
       ] ;

!!----------------------------------------------------------------------
!! <EnamexLocXxx>: General locations
!! - Words marked with GEO tag in morphology and inner local case
!! - Virtually always LocPpl:s and thus tagged as such
!! - NB: GEO words in other cases are marked only in 2. phase
!!       if none of the other rules in the 1. phase matches.
!!----------------------------------------------------------------------

Define LocGeneral1
       PropGeoLocInt ;

Define LocGeneral2
       PropGeoGen
       RC( WSep PropGeoLocInt ) ;

Define LocGeneral3
       [ LC( NoSentBoundary ) AlphaUp semtag_exact({[PROP=GEO]}) ] ;

Define LocGeneral4
       LC( NoSentBoundary ) AlphaUp semtag_exact( ({[PROP=LAST]}) {[PROP=GEO]} ({[PROP=LAST]}) ) ;

Define LocGeneralPrefixed
       LC( lemma_ends( [{pohjo}|{etelä}|{länt}|{itä}|{koill}|{kaakko}|{louna}|{luote}|{kesk}] {inen} ) WSep )
       [ CapMisc WSep ]*
       CapName ;

Define LocGeneralColloc1
       [ CapMisc WSep ]*
       [ CapNameGenNSB | PropGeoGen ]
       RC( WSep lemma_exact([ {pohjois} | {etelä} | {itä} | {länsi} | {koillis} | {kaakkois} | {lounais} | {luoteis} ]
       	   		      [ {osa} | {pää} ({ty}) | {puoli} ({nen}) ] | {asutus} Field ) ) ;

Define LocGeneralColloc2
       LC( lemma_exact( {hyökätä} | {matkustaa} | {lentää} | {purjehtia} | {saapua} | {muuttaa} | {takaisin} | {siirtyä} |
       	   		{palata} | {levitä} | {soutaa} | {ajaa} | {paeta} | {hyökkäys} | AlphaDown* {isku} | {muutto} | {asettua} |
       			{vetäytyä} | {luota} | {luokse} | {luo} | {lähettää} | {ratsastaa} ) WSep
       ( PosAdv WSep ) )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {CASE=ILL}|{CASE=ELA}|{CASE=ALL}|{CASE=ABL} ) ;

Define LocGeneralColloc3
       LC( lemma_exact( {asua} | {sijaita} | {opiskella} | {piileksiä} | {piileskellä} | {varttua} | {syntyä} | {käydä} |
       	   		{pysähtyä} | {asuinpaikka} | {asunto} | {talo} | {piipahtaa} | {matkustaa} | {matkustella} |
			{vierailla} | {sotatoimi} | {luona} | {maanjäristys} ) WSep
       ( PosAdv WSep ) )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {CASE=INE}|{CASE=ADE} ) ;

Define LocGeneralColloc4
       LC( morphtag_semtag({CASE=GEN}, {PROP=GEO}) WSep )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown morphtag({CASE=}[{ILL}|{INE}|{ELA}]) ;

!* "Agincourtissa [ vuonna 1415 ]"
Define LocGeneralColloc5
       [ AlphaUp AlphaDown morphtag({CASE=INE})::0.75 | wordform_exact({Nokialla})::0.10 ]
       RC( ( WSep wordform_exact({vuonna}) )
       	   WSep wordform_exact( [ "1" 0To9 | {20} ] 0To9 0To9 (".") ) ) ;

Define LocGeneralColloc6
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {NUM=SG} Field {CASE=ELA})
       RC( WSep wordform_exact( {pohjoiseen} | {etelään} | {itään} | {länteen} | {koilliseen} | {kaakkoon} | {luoteeseen} ) ) ;

Define LocGeneralColloc7
       LC( lemma_exact( {pitkin} | {ympäri} | {keskellä} ) WSep )
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {CASE=PAR}) ;

!* TODO:
!* [ Yyy:ssa ] Xxx:ssa
!* Xxx:ssa [ Yyy:ssa ]

! Category HEAD
Define LocGeneral
       [ Ins(LocGeneral1)::0.45
       | Ins(LocGeneral2)::0.45
       | Ins(LocGeneral3)::0.45
       | Ins(LocGeneral4)::0.45
       | Ins(LocGeneralPrefixed)::0.60
       | Ins(LocGeneralColloc1)::0.50
       | Ins(LocGeneralColloc2)::0.00
       | Ins(LocGeneralColloc3)::0.00
       | Ins(LocGeneralColloc4)::0.75
       | Ins(LocGeneralColloc5)::0.00
       | Ins(LocGeneralColloc6)::0.00
       | Ins(LocGeneralColloc7)::0.00
       ] EndTag(EnamexLocPpl) ;

!!----------------------------------------------------------------------
!! <EnamexLocAst>: Astronomical places
!!----------------------------------------------------------------------

Define ClstBody
       {Merkurius} | {Venus} | {Mars} | {Jupiter} | {Saturnus} | {Uranus} | {Neptunus} | {Pluto} |
       {Kepler} Dash 0To9+ Alpha+ | {Ceres} | {Ganymede} | {Vesta} | {Maapallo} | {Sedna} ;

Define LocAst1
       UppercaseAlpha lemma_exact( DownCase( ClstBody )) ;

Define LocAst2
       LC( NoSentBoundary )
       UppercaseAlpha lemma_exact_morph( {maa} | {kuu} | {aurinko}, {NUM=SG}) ;

Define LocAst3
       LC( NoSentBoundary )
       [ UppercaseAlpha lemma_ends( Dash [ AlphaDown* {planeetta} | {tähti} | {asteroidi} | {komeetta} | {kuu} |
       	 			    	   {sumu} | {galaksi} | {tähtisumu} ] ) ] |
       [ UppercaseAlpha lemma_ends( AlphaDown AlphaDown AlphaDown+ [ {sumu}::0.25 | {galaksi} ] ) ] ;

Define LocAst4
       CapNounGenNSB
       RC( WSep AlphaDown lemma_exact( {kuu} | {kiertolainen} | {sisarplaneetta} | {galaksi} | {tähtikuvio} | {tähdistö} |
       	   		  	       {tähtisumu} | {aurinkokunta} | {kiertorata} | {pyörähdysaika} | {kaasukehä} | {ilmakehä} ) ) ;       


Define LocAst5
       wordform_exact( {13} 0To9 0To9 0To9 0To9 ) WSep CapWord ;

!TODO: [X:n kuu] Y

Define LocAst6
       LC([ CapNameGen | PropGen ] WSep lemma_exact({kuu}) WSep )
       [ CapNameGen | Prop ] ;

Define LocAstGazMWord
       wf_lemma_x2( OptCap({Iso}), {karhu} ) |
       wf_lemma_x2( OptCap({Etelän}), {risti} ) |
       wf_lemma_x2( OptCap({Kuiperin}), {vyöhyke} ) |
       wf_lemma_x2( OptCap({Halleyn}), {komeetta} ) |
       wf_lemma_x2( OptCap({Lyyran}), {rengassumu} ) |
       wf_lemma_x2( OptCap({Andromedan}|{Kolmion}), {galaksi} ) |
       wf_lemma_x2( OptCap({Hillsin}|{Oortin}), {pilvi} ) |
       wf_lemma_x3( OptCap({Pieni}), OptCap({Jousimiehen}), {tähtipilvi} ) |
       lemma_sg_x2( {hajanainen}, {kiekko} ) |
       lemma_sg_x2( {pieni}, {nostopainosumu} ) ;

Define LocAstGaz1
       UppercaseAlpha lemma_exact_morph( {linnunrata} | {aurinkokunta} | {andromeda} | {nostopainosumu}, {NUM=SG}) ;

Define LocAstGaz2
       inflect_sg( @txt"gLocAstCelestialBody.txt" | ClstBody ) ;

! Category HEAD
Define LocAstro
       [ Ins(LocAst1)::0.25
       | Ins(LocAst2)::0.25
       | Ins(LocAst3)::0.25
       | Ins(LocAst4)::0.30
       | Ins(LocAst5)::0.30
       | Ins(LocAst6)::0.60
       | Ins(LocAstGaz1)::0.25
       | Ins(LocAstGaz2)::0.25
       | Ins(LocAstGazMWord)::0.25
       ] EndTag(EnamexLocAst) ;

!!----------------------------------------------------------------------
!! <EnamexLocGpl>: Geographical places
!!----------------------------------------------------------------------

!* "Saharan autiomaa", "Jukatanin niemimaa", "Yosemiten kansallispuisto"
Define LocGeoSuff1
       ( [ CapName WSep AndOfThe | CapMisc ] WSep )
       [ CapNounGen | CapNameGenNSB | PropGeoGen ] Capture(GeoNameGen1) WSep
       lemma_exact_morph( {tasanko} | {niemimaa} | {aavikko} | {sademetsä} | {alanko} | {ylänkö} | [{erä}|{autio}]{maa} | {putous} |
       			  {massiivi} | {jäätikkö} | {ylänkö} | [{kansallis}|{luonnon}]{puisto} | {luonnonsuojelualue} | {lintuvesi} |
			  {linnavuori} | {sola}, {NUM=SG} ) ;

!* "Vienanmeri", "Pohjanlahti", "Hyväntoivoinniemi", "Harveynjärvi", "Tokoinranta"
Define LocGeoSuff2
       AlphaUp lemma_ends( "n" [ {meri} | {meressä} | {merellä} | {lahti} | {niemi} | {salmi} | {putous} | {järvi} | {ranta} | {koski}
       	       		       | {kangas} | {selkä} | {huippu} | {salo} | {mäki} | {laakso}
			       ] ) ;

Define GeoType [ ( AlphaDown+ | Field Dash ) [ {joki} | {laakso} | {vuono} | {saari} | {rannikko} | {järvi} | {lahti} | {tunturi}
       	       | {vuori} | {vaara} | {luoto} | {kumpu} | {lampi} | {lammi} | {luola} | {lompolo} | {suvanto} | AlphaDown {vesi}
	       | {niittu} | {niitty} | {kallio} | {korpi} | {mäki} | {koski} | {jäätikkö} | {vuoristo} | {saaristo} | {geysir}
	       | {ylänkö} | {kukkula} | {kraatteri} | {kraateri} | {kaldera} | {pohja} | {harju} | Dash {virta} ]] -
	       [ Field [ {seuranta} | {veranta} | {basaari} | {husaari} | {pessaari} | {janitsaari} | {kvasaari} |
	       	       	 {peliluola} | {huumeluola} | {oopiumiluola} | {miesluola} | {pornoluola} ] ] ;

Define LocGeoSuff3A
       LC( NoSentBoundary )
       AlphaUp lemma_exact( [ Field AlphaDown+ Ins(GeoType) | AlphaDown+ {ranta} ]
       	       		    - [ Field [ {seuranta} | {veranta} | {basaari} | {husaari} | {pessaari} | {janitsaari} | {kvasaari} |
			      	      	{peliluola} | {huumeluola} | {oopiumiluola} | {miesluola} | {pornoluola} ] ] ) ;

Define LocGeoSuff3B
       [ CapMisc WSep ]*
       ( CapName WSep )
       CapName WSep
       DashExt lemma_exact( (Dash) Ins(GeoType) ) ;

Define LocGeoSuffRiver
       AlphaUp AlphaDown lemma_exact_morph( [ Field - [ Field [{lasku}|{lisä}|{pää}|{lohi}|{sivu}|{vesi}|{raja}]]] {joki}, {NUM=SG}) ;

Define LocGeoFalls
       ( [ CapName WSep AndOfThe | CapMisc ] WSep )
       [ CapNounGen | CapNameGenNSB | PropGeoGen ] WSep
       lemma_exact_morph( {putous}, {NUM=PL} ) ;

!* Suuri Klimetskoinsaari, Iso Iiluoto, Pieni Vasikkasaari
Define LocGeoSuff4
       AlphaUp lemma_exact( {pikku} | {pieni} | {iso} | {suuri} ) WSep
       AlphaUp lemma_exact( AlphaDown+ [ {järvi} | {saari} | {luoto} | {lammi} ] ) ;

Define LocGeoSuff5
       ( CapMisc WSep ) CapMisc WSep
       inflect_sg( {Otok} | {Lake}("s") | {Mountains} | {Glacier} | {Basin} | {Plain}("s") | {Grotto} | {Cave}("s") |
       		   {Cavern}("s") | {Volcano}({es}) | {River}::0.25 | {Creek} | {Canyon} | {Valley} | {Island}("s") | {Gunto}("u") |
		   {Guntō} | {Bay} | {Beach} | {Mesa} | {Vrh} | {Brdo} | {Vrelo} | {Izvor} | {Spring} | {Ridge} | {Tuff}::0.25 |
		   {Peak} | {Rock}("s")::0.25 | {Butte} | {Moors} | {Bluff} | {Riza} | {Taung} | {Bum} | {Kyun} | {Lagoon} |
		   {Char} | {ostrov} ) ;

Define LocGeoGuessed2
       inflect_sg( AlphaUp AlphaDown+ @txt"gLocGeoSfx.txt" ) ;

!* Itä-Aasia, Pohjois- ja Etelä-Amerikka
Define LocGeoPrefixed1
       ( wordform_exact( OptCap( GeoPfx Dash ) ) WSep
       lemma_exact({ja}) WSep )
       wordform_exact( OptCap( GeoPfx Dash AlphaUp AlphaDown+ ) ) ;

! "Serra de Estrela"
Define LocGeoPrefixed2
       wordform_exact( {Mont} ("e") | {Mt.} | {Mount} | {Lake} | {Lago} | {Loch} | {Cerro} | {Sierra} | {Serra} | {Costa} |
       		       {Côte} | {Île}("s") | {Isla}("s") | {Ilha} | {Rio} | {Río} | {Pulau} | {Tesik} | {Val}("l") | {Grotte} | {Grotto} |
		       {Vrh} | {Brdo} | {Vrelo} | {Izvor} | {Jabal} | {Koh} | {Ko} | {Char} | {Ostrov} | {Cape} | {Massif} | {Puy} | {Forêt} |
		       {Quebrada} | {Cueva} | {Gran} ) WSep
       ( DeLa WSep )
       [ CapName | CapMisc ] ;

Define LocGeoPrefixed3
       wordform_exact( {Baḩr} | {Bahr} | {Nahr} | {Umm} ) WSep
       [ [ wordform_exact( ["a"|"e"] ["s"|"l"|"z"|"n"] ) WSep CapWord ] |
       [ wordform_exact( ["a"|"e"] ["s"|"l"|"z"|"n"] Dash AlphaUp AlphaDown+ ) ] ] ;

!* "Atlantin valtameri"
Define LocGeoOcean1
       [ {Tyyn} | {Intian} | {Atlan} ] Word WSep
       lemma_exact( {valtameri} ) ;

!* "Tyynenmeren", "Alantti"
Define LocGeoOcean2
       UppercaseAlpha lemma_exact( [ {tyyn} AlphaDown+ | {punai} AlphaDown+ | {väli} | {etelä} | {koralli} | {musta} | {itä} | {jää} ] {meri} | (Ins(GeoPfx) Dash) {atlantti} ) ;

!* "Pohjoinen jäämeri"
Define LocGeoOcean3
       lemma_exact( {pohjoinen} | {eteläinen} ) WSep
       lemma_exact( {jäämeri} ) ;

Define LocGeoOcean4
       wordform_exact( [{Etelä}|{Itä}] Dash {Kiinan} ) WSep
       lemma_exact( {meri} ) ;       

Define LocGeoOceanTrench
       wordform_exact( {Caymanin} | {Mariaanien} | {Syvänmeren} | {Filippiinien} | {Kalypson} | {Kermadecin} | {Romanchen} |
       		       {Uuden-Britannian} ) EndTag(EnamexLocGpl2) WSep
       lemma_exact( {hauta} | {syvänne} ) ;

!* TODO: merivirrat, esim. Golfvirta

!* "Yyterin [hiekkarannat]", "Hispaniolan [saari]"
Define LocGeoColloc1
       [ CapNameGenNSB | AlphaUp PropGen | "A" lemma_morph({{amazon}("i"), {[NUM=SG][CASE=GEN]}) ] Capture(GeoNameGen2)
       RC( WSep AlphaDown lemma_exact( [[ AlphaDown* [ {ranta} | {virtaus} | {valuma-alue} | {suisto}({alue}) | {uoma} | {luola} | {laakso} | {joki} | {vuoristo} | {vuori} | {saari} | {niemi} | {saaristo} | {rannikko} | {metsä} | {laguuni} | {rinne} | {jyrkänne} | {atolli} | {kasvillisuus} | {eläimistö} | {ilmasto} ]] - [ {seuranta} | {veranta} | AlphaDown* (Dash) ["t"|"l"|"j"|"s"]{uoma} | {kraatteri} | {kraateri }] ] ) ) ;

Define LocGeoNationalPark1
       ( CapMisc WSep ) CapName WSep
       inflect_x2({National}, {Park}) ;

Define LocGeoNationalPark2
       wordform_x2({Parc}, OptCap( {national}("e") | {naturel} )) WSep
       ( CapMisc WSep )
       ( DeLa WSep )
       CapName ;

!* Xxxvuoret, Xxxsaaret
Define LocGeoPluralized
       LC( NoSentBoundary ) AlphaUp AlphaDown lemma_exact( AlphaDown AlphaDown+ (Dash) [ {vuori} | {saari} ], {NUM=PL} ) ;

Define gazLocGeoRegion     @txt"gLocGeoRegion.txt" ;
Define gazLocGeoIsland     @txt"gLocGeoIsland.txt" ;
Define gazLocGeoMountain   @txt"gLocGeoMountain.txt" ;
Define gazLocGeoReserve    @txt"gLocGeoReserve.txt" ;
Define gazLocGeoIslandPl   @txt"gLocGeoIslandPl.txt" ;
Define gazLocGeoMountainPl @txt"gLocGeoMountainPl.txt" ; 
Define gazLocGeoHydro 	   @txt"gLocGeoHydro.txt" ; ! NB: Excluded Amazon for the time being (-> ORG)

Define LocGeoGaz1A
       Field AlphaUp lemma_exact( ( Ins(GeoPfx) Dash) DownCase([ gazLocGeoRegion | gazLocGeoIsland | gazLocGeoHydro | gazLocGeoReserve | gazLocGeoMountain ]) ) ;

Define LocGeoGaz1B
       inflect_sg( ( Ins(GeoPfx) Dash) Cap([ gazLocGeoRegion | gazLocGeoIsland | gazLocGeoHydro | gazLocGeoReserve | gazLocGeoMountain ]) ) ;

Define LocGeoGaz2
       [ m4_include(`gLocGeoMWord.m4') ] ;

Define LocGeoGazPl
       Field AlphaUp lemma_morph( DownCase([ gazLocGeoIslandPl | gazLocGeoMountainPl ]), {NUM=PL} ) ;

Define LocGeoCaptured
       [ GeoNameGen1 | GeoNameGen2 ] ;

! Category HEAD
Define LocGeogr
       [ Ins(LocGeoSuff1)::0.25 
       | Ins(LocGeoSuff2)::0.25
       | Ins(LocGeoSuff3A)::0.40 | Ins(LocGeoSuff3B)::0.50
       | Ins(LocGeoSuff4)::0.50
       | Ins(LocGeoSuff5)::0.40
       | Ins(LocGeoSuffRiver)::0.50
       | Ins(LocGeoFalls)::0.50
       | Ins(LocGeoPrefixed1)::0.40
       | Ins(LocGeoPrefixed2)::0.400
       | Ins(LocGeoPrefixed3)::0.20
       | Ins(LocGeoPluralized)::0.50
       | Ins(LocGeoOcean1)::0.25
       | Ins(LocGeoOcean2)::0.25
       | Ins(LocGeoOcean3)::0.25
       | Ins(LocGeoOcean4)::0.25
       | Ins(LocGeoOceanTrench)::0.25
       | Ins(LocGeoNationalPark1)::0.25
       | Ins(LocGeoNationalPark2)::0.25
       | Ins(LocGeoGuessed2)::0.75
       | Ins(LocGeoColloc1)::0.30
       | Ins(LocGeoGaz1A)::0.25
       | Ins(LocGeoGaz1B)::0.25
       | Ins(LocGeoGaz2)::0.25
       | Ins(LocGeoGazPl)::0.25
       | Ins(LocGeoCaptured)::0.75
       ] EndTag(EnamexLocGpl) ;

!!----------------------------------------------------------------------
!! <EnamexLocPpl>: Political areas
!!----------------------------------------------------------------------

!* "Uusimaa" : "Uudenmaan"
Define LocPolAdjPfx
       {Iso} Field Dash lemma_ends( Dash {britannia} ) |
       {Uu}["d"|"t"] AlphaDown+ lemma_ends( [ Dash {seelanti} | Dash {guinea} | Dash {kaledonia} | {uu} AlphaDown+ {maa} ]) ;

!* "Koski TL"
Define LocPolComp1
       lemma_exact( {lappi} | {koski} | {pyhäjärvi} | {uusikirkko} | {uusikylä} ) WSep
       lemma_exact( {hl} | {tl} | {ol} | {ul} | {vpl} ) ;

!* "Washington D.C."
Define LocPolComp2
       lemma_exact( {washington} ) WSep
       [ lemma_exact({dc}) |
         lemma_exact( {d.} ) WSep lemma_exact( {c.} ) |
       	 lemma_exact( "d" ) WSep lemma_exact( "." ) WSep
	 lemma_exact( "c" ) WSep lemma_exact( "." )
       ] ;

Define LocPolComp3
       "Y" lemma_exact_morph( {yhdistyä}, {[VOICE=ACT][PCP=NUT]} ) WSep
       lemma_exact( {kuningaskunta} | {arabiemiraatti}({kunta}) ) ;

!* "New York City", "Mexico City"
Define LocPolSuffix1
       ( CapMisc WSep )
       CapMisc WSep
       inflect_sg( @txt"gLocPolSfxWord.txt" ) ;

!* "Ruotsin kuningaskunta", "Korean demokraattinen kansantasavalta", "Venäjän federaatio", "Suomen suuriruhtinaskunta"
Define LocPolSuffix2
       [ CapNameGenNSB | PropGeoGen ] WSep
       ( lemma_exact( {demokraattinen} | {sosialistinen} | {kommunistinen} | {federatiivinen} |
       	 	      {kuninkaallinen} | {keisarillinen} | {islamilainen} ) WSep )
       lemma_morph( {tasavalta} | {kuningaskunta} | {keisarikunta} | {federaatio} | {liittovaltio} | {emiraatti} | {kalifaatti} |
       		    {sulttaanikunta} | {suuriruhtinaskunta} | {suurherttuakunta} | {herttuakunta} | {shogunaatti} | {shōgunaatti},
		    {NUM=SG} ) ;

!* TODO: Blokkaa "Jokainen piirikunta"
Define LocPolSuffix3
       ( CapMisc WSep )
       CapNameGen
       RC( WSep lemma_exact( {osavaltio} | {raion}("i") | {piirikunta} | {departementti} | {valtakunta} | {maakunta} | {provinssi} ) ) ;

!* "Fukuin prefektuuri", "Leningradin oblasti/alue"
Define LocPolSubdivision
       ( CapMisc WSep )
       CapNameGen EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_exact_morph( {lääni} | {maalaiskunta} | {mlk} (".") | {kihlakunta} | {seutukunta} |
       			  {prefektuuri} | {kanton}("i") | {volost}("i") | {oblast}("i") | {piirikunta} |
			  {sairaanhoitopiiri} | {vaalipiiri} | {hiippakunta}, {NUM=SG} ) ;

Define LocPolSuffix5
       AlphaUp lemma_ends( Dash {niminen} ) WSep
       lemma_ends( {kylä} | {kaupunki} ) ;

Define LocPolSuffix6
       [ CapMisc WSep ]*
       Word WSep Word WSep
       Dash lemma_exact( (Dash) {niminen} ) WSep
       lemma_ends( {kylä} | {kaupunki} ) ;

Define LocPolSuffix7
       AlphaUp lemma_ends( AlphaDown Dash [ {kylä} | {kaupunki} | {shogunaatti} | {shōgunaatti} ] ) ;

Define LocPolSuffix8
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact( AlphaDown+ [ {kylä} | {kaupunki} ]) ;

Define LocPolPrefixed1
       wordform_exact( {Sant} Apostr AlphaUp AlphaDown+ | AlphaUp AlphaDown+ {abad} ({-e}) | @txt"gLocPolPfxWord.txt" ) WSep
       ( OptCap( "d" Field | ["a"|"e"] ["s"|"l"|"z"|"n"] ) FSep WSep ( AlphaDown+ FSep Word WSep ) )
       ( CapNameNom WSep::0.20 )
       [ PropGeo | CapName::0.10 ] ;

Define LocPolPrefixed2
       inflect_sg( [ {Peña} | {Nieder} | {Mont} | {Saint} Dash AlphaUp | {Roche} | {Châte} |
       		     {Fleury} | {Champ} | {Aix} Dash AlphaDown+ Dash ] AlphaDown AlphaDown+ ) ;

!* "Frankfurt am Main", "Kostanjevica na Krki"
Define LocPolInfixed1
       CapName WSep
       wordform_exact( {im} | {am} | {pri} | {na} | {ob} | {pod} ) WSep
       CapName ;

!* "Statford-on-Avon", "Aix-en-Provence", "Saint-André-de-Cubzac"
Define LocPolInfixed2
       wordform_exact( [ AlphaUp AlphaDown+ Dash ]+ AlphaDown+ [ Dash AlphaUp AlphaDown+ ]+ ) ;

!* "Xxx:n kylä" (muttei: "Xxx:n kotikylä")
Define LocPolColloc1
       ( CapMisc WSep ) ( CapMisc WSep )
       [ [ LC(NoSentBoundary) CapNameStr FinVowel Capture(LocPolCpt1) "n" FSep Word::0.50 ] | AlphaUp AlphaDown PropGen::0.25 | PropGeoGen::0.00 | AlphaUp lemma_exact_morph( DownCase(LocOrPer), {NUM=SG][CASE=GEN} ) ]
       RC( ( WSep lemma_exact_morph([ (AlphaDown+ - [{koti}|{synnyin}|{syntymä}]) {kaupunki} | {osavaltio} | ({maalais}|{pikku}){kunta} ], {CASE=GEN}) )
       WSep ( PosAdj WSep) lemma_exact( (AlphaDown+ - [{koti}]) {kylä} | {pitäjä} | {kirkonkylä} | {kirkkokylä} | {taajama} | {lähiö} |
       	      	     	   		{pormestari} | {kuvernööri} | {kaupunginjohtaja} | {arkkipiispa} | {kaupunginvaltuutettu} |
					{sulttaani} | {kuninga}["s"|{tar}] | {kalifi} | {asukas} ({luku}|{määrä}) | {alue} | {esikaupunki} |
					{ympäryskunta} | {maakunta} | {provinssi} | {lääni} | {asemakaava} | {kortteli} | {keskusta} |
					{lähiö} | {seutu} | {maisema} | {kaupunkikulttuuri} | {lähettyvil}[{lä}|{le}|{tä}] | {katu} |
					{puisto} | {asukas} | {konttori}::0.25 | {risteys}::0.25 | (Field {taso}|{kierto}){liittymä}::0.5 |
					{maantie} | {pommitus} | {verilöyly} | {maanjäristys} | {kauppala} | {väestö} | {ilmatila} |
					{ulkoministeri} | {kansanäänestys} | {kansalainen} | {kansalaisuus} | {sotilasjuntta} | {prinssi} ) ) ;

!* "Xxx:n kaupunki" (muttei: "Xxx:n kotikaupunki")
Define LocPolColloc2
       ( CapMisc WSep ) ( CapMisc WSep )
       [ AlphaUp AlphaDown PropGen::0.25 | LC(NoSentBoundary) CapNameStr FinVowel Capture(LocPolCpt2) "n" FSep Word::0.50 | PropGeoGen | AlphaUp lemma_exact_morph( DownCase(LocOrPer), {NUM=SG}) ]
       RC( WSep lemma_exact([ (AlphaDown+ - [{koti}|{synnyin}|{syntymä}]) {kaupunki} | {valtio} | {osavaltio} | {kaupunginosa} | ({maalais}|{pikku}){kunta} ]) ) ;

Define LocPolCity1
       LC( CaseGen WSep
       lemma_exact( AlphaDown+ [ {kaupunki} | {kylä} ] ) WSep )
       [ CapMisc WSep ]* 
       CapWord ;

Define LocPolCity2
       LC( wordform_ends( AlphaDown+ [ {kaupunki} | {kylä} ] ) WSep )
       ( CapMisc WSep )
       CapName ;

Define LocPolColloc9A
       LC( wordform_exact( {kotoisin} | {syntyisin} ) WSep )
       [ CapMisc WSep ]*
       wordform_exact( CapNameStr Vowel Capture(LocPolCpt3) [ {sta} | {stä} ] ) ;

Define LocPolColloc9B
       [ CapMisc WSep ]*
       AlphaUp wordform_ends( AlphaDown [ {sta} | {stä} ] )
       RC( WSep wordform_exact( {kotoisin} ) ) ;

! "Yhdysvalloissa"
Define LocPolMisc1
       ( lemma_morph({amerikka}, {CASE=GEN}) WSep )
       lemma_exact({yhdysvallat}|{yhdysvalta}) ;

! Defective tagger
Define LocPolMisc2
       wordform_ends([ {Kiinaan} | {Venäjään} | {Japaniin} | {Roomaan} ]) ;

Define LocPolMisc3
       ( CapMisc WSep ) CapName WSep
       inflect_sg( {Falls} | {Springs} | {Rapids} | {Country} | {County} ) ;

Define LocPolMisc4
       wordform_exact({Suomessa}({kin})) ;

Define LocPolMisc5
       LC( NoSentBoundary )
       "B" lemma_exact( {brittiläinen} ) WSep
       AlphaUp AlphaDown lemma_exact( AlphaDown AlphaDown+ (Dash) AlphaDown AlphaDown+ ) ;

Define LocPolColloc3
       LC( NoSentBoundary )
       [ UppercaseAlpha morphtag({CASE=INE}) ]
       RC( WSep lemma_exact( {sijait} ({sev}) "a" ) ) ;

Define LocPolColloc4
       [ CapMisc WSep ]*
       [ [ LC(NoSentBoundary) CapNameStr FinVowel Capture(LocPolCpt4) "n" FSep Word::0.50 ] | PropGeoGen ]
       RC( WSep lemma_ends(
       	   {markkina} | 
	   {lähetystö} | 
	   {suurlähettiläs} | 
	   {kansalainen} | 
	   {perustuslaki} | 
	   {ministeri} |
	   {lähettyvillä} |
	   {kansallispäivä} |
	   {lähistö} |
	   {miehitys} |
	   {valloitus} |
	   {lähistölle} |
	   {piirikunta} |
	   {suurlähettiläs} |
	   {lähetystö} |
	   {edustusto}
	   {patriarkka} |
	   {piispa} |
	   {viranomainen} | 
	   {virasto} | 
	   {poliisilaitos} |
	   {olympialai}[{nen}|{set}] | 
	   {lähistö} ) ) ;

Define LocPolColloc5
       [ CapMisc WSep ]*
       [ PropGeoGen ]
       RC( ( WSep wordform_ends({ksi}) )
       	     WSep lemma_morph({suuri}, {CMP=SUP}) ) ;

Define LocPolColloc6
       LC( lemma_exact( {klo} (".") | {kello} ) WSep 
       Word WSep ( Word WSep ) )
       [ CapNounGenNSB | PropGeoGen ]
       RC( WSep wordform_exact({aikaa}) ) ;

Define LocPolColloc7
       [ CapMisc WSep ]*
       [ CapNounIneNSB | CapNounAdeNSB | PropGeoIne | PropGeoAde ]
       RC( WSep wordform_exact( 
       	   [ {sijaitsev}
	   | {asuv}
	   | {varttun}
	   | {oleskelev}
	   | {olev} !!! ???
	   | {vierailev}
	   | {vierlaill}
	   | {toimiv}
	   | {järjestettäv}
	   | {tapahtu}{"v"|"n"}
	   ] FinVowel Field ) ) ;

Define LocPolSuffixed
       inflect_sg( (AlphaUp AlphaDown+ Dash) AlphaUp AlphaDown AlphaDown+ @txt"gLocPolSfx.txt" ) ;

Define LocPolXxxinen
       LC( NoSentBoundary )
       [ [ AlphaUp AlphaDown+ FSep Field {inen} FSep Field {NUM=PL} Field FSep Field FSep ] - CaseNom ] ;

Define LocPolDisamb
       AlphaUp lemma_exact_morph( DownCase(LocOrPer), {NUM=SG} Field {CASE=}[{ILL}|{INE}]) ;

Define LocPolCaptured
       wordform_exact( [ LocPolCpt1 | LocPolCpt2 | LocPolCpt3 | LocPolCpt4 ] FinSuff ) ;

Define gazLoc [ @txt"gLocPol1Part.txt" | CountryName ] ;
Define gazLocPl @txt"gLocPolPl.txt" ;

Define LocMiscGazSgA
       Field AlphaUp lemma_exact( ( Ins(GeoPfx) Dash ) DownCase(gazLoc) ("i") ) ;

Define LocMiscGazSgB
       wordform_exact( ( OptCap(GeoPfx) Dash ) Ins(gazLoc) ) ;

Define LocMiscGazSgC
       inflect_sg( ( OptCap(GeoPfx) Dash ) gazLoc ) ;
       
Define LocMiscGazPl
       Field AlphaUp lemma_morph( Ins(gazLocPl), {NUM=PL} ) ;

Define LocMultiPart [
       m4_include(`gLocPolMWord.m4')
       ] ;

!* Category HEAD
Define LocPolit
       [ Ins(LocPolAdjPfx)::0.25
       | Ins(LocPolComp1)::0.25
       | Ins(LocPolComp2)::0.25
       | Ins(LocPolComp3)::0.25
       | Ins(LocPolSuffix1)::0.30
       | Ins(LocPolSuffix2)::0.25
       | Ins(LocPolSuffix3)::0.50
       | Ins(LocPolSubdivision)::0.25
       | Ins(LocPolSuffix5)::0.25
       | Ins(LocPolSuffix6)::0.25
       | Ins(LocPolSuffix7)::0.25
       | Ins(LocPolSuffix8)::0.50
       | Ins(LocPolPrefixed1)::0.20
       | Ins(LocPolPrefixed2)::0.60
       | Ins(LocPolInfixed1)::0.25
       | Ins(LocPolInfixed2)::0.25
       | Ins(LocPolMisc1)::0.25
       | Ins(LocPolMisc2)::0.25
       | Ins(LocPolMisc3)::0.40
       | Ins(LocPolMisc4)::0.25
       | Ins(LocPolMisc5)::0.25
       | Ins(LocPolCity1)::0.50
       | Ins(LocPolCity2)::0.60
       | Ins(LocPolColloc1)::0.00
       | Ins(LocPolColloc2)::0.00
       | Ins(LocPolColloc3)::0.50
       | Ins(LocPolColloc4)::0.50
       | Ins(LocPolColloc5)::0.50
       | Ins(LocPolColloc6)::0.50
       | Ins(LocPolColloc7)::0.50
       | Ins(LocPolColloc9A)::0.50
       | Ins(LocPolColloc9B)::0.50
       | Ins(LocPolCaptured)::0.75
       | Ins(LocPolDisamb)::0.10
       | Ins(LocMiscGazSgA)::0.25
       | Ins(LocMiscGazSgB)::0.25
       | Ins(LocMiscGazSgC)::0.25
       | Ins(LocMiscGazPl)::0.25
       | Ins(LocMultiPart)::0.10
       | Ins(LocPolSuffixed)::0.75
       | Ins(LocPolXxxinen)::0.75
       ] EndTag(EnamexLocPpl) ;

!!----------------------------------------------------------------------
!! <EnamexLocStr>: Street locations
!!----------------------------------------------------------------------

Define StreetSfxFin	[ FinVowel ("s"|"n"|"l"|"r") {tie}({ltä}|{lle}|{llä}) | {katu} | {kuja} | {polku} | {väylä} | {bulevardi}
       			| {esplanadi} | {puistikko} ] ;

Define StreetSfxMisc	[ {väg} ({en}) | {gata} ("n") | {gränd} ({en}) | {stig} ({en}) | {veien} | {straat} !! Removed "gate/gaten"
			| {avenue} | {boulevard} | {bulevard}({en}) | {stra}[{ss}|"ß"]"e" | {gasse} | {uli}[{ts}|"c"]"a"
			| {storg} | {torget} ] ;

Define StreetSfxWord 	[ {street} | {lane} | {avenue} | {boulevard} | {row} | {route} | {driveway} | {parkway} | {gardens} | {circle}
       			| {turnpike} | {gate} | {court} | {walk} | {terrace} | {highway} | {freeway} | {road} | {strasse} | {straße}
			| {alley} | {gasse} | {ulica} | {ulice} | {ulitsa} | {sokak} | {prospekt} | {rd} | {str.} | {pkwy} | {plz} ] ;

! "Unioninkatu", "Brändovägen", "Fuggerstraße", "Länsiväylä", "Läntinen Linjakatu", "Vanha Turuntie"
Define LocStreet1A
       ( AlphaUp lemma_exact( GeoAdj | {pikku} | {iso} | {vanha} ) WSep )
       AlphaUp lemma_morph([ Alpha+ Ins(StreetSfxFin) ] - [ {kulkuväylä} ], {NUM=SG}) ;

Define LocStreet1B
       inflect_sg( UppercaseAlpha Field StreetSfxMisc ) ;

Define LocStreet1
       [ Ins(LocStreet1A) | Ins(LocStreet1B) ] ;

! "Urho Kekkosen katu"
Define LocStreet2
       [ [ AlphaUp AlphaDown PropNom WSep AlphaUp PropGen ] | [ PropFirstNom WSep CapNounGen WSep ] ] WSep
       lemma_exact( Ins(StreetSfxFin) ) ;

! "Downing Street", "Gleiwitzer Straße"
Define LocStreet3
       ( CapMisc WSep ) ( CapMisc WSep ( CapWord WSep ) ) CapMisc WSep
       inflect_sg( Cap(StreetSfxWord) ) ;

!* "Rue Xxx" "Avenue de Xxx"
Define LocStreet4
       wordform_exact( {Rue} | {Rua} | {Avenue} | {Boulevard} | {Bulevardul} | {Bulevar} | {Estrada} | {Calea} | {Strada} | {Via} | {Viale} |
       		       {Calle} | {Paseo} | {Av.} | {Tv.} | {Estr.} | {Parque} | {Plaza} | {Place} | {Piazza} | {Trg} | {Ulica} | {Ulitsa} |
		       {Jalan} | {Jl.} | {Lorong} | {Lebuh}({raya}) | {Prospekt} ) WSep
       ( NameInitial WSep )
       ( CapNameNom WSep )
       ( DeLa WSep )
       ( CapNameNom WSep )
       CapName ;

!!* TODO: "[osoitteessa] Xxxx 1 A"

Define LocStreet5
       wordform_exact({Sörnäisten}) WSep lemma_exact({rantatie}) ;

! "Unioninkatu 40", "Motzstraße 25 B 69"
Define LocStreetNbr
       [ Ins(LocStreet1) | Ins(LocStreet2) | Ins(LocStreet3) | Ins(LocStreet4) | Ins(LocStreet5) ]
       ( WSep lemma_exact( 1To9 (0To9 (0To9)) (Alpha (Alpha) (1To9 (0To9 (0To9)))) )
       ( WSep lemma_exact( Alpha )
       ( WSep lemma_exact( 1To9 (0To9 (0To9)) ) ))) ;

! "Kehä I", "Kehä kolmonen"
Define LocStreetNoNbr
       wordform_exact( {Kehä} | {kehä} ) WSep
       lemma_exact( "i" ("i") ("i") | {ykkönen} | {kakkonen} | {kolmonen} ) ;

Define LocStreetMisc1
       AlphaUp Field Dash lemma_ends( Dash [ {katu} | {aukio} | {tori} ] ) ;

Define LocStreetMisc2
       [ CapMisc WSep ]*
       ( CapName WSep )
       CapWord WSep
       DashExt lemma_exact( (Dash) [ AlphaDown* {katu} | {aukio} | {tori} ] ) ;

! "Piritori", "Alppipuisto", "Vaasanaukio", "Varsapuistikko", "Vanha Suurtori"
Define LocStreetMisc3
       LC( NoSentBoundary )
       ( AlphaUp lemma_exact( GeoAdj | {pikku} | {iso} | {vanha} ) WSep )
       AlphaUp lemma_exact( [ AlphaDown AlphaDown+ [ {tori} | {puisto} | {puistikko} | {aukio} ] ] - [ Field [ {pastori} | {ttori} | {ptori} | {zetori} | {haukio} | {htori} | {ktori} | {istori} | {kompostori} ]] ) ;

Define LocStreetHighway
       lemma_exact( {valtatie} | {yhdystie} ) WSep
       lemma_exact( 1To9 0To9* (".") ) ;

Define LocStreetGaz
       [ LC( NoSentBoundary ) AlphaUp lemma_exact_morph([ {esplanadi} | {bulevardi} | {kurvi} ], {NUM=SG}) ] |
       [ AlphaUp lemma_exact_morph([ {espa} | {mansku} | {freda} | {rotuaari} | {länäri} | {länsiväylä} | {turuntie} ], {NUM=SG} ) ] |
       [ inflect_sg( {Broadway} | {Cheapside} | {Champs-Élysées} | {Champs-Elysees} | {Rautatientori} | {Elielinaukio} | {Senaatintori} ) ] |
       [ wf_lemma_x3({Taivaallisen}, {rauhan}, {aukio}) ] ;

!* 67th  Street, 7th Avenue, 23rd Street
Define LocStreetNth
       wordform_exact( 1To9 (0To9) [{st}|{nd}|{rd}|{th}] ) WSep
       inflect_sg( OptCap( {street} | {avenue} ) ) ;

!* Category HEAD
Define LocStreet
       [ Ins(LocStreetNbr)::0.75
       | Ins(LocStreetNoNbr)::0.75
       | Ins(LocStreetMisc1)::0.75
       | Ins(LocStreetMisc2)::0.75
       | Ins(LocStreetMisc3)::0.75
       | Ins(LocStreetHighway)::0.50
       | Ins(LocStreetNth)::0.25
       | Ins(LocStreetGaz)::0.25
       ] EndTag(EnamexLocStr) ;

!!----------------------------------------------------------------------
!! <EnamexLocFnc>: Buildings, infrastructure, facilities, real estate/property
!!----------------------------------------------------------------------

Define LocReligiousType
       {kirkko}::0.20 | {kappeli} | [{tuomio}|{puu}|{kivi}|{paanu}|{sauva}|{suur}] {kirkko} | {katedraali} | {basilika} |
       {moskeija} | {synagoga} | {temppeli} | {luostari} ;

Define LocStructType
       {pato} | {kaivos} | {linna} | {kartano} | {linnoitus} | {linnake} | {palatsi} | {muuri} | {aukio} | {torni} | {majakka} |
       {stadion} | {areena} | {riemukaari} | {paviljonki} | {tunneli} | {allas} | [ [ Dash | Vowel "n" |
       [ FinVowel - Apostr ] ("s"|"l"|"r") ] {silta} ] ;

Define LocPlaceOfWorship1A
       LC( NoSentBoundary )
       AlphaUp lemma_ends( AlphaDown (Dash) Ins(LocReligiousType) ) ;

Define LocPlaceOfWorship1B
       AlphaUp lemma_exact( AlphaDown+ AlphaDown [ {nkirkko} | {nkappeli} ] ) ; 

!* Pyhän Henrikin katedraali, Pyhän ristin/kolminaisuuden kirkko, Helsingin tuomiokirkko, Sikstuksen kappeli, [Helsingin] Saksalainen kirkko
!* muttei: Kristuksen kirkko
Define LocPlaceOfWorship2
       ( wordform_exact( Cap( {sulttaani} | {kuningas} | {pyhän} | {shaahi} | {šaahi} | {pašša} | {pasha} | ["š"|{sh}]{eikki} ) ) WSep )
       ( CapName WSep )
       [ [ CapNounGen - lemma_exact( {kristus} | {jeesus} | {jumala} ) ]::0.10 |
       	 [ PropGeoGen EndTag(EnamexLocPpl2) ] |
       	 [ LC( NoSentBoundary ) AlphaUp AlphaDown PosAdj ]
	 ] WSep
       lemma_exact_morph( Ins(LocReligiousType), {NUM=SG}) ;

Define LocPlaceOfWorship3
       ( wordform_exact( OptCap({st.}) ) WSep )
       inflect_sg( AlphaUp AlphaDown+ [ {kyrka}("n") | {kirke}("n") | {kyrkja}("n") | {kirkja}("n") | {kirche} | {kerk}
       		   	   	      | {kathedraal} | {münster} | (Dash) {templom} | Dash {ji} ] ) ;

!* Helsingin tuomiokirkko
Define LocPlaceOfWorship4
       AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_morph( {katedraali} | {tuomiokirkko} | {suurmoskeija} | {synagoga} , {NUM=SG}) ;

! Ritarihuone, Makkaratalo, Aikatalo, Olavinlinna, Suomenlinna, Ylioppilastalo, Näsinsilta, Puutarhakanava, ?Kaivopiha, ?Vaasanaukio
! Barona-areena, Iisakinkirkko, Länsisatama
Define LocPlaceMisc1
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_morph( AlphaDown (Dash) [ {talo} | {huone} | {sali} | {halli} | {linna} | {nportti} | {kauppahalli} | {piha} | {tarha} | {satama} | Ins(LocStructType) | Ins(LocReligiousType) ], {NUM=SG}|{POS=ADVERB}) ;

! Suezin kanava, Tammerkosken silta, Puijon torni, Haukilahden vesitorni, Berliinin muuri, Itkumuuri, Houtskarin majakka, Ishtarin portti
! Valamon luostari, Auschwitz-Birkenaun keskitysleiri

Define LocPlaceMisc2
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_morph( Ins(LocStructType) | Ins(LocReligiousType) | {keskitysleiri} | {portti}, {NUM=SG} ) ;

Define LocPlaceMisc3
       [ AlphaUp PropGeoGen | wordform_exact( {Suezin} | {Panaman} | {Saimaan} | {Taipaleen} | {Liverpoolin} ) ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( {kanava}, {NUM=SG} ) ;

Define LocPlaceMisc4
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( {tori} | {portti} , {NUM=SG} ) ;

Define LocPlaceHyphen
       ( CapMisc WSep )
       [ AlphaUp AlphaDown+ [ Word WSep (Dash) | Dash ] ]
       lemma_ends({niminen}) WSep
       lemma_morph( Ins(LocStructType) | Ins(LocReligiousType) | {talo} | {huone} | {sali} | {halli} | {linna} | {kiinteistö} ) ;

!* TODO: Golden Gate -silta

!* Mannilan tila RN:o 17:15
Define LocPlaceProperty1
       [ AlphaUp PropGen | CapNameGenNSB ] Capture(PropertyNameGen) WSep
       [ lemma_exact_morph( {tila}, {NUM=SG} ) | lemma_exact( {tilalla} | {tilalle} ) ]
       RC( WSep [ lemma_exact({rn:o}) | PropGeoIne ]) ;

Define LocPlaceProperty2
       CapName
       ( WSep CapWord ) Capture(PropertyNameUnk)
       RC( WSep lemma_exact({rn:o}) ) ;

Define LocPlaceProperty3
       [ PropertyNameGen ] WSep
       [ lemma_exact_morph( {tila}, {NUM=SG} ) | lemma_exact( {tilalla} | {tilalle} ) ] ;

Define LocPlaceProperty4
       [ AlphaUp PropNom | CapNameNom ] WSep
       ( CapWord WSep )
       ( Dash ) lemma_ends({niminen}) WSep
       lemma_morph( {tila} | {kiinteistö} | {talo}, {NUM=SG} ) ;

Define LocPlaceProperty5
       PropertyNameUnk Word ;

Define LocPlaceMisc5
       [ CapMisc WSep ]*
       [ [ CapNameGenNSB::0.60 | PropGeoGen ] - PropOrg ] EndTag(EnamexLocPpl2) WSep
       lemma_morph(
            {lentokenttä} |
	    {lentoasema} |
            {satama} |
            {kaupungintalo} |
            {kunnantalo} |
	    {pappila} |
            {puisto} |
	    {eläinpuisto} | {eläintarha} |
	    {huvipuisto} | {teemapuisto} |
	    {hautausmaa} | {hautuumaa} |
	    {kaatopaikka} |
	    {tähtitorni} |
	    {observatorio} |
	    {amfiteatteri} |
	    {varuskunta} |
	    {lentotukikohta} |
	    {laivastotukikohta} |
            {metroasema} |
            {bussiasema} |
	    {telakka} |
	    {linja-autoasema} |
	    {salpa-asema} |
	    {poliisiasema} |
            {rautatie}(Dash){asema} |
	    {messukeskus} |
	    [{kisa}|{jää}|{uima}]{halli} |
	    {vankila} |
	    {golfkenttä} |
	    {golfrata} |
	    {uimahalli} |
	    {uintikeskus} |
	    {uimala} |
            {juna-asema} |
            {terminaali},
       {NUM=SG} ) ;

Define LocPlaceMisc6
       "V" lemma_exact_morph({valkoinen}, {NUM=SG} Field {CASE=}[{NOM}|{GEN}|{INE}|{ILL}|{ELA}|{TRA}]) WSep
       lemma_exact_morph({talo}, {NUM=SG} Field {CASE=}[{NOM}|{GEN}|{INE}|{ILL}|{ELA}|{TRA}]) ;

!* Xxx-rata

Define LocPlaceMisc7
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ]*
       [ CapMisc WSep ]*
       [ CapNameNSB | CapMisc | [ AlphaUp 1To9] AbbrNom::0.50 ] WSep
       inflect_sg( {Hotel} | {Park} | {Station} | {Garden} | {Castle} | {Abbey} | {Palace} | {Square} | {Stadium} | {Cathedral} |
       		   {Church}::0.25 | {Stadion} | {House}::0.25 | {Temple} | {Arena} | {Areena} | {Hall} | {Studio} | {Place} | {Plaza} |
		   {Ranch} | {Center}::0.25 | {Zoo} | {Speedway} | {Cemetery} | {Statehouse} | {Bridge} | {Kerk} | {Dom} | {Minster} |
		   {Memorial} | {Monument} | {Capitol} | {Tower}("s") | {Arch} | {Gate} | {Circuit} | {Aquarium} | {Münster} |
		   OptCap({most}) | {Shrine} | {Fountain} | {Lodge} | {Zamok} ) ;

Define LocPlaceMisc8
       inflect_sg( AlphaUp AlphaDown+ [ {stugan} | {huset} | {gården} | {parken} ] ) ;

Define LocPlaceDefensive
       AlphaUp lemma_exact( [ {kymijoki} | {salpa} | {luumäk}["i"|{en}] | [ AlphaDown+ Dash ]+ ] {linja} ) ;

Define LocPlacePrefixed
       wordform_exact( {Casa} | {Maison} | {Palazzo} | {Basilica} | {Loggia} | {Villa} | {Château} | {Chateau} | {Palais} | {Monasterio} |
       		       {Osservatorio} | {Pont} | {Porta} | {Puerta} | {Canal} | {Castel} | {Castello} | {Certosa} | {Santuario} |
		       {Nôtre-Dame} | {Notre-Dame}| {Gare} | {Estació}("n") | {Stazione} | {Convento} | {Catedral} | {Cathédrale} |
		       {Cathedrale} | {Torre} | {Panagía} | {Panagia} | {Cappella} | {Battistero} | {Stift} | {Scala} | {Escalier} |
		       {Fuente} | {Gabinetto} | {Camp} | {Crkva} | {Hospits} | {Templo} ) WSep
       [ ( CapWord WSep ) [ AndOfThe WSep ]+ ( CapNameNom WSep ) ]*
       ( CapMisc WSep )
       CapName ;

!* "Notre Dame de la Garde", "Santa Maria dell'Anima", "Santa María de Óvila", "Santa Maria sopra Minerva"
!* "Santa Maria degli Angeli e dei Martiri", "San Juan de Rabanera", "Santa María del Naranco",
!* "Santa Maria presso San Satiro", "San Carlo alle Quattro Fontane", "Santa Maria in Aracoeli"
!* "Santa Maria Maddalena", "Santa Maria Maggiore"
Define LocPlacePrefixed2
       [ wordform_x2( {Notre}|{Nôtre}, {Dame} )
       | wordform_x2( {Santa}, {Maria}|{María}|{Cruz} )
       | wordform_x2( {San}|{São}, AlphaUp AlphaDown+ ) ] WSep
       [ [ DeLa | AndOfThe ] WSep CapName | wordform_exact( "M" AlphaDown+ ) ] ;

Define LocPlacePrisonCamp
       AlphaUp lemma_ends( {vankileiri} ) WSep
       wordform_exact( 0To9+ (".") (":" AlphaDown+ ) ) ;

Define LocPlaceGaz
       [ m4_include(`gLocPlace.m4') ] ;

!* Category HEAD
Define LocPlace
       [ Ins(LocPlaceOfWorship1A)::0.500 | Ins(LocPlaceOfWorship1B)::0.500
       | Ins(LocPlaceOfWorship2)::0.100
       | Ins(LocPlaceOfWorship3)::0.500
       | Ins(LocPlaceOfWorship4)::0.500
       | Ins(LocPlaceMisc1)::0.500
       | Ins(LocPlaceMisc2)::0.500
       | Ins(LocPlaceMisc3)::0.500
       | Ins(LocPlaceMisc4)::0.500
       | Ins(LocPlaceMisc5)::0.500
       | Ins(LocPlaceMisc6)::0.500
       | Ins(LocPlaceMisc7)::0.40
       | Ins(LocPlaceMisc8)::0.30
       | Ins(LocPlaceHyphen)::0.25
       | Ins(LocPlaceProperty1)::0.25
       | Ins(LocPlaceProperty2)::0.25
       | Ins(LocPlaceProperty3)::0.25
       | Ins(LocPlaceProperty4)::0.25
       | Ins(LocPlaceProperty5)::0.25
       | Ins(LocPlaceGaz)::0.25
       | Ins(LocPlacePrefixed)::0.30
       | Ins(LocPlacePrefixed2)::0.20
       | Ins(LocPlaceDefensive)::0.50
       | Ins(LocPlacePrisonCamp)::0.50
       ] EndTag(EnamexLocFnc) ;

!!----------------------------------------------------------------------
!! <EnamexLocMyt>:
!! Classify these as EnamexLocPpl for now
!!----------------------------------------------------------------------

Define LocFictional
       [ m4_include(`gLocFictional.m4') ]
       EndTag(EnamexLocPpl) ;

!!----------------------------------------------------------------------
!! <HEAD>
!!----------------------------------------------------------------------

!* Category HEAD
Define Location
       [ Ins(LocGeneral)
       | Ins(LocGeogr)
       | Ins(LocPolit)
       | Ins(LocStreet)
       | Ins(LocAstro)
       | Ins(LocPlace)
       | Ins(LocFictional)
       ] ;

!!----------------------------------------------------------------------
!! <EnamexOrgAux>
!!----------------------------------------------------------------------

Define CorpSuffixAbbrStr [ {oy} | {ky} | {ab} | {AB} | {abp} | {oyj} | {ag} | {AG} | {KG} | {as.} | {AS} | {A/S} | {ASA}
       			 | {BV} | {Co} | {Corp} | {GmbH} | {Gmbh} | {inc} | {ltd} | {llc} | {sa} | {SA} | {Lp} | {NV}
			 | {OÜ} | {Oü} | {plc} | {SpA} | {SE} | {SA} | {sia} ] (".") ;

Define CorpSuffixAbbrList [ OptCap(CorpSuffixAbbrStr) | UpCase(CorpSuffixAbbrStr) ] ;

Define CorpSuffixAbbr [ wordform_exact( Ins(CorpSuffixAbbrList) (":" AlphaDown+ )) ] ;
Define CorpSuffixAbbrNom wordform_exact( Ins(CorpSuffixAbbrList) ) ;

Define NpoSuffixAbbr lemma_exact( [ {ry} | {rf} | {rs} | {r.y} | {r.f} | {r.s.} ] (".") ) ;

Define PolPtySuffixAbbr lemma_exact( [{rp}] (".") ) ;

Define gazCorpSuffixWord inflect_sg( OptCap(@txt"gCorpSuffWord.txt") ) ;
Define gazCorpSuffixWordFin UppercaseAlpha lemma_ends( @txt"gCorpSuffWordFin.txt" ) ;
Define gazCorpSuffixPart lemma_ends( @txt"gCorpSuffPart.txt" ) ;
Define gazCorpSuffixPart2 lemma_ends( [\"ä"][\"r"]{yhtiö} | {Yhtiö} ) ;
Define gazCorpSuffixPartCap lemma_exact( UppercaseAlpha Field @txt"gCorpSuffPartCap.txt" ) ;
Define gazCorpSuffixPartSg lemma_morph( @txt"gCorpSuffPartSg.txt", {[NUM=SG]} ) ;
Define gazCorpSuffixPartPl lemma_morph( @txt"gCorpSuffPartPl.txt", {[NUM=PL]} ) ;
Define gazNpoSuffixPart [ lemma_morph(
       [ {instituutti} | {säätiö} | {järjestö} | {yhdistys} | {vartiosto} | {esikunta} | {kilta} | {klubi} | {osakunta} | {kansanliike}
       | {liitto} | {kehittämiskeskus} | {unioni} | {komissio} | {arkisto} | {laitos}::0.50 | {terveyskeskus} | {käräjä}
       | {lääninhallitus} | {rajavartiosto} | {maanmittauskonttori} | {prikaati} | {rykmentti} | {divisioona}
       | {pataljoona} | {sotilaslääni} | {nimismiespiiri} | {hovioikeuspiiri} | {työvoimapiiri} | {vesipiiri}
       | {rakennuspiiri} | {hovioikeuspiiri} | {maanmittauspiiri} | {koululautakunta} | {tiepiiri} | {sotilaspiiri}
       | {sairaala} | {vanhainkoti} | {tulli} | {maistraatti} | AlphaDown {virasto} | {kauppakamari} | {lautakunta} | {nimismiespiiri}
       | {valtuuskunta} | {palokunta} | {poliisilaitos} | {hätäkeskus} | AlphaDown {toimisto} | {työvoimapiiri}
       | {tuomiokunta} | {kehittämiskeskus} | {ritarikunta} | {tutkimuskeskus} | {suojeluskunta} ], {NUM=SG} )
       - lemma_ends( {vaaliliitto} | {salaliitto} | {avioliitto} | {avoliitto} | {homoliitto} | {lesboliitto} | {neuvostoliitto} |
       	 	     {tuotantolaitos} | {oikeuslaitos} | {koululaitos} | {voimalaitos} | {oppilaitos} | {kastilaitos} | {tuontitulli} ) ] ;

Define OrgSuffixAbbr   [ CorpSuffixAbbr | NpoSuffixAbbr | PolPtySuffixAbbr ] ;
Define OrgSuffixNoAbbr [ gazCorpSuffixWord | gazCorpSuffixPart | gazCorpSuffixPart2 | gazCorpSuffixPartCap |
                       	 gazCorpSuffixPartSg | gazCorpSuffixPartPl | gazNpoSuffixPart ] ;

!Define NgoSuffix [ NpoSuffixAbbr | gazNpoSuffixPart ] ;

!!----------------------------------------------------------------------
!! <EnamexOrgAth>: Athletic/sports organizations
!!----------------------------------------------------------------------

Define gazAthTentative @txt"gTentativeOrgAth.txt" ;

! "Ajax", "Inter", "Pelicans"
Define AthleticOrgListSgA
       ( AlphaUp PropGeoGen WSep )
       AlphaUp lemma_exact( DownCase( {Blues} | {HIFK} | {HJK} | {TPS} | {SJK} | {JYP} | {Pelicans} | {Tappara} | {SaiPa} | {KeuPa} |
       	       		    	      {KalPa} | {MyPa} | {Lukko}({on}) | {Kärppä} | {Ilves} | {Kiekko-Espoo} | {Juventus} | {Ajax} |
				      {Inter} | {KooKoo} | {Jäähonka} | {Buffalo} | {Turku-pesis} )) ;

Define AthleticOrgListSgB
       ( AlphaUp PropGeoGen WSep )
       inflect_sg( {Blues} | {Pelicans} | {Buffalo} | {SaiPa} | {KeuPa} | {KalPa} | {MyPa} | {Ilves} | {Ajax} ) ;

! "Ässät", "Kärpät", "Jokerit"
Define AthleticOrgListPl
       AlphaUp lemma_exact_morph([ {ässä} | {kärppä} | {haukka} | {jokeri} ("t") | {pallokissa} | {karhu-kissa} ("t") ], {NUM=PL} ) ;

Define AthleticOrgYkkonen
       LC( NoSentBoundary )
       [ "Y" | "K" ]lemma_exact_morph( {ykkönen} | {kakkonen} | {kolmonen} , {NUM=SG} Field {CASE=}[{INE}|{ILL}|{ELA}] ) ;

Define AthleticOrgListGaz
       [ m4_include(`gOrgAthTeam.m4') ] ;

! "FC Blaablaa"
Define AthleticOrgPrefixed1
       wordform_exact( {FC} | {FF} | {JJK} | {AC} | {BC} | {HC} | {SC} | {LP} | {IF} ("K") | {AC} | {BIK} | {FBC} | {VfL} | {VfB} |
       		       {Basket} | {Idrottsföreningen} | {Real} | {Inter} ) WSep
       [ CapWord | CapNameNom WSep [ PropGeo - lemma_exact(DownCase(CountryName)) ] ] ;

! "Pallokissat", "Pallo-Veikot"
Define AthleticOrgPrefixed2
       ([ PropGeoGen | lemma_exact( {imatra}, {NUM=SG} Field {CASE=GEN}) ] EndTag(EnamexLocPpl2) WSep )
       wordform_morph([ {Pallo} | {Maila} | {Kiekko} ] Dash AlphaUp AlphaDown+, {NUM=PL} ) ;

! "Kiekko-Espoo"
Define AthleticOrgPrefixed3
       AlphaUp lemma_exact( [ {kiekko} | {pallo} ] Dash [ ? - "o" ] [ AlphaDown+ | 0To9+ ] ) ; 

! "Espoon Xxxx"
Define AthleticOrgSuffixed1
       [ PropGeoGen | lemma_exact( {imatra}, {NUM=SG} Field {CASE=GEN} ) ] EndTag(EnamexLocPpl2) WSep
       ( wordform_exact({Työväen}) WSep )
       AlphaUp lemma_exact( [ {pallo}|{luistin}|{hiihto}|{urheilu}|{jalkapallo}] ( Dash ) [{seura}|{kerho}|{klubi}] | {dynamo}
        	            | {pallo} ( Dash ) {kerho} | [{pallo}|{jää} ({kiekko})] ( Dash ) {klubi} |
			      Field {veikko} | NoFSep* {toveri} | Field {poika} | {urheilija} |
			      Field {palloilija} | {pallo} | {kiekko} | {maila} | {kuula} |
		                    {aura} | {tappara} | {lukko}({on}) | {haka} | {hanka} | Field {volley} |
				    {honka} | {kataja} | {suunta} | {viesti} | {veto} | {kiri} |
	                            {kilpa} | {kisa} | ["v"|"w"]{isa} | {vesa} | {pamaus} | {lentopallo} |
				    {salama} | {ponsi} | {ponnistus} | {tempaus} | {nopsa} | {jymy} |
				    {rivakka} | {ponteva} | {luja} | {jäntevä} | {reipas} | {ketterä} |
				    {reima} | {roima} | {huima} | {virkiä} | {vilpas} | {ahkera} |
				    {puhti} | {tarmo} | {into} | {sisu} | {pyrintö} | {ässä} | {pyrkivä} |
				    {riento} | {ura} | {parma} | {karhu} | {kissa} | {kärppä} | {ilves} |
				    {tiikeri} | {nmky} | {ifk} | {namika} )
				    ( WSep NpoSuffixAbbr ) ;

! "Blues", "Canucks", "75ers"
Define AthleticOrgXxxers
       inflect_sg( [ 1To9 0To9 {ers} ] | @txt"gOrgAthSfxWord.txt" ) ;

! "Manchester United"
Define AthleticOrgSuffixed2
       ( AlphaUp [ AbbrNom | PunctWord ] WSep )
       ( CapMisc WSep )
       [ CapMisc | CapNameNSB ] EndTag(EnamexLocPpl2) WSep
       [ inflect_sg( {FC} | {IF} | {IK} | {HC} | {HK} | {BK} | {HF} | {Bollklubb} | {United} ) | Ins(AthleticOrgXxxers) ] ;

! "Tennessee Basket Club"
Define AthleticOrgSuffixed3
       CapMisc WSep
       wordform_exact( {Basket} | {Hockey} | {Football} | {Soccer} | {Volley} | {Esporto} ) WSep
       inflect_sg( {Club}("e") ) ;

! "Espoo/Espon Blues", "Bluesin"
Define AthleticOrgSuffixed4
       [ ( wordform_exact( {Espoo} ("n") ) WSep ) inflect_sg( {Blues} ) ] |
       [ ( wordform_exact( {Helsingin} ) WSep ) inflect_sg( {IFK} ) ] |
       [ LC( NoSentBoundary) "P" lemma_exact_morph({ponnistus}, {NUM=SG}) ] ;

Define AthleticOrgSuffixed5
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt lemma_exact_morph( (Dash) [ {talli} | {urheiluseura} | {seura}::0.50 ], {NUM=SG} ) ;

Define AthleticOrgSuffixed6
       AlphaUp AlphaDown lemma_ends( Dash {talli} ) ;

! "ManU", "TamU", "RoPS"
Define AthleticOrgCamelCase
       inflect_sg( AlphaUp AlphaDown AlphaDown* [ "U" | {PS} | {PK} | {JK} | {Pa} | {To} ] ) |
       inflect_sg( AlphaUp+ {IFK} ) ;

Define AthleticOrgDivision
       inflect_sg( (AlphaUp AlphaDown+) {Allsvenskan} | AlphaUp AlphaDown+ {serien} ) ;

Define AthleticOrgLeague0
       AlphaUp PropGeoGen WSep
       lemma_exact( {veikkausliiga} | {valioliiga} | {superliiga} ) ;

Define AthleticOrgLeague1
       AlphaUp lemma_exact( {veikkausliiga} | {valioliiga} | {superliiga} | {mestis} | {sm-liiga} | {bundesliiga} ) ;

Define AthleticOrgLeague2
       [ CapMisc WSep ]+
       wordform_exact( {League} ) WSep
       CapWord ;

Define AthleticOrgLeague3
       [ CapMisc WSep ]+
       inflect_sg( {League} ) ;

Define AthleticOrgLeague4
       inflect_sg( UppercaseAlpha {HL} ) ;

Define AthleticOrgLeague5
       UppercaseAlpha UppercaseAlpha UppercaseAlpha lemma_exact( Alpha+ {hl} Dash {sarja} ) ;

Define AthleticOrgSerieX
       wordform_exact( {Serie} ) WSep
       [ "A" | "B" | "C" ] lemma_exact( "a" | "b" | "c" ) ; 

Define AthleticOrgColloc1
       LC( lemma_morph( AlphaDown+ (Dash) [ {joukkue} | {talli} | {seura} ] ) WSep )
       ( AlphaUp [ AbbrNom | PunctWord ] WSep )
       ( CapMisc WSep )
       CapWord ;

Define AthleticOrgColloc2
       LC( lemma_exact( {pelata} ) WSep )
       [ [ CapMisc WSep ]* AlphaUp AlphaDown morphtag_semtag({CASE=INE}, {PROP=GEO})::0.40 | infl_sg_ine( gazAthTentative ) ] ;

Define AthleticOrgColloc3
       ( AbbrNom WSep )
       [ CapMisc WSep ]* 
       [ CapNameGenNSB::0.40 | PropGen::0.30 | PropGeoGen::0.10 | infl_sg_gen( gazAthTentative ) | wordform_exact( UppercaseAlpha UppercaseAlpha UppercaseAlpha* {:n} ) ]
       RC( WSep lemma_ends( {manageri} | {hyökkääjä} | {maalivahti} | {päävalmentaja} | {pelityyli} | {valmentaja} |
       	   		    {kokoonpano} | {kotikenttä} |{maalitykki} | {kapteeni} | {kasvatti} | {liigottelu} | {liigajoukkue} |
			    {laitapakki} | {edustusjoukkue} | {kenttäpelaaja} | {pelipaita} | {laitahyökkääjä} | {alkukausi} |
			    {kotipeli} | {loppukausi} | {matsi} | {pakki}::0.25 | {kannattaja}::0.25 | {pelaaja}::0.25 | {maali} ) ) ;

Define AthleticOrgColloc4
       LC( NoSentBoundary )
       [ AlphaUp PropGeoPar::0.50 | AlphaUp AlphaDown morphtag({NUM=SG} Field {CASE=PAR})::0.80 ]
       RC( WSep wordform_exact( {vastaan} ) ) ;

!* Category HEAD
Define AthlOrg
       [ Ins(AthleticOrgListSgA)::0.30
       | Ins(AthleticOrgListSgB)::0.30
       | Ins(AthleticOrgListPl)::0.30
       | Ins(AthleticOrgListGaz)::0.25
       | Ins(AthleticOrgXxxers)::0.50
       | Ins(AthleticOrgYkkonen)::0.20
       | Ins(AthleticOrgPrefixed1)::0.30
       | Ins(AthleticOrgPrefixed2)::0.30
       | Ins(AthleticOrgPrefixed3)::0.75
       | Ins(AthleticOrgSuffixed1)::0.30
       | Ins(AthleticOrgSuffixed2)::0.30
       | Ins(AthleticOrgSuffixed3)::0.30
       | Ins(AthleticOrgSuffixed4)::0.30
       | Ins(AthleticOrgSuffixed5)::0.30
       | Ins(AthleticOrgSuffixed6)::0.30
       | Ins(AthleticOrgCamelCase)::0.50
       | Ins(AthleticOrgDivision)::0.50
       | Ins(AthleticOrgLeague0)::0.50
       | Ins(AthleticOrgLeague1)::0.50
       | Ins(AthleticOrgLeague2)::0.50
       | Ins(AthleticOrgLeague3)::0.50
       | Ins(AthleticOrgLeague4)::0.50
       | Ins(AthleticOrgLeague5)::0.50
       | Ins(AthleticOrgSerieX)::0.50
       | Ins(AthleticOrgColloc1)::0.70
       | Ins(AthleticOrgColloc2)::0.20
       | Ins(AthleticOrgColloc3)::0.20
       | Ins(AthleticOrgColloc4)::0.00
       ] EndTag(EnamexOrgAth) ;

!!----------------------------------------------------------------------
!! <EnamexOrgClt>: Cultural organizations
!!----------------------------------------------------------------------

! "Olarin kuoro", "Radion sinfoniaorkesteri"
Define CultGroupSuffixed1
       [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 | AlphaUp PropGen::0.05 ] WSep
       ( CapWordGen WSep )
       ( lemma_exact( {filharmoninen} ) WSep )
       [ lemma_ends( {orkesteri} | AlphaDown+ {yhtye} | {kuoro} | {soittokunta} ) |
       	 lemma_exact( {filharmonikko}, {NUM=PL}) ] ;

Define CultGroupSuffixed2
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ]*
       [ CapMisc WSep ]*
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt lemma_ends( {orkesteri} | {yhtye} | {kuoro} | {bändi} | {duo} | {soittokunta} | [{tanssi}|{teatteri}|{baletti}][{ryhmä}|{seurue}] | {kollektiivi} | {sirkus}({ryhmä}) ) ;

Define CultGroupSuffixed3A
       [ [ AlphaUp Field ] - Cap( {rap} | Field (Dash) {rock} | Field {pop} | {jazz} | {eurodance} | {ambient} | {house} | {studio} |
       	   	   	     	  {radio} | {punk} | {hiphop} | {hip-hop} ) ] Capture(CltCpt1) Dash AlphaDown Field FSep Field [ {orkesteri} |
				  {soittokunta} | {yhtye} | {kuoro} | {bändi} | {duo} ] FSep Word ;

!* NOT WORKING?
Define CultGroupCaptured
       wordform_exact( [ CltCpt1 ] ( FinSuff ) ) ;

! "Adolf Fredriks flickkör", "Bo Kaspers orkester", "Espoo Big Band"
Define CultGroupSuffixed4
       [ CapMisc WSep ]*
       [ CapNameNSB | PropNom ] WSep
       inflect_sg( Field [ {Band} | {Ensemble} | {Orchestra} | ["o"|"O"]{rkester} | {kör} | {Kör} | {Duo} | {Sinfonietta}
       		   	 | {Trio} | {Quartet} | {Quintet} | {Singers} | {Dancers} | {Ballet} | {Staatsballet} ] ) ;

Define CultGroupSuffixed6
       ( CapMisc WSep )
       CapName WSep
       wordform_exact( {Dance} | {Ballet} | {Theater} | {Theatre} ) WSep
       inflect_sg( {Company} ) ;

Define CultGroupSuffixed5
       [ CapMisc WSep ]*
       inflect_sg( AlphaUp Field [ {orkester}("n") | {kör}({en}) | {sångförening}({en}) | {teater}("n") | {ballett} ] ) ;

!* "Tanssiorkesteri Helmenkalastajat", "Soitinyhtye Savonia"
Define CultGroupPrefixed
       LC( NoSentBoundary )
       AlphaUp ( TruncPfx WSep lemma_exact({ja}) WSep )
       wordform_exact( AlphaDown+ [ {yhtye} | {trio} | {orkesteri} ] ) WSep
       CapWord ;

!* "Lordi" merkitään yhtyeeksi muualla kuin virkken alussa,
! kun sitä ei seuraa erisnimen näköinen kokonaisuus
Define CultGroupLordi
       LC( NoSentBoundary )
       inflect_sg( {Lordi} )
       NRC( WSep AlphaUp AlphaDown+ ) ;

! "Kansallismuseo"
Define CultOrgSuffixed1
       LC( NoSentBoundary )
       AlphaUp lemma_exact_morph( AlphaDown+ [ {museo} | {galleria} | {teatteri} | ("o" Dash){ooppera} | {kirjasto} ], {NUM=SG}) ;

Define CultOrgNational
       AlphaUp ( PropGeoGen WSep )
       lemma_exact( [ {kansallis} | {kansallinen} | {kaupungin} ] [ {ooppera} | {baletti} | {teatteri} | {museo} ]) ;

! "KOM-teatteri", "Kaisa-kirjasto", "Lenin-museo" (muttei: "OpenSSL-salauskirjasto")
Define CultOrgSuffixed2
       AlphaUp lemma_ends( Dash [ AlphaDown* {museo} | {teatteri} | {kirjasto} | {galleria} ] ) ; !! Excluded "ooppera", e.g. "Aida-ooppera, Tosca-ooppera"

Define CultOrgSuffixed3
       [ CapMisc WSep ]*
       ( CapName WSep )
       CapName WSep
       Dash AlphaDown lemma_ends( {museo} | {teatteri} | {kirjasto} ) ;

! "Ruotsin kuninkaallinen ooppera", "Helsingin kaupunginteatteri", "Suomen kansallismuseo"
Define CultOrgSuffixed4
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       ( lemma_ends({inen}) WSep )
       lemma_exact_morph( AlphaDown* [ {museo} | {teatteri} | {ooppera} | {kirjasto} | {galleria} ], {NUM=SG}) ;

! "Helsingin Työväen Teatteri"
Define CultOrgSuffixed5
       PropGeoGen WSep
       ( AlphaUp CaseGen WSep )
       AlphaUp lemma_exact_morph( AlphaDown* [ {museo} | {teatteri} | {ooppera} | {kirjasto} | {galleria} ], {NUM=SG}) ;

! "[teatteri] Viirus", "Tanssiteatteri Minimi"
Define CultOrgPrefixed1
       wordform_exact( Cap(AlphaDown* {teatteri}) ) WSep
       CapName ;

!* "Teatro Regio di Parma", "Opéra National de Paris", "Théâtre Impérial de Compiègne", "Galleria degli Uffizi"
Define CultOrgPrefixed2
       wordform_exact( {Thêatre} | {Galleria} | {Théatre} | {Teatro} | {Opera} | {Opéra} | {Galleri}["a"|"e"] | {Bibliothéque} | {Theatre} | {Gallery} | {Musée} | {Muzej} | {Musei} | {Museum} | {Muzeum} | {Museu} | {Museo} | {Library} | {Circo} | {Cirque} | {Sirkus} | {Ballet} ) WSep
       ( CapMisc WSep )
       [ ( CapWord WSep ) [ AndOfThe WSep ]+ ( CapNameNom WSep ) ]*
       [ CapMisc WSep ]*
       CapName ;

!* "Espoo Museum of Modern Art", "Tate Gallery", "Deutsche Oper Berlin", "National Gallery of British Art"
Define CultOrgSuffixed6
       [ [ CapMisc - wordform_exact( {The} ) ] WSep ]+
       inflect_sg( {Theatre} | {Gallery} | {Museum} | {Library}::0.25 | {Oper}("a") | {Teatern} | {Teater} )
       ( WSep [ AndOfThe WSep ]+ [ CapMisc WSep ]* CapName ) ;

Define CultOrgColloc1
       LC( lemma_morph( {yhtye} | {bändi} | {trio} | {orkesteri} , {CASE=NOM} ) WSep ( wordform_exact({nimeltä}) WSep ) )
       [ CapMisc WSep ]*
       CapName ;

Define CultOrgColloc2
       [ CapMisc WSep ]*
       [ PropGen | CapNameGenNSB ]
       RC( WSep lemma_ends( {single} | {albumi} | {fani} | [{hitti}|{uutuus}]{sinkku} | {kiertue} |
       	   		    {comeback} | {keikka} | {konsertti} | {laulaja} | {solisti} | {kitaristi} |
			    {basisti} | {rumpali} | {keikkatauko} ) ) ;
Define CultOrgColloc3
       [ CapMisc WSep ]*
       [ PropGen | CapNameGenNSB ]
       RC( WSep lemma_ends( {kävijä}({määrä}) | {näyttely} | {kokoelma} | {intendentti} | {pääsymaksu} ) ) ;

Define CultGazMacro1
       [ m4_include(`gOrgCult.m4') ] ;

Define CultGazMacro2
       [ m4_include(`gOrgCultCongr.m4') ] ;

Define CultSemtag
       semtag({PROP=CULTGRP}) ;

! Category HEAD
Define CultOrg
       [ Ins(CultGroupSuffixed1)::0.25
       | Ins(CultGroupSuffixed2)::0.25
       | Ins(CultGroupSuffixed3A)::0.60
       | Ins(CultGroupCaptured)::0.75
       | Ins(CultGroupSuffixed4)::0.30
       | Ins(CultGroupSuffixed5)::0.30
       | Ins(CultGroupSuffixed6)::0.25
       | Ins(CultGroupPrefixed)::0.25
       | Ins(CultOrgNational)::0.30
       | Ins(CultGroupLordi)::0.50
       | Ins(CultOrgSuffixed1)::0.50
       | Ins(CultOrgSuffixed2)::0.50
       | Ins(CultOrgSuffixed3)::0.50
       | Ins(CultOrgSuffixed4)::0.50
       | Ins(CultOrgSuffixed5)::0.50
       | Ins(CultOrgSuffixed6)::0.25
       | Ins(CultOrgPrefixed1)::0.50
       | Ins(CultOrgPrefixed2)::0.40
       | Ins(CultOrgColloc1)::0.75
       | Ins(CultOrgColloc2)::0.75
       | Ins(CultOrgColloc3)::0.75
       | Ins(CultGazMacro1)::0.00
       | Ins(CultGazMacro2)::0.00
       | Ins(CultSemtag)::0.40
       ] EndTag(EnamexOrgClt) ;

!!----------------------------------------------------------------------
!! <EnamexOrgEdu>: Educational organizations
!!----------------------------------------------------------------------

Define SchoolType lemma_morph([ {koulu} | {opisto} | {koulutuskeskus} | {koulukoti} | {akatemia} | {lyseo} | {lukio} | {oppilaitos} |
       		  		{instituutti} | {instituutinen} | [{ala-}|{ylä}]{aste} | "k"["y"|"i"]{mnaasi} | {koulutoimisto} |
				{konservatorio} ], {NUM=SG}) ;

!* "tekniikan laitos", "humanistinen tiedekunta"
Define SchoolFacultyDept
       ( PosAdj WSep )
       [ PosAdj | NounGen ] WSep
       lemma_exact( {laitos} | {tiedekunta} | {instituutti} ) ;

!* "Sibelius-akatemia", "Työväenopisto"
Define SchoolName1A
       LC( NoSentBoundary )
       AlphaUp Ins(SchoolType)
       ( WSep Ins(SchoolFacultyDept) ) ;

! "Militärhögskolan"
Define SchoolName1B
       inflect_sg( AlphaUp AlphaDown+ [ {skol}[{an}|"a"|"e"] | {universitet} | {schule} ] ) ;

!* "Helsingin yliopisto", "Teknillinen korkeakoulu", "Porin seudun työväenopisto", "Tukholman kuninkaallinen yliopisto"
Define SchoolName2A
       ( CapMisc WSep )
       [ CapNameGenNSB EndTag(EnamexLocPpl2) | AlphaUp [ PropGen EndTag(EnamexLocPpl2) | morphtag({POS=ADJECTIVE}) ]] WSep
       ( [ wordform_ends( {seudun} ) | lemma_ends({inen}) ] WSep )
       AlphaDown Ins(SchoolType)
       ( WSep Ins(SchoolFacultyDept) ) ;

!* Helsingin Suomalainen Yhteiskoulu, Turun Steiner-koulu
Define SchoolName2E
       AlphaUp PropGen EndTag(EnamexLocPpl2) WSep
       ( AlphaUp lemma_ends({inen}) WSep )
       AlphaUp Ins(SchoolType) ;

!* "Tekniikan Akatemia"
Define SchoolName2C
       CapWordGen WSep
       AlphaUp AlphaDown Ins(SchoolType) ;

!* "Chalmers tekniska högskola"
Define SchoolName2B
       CapMisc WSep
       ( wordform_ends( LowercaseAlpha+ ) WSep )
       inflect_sg( Field [ {skol}[{an}|"a"|"e"] | {universitet} | {schule} ] ) ;

!* "Jyväskylän seminaari"
Define SchoolName2D
       AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_ends({seminaari}) ;

!* "University of Oxford"
Define SchoolName3
       wordform_exact( {School} | {College} | {University} | {Academy} )
       WSep wordform_exact({of}) ( WSep wordform_exact({the}) )
       WSep CapWord
       ( ( WSep wordform_exact({and}) ) WSep CapWord ) ;

!* "Carnegie Mellon University", "Hogwarts School of Witchcraft and Wizardry", "Massachusetts Institute of Technology"
!* "Aalto University", "DeVry University"
Define SchoolName4
       CapWord WSep
       ( CapWord WSep )
       ( wordform_exact( {High} | {Secondary} | {Primary} ) WSep )
       inflect_sg( {School} | {College} | {University} | {Academy} | {Institute} | {Gimnazija} | {Schule} )
       ( WSep wordform_exact({of})
       WSep CapWord
       ( ( WSep wordform_exact({and}) ) WSep CapWord ) )
       ( WSep DashExt AlphaDown Ins(SchoolType) ) ;

Define SchoolPrefixed
       wordform_exact( {École} | {Université} | {Università} | {Universidad} | {Lycée} | {Gimnasio} | {Gimnazija} | {Accademia} ) WSep
       ( CapMisc WSep )
       [ ( CapWord WSep ) [ AndOfThe WSep ]+ ]*
       [ CapMisc WSep ]*
       CapName ;

Define SchoolName5
       ( PropGeoGen WSep )
       AlphaUp [ wordform_ends( AlphaDown [ {ian} | {tieteen} | {logian} | {opin} | {iikan} ]) | lemma_ends( {inen} ) ] WSep
       lemma_exact( {laitos} | {tiedekunta} | {instituutti} ) ;

Define SchoolSuffixed
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ]*
       [ CapMisc WSep ]*
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt AlphaDown Ins(SchoolType) ;

Define SchoolNameGaz1
       inflect_sg( {Yale} | {Harvard} | {Stanford} | {MIT} | {TKK} | {HY} | {UCL} | {Metropolia} | {Diak} | {Laurea} | {Tylypahka} | {Haaga-Helia} | {Arcada} | UppercaseAlpha {SU}::0.50 | {Humak} | {HUMAK} ) ;

Define SchoolNameGaz2
       lemma_exact( {aalto} Dash {yliopisto} | {aleksanteri} Dash {instituutti}| [ {metropolia} | {savonia} ] Dash {ammattikorkeakoulu} ) ;

Define SchoolNameGaz [ SchoolNameGaz1 | SchoolNameGaz2 ] ;

!* Category HEAD
Define EduOrg
       [ Ins(SchoolName1A)::0.25
       | Ins(SchoolName1B)::0.25
       | Ins(SchoolName2A)::0.25
       | Ins(SchoolName2B)::0.50
       | Ins(SchoolName2C)::0.30
       | Ins(SchoolName2D)::0.25
       | Ins(SchoolName2E)::0.25
       | Ins(SchoolName3)::0.25
       | Ins(SchoolName4)::0.25
       | Ins(SchoolName5)::0.25
       | Ins(SchoolSuffixed)::0.25
       | Ins(SchoolPrefixed)::0.30
       | Ins(SchoolNameGaz)::0.20
       ] EndTag(EnamexOrgEdu) ;

!!----------------------------------------------------------------------
!! <EnamexOrgFin>: Financial organizations
!!----------------------------------------------------------------------

!* "New Yorkin pörssi", "Helsingin pörssi"
Define OrgFinStockMarket
       ( wordform_exact({New}) WSep )
       AlphaUp morphtag({[POS=NOUN]} Field {[NUM=SG][CASE=GEN]}) EndTag(EnamexLocPpl2) WSep
       [ lemma_ends({pörssi}) - lemma_exact( [{maali}|{piste}|{tavara}]{pörssi} ) ] ;

!* "Bank of England", "Banca Transilvania", "Banque Populaire du Rwanda"
Define OrgFinBank
       wordform_exact( {Ban} [ {co} | {que} | {ka} | {ca} | {că} | "k" ] ) WSep
       [ CapWord WSep ]*
       ( wordform_exact( {of} | "a" | {de} | {du} | {del} | {do} | {dei} ) WSep ( AlphaDown Word WSep ) )
       [ CapNameNom WSep ]*
       CapWord ;

!* "Suomen Pankki"
Define OrgFinBank2A
       [ PropGeoGen | USpl | wordform_exact({Suomen}) | AlphaUp lemma_exact({kansainvälinen}) ] WSep
       lemma_morph({pankki} | AlphaDown {rahasto}, {NUM=SG}) ;

!* Postipankki Oy:n, Helsingin Osuuspankki Oy:n, Xxxxn Seudun Säästöpankki Oy:n
Define OrgFinBank2B
       ( [ [ CapNameGen EndTag(EnamexLocPpl2) WSep lemma_exact_morph( {seutu}, {CASE=GEN} ) ] | PropGeoGen EndTag(EnamexLocPpl2)
       	 | CapNameGenNSB::0.05 ] WSep )
       AlphaUp lemma_morph( {pankki} , {CASE=NOM} ) WSep
       lemma_ends( {oy}("j") | {ky} ) ;

!* Lappeenrannan Osuuspankin
Define OrgFinBank2C
       [ [ CapNameGen EndTag(EnamexLocPpl2) WSep lemma_exact_morph( {seutu}, {CASE=GEN} ) ] | PropGeoGen EndTag(EnamexLocPpl2)
       	 | CapNameGenNSB::0.05 ] WSep
       AlphaUp lemma_ends( {pankki} ) ;

!* "Handelsbanken", "Ålandsbanken", "Sparkasse", "Citibank"
Define OrgFinBank3
       ( CapMisc WSep )
       inflect_sg( AlphaUp Field [ {banken} | {bank} | {kasse} | {kassan} ] ) ;

!* [xxx] Postipankin
Define OrgFinBank4A
       LC( NoSentBoundary )
       AlphaUp lemma_ends( AlphaDown (Dash) {pankki}) ;

Define OrgFinBank4B
       AlphaUp Field Dash {Pank} lemma_ends( Dash {pankki} ) ;

!* "Xxx Xxx -säästöpankki"
Define OrgFinBank5
       ( CapMisc WSep )+
       CapWord WSep (CapWord WSep)
       Dash lemma_ends( {pankki} | {pankkiiriliike} | {rahasto} | {vakuutusyhtiö} ) ;

!* "Alexandria-pankkiiriliike"
Define OrgFinBank6
       LC( NoSentBoundary )
       AlphaUp Field Dash lemma_ends( Dash AlphaDown* {pankki} | {pankkiiriliike} | {rahasto} | {vakuutusyhtiö} ) ;

!* "[pankkiiriliike] Alexandria"
Define OrgFinBank7
       LC( lemma_morph( {pankkiiriliike} | {vakuutusyhtiö} | {säästöpankki}, {CASE=NOM} ) WSep )
       CapWord [ WSep CapMisc ]* ;

!* Danske Bank
Define OrgFinBank8
       [ CapMisc | wordform_exact({Danske}) ] WSep
       inflect_sg({Bank}) ;

!* OKO
Define OrgFinBank9
       {OKO} lemma_exact({oko}) ;

!* Category HEAD
Define FinancOrg
       [ Ins(OrgFinStockMarket)::0.25
       | Ins(OrgFinBank)::0.25
       | Ins(OrgFinBank2A)::0.25 | Ins(OrgFinBank2B)::0.25 | Ins(OrgFinBank2C)::0.25
       | Ins(OrgFinBank3)::0.40
       | Ins(OrgFinBank4A)::0.25 | Ins(OrgFinBank4B)::0.25
       | Ins(OrgFinBank5)::0.25
       | Ins(OrgFinBank6)::0.25
       | Ins(OrgFinBank7)::0.75
       | Ins(OrgFinBank8)::0.25
       | Ins(OrgFinBank9)::0.10
       ] EndTag(EnamexOrgFin) ;

!!----------------------------------------------------------------------
!! <EnamexOrgTvr>: Media organizations (TV, radio, press)
!!----------------------------------------------------------------------

! "talouslehti", "ruokablogi", "tiedejulkaisu" (muttei: "välilehti", "uudelleenjulkaisu")
Define MediaTypeStr
       [ [ Field [ {lehti}("ä") | {blogi} | {julkaisu} | {lehtitalo} | {uutis}[{toimisto}|{palvelu}|{portaali}] | {yleisradio}({yhtiö})
       	 | {verkkomedia} | {kanava} ] ]
	 - [ {välilehti} | {jakelukanava} | {uudelleenjulkaisu} | {murtautumiskanava} ] ] ;

Define MediaType lemma_exact(MediaTypeStr) ;

! "Forbes-lehti"
Define MediaSuffixed1
       [[ AlphaUp Field ] - [ {Youtube} | {YouTube} | {Chrome} ]] Dash Ins(MediaType) ;

!* "Aamulehti", "Helsingin Seutu"
Define MediaSuffixed2
       LC( NoSentBoundary )
       AlphaUp lemma_ends( {lehti} | {seutu} ) ;

Define MediaSuffixed3
       [ CapNameGenNSB::0.05 | AlphaUp PropGen EndTag(EnamexLocPpl2) ] WSep
       AlphaUp lemma_ends( {lehti} | {seutu} ) ;

!* "Aftonbladet", "Svenska Dagbladet", "Kyrkpressen", "Hommikuleht", "Jyllands-Posten"
Define MediaSuffixed4
       [ CapMisc WSep ]*
       inflect_sg( AlphaUp Field OptCap( {bladet} | {blad} | {pressen} | {avisen} | {tidende} | {tidningen} | {posten} | {leht} | {kuriren} |
       		   	   	 	 {zeitung} | {spiegel} | {bladid} | {blaðið} ) ) ;

!* "Fanni & Kaneli -ruokablogi", "Days of Old -lehti", "Rise of the Phoenix -blogi"
Define MediaSuffixed5
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ]*
       ( CapWord WSep )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       Dash Ins(MediaType) ;

Define MediaSuffixed6
       InQuotes WSep
       DashExt Ins(MediaType) ;

! "Wall Street Journal", "The New York Times", "Morning Herald -sanomalehti"
Define MediaSuffixed7
       ( wordform_exact({The}) WSep [ CapWord WSep ]* )
       [ CapMisc WSep ]*
       CapWord WSep
       inflect_sg( [ {Times} | {Journal} | {Mirror} | {Post} | {Herald} | {Gazette} | {Dagblad} ({et}) | {Aftonblad} | {Morgenpost} 
		   | {Zeitung} | {Tidning} ({en}|{ar}) | {Pravda} | {News} | {Novosti} | {Gazeta} | {Folkeblad} | {Folkblad} | {Allehanda}
		   | {Channel} | {Reporter} | {Magazine} | {Blog} | {Weekly} | {Daily} | {Monthly} | {Avis} | {Presse} | {Vesnik}
		   | {Tribune} | {Telegraph} | {Nyheter} | {Underrättelser} | ["I"|"E"]{nquirer} | {Bladet} | {Tidende} | {Tagblatt}
		   | {Today} | {Chronicle} | {Tidskrift} | {Krönika} | {TV} | {Radio} | {Ekspress} | {Hebdo} | {Quotidiano} | {Nachrichten}
		   | {Päevaleh}[ "t" ("i"|"e")|{de}] | {Hääl}("e") | {Sõnumid} | {Ajalehed} | {Abendblatt} | {Allgemeine} | {Teataja}
		   | {Tageblatt} | {Morgenblatt} | {Shimbun} | {Shinbun} | {Postimees}
		   | OptCap( {dnevnik} | {novosti} | {noviny} | {novine} | {týždenník} | {kronika} | {glasnik} | {novice} ) ] )
	( WSep Dash Ins(MediaType) ) ;

! "Taloussanomat", "Ilta-Sanomat"
Define MediaSuffixedPl1
       LC( NoSentBoundary )
       AlphaUp lemma_morph( AlphaDown+ (Dash) [ {sanoma} ("t") | {uuti} ({nen}|{set}) ], {NUM=PL} ) ;

! "Turun Sanomat", "Helsingin Uutiset", "Kansan Uutiset"
Define MediaSuffixedPl2
       [ PropGeoGen EndTag(EnamexLocPpl2) | CapWordGen::0.05 ] WSep
       AlphaUp lemma_morph( {sanoma} ("t") | {uuti} ({nen}|{set}), {NUM=PL} ) ;

Define MediaSuffixedPl3
       AlphaUp lemma_morph([{talous}|{viikko}|{ilta-}]{sanoma}("t"), {NUM=PL}) ;

!* "Xxxxxinen/Xxxx:n aikakauskirja"
Define MediaSuffixedPeriodical
       ( PropGeoGen EndTag(EnamexLocPpl2) WSep )
       [ CapNounGenNSB | AlphaUp lemma_ends({inen}) ] WSep
       lemma_exact_morph( {aikakauskirja} | {aikakauslehti}, {NUM=SG} ) ;

!* "Radio Suomipop"
Define MediaPrefixed1
       wordform_exact({Radio}) WSep CapWord ;

!* "Journal of Blah Blah Innovation Management"
Define MediaPrefixed2
       [ CapMisc WSep ]*
       wordform_exact( {Journal} | {News} ) WSep wordform_exact({of})
       [ [ WSep AndOfThe ]* [ WSep CapWord ]+ ]+
       ( WSep Dash lemma_ends( {lehti} | {julkaisu} ) ) ;

Define MediaPrefixed3
       ( wordform_exact( {La} | {Le} | {Il} | {El} | "O" | "A" ) WSep | {L} Apostr )
       wordform_exact( {Écho} | {Gazzetta} | {Giornale} | {Journal} | {Corriere} | {Quotidiano} | {Messaggero} | {Messager} |
       		       {Osservatore} | {Courrier} | {Voix} | {Matin} | {Tribune} | {Tribuna} | {Cahiers} | {Revue} | {Gazette} | {Diario} |
		       {Periódico} | {Periodico} | {Voz} | {Correo} | {Diari} | {Opinión} | {Diário} | {Correio} | {Jornal} |
		       {Slobodna} | {Glas} | {Dnevni} | {Večernji} | {Vetšerni} ("j") | {Monde} | {Mundo} | {Dagbladet} | {Bladet} |
		       {Ziarul} | {Monitorul} | {Gazeta} | {Noticias} | {Radiotelevisione} ) WSep
       ( DeLa WSep )
       CapName ;

Define MediaChannel
       wordform_exact( {Channel} | {Canal} | {Kanal} ) WSep
       lemma_exact( 1To9 ( 0To9 ) ) ;
       
Define Media1PartListA
       inflect_sg( @txt"gMedia1Part.txt") ;

Define Media1PartListB
       Ins(AlphaUp) lemma_exact_morph( DownCase(@txt"gMedia1PartFin.txt"), {NUM=SG}) ;

Define gazMediaMWordCongr OptQuotes([
       m4_include(`gOrgMediaCongr.m4')
       ]) ;

Define gazMediaMWordNoCongr OptQuotes([
       m4_include(`gOrgMedia.m4')
       ]) ;

Define MediaMWord
       [ Ins(gazMediaMWordNoCongr) | Ins(gazMediaMWordCongr) ]
       ( WSep Dash [ Ins(MediaType) | lemma_exact( (Dash)  AlphaDown* [ {sivusto} | {yhtiö} ]) ] ) ;
       
! [talouslehti] Forbes
Define MediaWithType
       LC( lemma_exact_morph(MediaTypeStr, {[NUM=SG][CASE=NOM]}) WSep )
       [ CapMisc WSep ]*
       [ CapName | CapMisc | Abbr | AbbrNom ]
       [ [ WSep AndOfThe ]+ WSep CapWord ]*
       ( WSep 0To9 PosNum ) ;

Define MediaWithXxxSg
       [ CapNameGenNSB | PropGen ]
       RC( WSep ( PosAdj WSep ) lemma_exact_morph( {toimitus} | {lukijakunta} | {journalismi} | {levikki} | {julkaisija} | {toimittaja} | {pääkirjoitus} | {uutinen} | {erikoisnumero} , {NUM=SG} ) ) ;

Define MediaWithXxxPl
       [ CapNameGenNSB | PropGen ]
       RC( WSep ( PosAdj WSep ) lemma_morph( {lukija} | {tilaaja} | {toimittaja} | {pääkirjoitus} | {uutiset}, {NUM=PL} ) ) ;

Define MediaYLE
       wordform_exact( {Yle} ({n}|{ä}|{lle}|{llä}|{ltä}|{ssä|{stä}|{en}) ({kin}|{kään}|{hän}) ) ;

Define MediaSemtag
       morphtag({SEM=MEDIA}) ;

!* Category HEAD
Define MediaOrg
       [ Ins(MediaSuffixed1)::0.20
       | Ins(MediaSuffixed2)::0.30
       | Ins(MediaSuffixed3)::0.25
       | OptQuotes(Ins(MediaSuffixed4)::0.25)
       | Ins(MediaSuffixed5)::0.25
       | Ins(MediaSuffixed6)::0.25
       | OptQuotes(Ins(MediaSuffixed7)::0.25)
       | OptQuotes(Ins(MediaSuffixedPl1)::0.25)
       | OptQuotes(Ins(MediaSuffixedPl2)::0.25)
       | OptQuotes(Ins(MediaSuffixedPl3)::0.25)
       | OptQuotes(Ins(MediaSuffixedPeriodical)::0.25)
       | Ins(MediaPrefixed1)::0.50
       | OptQuotes(Ins(MediaPrefixed2)::0.50)
       | OptQuotes(Ins(MediaPrefixed3)::0.25)
       | Ins(MediaChannel)::0.30
       | OptQuotes(Ins(Media1PartListA)::0.30)
       | OptQuotes(Ins(Media1PartListB)::0.30)
       | Ins(MediaWithType)::0.50
       | Ins(MediaYLE)::0.50
       | Ins(MediaMWord)::0.10
       | Ins(MediaWithXxxPl)::0.75
       | Ins(MediaWithXxxSg)::0.75
       | OptQuotes(Ins(MediaSemtag)::0.75)
       ] EndTag(EnamexOrgTvr) ;

!!----------------------------------------------------------------------
!! <EnamexOrgCrp>:
!! - Capitalized words followed by a common suffix "Inc.", "Group" etc.
!! - Capitalized words followed by another word typical for organizations
!! - Funder organizations: capitalized word(s) preceded by
!! the lemma "rahoittaja". Recognize all names in a list, separated by
!! commas, "ja" or "sekä".
!! ...
!!----------------------------------------------------------------------

!* "Supercell", "Vodafone"
Define CorpGuessedA
       inflect_sg( AlphaUp Alpha+ [ OptCap( @txt"gCorpSuff.txt" ) | {Media} ] ) ;

Define CorpGuessedB
       LC( NoSentBoundary )
       inflect_sg( AlphaUp Alpha+ [ {tel} | {media} ] ) ;

!-----------------------------------------------------------------------

Define AbbrInfl
       inflect_sg( UppercaseAlpha UppercaseAlpha (UppercaseAlpha) (UppercaseAlpha) (UppercaseAlpha) ) ;

Define AbbrBase
       wordform_exact( UppercaseAlpha UppercaseAlpha (UppercaseAlpha) (UppercaseAlpha) (UppercaseAlpha) ) ;

Define CorpSfxWordFin @txt"gCorpSuffWordFin.txt" ;

!-----------------------------------------------------------------------

! "Turku Energialle"
! "Yrittäjäin Vakuutukselle"
Define CorpSuffixedFin1A
       ( wordform_exact( {Oy} | {OY} | {Kommandiittiyhtiö} | {Ky} | {KY} ) WSep )
       [ AbbrBase
       | PropGeoGen EndTag(EnamexLocPpl2) ( WSep wordform_exact( OptCap({seudun}) ) )
       | PropGeoNom EndTag(EnamexLocPpl2) | CapMisc | CapNameGenNSB ] WSep
       AlphaUp Alpha+ (Dash AlphaUp AlphaDown+) FSep ( Alpha+ Dash ) Alpha* Ins(CorpSfxWordFin) FSep Word ;

! "Turku Energia Oy:lle"
! "Yrittäjäin Vakuutus keskinäiselle yhtiölle"
Define CorpSuffixedFin1B
       [ AbbrBase
       | PropGeoGen EndTag(EnamexLocPpl2) ( WSep wordform_exact( OptCap({seudun}) ) )
       | PropGeoNom EndTag(EnamexLocPpl2) | CapMisc | CapNameGenNSB | AlphaUp AlphaDown NounGen ] WSep
       ( TruncPfx WSep lemma_exact({ja}) WSep )
       AlphaUp Alpha+ (Dash AlphaUp AlphaDown+) FSep ( Alpha+ Dash ) Alpha* Ins(CorpSfxWordFin) FSep Field {CASE=NOM} Word WSep
       [ ( CapMisc WSep ) lemma_exact( {kommandiittiyhtiö} | {osake} (Dash) {yhtiö} | {ky} | {oy} ({:öö}) | {oyj} | {ab} | {abp} )
       | lemma_exact( {avoin} | {keskinäinen} ) WSep lemma_ends({yhtiö})
       | wordform_exact({Oy}) WSep "A" lemma_exact({ab}) ] ;

!* Suomen Maksuturva Oy
!* HUOM: Esim. "Ihalainen" ei välttämättä tunnistu nimeksi -> lisänä {inen}-sääntö
Define CorpSuffixedFin2A
       ( [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 | [ [ CapMisc | AbbrBase ] WSep ]* CapMisc
	 | AbbrBase | NameInitial | CapWord WSep wordform_exact("&") ] WSep )
       [ CapMisc | ( TruncPfx WSep lemma_exact({ja}) WSep ) CapNounNomNSB | AbbrBase | LC( NoSentBoundary) wordform_exact(AlphaUp AlphaDown AlphaDown+ {inen}) ] WSep
       [ lemma_exact( {oyj} | {oy} ({:öö}) | {ky} | {ab} | {abp} | {osake} (Dash){yhtiö} ) | wordform_exact({Oy}) WSep "A" lemma_exact({ab}) ] ;

!* Tunnista "Xxxx Oy" virkkeen alussa kun seuraava sana	ei ala isolla alkukirjaimella tai yhdysviivalla
Define CorpSuffixedFin2B
       ( [ AbbrBase | NameInitial | CapWord WSep wordform_exact("&") ] WSep )
       [ PropNom | CapName | AbbrBase | CapWordNom ] WSep
       [ [ AlphaUp lemma_exact( {oyj} | {oy} ({:öö}) | {ky} | {ab} | {abp} | {osakeyhtiö} ) NRC( WSep [ AlphaUp | Dash AlphaDown ]) ]
       | [ wordform_exact([ {Oy} | {Ab} | {OY} | {Ky} ] ":" CaseSfx ) ] ] ;

!* "Kymen Atk ja tekstinkäsittely Ky", Kymen Leikkaus- ja anestesiapalvelut Oy"
!* "Suomen nestesokeri Oy"
Define CorpSuffixedFin2C
       [ CapNameGenNSB | PropGeoGen ] ( WSep AlphaUp AlphaDown [ NounNom | TruncPfx ] ) WSep
       [ AlphaDown Word WSep ]^{1,3}
       lemma_exact( {oyj} | {oy} ({:öö}) | {ky} | {osake} (Dash) {yhtiö} ) NRC( WSep [ AlphaUp | Dash AlphaDown ]) ;

!** "Aaltosen Kenkätehdas", "Mäkelän Kone", "Hämeen Rakennuskone", "Kymen Vesi", "Tuottajain Maito"
Define CorpSuffixedFin3
       [ CapNameGenNSB | PropGen ] WSep
       AlphaUp lemma_exact( AlphaDown* {tehdas} | AlphaDown* {kone} | {vesi} | {maito} ) ;

! "Xxxxkauppa Xxx", "Xxxxliike X. X. Xxxx", "Xxxxtoimisto Xxx & Xxx"
Define CorpPrefixedFin1
       ( [ TruncPfx | CapNounNom - Prop ] WSep lemma_exact({ja}) WSep )
       LC( NoSentBoundary )
       wordform_exact( Cap(( AlphaDown AlphaDown+ Dash ) AlphaDown* [ {kahvila} | {leipomo} | {kukkakauppa} |
       		       {osuus}[{kunta}|{kauppa}] | {kauppahuone} | {katsastus} | {välitys} | {asennus} | {isännöinti} |
		       {huolto} | {kuljetus} | {saneeraus} | {siivous} | {rakennus} | {konepaja} | {lääkäriasema} |
		       {korjaamo} | {rakennuskunta} | {kodinkone} | {sairaala} | {kuntoutus} | {leipomo} | {kahvila} |
		       {ravintola} | {autotalo} | {pesula} | {kiinteistö} |
		       AlphaDown (Dash) [ {kauppa} | {palvelu} | {yhtiö} | {tukku} | {liike} | {kone} | {toimisto} | {myynti} ]
		       ]) ) WSep
       ( ( CapMisc WSep ) [ NameInitial WSep ]* | CapMisc WSep | CapWord WSep wordform_exact("&") WSep )
       [ CapName - lemma_exact({oy}) | AbbrInfl
       | [ CapMisc | AlphaUp AlphaDown [ NounNom | PosAdjNom ] | AbbrBase ] WSep lemma_exact( {kommandiittiyhtiö} | {ky} | {oy} ({:öö}) )
       !| ( CapMisc WSep ) lemma_exact({ja}|"&") WSep wordform_exact( {K:ni} | {Kumpp.} | {Kumppan} Field )
       | lemma_exact( {avoin} | {keskinäinen} ) WSep lemma_ends({yhtiö}) ] ;

Define CorpPrefixedFin2A
       ( CapNameGenNSB WSep )
       AlphaUp lemma_exact( {avoin} | {keskinäinen} ) WSep
       ( PropGeoGen WSep )
       lemma_ends( {yhtiö} ) WSep
       ( [ CapNameGen
       	 | (CapMisc WSep) PropFirstNom wordform_exact( {ja} | "&" ) PropFirstNom ] WSep )
       wordform_exact( AlphaUp Alpha Field ) ;

Define CorpPrefixedFin2B
       AlphaUp lemma_exact( {avoin} | {keskinäinen} ) WSep
       PropGeoGen WSep
       lemma_ends( {yhtiö} ) ;

Define CorpPrefixedFin3
       wordform_exact( {Oy} | {OY} ) WSep
       ( PropGeoGen WSep )
       ( CapMisc | AbbrBase ) WSep
       CapWord ;

!** "Veljekset Keskinen", "J & A Antikka", "P&S Ahoketo"
Define CorpPrefixedFin4
       [ wordform_exact({Veljekset} | UppercaseAlpha "&" UppercaseAlpha ) |
	 wordform_exact(AlphaUp) WSep wordform_exact("&") WSep wordform_exact(AlphaUp)
	 ]
       WSep CapWord ;

Define CorpCircumfixed1
       wordform_exact( {Oy} | {OY} ) WSep
       ( Word WSep )
       ( Word WSep )
       [ NounNom | CapNameNomNSB | CapName ] WSep
       lemma_exact( {ab} ) ;

Define CorpCircumfixed2
       wordform_exact( {Osakeyhtiö} ) WSep
       ( CapWord WSep )
       ( CapWord WSep )
       [ NounNom | CapNameNomNSB | CapName ] WSep
       inflect_sg( {Aktiebolag} ({et}) ) ;

Define CorpInfixed1
       CapName WSep
       wordform_exact( {Ab} | "&" ) WSep
       CapName ;

Define CorpSuffixedMisc1
       [ [ CapNameNomNSB | CapMisc | AlphaUp [ Field CapName | AbbrNom | AbbrBase | PunctWord | wordform_ends(0To9) ] ] WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) )
       [ [ CapNameNomNSB | CapMisc | AlphaUp [ Field CapName | AbbrNom | AbbrBase | PunctWord | wordform_ends(0To9) ] ] WSep ]*
       [ [ CapName | CapMisc | AlphaUp [ Field CapWord | Prop | AbbrNom | PunctWord | wordform_ends(0To9) ] ] - PropGeoGen ] WSep
       ( AndOfThe WSep )
       Ins(gazCorpSuffixWord)
       ( ( WSep AndOfThe ) WSep Ins(gazCorpSuffixWord) ) 
       NRC( WSep ( Word WSep ) Dash AlphaDown ) ;

Define CorpSuffixedMisc2
       [ [ CapNounNomNSB | CapNameNomNSB | AlphaUp [ PropNom | Field CapName | PunctWord | AlphaUp AbbrNom ] ] WSep ]^{0,2}
       ( CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) )
       [ [ CapNounNomNSB | CapNameNomNSB | AlphaUp [ PropNom | Field CapName | PunctWord | AlphaUp AbbrNom ] ] WSep ]^{0,2}
       ( CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) )
       [ CapNameNSB | CapMisc | AlphaUp [ Field CapWord | Prop | AbbrNom | PunctWord ] ] WSep
       ( Ins(CorpSuffixAbbrNom) WSep )
       Ins(CorpSuffixAbbr) ;

!* "X. Xxxx & Xxxx" "Xxx Xxxx [ & | ja] Kumpp./Kumppanit/K:ni"

Define CorpAffixed
	[ Ins(CorpSuffixedFin1A)  | Ins(CorpSuffixedFin1B) | Ins(CorpSuffixedFin3)  |
	  Ins(CorpSuffixedFin2A)  | Ins(CorpSuffixedFin2B) | Ins(CorpSuffixedFin2C) |
	  Ins(CorpPrefixedFin1)   | Ins(CorpPrefixedFin2A) | Ins(CorpPrefixedFin2B) |
	  Ins(CorpPrefixedFin3)   | Ins(CorpPrefixedFin4)  | 
	  Ins(CorpCircumfixed1)   | Ins(CorpCircumfixed2)  |
	  Ins(CorpInfixed1) |
	  Ins(CorpSuffixedMisc1)  | Ins(CorpSuffixedMisc2) ] ;

!-----------------------------------------------------------------------

!* "Asunto Oy Vuohikkalan Harhapolku 5", "Kiinteistöosakeyhtiö Blaa"
!* "As. Oy Jyväskylän maalaiskunnan Norolankuja 1", "As. Oy Neljäs linja 3"
Define CorpCondominium1
       [ "A" | "K" ] [ lemma_exact( {asunto} | {as.} | {kiinteistö} ) WSep lemma_exact_morph( {oy} | {osakeyhtiö}, {CASE=NOM})
       	       	     | lemma_exact( [{asunto-}|{kiinteistö}] [{osakeyhtiö}|{oy}|{oy.}] )
		     | lemma_exact( {kiinteistöyhtiö} )
		     | lemma_exact( [{as}|"k"] (".") {oy} )
		     ] WSep
       ( AlphaUp PosAdj WSep ) ( AlphaUp CaseGen WSep )
       [ CapWord |
       	 [ [ [ CapNameNom | CapWordNom ] ( WSep Alpha Word ) | CapName ] WSep 
       	   lemma_exact( 0To9 (0To9) ( Dash 0To9 (0To9) ) ( "." ) ) ] ]
       ( WSep wordform_exact( {Bostads} ) WSep lemma_exact({ab}) ) ;

Define CorpCondominium2
       wordform_exact( {Bostads} ) WSep lemma_exact( {ab} ) WSep
       ( CapMisc WSep )
       CapName
       ( WSep lemma_exact( 0To9 (0To9) ( Dash 0To9 (0To9) ) ( "." ) ) )
       ( WSep ( wordform_exact({Asunto}) WSep ) lemma_exact({oy}) ) ;

Define CorpCondominium
       [ CorpCondominium1 | CorpCondominium2 ] ;

!-----------------------------------------------------------------------

Define OrgTypeStr [ {konserni} | {yritys} | {startup}(("p")"i") | {ketju} | {operaattori} | AlphaDown {valmistaja} | {yhtiö} | {osuuskunta} |
                    {osuuskauppa} | {yhtymä} | {firma} | {pelitalo} | {varustamo} ] ;

Define OrgType lemma_morph( Ins(OrgTypeStr), {NUM=SG} ) ;

!-----------------------------------------------------------------------

Define CorpHyphen1A
       LC( NoSentBoundary )
       [ [ AlphaUp Field ] - [ {EU} | {LVI} | {IT} ] ] Dash ( lemma_ends( Dash {niminen} ) WSep ( PosAdj WSep ) ) AlphaDown Ins(OrgType) ;

Define CorpHyphen1B
       [ [ AlphaUp Field Dash AlphaDown Field ] - [ ADashA ] ] FSep Field Ins(OrgTypeStr) FSep Word ;

Define CorpHyphen1C
       AlphaUp Field Dash AlphaUp lemma_ends( Dash [ {yhtymä} | {yhtiö} ]) ;

! Xxx Xxx -sijoitusyhtiö
Define CorpHyphen2A
       [ ( PropOrgNom WSep )
       ( CapWord WSep AndOfThe WSep ( CapWord WSep ))
       ( CapWord WSep AndOfThe WSep ( CapWord WSep ))
       ( CapWord WSep ) CapWord | InQuotes ] WSep
       DashExt [ Ins(OrgSuffixNoAbbr) | Ins(OrgType) ] ;

Define CorpHyphen2B
       ( [ CapMisc | AbbrNom | AlphaUp PunctWord ] WSep )
       CapWord WSep
       ( [ AlphaDown | AlphaUp | 0To9 ] Word WSep )
       DashExt Ins(OrgType) ;

Define CorpHyphen
       [ Ins(CorpHyphen1A) | Ins(CorpHyphen1B) | Ins(CorpHyphen1C) | Ins(CorpHyphen2A) | Ins(CorpHyphen2B) ] ;

!-----------------------------------------------------------------------

Define CorpSuffixedAndCo
       [ [ CapMisc | NameInitial ] WSep ]*
       CapWord WSep
       wordform_exact( [ "&" | {and} ] ) WSep
       inflect_sg( {Co}(".") | {Sons} | {Company} | {Partners} ) ;

Define CorpSuffixedInc
       [ CapMisc WSep ]*
       ( CapWord WSep AndOfThe ( WSep CapWord ) WSep )
       [ CapMisc WSep ]*
       CapWord WSep
       ( wordform_exact( Comma ) WSep )
       inflect_sg( {Inc} ( "." | {orporated} ) ) ;

! "DPD Finland", "Erich Krause Finland", "Brenntag Nordic", "Pool Media International" 
Define CorpSuffixedMisc
       [[ CapMisc | AlphaUp [ AbbrNom | PunctWord ]] WSep ]+
       inflect_sg( {Finland} | {Sweden} | {Europe} | {France} | {International} | {Worldwide} | {Global} | {Nordic} | {Scandinavia} |
       		   {China} )
       ( WSep OrgSuffixAbbr ) ;

!** "TKD Suomi", "Yara Suomi" (muttei: Sara Suomessa)
Define CorpSuffixedSuomi1
       PropOrgNom WSep
       "S" lemma_exact_morph( {suomi}, {NUM=SG} Field {CASE=}[{NOM}|{PAR}|{PAR}|{ALL}|{ADE}|{ABL}|{TRA}] ) ;

Define CorpSuffixedSuomi2
       AbbrBase WSep
       "S" lemma_exact_morph( {suomi}, {NUM=SG}) ;

Define CorpPrefixedMisc
       wordform_exact( {Café} | {Hotel} | {Caffe} | {Brasserie} | {Buregdžinica} | {Ćevabdžinica} | {Cafe} | {Bar} |
       		       {Bistro} | {Pub} | {Pizzeria} | {Restaurant} | {Ristorante} ) WSep
       ( OptCap(DeLa) WSep )
       ( CapMisc WSep )
       CapName ;

Define CorpAffixedMisc
     [ Ins(CorpSuffixedMisc) | Ins(CorpSuffixedSuomi1) | Ins(CorpSuffixedSuomi2) |
       Ins(CorpPrefixedMisc) | Ins(CorpSuffixedAndCo) | Ins(CorpSuffixedInc) ] ;

!-----------------------------------------------------------------------

! "[ohjelmistojätti] Foofoo"
Define CorpPfxAttribute
       LC( wordform_ends( [ {yhtiö}
	   		  | {yritys}
			  | AlphaDown {konserni}
	   		  | AlphaDown {jätti}
	   		  | {yksikkö}
			  | AlphaDown {toimisto}
	   		  | {valmistaja}
	   		  | AlphaDown {firma}
	   		  | AlphaDown {talo}
			  | AlphaDown {kehittäjä}
			  | {yhdistys}
	   		  | {järjestö}
	   		  ] ) WSep )
       [ CapMisc WSep ]*
       CapWord ;

!  "Xxxx:n [markkinaosuus]"
Define CorpWithEconomy
       [ CapMisc WSep ]*
       [ [ AlphaUp morphtag({[POS=NOUN]}Field{[NUM=SG][CASE=GEN]}) ] - [ lemma_ends( {vuosi} | {firma} | {yksikkö} | {hetkinen} | {euro} | {dollari} | {neljännes} | {kuu} | {jakso} | {laite} | {yhtiö} | {yritys} | {miljardi} | {miljoona} ) ] ]
       RC( WSep lemma_ends( {osake} | {kurssi} | {liikevaihto} | {liiketappio} | {markkinaosuus} ) );

! "Xxxxxx:n [toimitusjohtaja/tytäryhtiö]"
! NB! "konttori" usually follows a LocPpl, not an OrgCrp
Define CorpWithEmployment
       ( [ CapMisc::0.25 | AbbrBase ] WSep )
       [ CapNameGenNSB | AbbrBase ]
       RC( WSep lemma_ends(
		AlphaDown {johtaja} | {vetäjä} | {puuhamies} |
		{työntekijä} | {jäsen} | {jäsenmäärä} | {virkamies}
		{toimihenkilö} | {henkilökunta} | {henkilöstö} |
		{toimi}[{paikka}|{piste}] | {pääkonttori} | {asiakaspalvelu} |
		{tavaratalo} | {myymälä} | {asiakaspalvelija} | {telakka} | {tehdas} | 
		{tytäryhtiö} | {emoyhtiö} | [{huvi}|{teema}]{puisto} ) ) ;

Define CorpWithXxx
       [ Ins(CorpWithEconomy)
       | Ins(CorpWithEmployment)
       ] ;

! Dillidillin [ lanseeraa / julkisti / on irtisanonut / ... ]
Define OrgColloc1
       [ [ [ CapNounNomNSB::0.50 | CapForeign::0.50 | AbbrBase | PropOrg ] - PropFirst ] WSep ]*
       [ [ CapNounNomNSB::0.50 | CapForeign::0.50 | PropOrg ] - [ PropLast | PropFirst | PropGeo ] ]
       RC( [ WSep AuxVerb ]^{0,4} WSep
	     lemma_morph(
		[ {julkistaa}
		| {markkinoida}
		| {lanseerata}
		| {tuottaa}
		| {valmistaa}
	     	| {työllistää}
		| {palkata}
		| {irtisanoa}
		], {VOICE=ACT})) ;

Define CorpColloc
       [ Ins(CorpPfxAttribute) | Ins(CorpWithXxx) | Ins(OrgColloc1) ] ;

!-----------------------------------------------------------------------

Define CorpListMWord
       [ m4_include(`gOrgCorpAll.m4') ] ;

!* Category HEAD
Define CorpOrg
       [ Ins(CorpGuessedA)::0.50 | Ins(CorpGuessedB)::0.75
       | Ins(CorpAffixed)::0.30
       | Ins(CorpAffixedMisc)::0.30
       | Ins(CorpCondominium)::0.25
       | Ins(CorpHyphen)::0.25
       | Ins(CorpColloc)::0.25
       | Ins(CorpListMWord)::0.15
       ] EndTag(EnamexOrgCrp) ;

!!----------------------------------------------------------------------
!! <EnamexOrgPlt>: Party abbreviation following a last name: a lowercase
!! word preceded by a last name and a left parenthesis and followed by
!! right parenthesis
!!----------------------------------------------------------------------

! SDP, Kok., RKP
Define PolitPartyAbbr1
       LC( wordform_exact(LPar) WSep )
       PartyMemberAbbr
       RC( WSep wordform_exact(RPar) ) ;

Define PolitPartyAbbr2
       AlphaUp lemma_exact([ {sdp} | {skp} | {rkp} | {skdl} | {smp} | {nkp} | {lkp} | {ml} ]) ;

! "Kokoomus", "Vasemmistoliitto", "Perussuomalaiset"
Define PolitParty1A
       ["K"|"P"] lemma_exact( {kokoomus}({puolue}) | {vasemmisto}({liitto}) ) ;

! "Keskusta", "Kipu"
Define PolitParty1B
       LC( NoSentBoundary )
       [ ["K"|"P"] lemma_exact( {keskusta} | {kipu} | {perussuomalainen} ) | wordform_exact({Keskusta}) ] ;

! "Keskustan [äänestäjät]" (muttei: "Keskustan [kävelykadut]")
Define PolitParty1C
       wordform_exact( {Keskustan} ({kin}|{kaan}) )
       RC( WSep lemma_ends( [ {eduskunta} | {puolue} | {valtuutettu} | {valtuusto} | {edustaja} |
	                     {äänestäjä} | {kannattaja} | {rivi} ] Field ) ) ;

! "Viskipuolue", "Piraattipuolue", "Oliivipuukoalitio"
Define PolitParty1D
       AlphaUp [ lemma_morph( AlphaDown [ (Dash) {puolue} | {koalitio} ], {NUM=SG} )
       - lemma_ends( [{hallitus}|{oppositio}|{valta}|{sisar}|{veljes}|{populisti}]{puolue} ) ];

!Define PolitParty1E
!       AlphaUp lemma_ends( [{viski}|{piraatti}|{itsenäisyys}] {puolue} ) ;

! "Suomalaisten talonpoikain puolue", "Kansallisen yhteynäisyyden puolue"
Define PolitParty2A
       AlphaUp ( PropGeoGen EndTag(EnamexLocPpl2) WSep )
       ( lemma_exact_morph( {suomalainen} | {kansallinen} , {CASE=GEN} ) WSep )
       lemma_morph( [ {talonpoika} | {viljelijä} | {yhtenäisyys} | {maaseutu}
       		    | {työ} | {vastuu} | {kansa} | {laki} ],
		    {CASE=GEN} ) WSep
       lemma_exact( AlphaDown* {puolue} ) ;

Define PolitParty2C
       LC( NoSentBoundary )
       AlphaUp PosAdj WSep
       lemma_exact( AlphaDown* {puolue} ) ;

! "Vihreä liitto", "
Define PolitParty2B
       AlphaUp ( lemma_exact_morph( DownCase(CountryName), {CASE=GEN}) EndTag(EnamexLocPpl2) WSep )
       lemma_exact( {vihreä} | {kirjava} ) WSep
       lemma_exact( {puolue} | {liitto} | {koalitio} ) ;

! "ruotsidemokraatit", "demarit", "?Ruotsin vihreät" (muttei: "Ruotsin vihreät niityt")
Define PolitParty3A
       AlphaUp lemma_exact_morph( AlphaDown+ {demokraatti} | {republikaani} | {perus} (?) {suomalainen} | {demari} ("t") | {moderaatti}, {NUM=PL} ) ;

! "ruotsidemokraatit", "demarit", "?Ruotsin vihreät" (muttei: "Ruotsin vihreät niityt")
Define PolitParty3B
       [ AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep | [ LC(NoSentBoundary) AlphaUp ] ]
       lemma_exact_morph( [ {demari} | {moderaatti} | {vihreä} | AlphaDown+ {demokraatti} ], {NUM=PL} )
       NRC( WSep morphtag({NUM=PL} Field {CASE=}) ) ;

! "Suomen työväenpuolue" (muttei: "Suomen puolue")
Define PolitParty4
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph([[ Field AlphaDown [ {puolue} | {liittouma} | {koalitio} ]] - [[{hallitus}|{oppositio}]{puolue}]], {NUM=SG})  ;

! "Ruotsin feministinen puolue", "Suomen ruotsalainen kansanpuolue" !! NB: PosAdj should congruate
Define PolitParty5A
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       PosAdj WSep
       lemma_exact_morph( ( Field AlphaDown ) [ {puolue} | {liittouma} | {koalitio} ], {NUM=SG}) ;

! "Liberaalinen Kansanpuolue"
Define PolitParty5B
       LC( NoSentBoundary )
       AlphaUp PosAdj WSep
       lemma_exact_morph( ( Field AlphaDown ) [ {puolue} | {liittouma} | {koalitio} ], {NUM=SG}) ;

Define PolitYouth
       AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep
       [ morphtag({NUM=PL} Field {CASE=GEN}) | lemma_morph( AlphaDown {puolue}, {[NUM=SG][CASE=GEN]} ) ] WSep
       lemma_exact({nuorisojärjestö}) ;

Define PolitHyphen1
       AlphaUp AlphaDown Field Dash AlphaDown lemma_morph( Dash AlphaDown* {puolue}, {NUM=SG}) ;

Define PolitHyphen2
       ( CapMisc WSep )
       CapName WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt lemma_ends( {puolue}, {NUM=SG} ) ;

Define PolitSuffixedP
       inflect_sg( AlphaUp Field [ {partiet} | {demokrater}({na}|{ne}) ] ) ;

Define PolitSfx inflect_sg( {Partei} | {Front} ) ;

Define PolitSuffixedWA
       CapMisc WSep
       Ins(PolitSfx) ;

Define PolitSuffixedWB
       CapName WSep
       Ins(PolitSfx)
       NRC( WSep AlphaUp ) ;

Define PolitPrefixed
       wordform_exact( {Alleanza} | {Alianza} | {Partia} | {Partido} | {Stranka} | {Democratici} | {Frente} ) WSep
       ( DeLa WSep )
       CapName ;

Define PolitWithAttribute
       LC( lemma_morph( {oikeistolainen} | {vasemmistolainen} | {konservatiivinen} | {maahanmuuttovastainen} | {nationalistinen} |
       	   		[{kansallis}| AlphaDown Dash ]{mielinen} , {NUM=SG}) WSep )
       CapWord ;

Define PolitGenWithX
       [ CapNounGenNSB | CapNameGenNSB | AlphaUp PropGen | "K" lemma_exact_morph({keskusta}, {CASE=GEN}) ]
       RC( WSep lemma_ends( {kannattajakunta} | {äänestäjä} | {puheenjohtaja} | {äänenkannattaja} |
       	   		    {puoluesihteeri} | {kansanedustaja} | {äänimäärä} | {nuorisojärjestö} |
			    {jäsenmäärä} | {vaalimenestys} | {puoluejohto} | {presidenttiehdokas} |
			    {kannatus} | {valtuutettu} | {vaalimainos} | {puoluekirja} | {vaalityö} |
			    {eduskuntaryhmä} | {puolueohjelma} ) ) ;

Define PolitGaz
       [ inflect_sg( {Jobbik} | {Fidesz} | {Syriza} | {Labour} | {UKIP} | {Podemos} | {HDZ} | {Dveri} | {Fatah} | {Hamas} | {Likud} ) ] |
       [ lemma_exact_sg( {maalaisliitto} | {keskustaliitto} | {vasemmistoliitto} ) ] |
       [ lemma_exact_sg({kansallinen}) WSep lemma_exact_sg({kokoomus}) ] |
       [ ( wordform_exact({Suomen}) WSep ) lemma_exact_sg({ruotsalainen}) WSep lemma_exact_sg({kansanpuolue}) ] ;

! "Ranskan parlamentti"
Define PolitLegislature1
       [ CapNameGenNSB | PropGeoGen | USpl ] EndTag(EnamexLocPpl2) WSep
       lemma_exact( {eduskunta} | {parlamentti} | {senaatti} | {kongressi} | {riigikogu} | {duuma} |
       		    [{folk}{stor}]{ting}({et}) | {liittokokous} | {liittoneuvosto} | {kansalliskokous} ) ;

Define PolitLegislature2
       [ CapNounGen | PropGeoGen | USpl ] WSep
       ( NounGen WSep )
       lemma_exact( {edustajainhuone} ) ;

Define PolitLegislature3
       lemma_morph( {ruotsi} | {saksa}, {NUM=SG} Field {CASE=GEN} ) WSep
       lemma_morph( {liittopäivä} | {valtiopäivä}, {NUM=PL} ) ;

! "Yhdysvaltain hallitus"
Define PolitGovernment
       [ USpl | AlphaUp lemma_exact_morph( DownCase(CountryName), {CASE=GEN}) ] EndTag(EnamexLocPpl2) WSep
       lemma_exact( {hallitus} ) ;

! Category HEAD
Define PolitOrg
       [ Ins(PolitParty1A)::0.50
       | Ins(PolitParty1B)::0.50
       | Ins(PolitParty1C)::0.50
       | Ins(PolitParty1D)::0.50
       | Ins(PolitParty2A)::0.50
       | Ins(PolitParty2B)::0.50
       | Ins(PolitParty2C)::0.50
       | Ins(PolitParty3A)::0.50
       | Ins(PolitParty3B)::0.50
       | Ins(PolitParty4)::0.50
       | Ins(PolitParty5A)::0.50 | Ins(PolitParty5B)::0.50
       | Ins(PolitYouth)
       | Ins(PolitPartyAbbr1)
       | Ins(PolitPartyAbbr2)
       | Ins(PolitWithAttribute)::0.75
       | Ins(PolitGenWithX)::0.75
       | Ins(PolitHyphen1)::0.25 | Ins(PolitHyphen2)::0.25
       | Ins(PolitSuffixedP)::0.25
       | Ins(PolitSuffixedWA)::0.50 | Ins(PolitSuffixedWB)::0.25
       | Ins(PolitPrefixed)::0.25
       | Ins(PolitGaz)::0.10
       | Ins(PolitLegislature1)
       | Ins(PolitLegislature2)
       | Ins(PolitLegislature3)
       | Ins(PolitGovernment)
       ] EndTag(EnamexOrgPlt) ;

!!----------------------------------------------------------------------
!! <EnamexOrgXxx>: Misc. organizations
!! 1) Names coded as ORG in the morphology
!!    (optionally preceded by a place name in genitive)
!!----------------------------------------------------------------------

!** "Suomen kirkkohistoriallinen seura", "Suomen perhostutkijain seura"
!** "Turun konservatorion kannatusyhdistys"
!** EI: "Kalevan kisojen paras seura"
Define OrgSociety1
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       [ [ lemma_morph( AlphaDown AlphaDown AlphaDown AlphaDown AlphaDown {inen}, {POS=ADJ}) - lemma_morph({CMP=}) ] |
       	 NounGen ] WSep
       lemma_morph( {seura} | {kannatusyhdistys}, {NUM=SG} ) ;

!** "Suomen Saunaseura", "Turun Ratagolfseura", "Suomi-Nigeria Ystävyysseura"
Define OrgSociety2
       [ CapWordGen EndTag(EnamexLocPpl2) | CapWordNom ] WSep
       ( TruncPfx WSep lemma_exact({ja}) WSep )
       lemma_morph( AlphaDown {seura}, {NUM=SG} ) ;

!** "Aleksis Kiven Seura", "Lauri Viita -seura", "Suomi-Unkari Seura" [!] (but not "Väinö Linnan seura")
Define OrgSociety3
       [ CapWordGen EndTag(EnamexLocPpl2) | CapWordNom ] WSep
       (CapWordNomGen WSep)
       [ Dash | UppercaseAlpha ] lemma_morph( {seura}, {NUM=SG} ) ;

Define OrgSociety4
       AlphaUp AlphaDown lemma_morph( Dash {seura}, {NUM=SG} ) ;
       
Define OrgSociety5
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_morph( AlphaDown [ {seura} | {yhdistys} ], {NUM=SG} ) ;

!** "Suomen Veturimiesyhdistys",
Define OrgSociety6
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_morph( AlphaDown {yhdistys}, {NUM=SG}) ;

Define OrgSocietyPrefixed
       wordform_exact( {Société} | {Society} | {Societas} | {Associazione} | {Assemblée} | {Ordre} ("s") ) WSep
       ( CapMisc WSep )
       [ ( CapWord WSep ) [ AndOfThe WSep ]+ ]*
       [ CapMisc WSep ]*
       CapName ;

!* "Xxx xxx xxx ry"
Define OrgSocietySuffixed1
       ( [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 ] WSep )
       [ CapName::0.05 | CapNounNom::0.05 | PropGeoGen EndTag(EnamexLocPpl2) ] WSep
       [ LowerWord WSep ]^{0,4}
       Ins(NpoSuffixAbbr) ;

!* "Xxx Xxx Xxx ry"
Define OrgSocietySuffixed2
       [ CapMisc WSep ]*
       [ CapNounNomNSB | CapNameNomNSB | AlphaUp [ AbbrNom | PunctWord ] ] WSep
       Ins(NpoSuffixAbbr) ;

Define OrgSociety
       [ Ins(OrgSociety1) | Ins(OrgSociety2) | Ins(OrgSociety3) | Ins(OrgSociety4) | Ins(OrgSociety5) |
       	 Ins(OrgSocietyPrefixed) | Ins(OrgSocietySuffixed1) | Ins(OrgSocietySuffixed2) ]::0.25 ;

!-----------------------------------------------------------------------

!** Länsi-Suomen metsänomistajain liitto
Define OrgUnion
       AlphaUp ( [ PropGeoGen EndTag(EnamexLocPpl2) |
       [ NounGen EndTag(EnamexLocPpl2) WSep lemma_morph( {seutu} | {alue} , {CASE=GEN} ) ] ] WSep )
       ( NounGenPl | wordform_ends( AlphaDown [ {ajain} | {äjäin} | {ijain} | {ijäin} ] ) WSep )
       NounGen WSep
       lemma_exact( {liitto} ) WSep
       Ins(NpoSuffixAbbr) ;


!** Kuopion Yrittäjät       

!-----------------------------------------------------------------------

!** "Päivän Nuoret", "Suomen Kristillisen Liiton Nuoret", "Suomen Keskustanuoret"
Define OrgYouth1
       [ PropGeoGen EndTag(EnamexLocPpl2) WSep [ CapWordGen::0.05 WSep ]* AlphaUp
       | [ LC(NoSentBoundary) AlphaUp ] ]
       lemma_morph( AlphaDown+ AlphaDown+ (Dash) {nuori}, {NUM=PL}) ;

!** "Keskustanuoret"
Define OrgYouth2
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_morph( {nuori}, {NUM=PL}) ;

Define OrgYouth
       [ Ins(OrgYouth1) | Ins(OrgYouth2) ] ;

!-----------------------------------------------------------------------

! "Itä-Suomen hovioikeus", "Helsingin raastuvanoikeus"
Define OrgJurid1
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       ( lemma_morph({piiri}, {CASE=GEN}) WSep )
       lemma_morph( [[{hovi}|{käräjä}|{maa}|{raastuvan}|{hallinto-}|{kihlakunnan}|{vesi}|{ali}|{sota}]{oikeus}] , {NUM=SG}) ;

!* Euroopan ihmisoikeustuomioistuin
Define OrgJurid2
       [ PropGeoGen | CapNounGenNSB ] EndTag(EnamexLocPpl2) WSep
       [ lemma_ends( {tuomioistuin} ) | ["H"|"M"|"K"|"R"] "O" lemma_exact( [ {ho} | {mo} | {ko} | {ro} ] (".") ) ] ;
       
! "Ranskan korkein oikeus"
Define OrgJurid3
       [ CapNounGen | USpl ] EndTag(EnamexLocPpl2) WSep
       "k" lemma_exact({korkea}|{korkein}|{korkee}) WSep lemma_exact(({hallinto-}){oikeus}) ;

Define OrgJurid4
       wordform_exact( {Korkei}["n"|"m"] Field ) WSep 
       lemma_ends({oikeus}) ;

Define OrgJurid5
       LC( NoSentBoundary )       
       AlphaUp lemma_morph( Dash {oikeus}, {NUM=SG}) ;

Define OrgJurid
       [ Ins(OrgJurid1) | Ins(OrgJurid2) | Ins(OrgJurid3) | Ins(OrgJurid4) | Ins(OrgJurid5) ] ;

!-----------------------------------------------------------------------

! "Vuohikkalan kunnanvaltuusto/kaupunginhallutus/kyläkäräjät"
Define OrgCityCouncil
       ( CapMisc WSep )
       [ PropGeoGen | CapNounGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_ends( AlphaDown [ {nhallitus} | {valtuusto} | {käräjä}("t") ] ) ;

!-----------------------------------------------------------------------

!* Xxx:n kunnalle/kunnalta/kunnalla -> ORG
Define OrgMunicipalityA
       ( CapMisc WSep )
       [ AlphaUp PropGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph([ ({maalais}){kunta} | {kaupunki} ], {NUM=SG} Field {CASE=}[{ALL}|{ADE}|{ABL}]) ;

! "Xxx:n kaupungin"
! NB: pitäisi ehkä pikemminkin muotoilla säännöt, joissa on LC/RC NRC:n sijaan
Define OrgMunicipalityB
       ( CapMisc WSep )
       [ AlphaUp PropGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph([ ({maalais}){kunta} | {kaupunki} ], {NUM=SG} Field {CASE=GEN})
       NRC( WSep ( [ CapNameGen | PosNumOrd | PosAdj | wordform_exact( NumRoman ) ] WSep ) [ lemma_ends( {asukas}({luku}|{määrä}) | {väki}({luku}) | {ulkopuol} Field | {väestö} | {katu} | {keskusta} | {lähiö} | {taajama} | {alue} | {esikaupunki} | {kylä} | {kaupunginosa} | AlphaDown {puoli} | {pommitus} | {verilöyly} ) | wordform_exact(".") ] )  ;

! "Helsingin/Espoon/Rovaniemen kaupunki" -> kyseessä käytännössä aina ORG
Define OrgMunicipalityC
       wordform_exact( {Helsingin} | {Turun} | {Espoon} | {Tampereen} | {Kuopion} | {Oulun} | {Rovaniemen} |
       		       {Jyväskylän} | {Lahden} | {Kajaanin} | {Savonlinnan} | {Mikkelin} | {Joensuu}
		       ) EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( ({maalais}){kunta} | {kaupunki}, {NUM=SG} Field {CASE=}[{NOM}|{PAR}|{ALL}|{ADE}|{ABL}] ) ;

Define OrgMunicipalityD
       [ AlphaUp PropGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( ({maalais}){kunta} , {NUM=SG} Field {CASE=}[{NOM}|{PAR}|{ALL}|{ADE}|{ABL}]) ;

Define OrgMunicipality
       [ Ins(OrgMunicipalityA) | Ins(OrgMunicipalityB) | Ins(OrgMunicipalityC) | Ins(OrgMunicipalityD) ] ;

!-----------------------------------------------------------------------

! "Federal Bureau of Investigation", "National Highway Traffic Safety Administration"
Define OrgAgencySuffixed
       ( wordform_exact( {US} | {American} | {British} | {Finnish} | {National} | {Federal} | {International} | {Global} ) WSep
       ( CapWord WSep ) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ( CapWord WSep ) )
       ( CapNounNom WSep ) CapWord WSep
       inflect_sg( {Administration} |
       		   {Agency} |
		   {Club} |
		   {Association} |
		   {Authority} |
		   {Register} |
		   {Board} |
		   {Bureau} |
		   {Front} |
		   {Commission} |
		   {Committee} |
		   {Assembly} |
		   {Institute} |
		   {Council} |
		   {Department} |
		   {Foundation} |
		   {Union} )
       [ [ WSep AndOfThe ]+ [ WSep CapMisc ]* WSep CapWord ]* ;

! Department of Homeland Security
Define OrgAgencyPrefixed
       wordform_exact( {Department} | {Society} )
       [ [ WSep AndOfThe ]+ [ WSep CapMisc ]* WSep CapWord ]+ ;

! "Suomen olympiakomitea", "Yhdysvaltain turvallisuusvirasto NSA", Helsingin syyttäjänvirasto"
Define OrgAgencyFin
       ( CapMisc WSep )
       [ PropGeoGen | CapNounGenNSB | wordform_exact( {Yhdysvalt}[{ain}|{ojen}] | {USA:n} ) ] EndTag(EnamexLocPpl2) WSep
       ( lemma_exact( {kansallinen} | {kuninkaallinen} | {keisarillinen} ) WSep )
       ( wordform_ends(Dash) WSep wordform_exact({ja}) WSep )
       lemma_morph( AlphaDown [ {komitea} | {komissio} | {instituutti} | {virasto} | {viranomainen} | {ministeriö} |
       		    	      	{neuvosto} | {iedustelupalvelu} | {urvallisuuspalvelu} ], {NUM=SG}) ;

Define OrgAgencyGaz
       lemma_exact(DownCase(@txt"gOrgGovernm.txt")) ;

Define OrgAgency
       [ Ins(OrgAgencySuffixed) | Ins(OrgAgencyPrefixed) | Ins(OrgAgencyFin) | Ins(OrgAgencyGaz) ] ;    


!-----------------------------------------------------------------------

!* Suomen Leijonan Ritarikunta, Kultaisen taljan ritarikunta, Pyhän Yrjön ritaristo
Define OrgMiscOrderOf
       AlphaUp ( PropGeoGen WSep )
       ( LC( NoSentBoundary ) PosAdjGen WSep )
       [ LC( NoSentBoundary ) NounGen ] WSep
       lemma_exact_morph( {ritarikunta} | {ritaristo} ) ;

!* Kalpaveljet, Ruusuritarit, 

!-----------------------------------------------------------------------

Define OrgMiscTypeStr
       [ {virasto} | {ryhmä} | {yksikkö} | {liiga} | {verkkosivusto} | {organisaatio} | {uutiskanava} | {yritys} |
       	 {start} (Dash) {up} (("p")"i") | {ketju} | {mafia} | {operaattori} | AlphaDown {valmistaja} | {osuus}[{kunta}|{kauppa}] | {yhtymä} |
	 {järjestö} | {liike} | {pelitalo} | {ryhmä} | {aivoriihi} | {liiga} | {kopla} | {divisioona} | {tiimi} | {säätiö} | {yhteisö} |
	 {yksikkö} | {operaattori} | {jengi} | {ajatuspaja} | {järjestö} | {organisaatio} | {laboratorio} ] ;

Define OrgMiscSemtag1
       [ LC( NoSentBoundary ) PropOrg ] ;

Define OrgMiscSemtag2
       LC( WSep [ ? - AlphaUp ] Word WSep )
       PropOrg
       RC( WSep [ ? - [ AlphaUp | Dash ] ]) ;

Define OrgMiscSemtag3
       Field " " Field PropOrg ;

!* "The Pretenders"
Define OrgMiscGuessed1
       wordform_exact({The}) WSep ( CapMisc WSep ) UppercaseAlpha wordform_ends({ers}) ;

!* "XXXX XXXX -hakkeriryhmä"
Define OrgMiscHyphen1
       ( wordform_exact({The}) WSep ( CapWord WSep ) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ )
       ( CapWord WSep ) CapWord WSep
       DashExt lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

!* "Syrian Electronic Army", "Lizard Squad"
Define OrgMiscGuessed2
       ( wordform_exact({The}) WSep ( CapWord WSep) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ )
       CapWord WSep
       inflect_sg( {Army} | {Squad} | {Team} | {Community} )
       ( WSep wordform_exact({of}) WSep CapWord ) ;

Define OrgMiscHyphen2
       [ CapMisc WSep ]*
       ( CapWord WSep ) CapWord WSep
       Dash lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

Define OrgMiscHyphen3
       LC( NoSentBoundary )
       Field AlphaUp [ ? - Dash ] Field Dash lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

Define OrgMiscHyphen4
       [ [ AlphaUp Field ] - ADashA ] FSep Field Dash AlphaDown* Ins(OrgMiscTypeStr) FSep Field {NUM=SG} Word ;

Define OrgMiscHyphen5
       AlphaUp Field Dash lemma_ends( Dash {niminen} ) WSep
       AlphaDown lemma_ends( Ins(OrgMiscTypeStr) ) ;

Define OrgMiscSuffixed1
       ( CapMisc WSep ) ( CapMisc WSep )
       inflect_sg( AlphaUp Field @txt"gOrgMiscSuff.txt" ) ;

Define OrgMiscSuffixed2
       ( CapMisc WSep ) CapMisc WSep
       inflect_sg( OptCap( AlphaDown* @txt"gOrgMiscSuff.txt" ) )
       ( WSep AndOfThe WSep CapWord ) ;


Define BoardType
       lemma_exact_morph([ Field AlphaDown [ {ministeriö} | {virasto} | {lautakunta} | {hallinto} ]] -
       			   [ {hirmuhallinto} | {itsehallinto} | {paikallishallinto} ], {NUM=SG}) ; 

Define OrgMiscBoardA
       [ PropGeoGen | USpl ] EndTag(EnamexLocPpl2) WSep
       ( TruncPfx WSep
       lemma_exact({ja}) WSep )
       Ins(BoardType) ;

Define OrgMiscBoardB
       AlphaUp TruncPfx WSep
       lemma_exact({ja}) WSep
       Ins(BoardType) ;

Define OrgMiscBoardC
       AlphaUp ( PropGen EndTag(EnamexLocPpl2) WSep )
       Ins(BoardType) ;

Define OrgMiscSpace
       [ PropGeoGen | USpl ] EndTag(EnamexLocPpl2) WSep
       lemma_exact( {avaruusjärjestö} | {avaruushallinto} )
       ( WSep UppercaseAlpha ) ;

Define OrgMiscState
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph({valtio}, {NUM=SG}) ;

Define OrgMiscHospital
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       ( lemma_ends({llinen}) WSep )
       lemma_ends( AlphaDown [ {sairaala} | {klinikka} ] ) ;

Define OrgMiscCommon
       LC( NoSentBoundary)
       AlphaUp lemma_exact(
       	       {tulli} |
	       {suojelupoliisi} |
	       AlphaDown+ [ {virasto} | {ministeriö} | {virasto} | {hallinto} | {hallitus} | {lautakunta} | {konttori} ]
	       ) ;

!* ???
Define OrgMiscNavy1
       [ PropGeoGen EndTag(EnamexLocPpl2) ( WSep [ PosNumOrd | lemma_ends({inen}) ] ) |
       	 LC( NoSentBoundary) AlphaUp PosAdj ( WSep PropGeoGen ) ] WSep
       lemma_morph( {laivasto}, {NUM=SG} ) ;

!* Brittiläinen Tyynenmeren laivasto
Define OrgMiscNavy2
       AlphaUp lemma_ends( AlphaDown AlphaDown AlphaDown [ {läinen} | {lainen} ] ) WSep
       [ AlphaUp wordform_ends( {nmeren} ) EndTag(EnamexLocPpl2) ] WSep
       lemma_morph( {laivasto}, {NUM=SG} ) ;

!* Kotilaivasto
Define OrgMiscNavy3
       LC( NoSentBoundary )
       AlphaUp lemma_morph( {laivasto}, {NUM=SG} ) ;

Define OrgMiscBattalionRegiment1
       ( PropGeoGen EndTag(EnamexLocPpl2) WSep ) wordform_ends( AlphaDown [ {pataljoona} | {rykmentti} ]) WSep
       lemma_exact( 0To9 ( 0To9 ) (".") ) ;

Define OrgMiscBattalionRegiment2
       wordform_exact( 0To9 ( 0To9 ) "." | Ins(NumRoman) ) WSep
       lemma_ends( AlphaDown [ {pataljoona} | {rykmentti} ] | {divisioona} ) ;

Define OrgMiscBattalionRegiment3
       LC( NoSentBoundary )
       AlphaUp lemma_ends( AlphaDown [ {pataljoona} | {rykmentti}] ) ;

Define OrgMiscBattalionRegiment4
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       wordform_exact( {kaartin} | {läänin} ) WSep
       ( lemma_morph( {pataljoona} | {rykmentti}, {NUM=SG}) WSep PosNumOrd WSep )
       lemma_ends( {pataljoona} | {rykmentti} ) ;       

Define OrgMiscPolice
       ( CapMisc WSep )
       [ PropGeoGen | CapNounGenNSB | USpl ] EndTag(EnamexLocPpl2) WSep
       ( [ PosAdj | NounGen ] WSep ) 
       [ [ lemma_exact_morph(({suojelu}|({keskus}){rikos}|{siveys}|{turvallisuus}|{huume}|{ratsu}){poliisi}, {NUM=SG}) ] | [ lemma_exact({salainen}) WSep lemma_exact( {palvelu} | {poliisi} ) ] ] ;

Define OrgMiscInstitute1
       LC( NoSentBoundary )
       AlphaUp Ins(gazNpoSuffixPart) ;

! Helsingin ja Uudenmaan sairaanhoitopiiri, 
!TODO: lisää Gaz jatkeeksi PropGeoGenille?
Define OrgMiscInstitute2
       ( CapMisc WSep )
       ( PropGeoGen EndTag(EnamexLocPpl2) WSep lemma_exact({ja}) WSep ) 
       [ PropGeoGen EndTag(EnamexLocPpl2) | CapNounGenNSB |
       CapNameGen EndTag(EnamexLocPpl2) WSep lemma_exact_morph( [{maalais}]{kunta} | {kaupunki} | ({osa}|{liitto}){valtio} | {prefektuuri} | {kanton}("i") | {lääni} | {seutu}, {[NUM=SG][CASE=GEN]}) ] WSep
       ( AlphaDown wordform_ends( AlphaDown Dash ) WSep lemma_exact({ja}) WSep )
       Ins(gazNpoSuffixPart)
       ( WSep Abbr ) ;

Define OrgMiscInstitute3
       CapNameGenNSB WSep
       ( AlphaDown wordform_ends( AlphaDown Dash ) WSep lemma_exact({ja}) WSep )
       Ins(gazNpoSuffixPart)
       ( WSep Abbr ) ;

Define OrgMiscInstitute4
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_ends({ainen}|{äinen}) WSep
       Ins(gazNpoSuffixPart)
       ( WSep Abbr ) ;

Define OrgMiscChurch
       [ lemma_exact_morph( DownCase(CountryName), {CASE=GEN}) ] EndTag(EnamexLocPpl2) WSep
       ( lemma_ends( {evankelinen} | {katolinen} | {luterilainen} | {ortodoksinen} | {koptilainen} ) WSep )
       lemma_exact_morph([Field - [ Field [{kivi}|{tuomio}|{puu}|{paanu}|{sauva}] ]] {kirkko}, {NUM=SG}) ;

! "Olarin seurakunta", "Helsingin juutalainen seurakunta", "Pyhän Paavalin luterilainen seurakunta", "Autuaan Hemmingin seurakunta"
Define OrgMiscCongregation1A
       [ PropGeoGen EndTag(EnamexLocPpl2) | wordform_exact({Pyhän}|{Autuaan}) WSep CapNameGen ] WSep 
       ( lemma_ends( {evankelinen} | {katolinen} | {ortodoksinen} | AlphaDown AlphaDown AlphaDown [{lainen}|{läinen}] ) WSep )
       lemma_morph( {seurakunta}({yhtymä}), {NUM=SG} ) ;

!* "Turun Islamilainen Yhdyskunta"
Define OrgMiscCongregation1B
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_ends( {evankelinen} | {katolinen} | {ortodoksinen} | AlphaDown AlphaDown AlphaDown [{lainen}|{läinen}] ) WSep
       lemma_morph( {yhdyskunta} ) ;

! "Xxx:n helluntaiseurakunta"
Define OrgMiscCongregation2
       [ CapNameGen | PropGeoGen ] EndTag(EnamexLocPpl2) WSep
       lemma_ends( AlphaDown {seurakunta} ) ;

Define OrgMiscCongregation3
       CapNameGen EndTag(EnamexLocPpl3) WSep
       ( lemma_morph({hiippakunta} , {NUM=SG} Field {CASE=GEN}) EndTag(EnamexLocPpl2) WSep )
       lemma_exact({tuomiokapituli}) ;

Define OrgMiscCongregation4
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact( AlphaDown+ [ {seurakunta} | {hiippakunta} ] ) ;

Define OrgMiscHolySee
       "P" lemma_exact({pyhä}) WSep
       [ lemma_exact({istuin}) | wordform_exact({istuin}) AlphaDown* ] ;

Define OrgMiscDefenceForces1
       [ PropGeoGen | USpl ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( [{puolustus}|{ase}|{ilma}|{meri}|{maa}]{voima}("t"), {NUM=PL} ) ;

Define OrgMiscDefenceForces2
       AlphaUp lemma_exact_morph( [{puolustus}|{ase}|{ilma}]{voima}("t"), {NUM=PL} ) ;

Define OrgDynastyClan1
       CapNameStr lemma_morph( Dash [ {dynastia} | {klaani} ], {NUM=SG}) ;

Define OrgDynastyClan2
       [ PropGen | CapNameGenNSB ] EndTag(EnamexPrsHum2) WSep
       lemma_exact( [ {dynastia} | {klaani} ], {NUM=SG}) ;

Define OrgWhiteHouseExt
       "V" lemma_exact_morph({valkoinen}, {NUM=SG} Field {CASE=}[{ALL}|{ADE}|{ABL}|{PAR}]) WSep
       lemma_exact_morph({talo}, {NUM=SG} Field {CASE=}[{ALL}|{ADE}|{ABL}|{PAR}]) ;

Define WhiteHouseNom
       wordform_exact({Valkoinen}) WSep
       wordform_exact({talo}) ;

Define WhiteHouseGen
       "V" lemma_exact_morph({valkoinen}, {NUM=SG} Field {CASE=GEN}) WSep
       lemma_exact_morph({talo}, {NUM=SG} Field {CASE=GEN}) ;

Define WhiteHousePar
       "V" lemma_exact_morph({valkoinen}, {NUM=SG} Field {CASE=PAR}) WSep
       lemma_exact_morph({talo}, {NUM=SG} Field {CASE=PAR}) ;

!* "YouTubelle"
Define OrgDisamb1
       wordform_exact( [ Ins(CorpOrPro) ] LocExtSuff ) ;

!* "YouTuben [mukaan]"
Define OrgDisamb2
       [ wordform_exact( [ Ins(CorpOrPro) | Ins(CorpOrLoc) ] GenSuff ) | Ins(PropOrgGen) | Ins(WhiteHouseGen) ]
       RC( WSep wordform_exact( {mukaan} | {mielestä} | {kanssa} | {kannalta} ) ) ;

!* "YouTuben [perustaja/omistaja/pääkonttori/lakimies]"
Define OrgDisamb3
       [ wordform_exact( [ Ins(CorpOrPro) | Ins(CorpOrLoc) ] GenSuff ) | Ins(PropOrgGen) | Ins(WhiteHouseGen) ]
       RC( WSep lemma_ends(
       	   {edustaja} | {perustaja} | {työtekijä} | {johtaja} | {omistaja} | {konttori} | {osake} | {liikevaihto} |
       	   {mies} | {kurssi} | {liikevaihto} | {liiketappio} | {markkinaosuus} | {listautuminen} | {palvelus} | {sijoittaja} | {blogi} |
	   {raportti} | {tiedote} | [{lehdistö}|{tiedotus}]{tilaisuus} | {suhtautuminen} | {lausunto} | {syyte} | {anteeksipyyntö} | {reaktio} | {omaisuus} | {hallitus} | {suunnitelma} | {insinööri} | {asiakaspalvelu} )
	   ) ;

!* "[syyttää/moittii/arvostelee/uhkailee] Facebookia"
Define OrgDisamb4
       LC( lemma_exact( {syyttää} | {uhkailla} | {painostaa} | {moittia} | {arvostella} | {rahoittaa} | {vaatia} ) WSep )
       [ wordform_exact( [ Ins(CorpOrPro) ] ParSuff ) | Ins(PropOrgPar) | Ins(WhiteHousePar) ]  ;

Define OrgDisamb5
       [ wordform_exact( [ Ins(CorpOrPro) ] ParSuff ) | Ins(PropOrgPar) ]
       RC( WSep wordform_exact( [ {syyttäv} | {uhkailev} | {moittiv} | {arvostelev} | {rahoittav} | {sponsoroiv} ] Alpha+ ) ) ;

!**
Define MunicipalityNom
       ( CapMisc WSep )
       [ AlphaUp PropGen | CapNameGenNSB ] WSep
       lemma_exact_morph( ({maalais}){kunta} | {kaupunki}, {NUM=SG} Field {CASE=NOM} ) ;


!* Facebook [syyttää/uhkailee/arvostelee]
Define OrgDisamb6
       [ wordform_exact( Ins(CorpOrPro) | Ins(CorpOrLoc) ) | Ins(MunicipalityNom) | Ins(PropOrgNom) | Ins(WhiteHouseNom) ]
       RC( (WSep PosAdv) [ WSep AuxVerb ( WSep PosAdv ) ]^{0,4} WSep lemma_exact_morph( VerbOrg , {VOICE=ACT} ) ) ;

Define OrgDisamb7
       [ wordform_exact( [ Ins(CorpOrPro) ] GenSuff ) | Ins(PropOrgGen) | Ins(WhiteHouseGen) ]
       RC( WSep wordform_exact( [ {sponsoroi} | {rahoitta} | {osta} | {omista} | {johta} | {kerto} ] [{ma}|{mi}] AlphaDown* ) ) ;

Define OrgDisamb8
       [ wordform_exact( [ Ins(CorpOrPro) ] GenSuff ) | Ins(PropOrgGen) ]
       RC( WSep morphtag( {PROP=} [{FIRST}|{LAST}] ) ) ;

Define OrgDefault
       inflect_sg( @txt"gStatORG.txt" | VehicleBrand ) ;

Define OrgMiscGaz [ m4_include(`gOrgMiscAll.m4') ] ;

!* Category HEAD
Define MiscOrg
       [ Ins(OrgSociety)
       | Ins(OrgUnion)
       | Ins(OrgYouth)
       | Ins(OrgJurid)
       | Ins(OrgCityCouncil)
       | Ins(OrgMunicipality)
       | Ins(OrgAgency)
       | Ins(OrgMiscOrderOf)::0.50
       | Ins(OrgMiscSemtag1)::0.50
       | Ins(OrgMiscSemtag2)::0.75
       | Ins(OrgMiscSemtag3)::0.30
       | Ins(OrgMiscGuessed1)::0.40
       | Ins(OrgMiscGuessed2)::0.50
       | Ins(OrgMiscHyphen1)::0.50
       | Ins(OrgMiscHyphen2)::0.50
       | Ins(OrgMiscHyphen3)::0.50
       | Ins(OrgMiscHyphen4)::0.50
       | Ins(OrgMiscHyphen5)::0.50
       | Ins(OrgMiscSuffixed1)::0.25
       | Ins(OrgMiscSuffixed2)::0.25
       | Ins(OrgMiscBoardA)::0.50
       | Ins(OrgMiscBoardB)::0.50
       | Ins(OrgMiscBoardC)::0.50
       | Ins(OrgMiscPolice)::0.50
       | Ins(OrgMiscSpace)::0.50
       | Ins(OrgMiscState)::0.50
       | Ins(OrgMiscCommon)::0.50
       | Ins(OrgMiscHospital)::0.50
       | Ins(OrgDisamb1)::0.00
       | Ins(OrgDisamb2)::0.00
       | Ins(OrgDisamb3)::0.00
       | Ins(OrgDisamb4)::0.00
       | Ins(OrgDisamb5)::0.00
       | Ins(OrgDisamb6)::0.00
       | Ins(OrgDisamb7)::0.00
       | Ins(OrgDisamb8)::0.00
       | Ins(OrgMiscGaz)::0.10
       | Ins(OrgDefault)::0.10
       | Ins(OrgMiscInstitute1)::0.50
       | Ins(OrgMiscInstitute2)::0.50
       | Ins(OrgMiscInstitute3)::0.50
       | Ins(OrgMiscInstitute4)::0.50
       | Ins(OrgMiscChurch)::0.25
       | Ins(OrgMiscCongregation1A)::0.50
       | Ins(OrgMiscCongregation1B)::0.50
       | Ins(OrgMiscCongregation2)::0.50
       | Ins(OrgMiscCongregation3)::0.50
       | Ins(OrgMiscCongregation4)::0.50
       | Ins(OrgMiscHolySee)::0.50
       | Ins(OrgDynastyClan1)::0.50
       | Ins(OrgDynastyClan2)::0.50
       | Ins(OrgWhiteHouseExt)::0.50
       | Ins(OrgMiscDefenceForces1)::0.50
       | Ins(OrgMiscDefenceForces2)::0.50
       | [ Ins(OrgMiscNavy1) | Ins(OrgMiscNavy2) | Ins(OrgMiscNavy3)
       | Ins(OrgMiscBattalionRegiment1) | Ins(OrgMiscBattalionRegiment2)
       | Ins(OrgMiscBattalionRegiment3) | Ins(OrgMiscBattalionRegiment4) ]::0.50
       ] EndTag(EnamexOrgCrp) ;

!!----------------------------------------------------------------------
!! <HEAD>
!!----------------------------------------------------------------------

!* Category HEAD
Define Organization
       [ Ins(MediaOrg)
       | Ins(EduOrg)
       | Ins(FinancOrg)
       | Ins(CorpOrg)
       | Ins(AthlOrg)
       | Ins(PolitOrg)
       | Ins(CultOrg)
       | Ins(MiscOrg)
       ] ;

!!----------------------------------------------------------------------
!! <EnamexProXxx>: Products (mainly software, electronics, and social
!! media platforms)
!!----------------------------------------------------------------------

Define VNum wordform_exact( 0To9+ ( "." [ 0To9|"X"|"x"]+ ) ( "." [ 0To9|"X"|"x"]+ ) (":" AlphaDown+ ) ) ;
Define VersionSeq
       ( lemma_ends({versio}) WSep )
       ( [ VNum WSep wordform_exact(Comma) WSep ]* VNum WSep wordform_exact( {ja} | {sekä} | {että} | "&" | Comma ) WSep ) VNum ;

Define VersionSeqX
       ( [ VNum WSep wordform_exact(Comma) WSep ]* VNum WSep wordform_exact( {ja} | {sekä} | {että} | "&" | Comma ) WSep ) VNum ;

Define ProTypeStr @txt"gProdType.txt" ;
Define ProType lemma_ends( ProTypeStr ) ;
Define ProMfac @txt"gProdMfac.txt" ;
Define ProSuff @txt"gProdSuff.txt" ;
Define ProSeries @txt"gProdSeries.txt" ;
Define ProOS @txt"gProdOS.txt" ;
Define ProBrowser @txt"gProdBrowser.txt" ;

!------------------------------------------------------------------------
!* Video games
!------------------------------------------------------------------------

Define GameSfx [ {3D} | {DX} | {Plus} | {Deluxe} | {64} ] ;
Define GameType lemma_ends( [ {peli}({sarja}) | {räiskintä} | {taso}[{hyppely}|{loikka}] | {seikkailu} | ["j"|{mmo}]{rpg} | {simulaattori} | {pelikokoelma} ] ) ;

Define gazProVG [ m4_include(`gProdGame.m4') ] ;

Define ProVG1
       AlphaUp Field Capture(ProCpt01) Dash Ins(GameType) ;

Define ProVG2
       ( [ CapMisc WSep ]*
       	 [ AlphaUp | 0To9 ] Word WSep lemma_exact(":") WSep )
       [ [ AlphaUp AbbrNom | AlphaUp PunctWord | CapMisc ] WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ [ CapWord WSep ]* )
       Field AlphaUp ( Word WSep )
       [ NoFSep - SentencePunct ] Field Capture(ProCpt02) FSep Word WSep
       DashExt Ins(GameType) ;

Define ProVG4
       InQuotes WSep
       DashExt Ins(GameType) ;

Define ProVG3
       ( CapMisc WSep )
       gazProVG
       ( WSep AlphaUp AlphaDown+ FSep Word )
       ( WSep wordform_exact([ Ins(NumRoman) | Ins(GameSfx) | 0To9 ]) )
       ( WSep wordform_exact([ Ins(NumRoman) | Ins(GameSfx) | 0To9 ](":" AlphaDown+)) )
       ( WSep lemma_exact(":")
       	 WSep CapWord ( [ WSep CapWord ]* [ WSep AndOfThe ]+ WSep CapWord )
       	 [ WSep CapName ]* )
       ( WSep Dash Ins(GameType) )
       NRC( WSep Dash Word ) ;

Define ProVideoGame
       [ Ins(ProVG1)::0.50
       | Ins(ProVG2)::0.50
       | OptQuotes(Ins(ProVG3))::0.25
       | Ins(ProVG4)::0.25
       ] ;

!------------------------------------------------------------------------
!* Film & Television
!------------------------------------------------------------------------

Define FilmTVType lemma_ends( [ [ {elokuva} | {leffa} ]({sarja}) | [ {tv-} | {televisio} | {kultti} | {animaatio} | {draama} |
       		  	      	  	      	      		     {komedia} | {sketsi} | {piirros} | {scifi-} |
								     {sci-fi} | {tieteis} | {reality} | {jännitys} ]{sarja}
				| {jatko-osa} | {trilogi} ("a") | {tetralogi} ("a") | {sketsi} | {talkshow} | {spinoff} | {spin} (Dash) {off}
				| {komedia} | {draama} | {animaatio} | {trilleri} | {anime} | {telenovela} | {dokkari} | {show}
				| {dokumentti} | {epookki} | {tragedia} | {musikaali} | {tieteisfantasia} !| {ohjelma} | {sarja}
				| {avaruusooppera} | {reality} | {tosi-tv-}[{kilpailu}|{kisa}] | {tietovisa} | {ooppera} | {näytelmä}
				| {klassikko} ] ) ;

Define gazProFilmTV [ m4_include(`gProdFilmTvMWord.m4') ] ;

Define ProFilmTVGaz
       gazProFilmTV
       ( WSep CapName )
       ( WSep wordform_exact([ NumRoman | 0To9 ](":" AlphaDown+)) )
       ( WSep lemma_exact( ":" | Dash )
       	 WSep CapWord ( [ WSep CapWord ]* [ WSep AndOfThe ]+ WSep CapWord )
	 [ WSep CapName ]* )
       ( WSep DashExt Ins(FilmTVType) )
       NRC( WSep Dash AlphaDown ) ;

Define ProFilmTVSuffixed1
       AlphaUp Field Capture(ProCpt03) Dash lemma_ends( Ins(FilmTVType) ) ;

Define ProFilmTVSuffixed2
       ( [ CapMisc WSep ]*
	 [ AlphaUp | 0To9 ] Word WSep lemma_exact(":") WSep )
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ [ CapWord WSep ]* )
       [ CapMisc WSep ]*
       [ AlphaUp | 0To9 ] Field Capture(ProCpt04) FSep Word WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt Ins(FilmTVType ) ;

Define ProFilmTVSuffixed3
       InQuotes WSep
       DashExt [ Ins(FilmTVType ) | lemma_exact( (Dash) [ {video} | {ohjelma} ] ) ] ;

Define ProFilmTVWith
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ [ CapWord WSep ]* )
       [ CapNameGenNSB | AlphaUp PropGen ]
       RC( WSep lemma_exact( {ensi-ilta} | {katsojaluku} | {tuottaja} | {käsikirjoittaja} | {ohjaaja} | {käsikirjoitus} | AlphaDown* {pääosa} | {kuvaus} | ["o"|"ö"]{skausi} | {pilottijakso} | {päätösjakso} | {pääosa} | {päähenkilö} | {tarina} | {prologi} ) ) ;

! X:n elokuva Y, elokuvassa Y
Define ProFilmColloc
       LC( WSep [ ? - Dash ] [ FilmTVType | lemma_ends( {ohjelma} ) ] WSep ( wordform_exact({nimeltä}) WSep ) )
       [ [ CapMisc WSep ]* CapName ( ( WSep CapWord ) WSep [ AndOfThe WSep ]+ CapWord )::0.75 | InQuotes ] ;

Define ProFilmTV
       [ Ins(ProFilmTVSuffixed1)::0.25
       | Ins(ProFilmTVSuffixed2)::0.25
       | Ins(ProFilmTVSuffixed3)::0.25
       | OptQuotes(Ins(ProFilmTVGaz))::0.25
       | Ins(ProFilmTVWith)::0.60
       | Ins(ProFilmColloc)::0.20 
       ] ;

!------------------------------------------------------------------------
!* Books & Literature
!------------------------------------------------------------------------

Define LitType [[ ( AlphaDown Field ) [ {kirja}({sarja}) | {elämäkerta} | {teos} | {romaani}({sarja}) | {novelli} | {dekkari}({sarja}) | 
      	       [{runo}|{novelli}|{essee}]{kokoelma} | {essee} | {runo} | {sarjakuva} | {sarjis} | {manga} | {jännäri} | {trilleri} |
	       {näytelmä} | {ooppera} | {klassikko} ] ]
	       - [ Field [ {asiakirja} | {väitöskirja} | {opaskirja} | {pöytäkirja} ] ] ] ;

Define ProLitSuffixed1
       [ CapMisc WSep ]*
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       Dash lemma_exact( (Dash) Ins(LitType) ) ;

Define ProLitSuffixed2
       LC( NoSentBoundary )
       AlphaUp Field Capture(ProCpt06) lemma_exact( Field Dash Ins(LitType) ) ;

Define ProLitSuffixed3
       InQuotes WSep
       DashExt lemma_exact( (Dash) Ins(LitType) ) ;

Define ProLitSuffixed4
       ( wordform_exact({The}) WSep ( CapWord WSep ) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) ]+
       [ CapMisc WSep ]*
       ( CapWord WSep )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt lemma_ends( Ins(LitType) ) ;

Define ProLitWithAuthor
       LC( CaseGen WSep ( PosAdj WSep ) lemma_exact(LitType) WSep ( wordform_exact({nimeltä}) WSep ) )
       [ CapName ( ( WSep CapWord ) WSep [ AndOfThe WSep ]+ CapWord ) | InQuotes ] ;

Define ProLitQuoted
       LC( lemma_exact(LitType) WSep ( wordform_exact({nimeltä}) WSep ) )
       InQuotes ;

Define ProLitGaz
       [ m4_include(`gProdLitMWord.m4') ] ;

Define ProLiterature
       [ Ins(ProLitSuffixed1)::0.250
       | Ins(ProLitSuffixed2)::0.250
       | Ins(ProLitSuffixed3)::0.250
       | Ins(ProLitSuffixed4)::0.250
       | Ins(ProLitQuoted)::0.500
       | Ins(ProLitWithAuthor)::0.750
       | OptQuotes(Ins(ProLitGaz))::0.100
       ] ;

!------------------------------------------------------------------------
!TODO: rukoukset yms.
!------------------------------------------------------------------------

!------------------------------------------------------------------------
!* Artwork, Paintings
!------------------------------------------------------------------------

Define ArtType [ {taideteos} | {maalaus} | AlphaDown {värityö} | {performanssi} | {kollaasi} | {installaatio} | {potretti} | {muotokuva} | {litografia} | {fresko} | {muraali} | {triptyykki} | {musiikkivideo} ] ;

Define ProArtSuffixed1
       [ CapMisc WSep ]*
       CapName WSep
       [ AlphaDown Word WSep ]*
       [ NoFSep - SentencePunct ] Word WSep
       DashExt lemma_ends(Ins(ArtType)) ;

Define ProArtSuffixed2
       LC( NoSentBoundary )
       AlphaUp Field ( Word WSep ) Dash lemma_ends(Ins(ArtType)) ;

Define ProArtSuffixed3
       InQuotes WSep
       DashExt lemma_ends(Ins(ArtType)) ;

Define ProArtWithArtist
       LC( CaseGen WSep ( PosAdj WSep ) lemma_exact(ArtType) WSep ( wordform_exact({nimeltä}) WSep ) )
       [ CapName ( ( WSep CapWord ) WSep [ AndOfThe WSep ]+ CapWord ) | InQuotes ] ;

Define ProArtSemtag
       OptQuotes( semtag({PROP=ARTWORK}) ) ;

Define ProArtwork
       [ ProArtSuffixed1::0.25
       | ProArtSuffixed2::0.25
       | ProArtSuffixed3::0.25
       | ProArtSemtag::0.50
       | ProArtWithArtist::0.75
       ] ;

!------------------------------------------------------------------------
!* Vehicles & Vessels
! - ships, boats, jachts
! - airplanes, helicopters, airships
! - automobiles, motorcycles, bikes
! - trains, locomotives
! - armored and military vehicles
! - space shuttles
!------------------------------------------------------------------------

Define VehicleBrandNom wordform_exact(VehicleBrand) ;
Define VehicleType lemma_ends( @txt"gProdVehicleType.txt" ) ;

Define ProVehicleSuffixed1
       LC( NoSentBoundary )
       [ AlphaUp | 0To9 ] Field Capture(ProCptV01) Dash Ins(VehicleType) ;

Define ProVehicleSuffixed2
       [[ CapMisc | AcrNom ] WSep ]*
       ( [ AlphaUp | 0To9 ] Word WSep )
       [ NoFSep - SentencePunct ] Field Capture(ProCptV02) FSep Word WSep
       DashExt Ins(VehicleType) ;

Define ProVehicleSuffixed3
       InQuotes WSep
       DashExt Ins(VehicleType) ;

Define ProVehiclePrefixed1
       Ins(VehicleBrandNom) EndTag(EnamexOrgCrp2) WSep
       ( [ CapWord | NumWord ] WSep )
       [ CapWord | NumWord ] ;

Define ProVehicleQuotes
       LC( VehicleType WSep ( wordform_exact({nimeltä}) WSep ) )
       [ SetQuotes( ( CapWord WSep ) ( CapMisc WSep ) CapName ) | CapName::0.50 ] ;

Define ProVehicleMisc1
       inflect_sg( @txt"gProdVehicleModel.txt" ) ;

Define ProVehicleBrandPl
       inflect_pl( VehicleBrand ) ;

!TODO: ajaa Teslaa/Teslalla, tankata/virittää/huoltaa/pestä/katsastaa

Define ProVehicleColloc1
       [ PropGen::0.40 | CapNameGenNSB::0.60 | infl_sg_gen(VehicleBrand)::0.10 ] 
       RC( WSep lemma_exact( [{taka}|{etu}|{nahka}]{penkki} | {istuin} | {moottori} | {tuulilasi} | {ratti} | {konepelti} | {pakoputki} |
       	   		     {takakontti} | {verhoilu} | {rengas} | {vaihteisto} | {ohjattavuus} | {ohjaustuntuma} | {käyntiääni} |
			     {tankkaaminen} | {tankkaus} | {takalasi} | {sivupeili} | {poljin} | {kytkin} | {kojelauta} | {bensamittari} |
			     {mittari} | {ohjekirja} | {kuljettaja} | {kuski} | {kyyti} | {kyydissä} | {kyytiin} | {kyydistä} |
			     {bensatankki} | {polttoainetankki} | {takaveto} | {takavalo} | {vaihdelaatikko} | {varoitusvalo} |
			     {merkkivalo} | {runko} | {keula} | {huoltaminen} | {vuosihuolto} | {katsastus} | {vilkku} | {ohjaamo} ) ) ;

! "USS Enterprise", "HMS Victory", "USCGC Eagle (WIX-327)", "MS Allure of the Seas"
Define ProVehicleShipNameA
       wordform_exact( ["M"|"S"]("/")["S"|"V"] | {RMS} | {GTS} | {USS} | {USF} | {HMS} | {USCGC} | {HMAS} | {FS} ) WSep
       [ CapMisc WSep ]*
       CapName ( WSep [ AndOfThe WSep ]+ CapName )
       ( WSep lemma_exact( LPar ) WSep CapWord WSep lemma_exact( RPar ) ) ;

Define ProVehicleShipNameB
       wordform_exact( "M" | "S" ) WSep Slash WSep wordform_exact( "S" | "V" ) WSep
       [ CapMisc WSep ]* CapName
       ( WSep lemma_exact( LPar ) WSep CapWord WSep lemma_exact( RPar ) ) ;

Define ProVehicleShipSpecial
       LC( lemma_morph( {miinalaiva}, {CASE=NOM} ) WSep )
       OptQuotes( AlphaUp lemma_ends( {nmaa} ) ) ;

Define ProVehicle
       [ Ins(ProVehicleSuffixed1)::0.25
       | Ins(ProVehicleSuffixed2)::0.25
       | Ins(ProVehicleSuffixed3)::0.25
       | Ins(ProVehicleColloc1)::0.00
       | OptQuotes(Ins(ProVehiclePrefixed1)::0.60)
       | OptQuotes(Ins(ProVehicleMisc1)::0.30)
       | OptQuotes(Ins(ProVehicleShipNameA)::0.25)
       | OptQuotes(Ins(ProVehicleShipNameB)::0.25)
       | Ins(ProVehicleShipSpecial)::0.20
       | Ins(ProVehicleQuotes)::0.75
       | Ins(ProVehicleBrandPl)::0.20
       ] ;

!------------------------------------------------------------------------
!* Music
!------------------------------------------------------------------------

Define MusicType
       lemma_exact( Field [ {laulu} | {kappale} | {biisi} | {single} | {sinkku} | {albumi} | {cd} | {pitkäsoitto} | {älppäri} | {levy}
       		    	  | {tango} | {valssi} | {vinyyli} | {hitti} | {renkutus} ] | {ep} | {trilogia} | {sinfonia} | {tetralogia}
			  | {konsertto} | {menuetti} | {aaria} | {avausraita} | {lopetusraita} | {päätösraita} ) ;

Define ProMusicSuffixed1
       ( wordform_exact( {A} | {The} | {Of} | {From} | {In} ) WSep ) 
       [ CapMisc WSep ]*
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       Dash Ins(MusicType) ;

Define ProMusicSuffixed2
       AlphaUp Field Dash Ins(MusicType) ;

Define ProMusicSuffixed3
       InQuotes WSep
       DashExt Ins(MusicType) ;

Define ProMusicColloc
       LC( WSep Word WSep MusicType WSep )
       [ CapMisc WSep ]*
       [ CapName ( ( WSep CapWord ) WSep [ AndOfThe WSep ]+ CapWord ) | InQuotes ] ;

Define ProMusic
       [ Ins(ProMusicSuffixed1)::0.25
       | Ins(ProMusicSuffixed2)::0.25
       | Ins(ProMusicSuffixed3)::0.25
       | Ins(ProMusicColloc)::0.70
       ] ;

!------------------------------------------------------------------------
!* Awards, Prizes, Scholarships
!------------------------------------------------------------------------

Define AwardType [ {palkint}["o"|"a"] | {mitali} | {pokaali} | {pysti} | [{kunnia}|{ansio}]{merkki} | {kunniamaininta} | {tunnustus}
       		 | {suurristi} | {ansioristi} | {stipendi} ] ;

Define ProAwardSuffixed1
       AlphaUp Field Dash lemma_ends( Ins(AwardType) ) ;

Define ProAwardSuffixed2
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) )
       [ CapMisc WSep ]*
       AlphaUp Field FSep Capture(ProCptL01) Word WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       Dash lemma_ends( Ins(AwardType) ) ;

Define ProAwardSuffixed3
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) )
       CapName WSep
       inflect_sg( {Award} | {Prize} | {Medal} | {Trophy} )
       [ WSep [ AndOfThe WSep ]+ CapWord ( WSep CapMisc ) ]*
       ( WSep inflect_sg( {Finland} | {Sweden} ) ) ;

Define ProAwardSuffixed4
       InQuotes WSep
       DashExt lemma_ends( Ins(AwardType) ) ;

Define ProAwardSuffixed5
       AlphaUp lemma_exact( DownCase(CountryName), {NUM=SG} FSep {CASE=GEN} ) EndTag(EnamexLocPpl3) WSep
       [ AlphaUp ( PosAdjGen WSep ) NounGen | CapNameGen ] EndTag(EnamexOrgCrp2) WSep
       lemma_exact( {suurristi} | {ansioristi} ) ;

! "Jussit", "Nobelit", "Oscarit"
Define ProAwardPl
       AlphaUp lemma_exact_morph(
       	       [ {jussi} | {emma} | {emmy} | {oscar} | {venla} | {nobel} ], {NUM=PL} ) ;

Define ProAwardMisc1
       AlphaUp lemma_exact( {grammy} | {emmy} | {telvis} | {razzie} | {effie} | {pulitzer} | {guldbagge} | {bafta} | {aacta} ) ;

Define ProAwardMisc2
       inflect_sg( {Grammy} | {Razzie} | {Bafta} | {Pulitzer} | {Guldbagge} | {Aacta} | {BAFTA} | {AACTA} ) ;

Define ProAwardMWord
       wordform_exact({Golden}) WSep inflect_sg( {Globe} | {Raspberry} ) |
       wordform_exact({Nobelin}) WSep lemma_ends( {palkinto} ) ;

Define ProAward
       [ Ins(ProAwardSuffixed1)
       | Ins(ProAwardSuffixed2)
       | Ins(ProAwardSuffixed3)
       | Ins(ProAwardSuffixed4)
       | Ins(ProAwardSuffixed5)
       | Ins(ProAwardPl)
       | Ins(ProAwardMisc1)
       | Ins(ProAwardMisc2)
       | Ins(ProAwardMWord)
       ] ;

!------------------------------------------------------------------------
!* Pharmaceuticals & narcotics
!------------------------------------------------------------------------

Define ProDrugType lemma_ends( @txt"gProdDrugType.txt" ) ;

Define ProDrugSuffixed1A
       LC( NoSentBoundary )
       AlphaUp Field Dash Field Ins(ProDrugType) ;

Define ProDrugSuffixed1B
       [ [ AlphaUp Field Dash AlphaDown Field Ins(ProDrugType) ] - ADashA ] ;

Define ProDrugSuffixed2
       ( CapMisc WSep )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt Ins(ProDrugType) ;

!Define ProDrugColloc
! X:n sivuvaikutus/vaikuttava aine/väärinkäyttäjä/pakkaus

Define gazProDrug
       [ m4_include(`gProdDrug.m4') ] ;

Define ProDrugGaz
       OptQuotes( Ins(gazProDrug) )
       ( WSep DashExt Ins(ProDrugType) ) ;

Define ProDrug
       [ Ins(ProDrugSuffixed1A)::0.25
       | Ins(ProDrugSuffixed1B)::0.25
       | Ins(ProDrugSuffixed2)::0.25
       | Ins(ProDrugGaz)
       ] ;

!------------------------------------------------------------------------
!* Legislation
!------------------------------------------------------------------------

Define ProLawHyphen1
       LC( NoSentBoundary )
       AlphaUp Field Dash lemma_ends( {laki} | {kansalaisaloite} ) ;

Define ProLawHyphen2
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) )
       CapName WSep
       Dash lemma_exact( Field {laki} | {lain} | {kansalaisaloite} ) ;

Define ProLawHyphenQuote
       InQuotes WSep
       Dash lemma_exact( Field {laki} | {lain} | {kansalaisaloite} ) ;

Define ProLawSuffixed1
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) )
       CapName WSep
       inflect_sg( {Act} | {Amendment} | {Statute} | {Initiative} ) ;

Define ProLawPrefixed1
       wordform_exact( {Proposition} | {Title} ) WSep
       wordform_exact( [ 0To9 ( 0To9 ) | NumRoman ] (":" AlphaDown ) ) ;

Define ProLaw
       [ Ins(ProLawHyphen1)::0.30
       | Ins(ProLawHyphen2)::0.30
       | Ins(ProLawHyphenQuote)::0.30
       | OptQuotes(Ins(ProLawPrefixed1)::0.50)
       | OptQuotes(Ins(ProLawSuffixed1)::0.30)
       ] ;

!------------------------------------------------------------------------
!* Projects
!------------------------------------------------------------------------

Define ProProjectHyphen1
       AlphaUp lemma_exact( Field Dash Field [ {projekti} | {hanke} | {avaruusohjelma} | {operaatio} ] ) ;

Define ProProjectHyphen2
       ( CapMisc WSep )
       CapName WSep
       ( CapWord WSep
       	 ( ( LowerWord WSep ) ( LowerWord WSep )
	   NotConj WSep ) )
       DashExt lemma_ends( {projekti} | {hanke} | [{avaruus}]{ojelma} | {operaatio} ) ;

Define ProProjectSuffixed
       [ CapMisc WSep ]*
       [ CapMisc | PropNom ] WSep
       inflect_sg( {Project} | {Operation} ) ;

! "Project MKUltra", "Operation Desert Storm"
Define ProProjectPrefixed1
       wordform_exact( {Project} | {Operation} | {Projekti} | OptCap({operaatio}) ) WSep
       ( CapMisc WSep ) ( CapMisc WSep )
       CapWord ;

! "operaatio Valettu lyijy"
Define ProProjectPrefixed2
       wordform_exact( OptCap({operaatio}) ) WSep
       AlphaUp PosAdj WSep
       PosNoun ;

Define ProProject
       [ Ins(ProProjectHyphen1)::0.25
       | Ins(ProProjectHyphen2)::0.25
       | OptQuotes(Ins(ProProjectPrefixed1)::0.50)
       | Ins(ProProjectPrefixed2)::0.50
       | OptQuotes(Ins(ProProjectSuffixed)::0.50)
       ] ; 


!------------------------------------------------------------------------
!* Agreements
!------------------------------------------------------------------------

Define ProAgreementSuffixed1
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       [ lemma_ends( {sopimus} ) - lemma_ends( {työsopimus} ) ] ;

Define ProAgreementHyphen1
       [ CapMisc WSep ]*
       ( CapWord WSep )
       Word WSep
       Dash AlphaDown lemma_ends( {sopimus} ) ;

Define ProAgreementHyphen2
       AlphaUp lemma_morph( Dash {sopimus}, {NUM=SG} ) ;

Define ProAgreementSuffixed2
       [ CapMisc WSep ]*
       ( CapWord WSep )
       CapWord WSep
       inflect_sg( {Treaty} | {Agreement} | {Pact} ) ;

Define ProAgreement
       [ Ins(ProAgreementSuffixed1)::0.30
       | Ins(ProAgreementSuffixed2)::0.30
       | Ins(ProAgreementHyphen1)::0.30
       | Ins(ProAgreementHyphen2)::0.30
       ] ;
!------------------------------------------------------------------------
!* Software, Electronics & Miscellanea
!------------------------------------------------------------------------

!* "Xxx-sovellus"
Define ProMiscSuffixed1A
       [ Alpha Field | 0To9 ] [ 0To9 | AlphaUp ] Field Capture(ProCptD) Dash Ins(ProType) ;

Define ProMiscSuffixed1B
       LC( NoSentBoundary )
       AlphaUp Field Capture(ProCptE) Dash Ins(ProType) ;

Define ProMiscSuffixed1C
       [ [ AlphaUp Field Dash AlphaDown Field ] - [ ADashA ] ] Capture(ProCptF) FSep Field Ins(ProTypeStr) FSep Word ;

Define ProMiscSuffixed1D
       Field Capture(ProCptG) lemma_ends( ? Dash [ {niminen} | {merkkinen} ] ) WSep
       Ins(ProType) ;

!Define ProMiscSuffixed1E
!       [ AlphaUp Field Dash FSep Word WSep
!       lemma_exact( "," ) WSep ]*
!       AlphaUp Field Dash FSep Word WSep
!       lemma_exact( {ja} | {sekä} ) WSep
!       AlphaUp Field Dash Ins(ProType) ;

!* "Xxx 999 -sovellus"
Define ProMiscSuffixed2
       [ Alpha* [ CapMisc | AcrNom ] WSep ]*
       ( Alpha* [ AlphaUp | 0To9 ] Word WSep )
       Alpha* [ AlphaUp | 0To9 ] Field Capture(ProCptA) FSep Word WSep
       DashExt Ins(ProType) ;

!* "The X of the Y -kirja"
Define ProMiscSuffixed3A
       ( wordform_exact({The}) WSep ( CapWord WSep ) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) ]
       [ CapMisc WSep ]*
       ( CapWord WSep )
       [ NoFSep - SentencePunct ] Field Capture(ProCptB) FSep Word WSep
       DashExt Ins(ProType) ;

Define ProMiscSuffixed3B
       ( CapMisc WSep )
       wordform_exact({The}) WSep ( CapWord WSep ) ( CapWord WSep )
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ]*
       [ CapMisc WSep ]*
       [ NoFSep - SentencePunct ] Field Capture(ProCptC) FSep Word WSep
       DashExt Ins(ProType) ;

Define ProMiscSuffixed3C
       [ InQuotes ] WSep
       DashExt Ins(ProType) ;

Define ProMiscSuffixed3D
       CapWord WSep
       ( ( LowerWord WSep )
       NotConj WSep )
       DashExt Ins(ProType) ;

Define ProMiscSuffixed4A
       ( [ Alpha* [ CapMisc | AcrNom ] WSep ]+
       	 NumNom WSep )
       [ Alpha* [ CapMisc | AcrNom ] WSep ]+
       wordform_ends( ProSuff )
       [ WSep Alpha* [ CapMisc | AcrNom | NumNom ] ]*
       ( WSep [ VersionSeq | 0To9 Word | CapWord ] )
       ( WSep DashExt Ins(ProType) ) ;

Define ProMiscSuffixed4B
       ( [ Alpha* [ CapMisc | AcrNom ] WSep ]+
       	 NumNom WSep )
       [ Alpha* [ CapMisc | AcrNom ] WSep ]+
       inflect_sg( Field ProSuff ) ;

Define ProMiscSuffixed5
       InQuotes WSep
       ( WSep DashExt Ins(ProType) ) ;

Define ProMiscSuffixed
       [ Ins(ProMiscSuffixed1A) | Ins(ProMiscSuffixed1B) | Ins(ProMiscSuffixed1C) | Ins(ProMiscSuffixed1D)
       | Ins(ProMiscSuffixed2)
       | Ins(ProMiscSuffixed3A) | Ins(ProMiscSuffixed3B) | Ins(ProMiscSuffixed3C) | Ins(ProMiscSuffixed3D)
       | Ins(ProMiscSuffixed4A) | Ins(ProMiscSuffixed4B)
       | Ins(ProMiscSuffixed5)
       ] ;

Define ProPfx [ wordform_exact( Ins(ProMfac) ) EndTag(EnamexOrgCrp2) | wordform_exact( Ins(CorpOrPro) | Ins(ProSeries) | Ins(ProOS) | Ins(ProBrowser) ) ] ;

! "Xxx Reader", "Samsung Xxx Pro"
Define ProMiscOther1A
       Ins(ProPfx) WSep
       [ [ Alpha | 0To9 ]* [ CapNameNom | CapNum ] WSep ]*
       ( VersionSeq WSep )
       wordform_exact( Ins(ProSeries) | Ins(ProSuff) )
       [ WSep [ Alpha | 0To9 ]* [ CapNameNom | CapNum ] ]*
       ( WSep VersionSeq )
       ( WSep CapWord )
       ( WSep DashExt Ins(ProType) ) ;
       
Define ProMiscOther1B
       Ins(ProPfx) WSep
       [ [ Alpha | 0To9 ]* [ CapNameNom | CapNum ] WSep ]*
       ( VersionSeq WSep )
       inflect_sg( ProSeries | ProSuff )
       ( WSep DashExt Ins(ProType) ) ;

! "Xxx 4 Yyy:ssä"
Define ProMiscOther2A
       ( Alpha* CapMisc WSep )
       Ins(ProPfx)
       [ WSep CapMisc ]*
       WSep Alpha* 0To9 [ CapMisc | NumNom ]
       [ WSep CapMisc ]*
       WSep Alpha* [ CapName | 0To9 Word ]
       ( WSep DashExt Ins(ProType) ) ;

!* "Xxxx 4:ssä"
Define ProMiscOther2B
       ( Alpha* CapMisc WSep )
       Ins(ProPfx)
       [ WSep [ CapMisc | AcrNom | NumNom ] ]*
       WSep [ Alpha* 0To9 Word | VersionSeq ]
       ( WSep DashExt Ins(ProType) ) ;

Define ProMiscOther3
       [ Alpha* [ CapMisc | AcrNom ] WSep ]*
       Ins(ProPfx)
       [ WSep Alpha* [ NumNom | CapMisc | AcrNom ] ]*
       WSep Alpha* [ 0To9 | AlphaUp ] Word
       ( WSep DashExt Ins(ProType) ) ;

!* Xxx Development Kit
Define ProMiscOther4
       [ Alpha* CapMisc WSep ]+
       [ wordform_exact({App}) WSep inflect_sg({Store}) |
         wordform_exact({Development}) inflect_sg({Kit}) |
         wordform_exact({Live}) WSep inflect_sg({System}) |
	 wordform_exact({Remote}) WSep lemma_exact({Desktop}) |
         wordform_exact({Speed}) WSep inflect_sg({Test}) |
         wordform_exact({Storage}) WSep inflect_sg({Service}) |
         wordform_exact({Media}) WSep inflect_sg({Player}) |
         inflect_sg( {Beta} ) ]
       ( WSep Ins(VersionSeq) )
       ( WSep DashExt Ins(ProType) ) ;

Define ProAppStore
       [ Alpha* CapMisc WSep ]*
       CapWord WSep
       wordform_ends( {Store} | {Play} )
       WSep Dash lemma_ends({kauppa}) ;

Define ModelString
       ( [ AlphaUp | 0To9 ]+ Dash )
       [ AlphaUp | 0To9 ]* [ AlphaUp 0To9 | 0To9 AlphaUp ] [ AlphaUp | 0To9 ]*
       ( Dash [ AlphaUp | 0To9 ]+ ) ;

Define ProMiscModel1A
       [ Alpha* [ CapMisc | AcrNom ] WSep ]+
       ( wordform_exact( ModelString ) WSep )
       wordform_exact( ModelString )
       [ WSep Alpha* [ CapMisc | AcrNom ] ]*
       ( WSep DashExt Ins(ProType) ) ;

Define ProMiscModel1B
       [ Alpha* [ CapMisc | AcrNom ] WSep ]+
       ( wordform_exact( ModelString ) WSep )
       inflect_sg( ModelString ) ;

Define ProMiscVersion1
       [ Alpha* [ CapMisc | AcrNom ] WSep ]*
       [ Alpha* [ CapNameGenNSB | AlphaUp PropGen | CapForeign ] ] WSep
       lemma_exact( [ Field - DownCase(ProOS) ] Dash {versio}) ;

Define ProMiscVersion2
       [ Alpha* [ CapMisc | AcrNom ] WSep ]*
       [ Alpha* [ CapNameGenNSB | AlphaUp PropGen | CapForeign ] ] WSep
       lemma_exact({versio}) WSep Ins(VersionSeqX) ;

Define ProMiscVersion3
       [ Alpha* [ CapMisc | AcrNom ] WSep ]*
       wordform_exact( ProOS ) WSep
       [ Alpha* [ CapMisc | AcrNom ] WSep ]*
       lemma_exact({versio}) WSep Ins(VersionSeqX) ;

Define ProMiscOther5
       LC( WSep [ Field - [ Field AlphaUp Field ] ] FSep Word WSep )
       inflect_sg( Alpha* ProSuff )
       RC( WSep [ ? - [ AlphaUp | Dash | 0To9 ] ]) ;

Define ProDStr [ Ins(CorpOrPro) | CamelCase::1.00 | AlphaUp WebDomain::1.00 ] ;

!* "Facebookissa"
Define ProDisamb1
       wordform_exact( Ins(ProDStr) LocIntSuff ) ;

!* "Facebookin [kautta]"
Define ProDisamb2
       wordform_exact( Ins(ProDStr) GenSuff )
       RC( WSep wordform_ends(
		{avulla} |
		{kautta} |
		{välityksellä} |
		{ulkopuolella} ) ) ;

!* "Facebookin [käyttäjät]"
Define ProDisamb3
       wordform_exact( Ins(ProDStr) GenSuff )
       RC( WSep lemma_ends(
		{käyttäjä} |
		{kehittäjä} |
		{valmistaja} |
		{käyttö} |
		{käyttöehto} |
		{asetus} |
		{haavoittuvuus} |
		{lähdekoodi} |
		{sovellus} |
		{laitteisto} |
		{ominaisuus} |
		{versio} |
		{valikko} |
		{näyttö} |
		{näppäimistö} |
		{päivitys} |
		{akku} |
		{näppäin} |
		{kuvake} |
		{yhteensopivuus} |
		{estäminen} |
		{suosio} |
		{suoritin} |
		{käyttöliittymä} ) ) ;

!* "[asentaa/poistaa] WhatsApp"
Define ProDisamb4
       LC( lemma_exact( {asentaa} | {poistaa} | {julkaista} ) WSep ( PosAdv WSep ) )
       wordform_exact( Ins(ProDStr) [ NomSuff | GenSuff ] ) ;

!* "[käyttää/asentaa/hyödyntää/päivittää] Facebookia"
Define ProDisamb5
       LC( lemma_exact( {käyttää} | {asentaa} | {ladata} | {hyödyntää} | {kehittää} | {päivittää} | {poistaa} ) WSep ( PosAdv WSep ) )
       wordform_exact( Ins(ProDStr) ParSuff ) ;

!* "Facebookia [käyttävien]"
Define ProDisamb6
       wordform_exact( Ins(ProDStr) ParSuff )
       RC( WSep ( PosAdv WSep ) wordform_exact( [ {käyttäv} | {asentav} | {hyödyntäv} | {kehittäv} ] Alpha+ ) ) ;

Define ProCapture
       [ ProCpt01 | ProCpt02 | ProCpt03
       | ProCpt04 | ProCpt06 | ProCptV01 | ProCptV02
       | ProCptA  | ProCptB  | ProCptC   | ProCptD
       | ProCptE  | ProCptF  | ProCptG ] FinSuff FSep Word ;

Define ProCollocSg
       [ CapMisc WSep ( NumWord WSep ) ]*
       [ CapNameGenNSB | AlphaUp PropGen ]
       RC( ( WSep morphtag({ADJECTIVE}) )
	   WSep [ ? - [ Dash | AlphaUp ] ] lemma_morph(
       	   {sammuttaminen} |
	   {kaatuminen} |
	   {asennus} |
	   {asentaminen} |
	   {valmistaja} |
	   {akku} |
	   {näyttö} |
	   {ruutu} |
	   {varuste} |
	   {näppäin} |
	   {yhteensopivuus} |
	   {anturi} |
	   {kamera} |
	   {laajenuus} |
	   {näppämistö} |
	   {tallennustila} |
	   {suoritin} |
	   {laitteisto} |
	   {prosessori} |
	   {haavoittuvuus} |
	   {lähdekoodi} |
	   {prototyyppi} |
	   {versio} |
	   {beta} |
	   {päivitys} |
	   {käyttöliittymä} |
	   {käyttöjärjestelmä} |
	   {kuvake} |
	   {käyttöehto} |
	   {valikko} |
	   {käyttäjä} |
	   {ylläpitäjä} |
	   {julkaisu} |
	   {lanseeraus} |
	   {julkistus} |
	   {julkaisija} |
	   {lisenssi} |
	   {hinta} |
	   {menekki} |
	   {myyntimäärä} |
	   {toimitusmäärä}, {NUM=SG}) ) ;

Define ProCollocPl
       [ CapMisc WSep ( NumWord WSep ) ]*
       [ CapNameGenNSB | AlphaUp PropGen ]
       RC( ( WSep morphtag({ADJECTIVE}) )
           WSep [ ? - [ Dash | AlphaUp ] ] lemma_morph(
	   {päivitys} |
	   {käyttöehto} |
	   {näppäin}
	   {varuste} |
	   {haavoittuvuus} |
	   {kuvake} |
	   {käyttäjä} |
	   {myyntimäärä} |
	   {toimitusmäärä}, {NUM=PL}) ) ;

Define ProQuotesAndYear
       InQuotes
       RC( WSep wordform_exact(LPar)
       WSep wordform_exact( ["1"|"2"] 0To9 0To9 0To9 ( Dash ( ["1"|"2"] 0To9 0To9 0To9 ) ) )
       ( WSep wordform_exact( Dash ) )
       WSep wordform_exact(RPar) ) ;

Define gazProdMWordNoCongr [
       m4_include(`gProdMWord.m4')
       ] ;

Define ProMiscMultiWord
       OptQuotes( Ins(gazProdMWordNoCongr)
       [ WSep [ CapMisc | CapNum | AcrNom ] ]*
       ( WSep [ CapName | NumWord ] ) )
       ( WSep DashExt Ins(ProType) ) ;

Define ProMiscPl
       inflect_pl( ProSeries | @txt"gProdVehicleModel.txt" | {Xperia} | {Nokia} | {Lumia} | {Tesla} ) ;

Define ProDefault
       inflect_sg( @txt"gStatPRO.txt" ) ;

!* Category HEAD
Define Product
       [ Ins(ProLaw)::0.00
       | Ins(ProAgreement)::0.00
       | Ins(ProAward)::0.25
       | Ins(ProVideoGame)::0.25
       | Ins(ProFilmTV)::0.25
       | Ins(ProLiterature)::0.25
       | Ins(ProVehicle)
       | Ins(ProProject)
       | Ins(ProMusic)
       | Ins(ProArtwork)
       | Ins(ProDrug)
       | Ins(ProMiscSuffixed)::0.25
       | Ins(ProMiscOther1A)::0.50
       | Ins(ProMiscOther1B)::0.50
       | Ins(ProMiscOther2A)::0.50
       | Ins(ProMiscOther2B)::0.50
       | Ins(ProMiscOther3)::0.75
       | Ins(ProMiscOther4)::0.75
       | Ins(ProMiscOther5)::0.75
       | Ins(ProMiscModel1A)::0.50
       | Ins(ProMiscModel1B)::0.50
       | Ins(ProMiscVersion1)::0.25
       | Ins(ProMiscVersion2)::0.25
       | Ins(ProMiscVersion3)::0.25
       | Ins(ProAppStore)::0.25
       | Ins(ProMiscPl)::0.50
       | Ins(ProCollocSg)::0.95
       | Ins(ProCollocPl)::0.95
       | Ins(ProDisamb1)::0.00
       | Ins(ProDisamb2)::0.00
       | Ins(ProDisamb3)::0.00
       | Ins(ProDisamb4)::0.00
       | Ins(ProDisamb5)::0.00
       | Ins(ProDisamb6)::0.00
       | Ins(ProDefault)::0.25
       | Ins(ProMiscMultiWord)::0.20
       | Ins(ProQuotesAndYear)::0.75
       | Ins(ProCapture)::0.90
       ] EndTag(EnamexProXxx) ;

!!----------------------------------------------------------------------
!! TODO: Phenomena, weather (storms, hurricanes earthquakes)
!! 	 Winds (mistral, ?föhn)
!!----------------------------------------------------------------------

!!----------------------------------------------------------------------
!! <EnamexEvtXxx>: Events
!!----------------------------------------------------------------------

!* "Korean sota", "Krimin kriisi"
Define EvtCrisis
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_morph( {kriisi} | {vallankumous} | {kansannousu} | {vallankaappaus} , {NUM=SG}) ;

Define EvtConflict1
       [ lemma_exact( {toinen} | {ensimmäinen} | {kolmas} ) | wordform_exact( "I" | {II} | {III} | {1.} | {2.} | {3.} ) ] WSep
       lemma_exact( {maailmansota} ) ;

Define EvtConflict2
       lemma_exact( [ {jatko} | {talvi} ] {sota} ) ;

!* "Falklandin sota", "Isänmaallinen sota"
Define EvtConflict3
       [ ( AlphaUp PropGeoGen WSep wordform_exact(Dash) WSep )
	 AlphaUp PropGeoGen EndTag(EnamexLocPpl2) | [ LC( NoSentBoundary ) AlphaUp PosAdj ] ] WSep
       lemma_exact_morph({sota}, {NUM=SG})
       NRC( WSep Word ( WSep Word ) ( WSep Word ) WSep wordform_exact( {vastaan} ) ) ;

Define EvtConflict4
       [ [ AlphaUp PropGeoGen | lemma_morph( DownCase(CountryName), {NUM=SG} Field {CASE=GEN}) ] EndTag(EnamexLocPpl2) | LC( NoSentBoundary ) AlphaUp PosAdj ] WSep
       lemma_exact_morph( [{sisällis}|{kansalais}|{vapaus}]{sota}, {NUM=SG}) ;

! "Xxx:n taistelu", "Xxx:n ensimmäinen meritaistelu"
Define EvtBattle
       ( CapMisc WSep )
       [ AlphaUp PropGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       ( lemma_exact( {toinen} | {ensimmäinen} | {kolmas} ) WSep )
       lemma_exact_morph( ({meri}) {taistelu} , {NUM=SG} )
       NRC( WSep Word ( WSep Word ) ( WSep Word ) WSep wordform_exact( {vastaan} ) ) ;

Define EvtEcumCouncil
       [ AlphaUp PropGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact( {toinen} | {ensimmäinen} | {kolmas} ) WSep
       ( lemma_exact( {ekumeeninen} ) WSep )
       lemma_exact( {kirkolliskokous} ) ;

! "Samettivallankumous"
Define EvtRevolution1
       LC( NoSentBoundary )
       AlphaUp lemma_exact( AlphaDown+ [ {vallankumous} | {kapina} ] ) ;

Define EvtRevolution2
       wordform_exact( OptCap( {helmikuun} | {lokakuun} ) ) EndTag(TimexTmeDat2) WSep
       lemma_exact( {vallankumous} ) ;

Define EvtType
       lemma_ends([ {tapahtuma} | {tilaisuus} | {tapaaminen} | {seminaari} | {gaala} | {konsertti} | {kilpailu} | {turnaus} | {kiertue}
       		  | {festivaali} | {festari} | {messu}("t") | {karnevaali} | {regatta} | {konferenssi} | {kongressi} | {näyttely}
		  | {biennaali} | {kurssi} | [{ilmasto}|{huippu}]{kokous} | {marssi} | {rieha} | {jamboree} ]) ;


Define EvtRockFestival
       LC( NoSentBoundary )
       AlphaUp lemma_exact( AlphaDown AlphaDown+ {rock} ) ;

!* "Pori Jazz -festivaali"
Define EvtSocial1
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ ( CapWord WSep ) ]*
       [ CapMisc WSep ]*
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt Ins(EvtType) ;

!* "Weekend-festivaali"
Define EvtSocial2
       [ LC( NoSentBoundary ) AlphaUp Ins(EvtType) ] |
       [ AlphaUp Field Dash Ins(EvtType) ] ;

Define EvtSocialQuoted
       InQuotes WSep
       DashExt Ins(EvtType) ;

!* "Tallinnan laulujuhlat", "Helsingin juhlaviikot"
!* NB: excluded "markkina(t)" for too many false alarms
Define EvtSocial3A
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       ( lemma_exact_morph( {kansainvälinen} | {valtakunnallinen}, {NUM=PL}) WSep )
       Alpha AlphaDown lemma_morph( AlphaDown+ [ {viikko} | {juhla} | {päivä} | {messu} | AlphaDown AlphaDown {ajo} | {festivaali} | {festari}
       	     		  	     | {tanssi} | {kisa} | {kilpailu} ("t") ] | {syysmarkkina} ("t") | {suurmarkkina} ("t"), {NUM=PL} ) ;

!* "[Turun] Silakkamarkkinat"
Define EvtSocial3C
       [ PropGeoGen WSep AlphaUp ] | [ LC( NoSentBoundary) AlphaUp ] 
       Alpha AlphaDown lemma_morph( AlphaDown+ [ {viikko} | {juhla} | {päivä} | {messu} | AlphaDown AlphaDown {ajo} | {juoksu}
       	     		  	     | {festivaali} | {festari}
       	     		  	     | {tanssi} | {kisa} | {markkina} ] ("t"), {NUM=PL} ) ;

!* "Tuomaan markkinat", "Xxx:n keskiaikaiset markkinat"
Define EvtSocial3D
       [ [ AlphaUp PropFirstGen | wordform_exact( {Tuomaan} | {Heikin} ) ]
       | [ PropGeoGen WSep lemma_exact_morph({keskiaikainen}, {NUM=PL}) ] ] WSep
       lemma_exact_morph( {markkina}, {NUM=PL} ) ;

Define EvtSocial3B
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_morph( {konferenssi} | {kongressi} | AlphaDown (Dash) {näyttely}, {NUM=SG} ) ;

Define EvtDate
       lemma_exact( [{19}|{20}|Apostr] 0To9 0To9 ) EndTag(TimexTmeDat2) ;

!* "Tokion olympialaiset"
Define EvtOlympics1
       ( CapMisc WSep )
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_morph( {olympialainen} | {olympialaiset} | {olympiakisa}("t") )
       ( WSep Ins(EvtDate) ) ;

Define EvtOlympics2
       wordform_exact( ["v"|"V"]{uoden} ) WSep
       lemma_exact( [{19}|{20}|Apostr] 0To9 0To9 ) EndTag(TimexTmeDat2) WSep
       lemma_morph( {olympialainen} | {olympialaiset} | {olympiakisa}("t") | {maailmannäyttely} ) ;

!* "Jalkapallon EM-kisat 2017"
Define EvtChampionships1
       lemma_morph( AlphaDown AlphaDown AlphaDown+, {NUM=SG} Field {CASE=GEN} ) WSep
       ( AlphaDown morphtag({CASE=GEN}) WSep )
       lemma_morph( AlphaDown+ Dash AlphaDown* [ {kilpailu}("t") | {kisa}("t") ], {NUM=PL} )
       ( WSep Ins(EvtDate) ) ;

Define EvtChampionships2
       wordform_exact( ["v"|"V"]{uoden} ) WSep
       lemma_exact( [{19}|{20}|Apostr] 0To9 0To9 ) EndTag(TimexTmeDat2) WSep
       ( AlphaDown morphtag({CASE=GEN}) WSep )
       lemma_morph( AlphaDown+ Dash AlphaDown* [ {kilpailu}("t") | {kisa}("t") ], {NUM=PL} ) ;

Define EvtChampionships3
       [[ AlphaDown lemma_morph( AlphaDown AlphaDown AlphaDown+, {NUM=SG} Field {CASE=GEN} ) ] - PropGen ]WSep
       [ wordform_exact( ["v"|"V"]{uoden} ) WSep Ins(EvtDate) WSep ]
       lemma_morph( AlphaDown+ Dash AlphaDown* [ {kilpailu}("t") | {kisa}("t") ], {NUM=PL} ) ;

Define EvtChampionships4
       AlphaUp lemma_exact([ {em} | {mm} ] Dash [ {kilpailu}("t") | {kisa}("t") ]) WSep
       Ins(EvtDate) ;

!* "Electronic Entertainment Expo 2017", "New York Fashion Week", "Golden Globe Awards"
Define EvtSocial4
       [ CapMisc WSep ]*
       CapWord WSep
       inflect_sg( {Festival}("s") | {Week}({end}) | {Celebration} | {Party}::0.50 | {Contest} | {Concert} | {Gala} |
       		   {Competition} | {Convention} | {Conference} | {Congress} | {Reunion} | {Awards} | {Parade} |
       		   {Expo} | {Exhibition} | {Fair} | {Ball}::0.25 | {Gathering} | {Show} | {Concert} | {Meeting} | {Summit} |
		   {Tournament} | {Championship}("s") | {Cup} | {Challenge} | {Marathon} | {Tour} | {Pride} | ! {Games}
		   {Jazz} | {Race} | {Biennal} | {Piknik} | {Picnic} | {Festivála} | {Ralli} )
       ( WSep Ins(EvtDate) )
       ( WSep Dash Ins(EvtType) ) ;

Define EvtSocial4B
       ( CapMisc WSep )
       CapWord WSep
       [ inflect_x2( {Open}, {Air} ) 
       | inflect_x2( {Film}, {Festival} )
       ] ;

Define EvtSocial4C
       [ CapNameGenNSB | PropGeoGen ] WSep
       "Y" lemma_exact( {yö} ) ;

Define EvtSocial5
       inflect_sg( AlphaUp Field [ {Con} | {Expo} | {Xpo} | {Cup} | {cup} | {games} ] ) ;

Define EvtGrandPrix1
       [ CapNameGen EndTag(EnamexLocPpl2) | CapMisc ] WSep
       wordform_exact({Grand}) WSep
       inflect_sg({Prix})
       ( WSep Ins(EvtDate) ) ;

Define EvtGrandPrix2
       [ CapNameGen EndTag(EnamexLocPpl2) | CapMisc ] WSep
       "GP" lemma_exact( {gp} ) ;

Define EvtSocial6
       inflect_sg( AlphaUp Field @txt"gEventSuff.txt" ) ;

Define EvtChampionsLeague1
       ( wordform_exact( AlphaUp AlphaUp+ ) WSep )
       wordform_exact( {Champions} ) WSep
       ( [ CapMisc | CapName ] WSep )
       inflect_sg( {League} ) ;

Define EvtChampionsLeague2
       AlphaUp ( NounGen WSep )
       lemma_exact({mestari} | {eurooppa}, {[CASE=GEN]}) WSep
       lemma_exact_morph({liiga}, {NUM=SG}) ;

Define EvtChampionsLeague3
       "E" lemma_exact( {eurooppa} Dash {liiga} ) ;

Define EvtSocialGaz
       [ m4_include(`gEventMisc.m4') ]
       ( DashExt Ins(EvtType) ) ;

Define EvtPrefixed
       wordform_exact( {Tour} ) WSep
       wordform_exact( {de} ) WSep
       CapName ;

Define EvtSemtag
       semtag({PROP=EVENT}) ;

!* Xxx:n osallistujat/yleisö/osallistumismaksu

! Category HEAD
Define Event
       [ Ins(EvtConflict1)::0.50
       | Ins(EvtConflict2)::0.30
       | Ins(EvtConflict3)::0.30
       | Ins(EvtConflict4)::0.30
       | Ins(EvtCrisis)::0.30
       | Ins(EvtBattle)::0.25
       | Ins(EvtEcumCouncil)::0.30
       | Ins(EvtRevolution1)::0.50
       | Ins(EvtRevolution2)::0.50
       | Ins(EvtRockFestival)::0.50
       | Ins(EvtSocial1)::0.50
       | Ins(EvtSocial2)::0.50
       | Ins(EvtSocialQuoted)::0.50
       | Ins(EvtSocial3A)::0.50
       | Ins(EvtSocial3B)::0.50
       | Ins(EvtSocial3C)::0.50
       | Ins(EvtSocial3D)::0.50
       | Ins(EvtOlympics1)::0.50
       | Ins(EvtOlympics2)::0.50
       | Ins(EvtChampionships1)::0.50
       | Ins(EvtChampionships2)::0.50
       | Ins(EvtChampionships3)::0.50
       | Ins(EvtChampionships4)::0.50
       | Ins(EvtSemtag)::0.75
       | OptQuotes(Ins(EvtSocial4)::0.25)
       | OptQuotes(Ins(EvtSocial4B)::0.25)
       | OptQuotes(Ins(EvtSocial4C)::0.30)
       | OptQuotes(Ins(EvtSocial5)::0.50)
       | OptQuotes(Ins(EvtSocial6)::0.50)
       | EvtGrandPrix1::0.20
       | EvtGrandPrix2::0.20
       | OptQuotes(Ins(EvtPrefixed)::0.20)
       | OptQuotes(Ins(EvtChampionsLeague1)::0.50)
       | Ins(EvtChampionsLeague2)::0.50
       | Ins(EvtChampionsLeague3)::0.25
       | OptQuotes(Ins(EvtSocialGaz)::0.50)
       ] EndTag(EnamexEvtXxx) ;

!!----------------------------------------------------------------------
!! <TimexTmeDat>: Dates
!!----------------------------------------------------------------------

Define YearNum [ 1To9 0To9 0To9 0To9 ] ;
Define Year wordform_exact( YearNum (".") ) ;
Define YearAny wordform_exact( 1To9 0To9 0To9 (0To9) (".") ) ;
Define ProbYearNum [ {18} | {19} | {20} ] 0To9 0To9 ;
Define ProbYear wordform_exact( ProbYearNum (".") ) ;
Define MonthAbbr OptCap( MonthPfx {k.} ) ;
Define MonthName OptCap( MonthPfx {kuu} ) ;
Define DayStr DayNum ( ( "." ) Dash DayNum ) "." ;
Define Day [ wordform_exact( DayStr ) | PosNumOrd ] ;
Define MonthRange OptCap( MonthPfx Dash MonthPfx "k"["."|{uu}] ) ;
Define Paiva [ {päivä} | {p.} | {pvä} (".") | {pnä} (".") | "p" ] ;
Define Era wordform_exact( {jaa.} | {eaa}(".") | ["j"|"e"]["k"|"K"] "r" (".") | {AD} ) ; 

Define DayAndDay
       [ Day WSep wordform_exact( {ja} | Dash ) WSep Day ] |
       [ lemma_exact({sekä}) WSep Day WSep lemma_exact({että}) WSep Day ] ;

Define OnDay
       [ Day | Ins(DayAndDay) | PosNumOrd | wordform_exact( 1To9+ {:n}["n"|"t"]"e" AlphaDown+ ) ] ( WSep lemma_exact( Paiva ) ) ;

Define YearAttr
       lemma_exact_morph({vuosi}, {CASE=GEN}) WSep YearAny WSep ;

Define InYear
       [ lemma_exact( {vuonna} | {vuosi} | {v.} ) | wordform_exact(["V"|"v"]{uoteen}) ] WSep YearAny ;

Define YearTrail
       WSep [ InYear | Year ] ;

! 2001 (muttei: 2001 kertaa)
Define InYearNum1
       LC( lemma_exact( AlphaDown* [
       	   {syksy} | {kevät} | {kesä} | {talvi} |
	   {kausi} | AlphaDown {vuosi} ] |
	   {syntyä} | {kuolla} | {perustaa} | {valmistua} |
	   {aikaisin}({taan}) | {myöhään} | {jo} |
	   {alkaa} | {päättyä} |
	   {joulu} | {vappu} | {juhannus} | {pääsiäinen} | {vuosimalli} | {synt.} | {s.} ) WSep )
       [ ProbYear | wordform_exact( [ "1" 1To9 | {20} ] 0To9 0To9 (".") ) ] ;

Define InYearNum2
       LC( lemma_exact( Field - {vuosi} ) WSep )
       ProbYear
       RC( WSep lemma_exact( {aika}({na}) | {loppu} | {alku} | {puoliväli} | {jälkeen} | {aikana} | {asti} | {mennessä} | {lähtien} |
       	   		     {alkaen} | {kisa}("t") | {saakka} | {kesä} | {kevät} | {syksy | {talvi} ) ) ;

Define InYearNum3
       NLC( lemma_exact( {yhteensä} | {vain} | {noin} | {tasan} | {täsmälleen} | {suunnilleen} | {jopa} | {kaikkiaan} | {alle} | {yli} |
       	    		 {miltei | {vajaa} ) WSep )
       wordform_exact( [ "1" 1To9 | {20} ] 0To9 1To9 (".") ) ;

Define InYearNum4
       ProbYear
       RC( WSep wordform_exact([ {rakennet} | {perustet} ] ("t")("u") AlphaDown* | {syntyn}[{yt}|"e"] AlphaDown* ) )  ;

Define InYearNum5
       LC( wordform_exact(Quote) WSep lemma_exact(LPar) WSep )
       wordform_exact( [ "1" 1To9 | {20} ] 0To9 0To9 )
       RC( WSep lemma_exact(RPar) ) ;

Define InYearEra
       ( lemma_exact( {vuonna} | {vuosi} | wordform_exact(["V"|"v"]{uoteen}) | {v.E} ) WSep )
       wordform_exact( [ 1To9 0To9 (0To9) (0To9) ( Dash 1To9 0To9 (0To9) (0To9) ) ] |
       		       [ 1To9 0To9 (0To9) { 000} ]
       		       ) WSep Era ;

Define InYearNum6
       NLC( lemma_exact( {yhteensä} | {noin} | {sunnilleen} | {tasan} | {täsmälleen} | {vain} | {jopa} | {kaikkiaan} | {alle} | {yli} |
       	    		 {miltei} | {vajaa} ) WSep )
       wordform_exact( [ {18} | {19} | {20} ] 1To9 "0" (".") )
       NRC( WSep morphtag( {[NUM=SG][CASE=PAR]} ) ) ;

Define InYearNum
       [ InYearNum1
       | InYearNum2
       | InYearNum3
       | InYearNum4
       | InYearNum5
       | InYearNum6
       | InYearEra
       ] ;

! 2016-10-09
Define YYYYMMDD
       wordform_exact( YearNum Dash MonthNum Dash DayNum ) |
       wordform_exact( YearNum "/" MonthNum "/" DayNum ) |
       [ wordform_exact( YearNum ) WSep Slash WSep
       	 wordform_exact( MonthNum ) WSep Slash WSep
	 wordform_exact( DayNum ) ] ;

! 1.10.2016
! 1.-8.10.2016
! dd-dd.mm.yyyy
Define DDMMYYYY
       ( wordform_exact( DayStr ( MonthNum "." ) ) WSep
       wordform_exact( Dash ) WSep )
       wordform_exact( DayStr MonthNum "." ( YearNum (".") ) ) ;

Define DDMMYYYY2
       wordform_exact( DayStr ( MonthNum "." ( YearNum ) ) (" ") Dash (" ") DayStr MonthNum "." ( YearNum (".") ) ) ;

! 1. 10. 2016.
Define DD_MM_YYYY
       wordform_exact( DayStr ) WSep
       wordform_exact( MonthNum "." ) WSep
       wordform_exact( YearNum (".") ) ;

! tammikuussa, helmikuussa
! tammi-helmikuussa
Define InMonth
       ( YearAttr )
       ( wordform_exact( OptCap(MonthPfx) ) WSep wordform_exact(Dash) WSep )
       wordform_exact( [ MonthName | MonthRange ] ( "n" | {lta} | {sta} | {ssa} | {hun} | {lle} | {lta} | {lla} | {ta} | {ksi} ) )
       ( YearTrail ) ;

! tammikuun 1.
! tammikuun 1. päivänä
! tammikuun 1. päivään
Define FullDate1
       wordform_exact( MonthName "n" | MonthAbbr ) WSep OnDay ( YearTrail ) ;

! 1. tammikuuta
! 1. päivä tammikuuta
Define FullDate2
       OnDay WSep wordform_exact( MonthName {ta} )
       ( YearTrail ) ;

Define FullDate
       [ Ins(FullDate1) | Ins(FullDate2) ] ;

Define DateRange1A
       [ Ins(FullDate) | Ins(InYearNum) | OnDay ] WSep wordform_exact(Dash) WSep [ Ins(FullDate) | OnDay ]
       ( WSep ( AlphaDown Word WSep ) wordform_exact( {aikana} | {välillä} ) ) ;

Define DateRange1B
       [ Ins(FullDate) | Ins(InYearNum) | OnDay ] WSep wordform_exact({ja}) WSep [ Ins(FullDate) ] WSep
       ( AlphaDown Word WSep ) wordform_exact( {aikana} | {välillä} ) ;

Define DateRange2
       ( wordform_exact( ["a"|"A"]{lkaen} ) WSep )
       [ Ins(FullDate) | OnDay ] WSep
       ( wordform_exact( {päivästä} ) WSep )
       ( wordform_exact( {lähtien} | {alkaen} | {asti} ) WSep )
       ( Word WSep )
       [ Ins(FullDate) | OnDay ] WSep
       ( wordform_exact( {päivään} ) WSep )
       wordform_exact( {asti} | {mennessä} | {saakka} | {päivään} | {aikana} | {välillä} ) ;

!Define DateRange3
!       Ins(FullDate) WSep Ins(FullDate) ;

Define MonthRange1
       InMonth WSep lemma_exact({ja}) WSep InMonth WSep
       ( AlphaDown Word WSep ) wordform_exact( {aikana} | {välillä} ) ;

! 2000 ja 2001
! 2000 - 2001
! vuosina 2000 ja 2001
! vuosina 2000 - 2001
Define Years
       [ Year WSep wordform_exact({ja} | Dash) WSep Year ] |
       [ wordform_exact( YearNum (" ") Dash (" ") YearNum (".") ) ] ;

Define ProbYears
       [ ProbYear WSep wordform_exact({ja} | Dash) WSep ProbYear ] |
       [ wordform_exact( ProbYearNum (" ") Dash (" ") ProbYearNum ) ] ;

Define YearRange1
       lemma_exact({vuosi}) WSep Ins(Years) ( WSep Era )
       ( WSep ( Word WSep) wordform_exact( {aikana} | {välillä} ) ) ;

Define YearRange2
       Ins(ProbYears) ( WSep Era )
       ( WSep ( Word WSep) wordform_exact( {aikana} | {välillä} ) ) ;

Define YearRange3
       lemma_exact({vuosi}, {CASE=ELA}) WSep Year
       ( WSep Era )
       ( WSep AlphaDown Word WSep )
       [ lemma_exact({vuosi}, {CASE=ILL}) | wordform_exact(["V"|"v"]{uoteen}) ] WSep Year
       ( WSep Era )
       ( WSep wordform_exact( {asti} | {mennessä} | {saakka} ) ) ;

Define YearRange4
       wordform_exact( OptCap({vuonna}|{vuosina}) ) WSep
       wordform_exact( 1To9 0To9 (0To9) (0To9) Dash 1To9 0To9 (0To9) (0To9) ) ;

Define Holiday1
       lemma_exact( {joulupäivä} ) WSep Year ;

Define Holiday2
       wordform_exact( OptCap({vuoden}) ) WSep Year WSep lemma_exact( {joulupäivä} ) ;

! Category HEAD
Define Date
       [ Ins(YYYYMMDD)
       | Ins(DDMMYYYY)
       | Ins(DDMMYYYY2)
       | Ins(DD_MM_YYYY)
       | Ins(InMonth)
       | Ins(InYear)
       | Ins(InYearNum)
       | Ins(FullDate)
       | Ins(DateRange1A) | Ins(DateRange1B)
       | Ins(DateRange2)
       | Ins(Years)
       | Ins(YearRange1)
       | Ins(YearRange2)
       | Ins(YearRange3)
       | Ins(YearRange4)
       | Ins(MonthRange1)
       | Ins(Holiday1)
       | Ins(Holiday2)
       ] EndTag(TimexTmeDat) ;

!!----------------------------------------------------------------------
!! <TimexTmeHrm>:Time/Hour
!!----------------------------------------------------------------------

!! Kello X (Yyy:n aikaa)
!! Kello X aamulla/iltapäivällä/illalla
!! HH:MM AM/PM
!! HH:MM:SS

Define THour [ [ ("0") | "1" ] 0To9 | "2" [ "0" | "1" | "2" | "3" ] ] ;
Define THourWord
       [ {yksi} | {kaksi} | {kolme} | {neljä} | {viisi} | {kuusi} | {seitsemän} | {kahdeksan} | {yhdeksän} | {kymmenen}
       | [{yksi}|{kaksi}]{toista} ] ;
Define TSpecial [ {puoliyö} | {keskiyö} | {puolipäivä} | {tasan} ] ;
Define TMinute [ "0" | "1" | "2" | "3" | "4" | "5" ] 0To9 ;

Define TimeAMPM
       lemma_exact_morph( [{ilta}|{aamu}]({päivä}), {[NUM=SG][CASE=ADE]} ) |
       wordform_exact( {AM} | {PM} ) ;

!* "Suomen aikaa", "paikallista aikaa"
Define TimeZoneCountry
       [ [ CapWord WSep ]* AlphaUp CaseGen EndTag(EnamexLocPpl2) | wordform_exact({paikallista}) ] WSep
       lemma_exact_morph( {aika}, {[NUM=SG][CASE=PAR]} ) ;

Define TimeZoneUTC
       wordform_exact( {UTC} | {GMT} ["+"|"-"|"±"] 0To9 Field ) ;

Define TimeZone [ Ins(TimeZoneUTC) | Ins(TimeZoneCountry) ] ;

!* "iltapäivällä", "AM"
Define TimeHHMM1
       wordform_exact( THour [ ":" | "." ] TMinute ( " " Dash " " THour [ ":" | "." ] TMinute ) )
       ( WSep Ins(TimeAMPM) ) ( WSep Ins(TimeZone) ) ;

Define TimeHHMM2
       wordform_exact( THour [ ":" | "." ] TMinute )
       ( WSep wordform_exact(Dash) WSep
       wordform_exact( THour [ ":" | "." ] TMinute ) )
       ( WSep Ins(TimeAMPM) ) ( WSep Ins(TimeZone) ) ;

Define TimeHHMM
       [ Ins(TimeHHMM1) | Ins(TimeHHMM2) ] ;

Define TimeNoQualifier
       lemma_exact( THourWord | THour )
       ( WSep Ins(TimeAMPM) ) ( WSep Ins(TimeZone) ) ;

Define TimeCaseAndQualifier
       lemma_exact_morph( THourWord, {CASE=}[{PAR}|{ILL}|{INE}|{ELA}|{ABL}|{TRA}] ) WSep
       Ins(TimeAMPM) ( WSep Ins(TimeZone) ) ;
       
Define TimePastTo
       [
       [ lemma_exact_morph( {vartti}, {[NUM=SG][CASE=PAR]} )
       | morphtag_exact( {[POS=NUMERAL][SUBCAT=CARD]}({[NUM=SG][CASE=]}[{NOM}|{PAR}|{GEN}] ?)) ] WSep 
       lemma_exact( {vaille} | {yli} ) |
       lemma_exact( {puoli} )
       ] WSep
       [ TimeNoQualifier | lemma_exact( TSpecial ) ] ;

Define TimeOClock
       wordform_exact( ["k"|"K"][ {ello} | {l.} | {lo}(".") ] ) WSep
       [ Ins(TimePastTo) | Ins(TimeHHMM) | Ins(TimeNoQualifier) ] ;

Define TimeColloc
       LC( lemma_exact({kello}) WSep lemma_morph( {olla} | {lyödä} | {tulla}, {POS=VERB} ) WSep )
       wordform_exact( THourWord | THour ) ;

Define TimeClock
       [ Ins(TimeOClock)
       | Ins(TimePastTo)
       | Ins(TimeCaseAndQualifier)
       | Ins(TimeHHMM)
       | Ins(TimeColloc)
       ] EndTag(TimexTmeHrm) ;

!!----------------------------------------------------------------------
!! <NumexMsrCur>
!! 1) A number followed by a currency word/symbol
!! 2) A number expression followed by a financial term implying money amount
!!----------------------------------------------------------------------

Define CurrencySymbol [ "€" | "$" | "¥" | "£" | "₽" | "¢" | {mk} | {EUR} | {USD} | {JPY} ] ;
Define Currency [ Ins(AlphaDown) morphorsemtag({CURRENCY})
       		| (PropGeoGen EndTag(EnamexLocPpl2) WSep) Ins(AlphaDown) lemma_exact( @txt"gCurrency.txt" )
       		| wordform_exact( CurrencySymbol ( ":" AlphaDown+ ) ) ] ;

Define MoneyAmount1
       ( lemma_exact({puoli}|{pari}|{muutama}) WSep )
       PosNumCard [ WSep LowercaseAlpha PosNumCard ]* WSep Currency ;

Define MoneyAmount2
       ( lemma_exact({puoli}|{pari}|{muutama}) WSep)
       PosNumCard [ WSep [ Alpha PosNumCard | lemma_exact( [{milj}|{mrd}](".") )]]
       RC( WSep lemma_ends({tulos} | {liikevaihto} | {voitto} | {tappio} | {korvaus} | {vahinko} | {palkkio}) ) ;

Define CurrencyExpr [ MoneyAmount1 | MoneyAmount2 ] EndTag(NumexMsrCur) ;

!!----------------------------------------------------------------------
!! <NumexMsrXxx>
!! A number followed by a measurement unit
!!----------------------------------------------------------------------

Define UnitSymbolSI
       ( "µ" | "m" | "c" | "d" | "h" | "k" | "M" | "G" | "T" | "P" )
       [ {m} | "s" | {g} | {W} | {B} | {Hz} | {°C} | {Pa} | {Ah} | {m²} | {m³} | {m2} | {m3} | {s²} | {s2} | "J" ] ;

Define UnitLiteralSI
       ( {neliö} | {kuutio} )
       ( {tsetto} | {jokto} | {piko} | {nano} | {mikro} | {milli} | {sentti} | {desi} |
       	 {deka} | {hehto} | {kilo} | {mega} | {giga} | {tera} | {peta} )
       [ {metri} | {gramma} | {watti} | {joule} | {hertsi} | {bitti} | {voltti} | {ampeeri} | {ampeeritunti} | {kandela} ] ;

Define UnitSymbol
       [ {ml} | {cl} | {dl} | "l" | {AU} | {mol} | {mph} | "K" | {rkl} | {tl} | "°" | UnitSymbolSI | {Mt} | {Gt} | {mm.}
       	 ("k"){cal} ] ;

Define UnitLiteral
       [ {mooli} | {kelvin} | {kalori} | {valovuosi} | {parsek}({ki}) | {peninkulma} | {maili} | {virsta} | {tuuma} | {jaardi}
       | {aste}({essa}) | {celsius} | {celsiusaste} | {fahrenheit} | {kelvinaste} | {radiaani} | {steradiaani} | {aari} | {hehtaari}
       | {pauna} | ({kilo}|{mega}|{giga}|{tera}|{peta}){tavu} | {sentti} | {milli} | {kilsa} | {mega} | {giga}
       | UnitLiteralSI ] ;

Define UnitPhrase
       [ ( wordform_exact( Ins(UnitSymbol) ) WSep wordform_exact("/") WSep ) wordform_exact( Ins(UnitSymbol) (":" AlphaDown+)) ] |
       [ lemma_exact( Ins(UnitLiteral) ) ( WSep wordform_ends( {tunnissa} | {sekunnissa} | {minuutissa} ) ) ] ;

Define MeasureUnitAcro
       morphorsemtag({[SUBCAT=ACRONYM]} NoWSep* {[SEM=MEASURE]}) ;

Define Multiply wordform_exact( "x" | "X" | "×" ) ;

!* NNN:n neliön asunto/pinta-ala/suurinen/kokoinen

!* 17°
!* Define LengthUSCustomary

Define NumFraction
       [ lemma_exact( 1To9 0To9* ["½"|"¼"] ) ] |
       [ lemma_exact( 1To9 0To9* ) WSep lemma_exact("½"|"¼") ] ;

Define MeasureExpr
       ( PosNumCard WSep Multiply WSep )
       ( [ PosNumCard | Ins(NumFraction) ] WSep [ Multiply | lemma_exact(Dash) ] WSep )
       [ PosNumCard | Ins(NumFraction) ] [ WSep LowercaseAlpha PosNumCard ]* WSep [ UnitPhrase | MeasureUnitAcro ]
       EndTag(NumexMsrXxx) ;   

!!----------------------------------------------------------------------
!! <Backoff>
!! Backoff rules: Default tagging for individiual words
!! based on superficial appearance.
!! Generally of poor accuracy (~60%), should be disabled during development.
!!----------------------------------------------------------------------

! "CamelCase" words are generally Organizations (unless they are products)
Define BackoffUpperCamelCase
       wordform_exact( AlphaUp+ AlphaDown AlphaUp Field )
       EndTag(EnamexOrgCrp) ;

! "camelCase" words are probably Products
Define BackoffLowerCamelCase
       wordform_exact( AlphaDown+ AlphaUp [ AlphaDown | AlphaUp | 0To9 ]+ )
       EndTag(EnamexProXxx) ;

! "001:xxx" are probably Products
Define BackoffNumWithColon
       wordform_exact( [ "0" | 0To9 0To9 ] 0To9+ 1To9 ":" FinSuff )
       EndTag(EnamexProXxx) ;

! Initialisms are probably Organizations
Define BackoffInitialism
       wordform_exact( AlphaUp AlphaUp+ ":" FinSuff )
       EndTag(EnamexOrgCrp) ;

! Capital letter followed by a string of numbers is probably a product
Define BackoffSerial
       wordform_exact( AlphaUp 0To9+ ( ":" FinSuff Field ) )
       EndTag(EnamexProXxx) ;

! Web domains are generally organizations
Define BackoffDomain
       inflect_sg( AlphaUp WebDomain )
       EndTag(EnamexOrgCrp) ;

! Capitalized Strings within quotes are generally products
Define BackoffQuoted
       LC( NoSentBoundary )
       SetQuotes(
       [ CapMisc WSep ]*
       CapName )
       NRC( WSep Dash AlphaDown )
       EndTag(EnamexProXxx) ;

Define BackoffTheXxx
       OptQuotes(
       wordform_exact( {The} | {From} | {Of} ) WSep
       ( [ CapMisc | wordform_exact( AlphaUp Field Apostr "s" ) ] WSep )
       ( ( CapWord WSep ) AndOfThe WSep ( CapMisc WSep ) )
       CapWord )
       RC( WSep [ ? - [ AlphaUp | Dash ] ] )
       EndTag(EnamexProXxx) ;

Define BackoffCapInternalLoc
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_morph( AlphaDown, {NUM=SG} Field {CASE=}[{ILL}|{INE}|{ELA}] )
       EndTag(EnamexLocXxx) ;

Define Backoff
       [ Ins(BackoffLowerCamelCase)::2.00
       | Ins(BackoffNumWithColon)::2.00
       | Ins(BackoffInitialism)::2.00
       | Ins(BackoffSerial)::2.00
       | Ins(BackoffDomain)::2.00
       !| Ins(BackoffQuoted)::2.00
       | Ins(BackoffTheXxx)::2.00
       !| Ins(BackoffCapInternalLoc)::2.00
       ] ;

!!----------------------------------------------------------------------
!! <Exceptions>: Words that shouldn't get tagged by other rules
!! (in phase 2 or by shorter matches in this rule set)
!!----------------------------------------------------------------------

Define OrdinalWord wordform_exact( 0To9 (0To9) (0To9) "." ) ;

Define ExceptKorko
       wordform_exact( {Korot} )
       RC( WSep lemma_ends( {nousu} | {lasku} | {nousta} | {laskea} | {painua} | {pysy} ({tell}) "ä" | {kasva} ({tt}) {aa} ) )
       EndTag(Exc001) ;

Define ExceptJosKun
       LC( SentBoundary | OrdinalWord WSep )
       wordform_exact( [{Jos} | {Sen} | {Liian} |{Mutta} | {Jotta} | {Kun} | {Toki} | {Joissakin} | {Myös} | {Heistä} | {Vaikka} |
       {Jopa} | {Jo} | {Luin}] ({pa}|{kin}) | {But} | {Perin} | {Perillä} | {Periltä} | {Perille} )
       EndTag(Exc002) ;

Define ExceptCommonNounPersName1
       LC( SentBoundary | OrdinalWord WSep )
       wordform_ends( [ {Aina} ({kin}) | {Lunasta} | {Meri} | {Ainoa} | {Mai}[{ssa}|{hin}|{sta}|{lle}|{lta}] | {Halpa} | {Alun} | {Jo} | {Alla} | {Ole}("n") | {Onne} ? | {Rauha} | {Toivo} | {Lintu} | {Alan} | {Portin} | {Hiljaa} | {Vappu} | {Anna}("n"|"t"|{mme}|{tte}) ] ({pa}|{kin}|{han}|{kaan}) | {Aku}["n"|{ssa}|{sta}] )
       EndTag(Exc003) ;

Define ExceptCommonNounPersName2
       LC( SentBoundary | OrdinalWord WSep )
       lemma_exact(
		{aina} ({kin}) | {alla} | {antaa} | {hiljaa} | {aarre} | {meri} | {saari} | {hoikka} | {levy} | {rannikko} | {tuuli} | {siru} | {voitto} | {taisto} | {arvo} |
		{myrsky} | {syksy} | {rauha} | {toivo}("a") | {jolla} | {lintu} | {lumi} | {vanha} | {lima} | {mäki} | {kallio} | {linna} | {eli} | {elää} | {aamu} |
		{meri} | {lahja} | {kukka} | {maili} | {mainio} | {oiva} | {mimmi} | {poika} | {pilvi} | {rauha} | {sade} | {säde} | {satu} | {syksy} | {usko} |
		{usva} | {vadelma} | {unelma} | {vilja} | {taisto} | {taimi} | {taika} | {ilta} | {into} | {junior} | {kaisla} | {kaari} | {suvi} | {tuuli} | {meri} |
		{vappu} | {taito} | {lukko} | {kärppä} | {ilves} | {mieli} | {miele} AlphaDown+ | {motti} | {mantere} | {manner} | {lehti} | {tästedes} | {vastedes} |
		{valo} | {toimi} | {kärki} | AlphaDown+ [{lainen}|{läinen}] | {aurinko} | {ankara} | {elastinen} | {kirkas} | {blondi} | {yö} | {mamba} | {elo} |
		{rajaton} | {onni} | {raptori} | {dingo} | {itä} | {länsi} | {rautatie} | {sisarus} | {asevoima}("t") | {kai} | {tehosekoitin} | {tuska} |
		{provinssi} | {suurlähettiläs} | {manifesti} | {paavius} | {naiivius} | {määrä} | {miina} | {ansa} | {alanko} | {media} | {kiista} | {vuori} | {laakso} | {tori} | {areena} | {flow} (Apostr) | {pitkä} | {kylä} | {merituuli} | {hovi} | {etelä} | {kuola} | Field {bisnes} | {erikseen} | {palava} | {urakka} | {siksi} | {sitä} | {nirvana} | {provinssi} | {luola} )
       EndTag(Exc003A) ;

Define ExceptMiesPoika
       LC( SentBoundary | OrdinalWord WSep )
       lemma_exact( {mies} | {he} | {liika} |{pian} | {lista} | {avain} | {joki} | {kohta} | {avata} | {se} | {senkin} | {olla} | {ainoa} | {poika} | {monet} | {moni} | {muu} | {jokin} | {jotta} | {ainakin} | {vanha} | {laina} | {ryhmä} | {jatkettu} | {linkki} | {internet} | {hakkeri} | {ainakaan} | {talo} | {tuleva} | {harva} | {tietty} | {miljoon}("a") | {oma} | {viisi} | {korke}("e") | {jakaa} | {metropoli} | {imago} | {varhaisteini} )
       EndTag(Exc004) ;

Define LangOrLoc @txt"gMiscLanguage.txt" ;

Define ExceptInLanguage
       lemma_exact_morph( Ins(LangOrLoc), {[NUM=SG][CASE=TRA]})
       EndTag(Exc004) ;

Define ExceptLanguage1
       lemma_exact_morph( Ins(LangOrLoc), {[NUM=SG]}[{[CASE=GEN]}|{[CASE=INE]}] ) WSep
       ( AlphaDown PosAdj WSep )
       lemma_exact( ({kirja}|{yleis}|{puhe}) {kieli} | {syntaksi} | {kielioppi} | {lauseoppi} | {ääntämys} | {äännejärjestelmä} |
       		    {sanajärjestys} | {ortografia} | {oikeinkirjoitus} | {essee} | {fonologia} | {sana} | Field {taivutus} |
		    Field {verbi} | {adjektiivi} | {sanaluokka} | {sijamuoto} | {kirjaimisto} | {kirjoitusjärjestelmä} )
      		    EndTag(Exc004) ;

Define ExceptLanguage2
       lemma_exact_morph( Ins(LangOrLoc), {[NUM=SG][CASE=PAR]})
       RC( [ WSep AuxVerb ]^{0,4}
       	     WSep lemma_exact_morph( {puhua} | {kirjoittaa} | {lukea} | {käyttää} | {lausua} | {ääntää} |
       	     	  	  	     {opettaa} | {opiskella} | {harjoitella} )) EndTag(Exc004) ;

Define ExceptLanguage3
       LowercaseAlpha lemma_exact_morph( Ins(LangOrLoc) )
       EndTag(Exc004) ;

Define ExceptNotTurkey
       wordform_exact( {Turkin} ) WSep
       lemma_exact( {hoito} | {hoitaminen} | {laatu} | {kiilto} | {väri} | {harjaus} | {harjaaminen} | {hiha} | {kunto} |
       		    {pituus} | {leikkaaminen} | {hoitaa} | {pesu} | {harjata} | {kasvu} | {trimmaus} | {väritys} | {hilseily}
		    {paksuus} | {likaisuus} | {kampaaminen} | {leikkuu} | {värjääminen} ) EndTag(Exc004) ;

!----------------

!* "TV-kanava", "Youtube-kanava"
Define ExceptChannel
       lemma_exact(
		[ {tv} | {youtube} ]
       		Dash [ {kanava} | {video} ] )
       EndTag(Exc005) ;

!* "Netflix-sarja", "Hollywood-elokuva" ≠ "Netflix-niminen sarja", "Hollywood-niminen elokuva"
Define ExceptFilm
       lemma_exact(
		["b"|"h"]{ollywood} Dash AlphaDown* [{elokuva}|{leffa}|{filmi}|{filmatisointi}|{sovitus}] |
       		[{netflix}|{tv}|{youtube}|{hbo}] Dash AlphaDown* [{sarja}|{elokuva}|{leffa}|{filmi}|{filmatisointi}|{sovitus}] |
       		{spotify-kappale}
       ) EndTag(Exc006) ;

!* "Android-puhelin" ≠ "Android-niminen puhelin"
Define ExceptOSDevice
       lemma_exact(
		[ {sailfish} | {android} | {windows} | {ios} | {ubuntu} | {symbian} | {linux} | {tizen} ]
       		Dash Field
		[ {laite} | {puhelin} | {kännykkä} | {kone} | {tabletti} | {palvelin} | {serveri} | {televisio} | {tv} |
		  {sovellus} | {versio} | {päivitys} | {ohjelma} | {kello} ])
       EndTag(Exc007) ;

!* "Xbox-peli", "Windows-sovellus"
Define ExceptDeviceSoftware
       lemma_exact(
		[ {xbox} | {playstation} | {nintendo} | {n64} | {wii} | {switch} | ("3"){ds} | Alpha+ [{phone}|{pad}] ]
       		Dash Field
		[ {peli} | {sovellus} | {päivitys} | {ohjelma} ] )
       EndTag(Exc014) ;

!* "Firefox-sovellukset", "Xbox-pelit"
Define ExceptBrowserApps
       lemma_morph(
		Field Dash Field [ {sovellus} | {ohjelma} | {peli} | {päivitys} | {haku} | {palvelu} | {kauppa} ], {NUM=PL} )
       EndTag(Exc008) ;
	
!* "Facebook-puhelin" ≠ "Facebook-niminen puhelin"
Define ExceptBrowserDevice
       lemma_exact(
		[ {firefox} | {safari} | {explorer} | {chrome} | {opera} | {facebook} | {instagram} ]
		Dash Field [ {laite} | {puhelin} | {kännykkä} | {kone} | {tabletti} | {päivitys} ] )
       EndTag(Exc009) ;

!* "4G:n", "3G-verkko", "MP3-soitin", "Wlan-asema", "DVD-elokuva"
Define ExceptMisc
       [ 1To9 [ "g" | "G" ] | {4K} | {GSM} | {5K} | {HD} | {RnB} | {R&B} | {EDM} | {ATK} | {HIV} | {AIDS} | {Atk} | {IT} | {It} | {pH}
       | {WC} | {UV} | {AU} | {LSD} | {TV} | {Tv} | {LTE} | {LVI} | {BKT} | {MP3 } | {mp3} | {jp2} | {JPG} | {JP2} | {PNG} | {DJ} | {MC} | {GIF}
       | {SVG} | {XML} | {Xml} | {Https} | {SSH} | {PC} | {GUI} | {API} | ("X"){HTML}(1To9) | ("x"){html}(1To9) | {Dvd} | {DVD}
       | {VHS} | {Blu-ray} | ("J"|{MMO}){RPG} | {DIY} | {VPN} | {Web} | {Tdd} | {Wlan} | {Telnet} | {Internet} | {Televisio} 
       | [ {LGBT} | {HLBT} ] UppercaseAlpha* | {F1} | {F2} | {F3} | {Startup} | {LED} | {LP} | {GPS}
       | {Wi}(Dash)[{fi}|{Fi}] | {IoT} ] [ Dash | ":" ] Word
       EndTag(Exc010) ;

Define ExceptChampionship
       lemma_exact( [ {sm} | {em} | {mm} ] Dash AlphaDown* [ {kisa} | {kilpailu} | {sarja} | {ottelu} | {hopea} | {pronssi} | {kulta} | {mitali} ] ) EndTag(Exc010) ;

! "1024 x 860 -näyttö", "30 x 40 x 50"
Define ExceptDimensions
       ( NumNom WSep wordform_exact( "x" | "X" | "×" | {kertaa} ) WSep )
       NumNom WSep wordform_exact( "x" | "X" | "×" | {kertaa} ) WSep
       NumNom
       ( WSep Dash AlphaDown Word )
       EndTag(Exc013) ;

Define ExceptMiscMWord
       ( CapNameNomNSB WSep )
       ( Word WSep )
       Word WSep
       Dash lemma_ends( @txt"gMiscSuffixWord.txt" )
       EndTag(Exc012) ;

Define ExceptPicture
       ( Word WSep ) ( Word WSep )
       ( AlphaUp Field ) Dash lemma_exact( ( Field Dash ) {kuva} )
       EndTag(Exc013) ;

Define ExceptUnit
       ( NumNom WSep wordform_exact(Dash) WSep )
       NumNom WSep
       lemma_ends( {prosentti} | {miljoona} | {miljardi} )
       EndTag(Exc022) ;

Define ExceptNotYear
       wordform_exact( OptCap( {tänä} | {ensi} | {viime} | {edellisenä} | {kuluvana} | {seuraavana} | {tulevana} ) ) WSep
       lemma_exact( {vuonna} | {vuosi} ) WSep
       wordform_exact( 1To9 0To9+ ( Dash 1To9 0To9+ ) )
       EndTag(Exc023) ;

Define ExceptStorm
       lemma_exact_morph( {hurrikaani} | {hirmumyrsky} | {taifuuni} ) WSep
       CapName
       EndTag(Exc024) ;

!* Exclude dates that do not refer to a specific month (of a specific year)
Define ExceptNotDate
       LC( [ lemma_exact( {aina} | {yleensä} | {ennen} | {viettää} | {vuosittain} | {yleensä} | {tavallisesti} ) |
       wordform_exact( {vietetään} ) ] WSep )
       lemma_exact( MonthPfx {kuu} )
       EndTag(Exc025) ;

Define ExceptNotPlanetEarth
       LC( [ # | ".#." WSep | SentencePunct WSep | OrdinalWord WSep ] )
       wordform_exact( {Maan} ) WSep
       lemma_exact( {pääkaupunki} | {asukasluku} | {väkiluku} )
       EndTag(Exc026) ;

Define ExceptProductCommunity
       @txt"gStatPRO.txt" Dash lemma_ends( Dash [ {ryhmä} | {yhteisö} | {tiimi} | {projekti} ] ) ;


!* Category HEAD
Define Exceptions
       [ Ins(ExceptKorko)::0.00
       | Ins(ExceptJosKun)::0.00
       | Ins(ExceptCommonNounPersName1)::0.00
       | Ins(ExceptCommonNounPersName2)::0.00
       | Ins(ExceptMiesPoika)::0.00
       | Ins(ExceptChannel)::0.00
       | Ins(ExceptFilm)::0.00
       | Ins(ExceptOSDevice)::0.00
       | Ins(ExceptDeviceSoftware)::0.00
       | Ins(ExceptBrowserApps)::0.00
       | Ins(ExceptBrowserDevice)::0.00
       | Ins(ExceptMisc)::0.00
       | Ins(ExceptUnit)::0.00
       | Ins(ExceptChampionship)::0.00
       | Ins(ExceptLanguage1)::0.00
       | Ins(ExceptLanguage2)::0.00
       | Ins(ExceptLanguage3)::0.00
       | Ins(ExceptNotTurkey)::0.00
       | Ins(ExceptInLanguage)::0.00
       | Ins(ExceptMiscMWord)::0.00
       | Ins(ExceptPicture)::0.00
       | Ins(ExceptDimensions)::0.00
       | Ins(ExceptNotYear)::0.00
       | Ins(ExceptStorm)::0.00
       | Ins(ExceptNotDate)::0.00
       | Ins(ExceptNotPlanetEarth)::0.00
       | Ins(ExceptProductCommunity)::0.00
       ] ;

!!----------------------------------------------------------------------
!! TOP: Main entry of the recognizer
!!----------------------------------------------------------------------

Define TOP whole_word(`
       Ins(Person) |
       Ins(Organization) |
       Ins(Location) |
       Ins(Product) |
       Ins(Event) |
       Ins(Date) |
       Ins(TimeClock) |
       Ins(CurrencyExpr) |
       Ins(MeasureExpr) |
       Ins(Backoff) |
       Ins(Exceptions)') ;
