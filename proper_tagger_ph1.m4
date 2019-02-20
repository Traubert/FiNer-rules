!-*- coding: utf-8 -*-

! HFST Pmatch rules for recognizing Finnish named entities.
! The rules assume that input words are one per line and have five fields,
! separated by tabs: 1) wordform 2) lemma 3) morphological tags 4) proper/semantic tags 5) (empty) field for NER tags

!======================================================================
!==== Auxiliary definitions
!======================================================================

m4_include(`finer_defs.m4')

Define VehicleBrand [ m4_include(`gaz/gProdVehicleBrandStr.m4') ] ;

Define CorpOrPro @txt"gaz/gStatORGxPRO.txt" | Ins(VehicleBrand) ;
Define CorpOrLoc @txt"gaz/gStatLOCxORG.txt" ;
Define LocOrPer  @txt"gaz/gStatLOCxPER.txt" ;

Define VerbPer	 @txt"per-verbs.txt" ; ! Verbs for disambiguating people from other entities
Define VerbOrg	 @txt"org-verbs.txt" ; ! Verbs for disambiguating organizations from e.g. locations or products

Define PartyMemberAbbr lemma_exact( [ {kok} | {sit} | {r} | {rkp} | {sdp} | {sd} | {kd} | {vihr} | {skp} | {sin} |
       		       		      {ps} | {kom} | {kesk} | {p} | {skdl} | {lib} ] (".") | {vas} ) ;

Define GeoAdj    [ {pohjo} | {etelä} | {länt} | {itä} | {kesk} | {koill} | {kaakko} | {louna} | {luote} ] {inen} ;
Define GeoPfx	 [ {pohjois} | {etelä} | {itä} | {länsi} | {koillis} | {kaakkois} | {lounais} | {luoteis} |
                   {manner} | {sisä} | {meri} | {vähä} | {suur} | {ylä} | {keski} ] ;

Define DayNum	 [ ( "0" ) 1To9 | [ "1" | "2" ] 0To9 | {30} | {31} ] ;
Define MonthNum	 [ ( "0" ) 1To9 | {10} | {11} | {12} ] ;
Define MonthPfx	 [ {tammi} | {helmi} | {maalis} | {huhti} | {touko} | {kesä} |
       		   {heinä} | {elo} | {syys} | {loka} | {marras} | {joulu} ] ;

Define GeoNameForeign [ {berg} | {strand} | {wick} | {øy} | {å} | {holm} | {lund} ] ;
Define CountryName    DownCase( @txt"gaz/gLocCountry.txt" ) ;
Define NameInitial    wordform_exact( AlphaUp "." (AlphaUp ".") | {Th.} | {Fr.} ) ;

Define Color	 [ {valkoinen} | {musta} | {punainen} | {sininen} | {vihreä} | {keltainen} | {harmaa} |
       		   {hopeinen} | {värinen} | {sävyinen} ] ;

!!----------------------------------------------------------------------
!! <EnamexPrsAux>
!!----------------------------------------------------------------------

Define PersTitleStrNom    @txt"gaz/gPersTitleAbbr.txt" | {aviomies} | {isä} | {sisar} | {äiti} ;
Define PersTitleStr 	  [ Field [ @txt"gaz/gPersTitle.txt" ]
       			  - [ Field [ {digiassistentti} | {digiavustaja} | {markkinajohtaja} |
			      	      {järjestelmätoimittaja} | {laitetoimittaja} | {syöjätär} ]] ] ;

!* Do not use Ins() here!
Define PersTitle    lemma_exact_morph( PersTitleStr, {NUM=SG}) ;
Define PersTitleNom lemma_exact_morph( PersTitleStr | PersTitleStrNom , {[NUM=SG][CASE=NOM]} ) ;

Define PersNameParticle
       wordform_exact( ( AlphaUp AlphaDown AlphaDown+ Dash )
       		       OptCap( [ {av} | {af} | {von} | {van} | {de} | {di} | {da} | {del} | {della} | {ibn} ]) |
		       {der} | {bint} | {bin} | "Ó" | {Vander} | {El} | {Al} |
		       {O} FSep Word WSep Apostr ) ;

Define SurnameSfxPatterns
       AlphaUp AlphaDown* [ @txt"gaz/gPersSurnameSuff.txt" ] ;

Define SurnamePfxPatterns
       [ [ {O} Apostr | {Fitz} | {Mc} | {Mac} |{bin-} | {al-} | {el-} | {ash-} | {Di} | {De} | {Le} ] AlphaUp |
       	 {Fitz} | {Vander} | {Adler} | {Öz} | {Rosen} | {Wester} | {Öster} | {Vester} | {Öfver} | {Silfver} |
	 {Mandel} ] AlphaDown+ ;

Define SurnameAffixed
       ( AlphaUp AlphaDown Field+ Dash ) [ SurnamePfxPatterns | SurnameSfxPatterns ] ( Dash AlphaUp AlphaDown Field ) ;

Define SurnameSuffixedFin
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact_morph( AlphaDown+
       [ {lainen} | {läinen} | {skanen} | {skinen} | {kainen} | {käinen} | 
       	 {kkanen} | {kkonen} | {kkönen} | {pponen} | {ppönen} | {ttönen} |
       	 {ttinen} | {ttunen} | {kkinen} | {kangas} | {lenius} | {nheimo} |
       	 {nsalo}  | {a-aho}  ]::0.05 , {NUM=SG} ) ;

Define PersonMultiPartMisc
       [ m4_include(`gaz/gPersMWord.m4') ] ;

Define PersonMultiPartFin
       [ m4_include(`gaz/gPersMWordFin.m4') ] ;

!!----------------------------------------------------------------------
!! <EnamexPrsHum>: Human persons
!!----------------------------------------------------------------------

Define SurnameFinnishStr @txt"gaz/gPersSurnameFinnish.txt" ;

Define SurnameFinnish
       [ Ins(SurnameSuffixedFin) ] |
       [ AlphaUp lemma_exact(DownCase(SurnameFinnishStr)) ] |
       [ wordform_exact( Ins(SurnameFinnishStr) ) ] ;

Define FirstnameFinnishStr
       DownCase(@txt"gaz/gPersFirstnameFinnish.txt") ;

Define FirstnameMiscStr
       expand_stems( @txt"gaz/gPersFirstnameMisc.txt" ) ;

Define WeightedPrefix
       AlphaUp AlphaDown+ Dash::0.20 ;

Define SurnameMiscStr
       @txt"gaz/gPersSurnameMisc.txt" ;

Define SurnameMisc
       ( Ins(WeightedPrefix) ) inflect_sg( Ins(SurnameMiscStr) ) ;

Define PersonFirstname
       ( Ins(WeightedPrefix) ) inflect_sg(Ins(FirstnameMiscStr)) |
       [ ( Ins(WeightedPrefix) ) AlphaUp AlphaDown+ FSep
       	   		       ( AlphaDown+ Dash ) Ins(FirstnameFinnishStr) FSep Field {NUM=SG} Word ] ;

Define PersonFirstnameNom
       ( Ins(WeightedPrefix) ) wordform_exact(Ins(FirstnameMiscStr)) |
       [ ( Ins(WeightedPrefix) ) AlphaUp AlphaDown+ FSep ( AlphaDown+ Dash ) Ins(FirstnameFinnishStr) FSep Field
       	 [{[NUM=SG][CASE=NOM]}|{POS=UNKNOWN}] Word ] ;

Define JrSr lemma_exact({jr.}|{sr.}) ;

Define GuessedSurnameA
       ( Ins(PersNameParticle) WSep ) Ins(PersNameParticle) WSep CapName ;

Define GuessedSurnameB
       inflect_sg( Ins(SurnameAffixed) ) ;

Define GuessedSurnameC
       inflect_sg( AlphaUp AlphaDown Field Ins(GeoNameForeign) ) ;

Define PersonSurnameNom
       ( Ins(WeightedPrefix) ) wordform_exact( Ins(SurnameMiscStr) ) ;

Define PersonSurname
       [ Ins(GuessedSurnameA)::0.20 | Ins(GuessedSurnameC)::0.10 | Ins(GuessedSurnameB)::0.20 |
       	 Ins(SurnameFinnish) | Ins(SurnameMisc) ] ;

Define PersonNickname SetQuotes( (AlphaDown) CapWord ( WSep CapWord ) ) ;

!!----------------------------------------------------------------------

Define PersonPrefixed1
       [ Ins(PersonFirstnameNom) WSep ]*
       Ins(PersonFirstnameNom)
       [ WSep NameInitial ]*
       ( WSep define( CapNameStr Capture(PerCptS1) FSep Word ) )
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
       PersonNickname WSep
       CapName ;

Define PersonPrefixed4
       [ wordform_exact( Ins(FirstnameMiscStr) ) WSep ]
       CapNameNom WSep
       [CapName - PropOrg] ;

Define PersonSuffixed1
       [ [ Ins(PersonFirstnameNom) | PropFirstNom ] WSep ]*
       ( CapMisc::0.10 WSep )
       [ NameInitial WSep ]*
       ( [ CapNameNom | CapMisc ] WSep PersonNickname WSep )
       ( Ins(PersonSurnameNom) WSep )
       Ins(PersonSurname)
       ( WSep JrSr )
       NRC( WSep Dash AlphaDown ) ;

Define PersonGazIsol
       [ Ins(PersonFirstname) | Ins(PersonSurname) ]
       NRC( WSep [ Dash | AlphaUp ] AlphaDown ) ;

Define OnlyPropFirstLast
       AlphaUp morphtag_semtag_exact({[NUM=SG]}, [{[PROP=FIRST]}|{[PROP=LAST]}]+ ) ;

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
       [ AlphaUp AlphaDown PropFirstNom WSep ]
       [ NameInitial WSep ]*
       CapNameNom
       ( WSep [ PropFirst | PropLast ])
       NRC( WSep Dash AlphaDown ) ;

Define PersonSemtag3
       LC( NoSentBoundary )
       AlphaUp AlphaDown OnlyPropFirstLastNom
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

Define PersonSemtag6
       [ CapNameNomNSB | PropFirstNom ] WSep
       PropLast
       NRC( WSep Dash AlphaDown ) ;

! "Aleksanteri II", "Johannes Paavali II"
Define PersonMonarch
       [ [ AlphaUp PropFirstNom WSep | Ins(PersonFirstnameNom) WSep ]+ |
       	 [ LC( lemma_exact( {kuningas} | {keisari} | {kuningatar} | {keisarinna} | {hallitsija} | {paavi} | {piispa} |
	       		    {ruhtinas} | {herttua} ) WSep ) CapName WSep ] ]
       [ wordform_exact( NumRoman (":" Alpha Field ) ) |
       	 ( wordform_exact(NumRoman) WSep ) AlphaUp lemma_exact({suuri} | AlphaDown+ {npoika}) ] ;

!* "Fransiskus Assisilainen", "Katariina Suuri", "Iivana Julma", "Johannes Kastaja", "Vlad Seivästäjä"
!* "Elisabet Pyhä", "Pyhä Benedictus Nursialainen"
Define PersonEpithet
       ( "P" lemma_exact( {pyhä} ) WSep )
       [ AlphaUp PropFirstNom | Ins(PersonFirstnameNom) ] WSep
       AlphaUp [ morphtag({POS=ADJECTIVE} Field {NUM=SG}) |
       	       	 lemma_morph( ["a"|"i"]{ja}| ["ä"|"i"]{jä} | "l"["ä"|"a"]{inen} | {npoika} , {NUM=SG}) ] ;

! "Pyhä Birgitta"
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
       LC( lemma_exact_morph( ( Field Dash ) [ {nimimerkki} | {käyttäjä} ], {NUM=SG}) WSep )
       [ wordform_exact( "@" Field [ Alpha | 0To9 ] Field ) | Field CapWord | SetQuotes( Field AlphaUp Word ) ] ;

Define PersonGrecoRoman
       ( CapMisc WSep ( wordform_exact(NumRoman) WSep ) )
       inflect_sg( AlphaUp AlphaDown+ expand_stems( @txt"gaz/gPersGrecoRomanSfx.txt" ) ) ;

Define SurnameEastAsian
       wordform_exact( @txt"gaz/gPersSurnameEastAsian.txt" ) ;

!* Chinese, Korean and Vietnamese names of the form [Family Name] [Given Name]
Define PersonEastAsian1
       ( [ CapMisc::0.25 | Ins(SurnameEastAsian) ] WSep )
       inflect_sg( AlphaUp AlphaDown+ Dash OptCap( @txt"gaz/gPersGivenNameEastAsianSfx.txt" ) ) ;

Define PersonEastAsian2
       [ Ins(SurnameEastAsian) WSep ]+
       ( CapMisc WSep )
       CapName ;

!* Spanish and Portuguese multi-part names
Define PersonHispanicA
       [ PropFirstNom WSep ]*
       ( CapMisc WSep )
       [CapName - PropOrg] ;

Define PersonHispanicB
       [ PropFirstNom WSep ]*
       ( CapName WSep )
       DeLa WSep
       CapName ;

Define PersonHispanicC
       [ DeLa WSep | CapMisc WSep ]*
       CapName WSep
       wordform_exact( {y} | {e} ) WSep
       CapName ;

Define PersonHispanic
       [ wordform_exact( Ins(FirstnameMiscStr) ) WSep ]+
       [ Ins(PersonHispanicA) | Ins(PersonHispanicB) | Ins(PersonHispanicC)] ;

!!----------------------------------------------------------------------

Define PersonTitled1
       LC( PersTitleNom WSep )
       [ NameInitial WSep ]*
       ( [ define( CapNameNomStr Capture(PerCptF1) ) FSep Word::0.25 | CapMisc::0.30 | PropFirstLastNom ] WSep )
       ( define( CapNameStr Capture(PerCptF2) ) FSep Word::0.10 WSep [ DeLa | NameInitial ] WSep )
       [ ( PropFirstLastNom WSep ) define( CapNameStr Capture(PerCptS2) ) FSep Word::0.25 |
       	 define( CapNameNomStr Capture(PerCptS3) ) FSep Word::0.25 ( WSep PropFirstLast ) ] ;

Define PersonTitled2
       LC( PersTitleNom WSep )
       [ wordform_exact( "@" Alpha+ ) | Field CapWord::0.90 | AlphaUp lemma_exact( DownCase(LocOrPer) )::0.25 |
       	 PropFirstLast::0.25 ] ;

Define PersonTitled3
       LC( PersTitle WSep )
       ( [ define( CapNameNomStr Capture(PerCptF3) ) FSep Word::0.25 | CapMisc::0.30 | PropFirstLastNom ] WSep )
       [ NameInitial WSep ]*
       [ define( CapNameStr Capture(PerCptS4) ) FSep Word::0.25 | PropFirstLast ] ;

Define PersonTitled4
       LC( PersTitleNom WSep )
       [CapName - [PropOrg|PropGeo]] WSep
       [CapName - [PropOrg|PropGeo]] ;

Define PersonHyphen1
       [ CapMisc WSep ]*
       [ NameInitial WSep ]*
       ( CapMisc WSep )
       AlphaUp Field [ Word WSep | Dash {nimi} ] lemma_ends({niminen}) WSep
       [ Ins(PersTitle) | lemma_exact( AlphaDown* [ {henkilö} | {asiakas} | {käyttäjä} | {nainen} | {mies} |
       	 		  	       {poika} | {tyttö} ]) ] ;

!!----------------------------------------------------------------------

Define PersonAliasPrefixed
       wordform_exact( {DJ} | {Mr.} | {Dr.} | {Dr} | {Mr} | {MC} ) WSep
       ( CapMisc WSep )
       wordform_exact( Field AlphaUp Field Capture(PerCptX1) ) ;

!* Xxx [, 76, kertoo...]
Define PersonWithAge
       ( CapMisc WSep )
       wordform_exact( CapNameStr Capture(PerCptS3) )
       RC( WSep lemma_exact(Comma) WSep PosNum WSep lemma_exact(Comma) ) ;

Define PerCpt [ PerCptF1::0.80 | PerCptF2::0.80 | PerCptF3::0.80 | PerCptS1::0.40 |
       	      	PerCptS2::0.80 | PerCptS3::0.80 | PerCptS4::0.80 ] ;

Define PersonCaptured
       [ [ wordform_exact( PerCpt ) | PropFirstNom | PropLastNom ] WSep ]*
       inflect_sg( PerCpt | PerCptX1::0.40 ) ;

!* Xxx Xxx (sd)
Define PersonWithParty
       ( CapMisc WSep )
       CapName
       RC( WSep lemma_exact(LPar) WSep PartyMemberAbbr WSep lemma_exact(RPar) ) ;

Define HumanRelativeWord
       lemma_exact([ {puoliso} | {vaimo} | {avio}[{mies}|{puoliso}|{vaimo}] | {kihlattu} | {jalkavaimo} |
       		     {salarakas} | ({elämän}){kumppani} | {tytär} | {vauva} | {esikoinen} | {poika} |
		     {poikaystävä} | {tyttöystävä} | {naisystävä} | {miesystävä} | {ystävätär} |  
       		     [{pojan}|{tyttären}|{siskon}|{sisaren}|{veljen}][{poika}|{tytär}|{tyttö}] |
       		     ({iso}){isä} ({puoli}) | ({iso}){äiti} ({puoli}) | ({iso}|{pikku}){veli} ({puoli}) |
		     ({iso}|{pikku}){sisko} ({puoli}) | {sisar} ({puoli}) | ({pikku}){serkku} | {täti} |
		     {setä} | {eno} | {kummi} | {mumm}["i"|"o"|"u"] | {vaari} | {pa} ("a") {ppa} |
		     {sukulainen} | {perhe}({enjäsen}) | {rakastaja}({tar}) ]) ;

Define PersonIsRelative
       LC( wordform_ends( Vowel "n" ) WSep ( PosAdj WSep ) HumanRelativeWord WSep )
       ( CapMisc WSep )
       CapName ;

!* Raili-mummo, Tom-herra, Kaarle-kuningas, Juhana-herttua, Yukari-sensei
Define PersonHyphen2
       !LC( NoSentBoundary )
       AlphaUp AlphaDown+ Dash AlphaDown lemma_morph( {veli} | {sisko} | {täti} | {setä} | {vaari} | {ukki} |
       	       		       		 	      {mumm}["i"|"o"|"u"] | {mamma} | {pappa} | {poika} | {serkku} |
						      {herra} | {rouva} | {neiti} | {kuningas} | {herttua} |
						      {-san} | {-sensei} | {-sama} | {-chan}, {NUM=SG}) ;

! "Xxx [hengästyy]"
Define PersonAction1
       ( Ins(PersonFirstnameNom) WSep )
       ( [ CapNameNomNSB | PropFirstLastNom ] WSep )
       [ PropFirstLastNom::0.10 | CapMisc::0.30 ]
       RC( [ WSep AuxVerb ]* WSep lemma_exact_morph(VerbPer, {VOICE=ACT}) ) ;

! "[..., huomauttaa] Xxx"
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

!* Xxx kertoo
Define PersonAction3
       ( CapMisc WSep ) ( CapMisc WSep )
       [ NameInitial WSep ]*
       [ CapMisc | CapNameNSB::0.40 | CapWordNomNSB::0.55 ]
       RC( [ WSep AuxVerb ]* WSep lemma_exact_morph( VerbPer | {sanoa} | {kertoa} | {väittää} | {ehdottaa} |
       	     	  	     	  		     {kritisoida} | {pohtia} | {todeta} | {korostaa} | {valittaa} |
						     {luonnehtia}, {VOICE=ACT}) ) ;

!* Xxx:n vanhemmat
Define PersonWithRelative
       ( [ PropFirstNom ] WSep )
       [ NameInitial WSep ]*
       [ AlphaUp AlphaDown PropGen::0.40 | CapNameGenNSB::0.50 | PropFirstLastGen::0.10 ]
       RC( WSep [ HumanRelativeWord | lemma_exact_morph({vanhempi}|{vanhemmat}, {NUM=PL}) |
       	   	  lemma_exact_morph({vanha}, {CMP=CMP} Field {NUM=PL}) ] ) ;

!* Xxx:n hiukset
Define PersonWithFeature
       ( [ PropFirstNom ] WSep )
       [ NameInitial WSep ]*
       [ AlphaUp AlphaDown PropGen::0.40 | CapNameGenNSB::0.50 | PropFirstLastGen::0.10 ]
       RC( WSep lemma_ends( {sormi} | {kasvo} ("t") | {tukka} | {parta} | {hius} | {vatsa} | {korva} | {huuli} |
       	   		    {varvas} | {käsivarsi} | {kämmen} | {selkä} | {niska} | {päälaki} | {ruumis} |
			    {suku} Field | {elämä} | {luo}({kse}) | {luota} | {syntymäpäivä} | {hautakivi} |
			    {nauru} | {tokaisu} | {huudahdus} | {käytös} | {mieli} | {kotikylä} | {kotikaupunki} |
			    {seura}({ssa}) | {lapsuus} | {nuoruus} |
       	   		    {maalaus} | {sävellys} | {teos} | {romaani} | {novelli} | {kolumni} | {runo} | {elokuva} |
			    {keksintö} | {kotona} | {luona} | {kotiovi} | {asunto} | {lemmikki} | {kotieläin} |
			    {makuuhuone} | {työhuone} | {kuolinvuode} | {mausoleumi} | {kuolinpesä} | {työsopimus} |
			    {työpanos} | {työsuhde} ) ) ;
		!! NB: excluded "käsi" and "kirja" due to frequent methaphorical usage

!* Xxx:n seurassa
Define PersonWithPostposition1
       ( CapMisc WSep ) ( CapMisc WSep )
       [ NameInitial WSep ]*
       [ CapNameGenNSB::0.50 | PropGen::0.60 | PropFirstLastGen::0.20 |
       	 AlphaUp lemma_exact_morph( DownCase(LocOrPer), {CASE=GEN})::0.10 ]
       RC( WSep wordform_exact( {mielestä} | {seurassa} | {mukaan} | {kanssa} )) ;

!* Xxx:aa kohtaan
!Define PersonWithPostposition2
!       ( CapMisc WSep ) ( CapMisc WSep )
!       [ NameInitial WSep ]*
!       [ CapNameParNSB::0.50 | PropPar::0.50 | PropFirstLastPar::0.20 |
!         AlphaUp lemma_exact_morph( DownCase(LocOrPer), {CASE=PAR})::0.10 ]
!       RC( WSep wordform_exact( {kohtaan} )) ;

Define PersonWithPostposition
       [ PersonWithPostposition1 ] ; !| PersonWithPostposition2 ] ;

!* Xxx on kotoisin
Define PersonWithOrigins
       ( CapMisc WSep ) ( CapMisc WSep )
       [ NameInitial WSep ]*
       CapMisc
       RC( WSep lemma_exact({olla}) WSep ( PosAdv WSep ) wordform_ends( {syntynyt} | {syntyisin} | {kotoisin} | {syntyjään} ) ) ;

!* o.s. Xxx
Define PersonWithAlias
       LC( [ lemma_exact( {o.s.} | {alias} ) |
       	     wordform_exact({omaa}|{o.}) WSep wordform_exact({sukua}({an}|{nsa}) | {s.}) ] WSep )
       ( CapName WSep )
       [ CapName | Ins(PersonSurname) ] ;

!* Category HEAD
Define PersHuman
       [ Ins(PersonPrefixed1)::0.35
       | Ins(PersonPrefixed2)::0.37
       | Ins(PersonPrefixed3)::0.37
       | Ins(PersonPrefixed4)::0.37
       | Ins(PersonSuffixed1)::0.30
       | Ins(PersonGazIsol)::0.30
       | Ins(PersonSemtag1)::0.80
       | Ins(PersonSemtag2)::0.80
       | Ins(PersonSemtag3)::0.80
       | Ins(PersonSemtag4)::0.80
       | Ins(PersonSemtag5)::0.80
       | Ins(PersonSemtag6)::0.80
       | Ins(PersonEpithet)::0.25
       | Ins(PersonMonarch)::0.25
       | Ins(PersonSaint)::0.50
       | Ins(PersonChrist)::0.50
       | Ins(PersonAliasPrefixed)::0.30
       | Ins(PersonSurnameInitialism)::0.50
       | Ins(PersonUsername)::0.80
       | Ins(PersonGrecoRoman)::0.75
       | Ins(PersonEastAsian1)::0.75
       | Ins(PersonEastAsian2)::0.75
       | Ins(PersonHispanic)::0.50
       | Ins(PersonTitled1)::0.25
       | Ins(PersonTitled4)::0.80
       | Ins(PersonTitled2)::0.00
       | Ins(PersonTitled3)::0.25
       | Ins(PersonHyphen1)::0.50
       | Ins(PersonCaptured)::0.00
       | Ins(PersonWithAge)::0.50
       | Ins(PersonWithParty)::0.50
       | Ins(PersonIsRelative)::0.50
       | Ins(PersonHyphen2)::0.50
       | Ins(PersonAction1)::0.00
       | Ins(PersonAction2)::0.40
       | Ins(PersonAction3)::0.40
       | Ins(PersonWithRelative)
       | Ins(PersonWithFeature)
       | Ins(PersonWithPostposition)
       | Ins(PersonWithOrigins)::0.50
       | Ins(PersonWithAlias)::0.50
       | Ins(PersonMultiPartMisc)::0.00
       | Ins(PersonMultiPartFin)::0.00
       ] EndTag(EnamexPrsHum) ;

!!----------------------------------------------------------------------
!! <EnamexPrsAnm>:
!! Animals, ?mythical beasts (see also below)
!!----------------------------------------------------------------------

!* species, breed
Define AnimalType
       [ [ AlphaDown* [ @txt"gaz/gDogBreedSfx.txt" | {kissa} | {papukaija} | {kakadu} | {hevonen} | {poni} | {lisko} |
      		      	{lehmä} | {sonni} | {vasikka} | {lammas} ] ] - {tamponi} ] | {ori} | {ruuna} ;

Define AnimalOther
       AlphaDown* [ {koiras} | {naaras} | {uros} | {vasa} | {poikanen} | {pentu} ] ;

Define AnimalNameHyphen1
       AlphaUp AlphaDown+ Dash lemma_exact_sg( Field Dash Ins(AnimalType) )::0.20 ;

Define AnimalNameHyphen2
       ( CapMisc WSep )
       CapName WSep
       ( CapName WSep )
       DashExt lemma_exact_sg( (Dash) Ins(AnimalType) )::0.20 ;

Define AnimalNameHyphen3
       AlphaUp lemma_exact_sg( Field AlphaDown Dash {niminen} ) WSep
       lemma_exact_sg( Ins(AnimalType) | Ins(AnimalOther) ) ;

Define AnimalNameColloc1
       [ PropFirstLastGen::0.20 | PropGen::0.60 | CapNameGenNSB::0.60 ]
       RC( WSep [ [ AlphaDown lemma_ends( {turkki} | {pyrstö} | {häntä} | {tassu} | {käpälä} | {sorkka} | {kavio} |
       	   	    	      		  {kuono} | {poikanen} | {pentu} | {haukunta} | {nau'unta} | {naukuminen} |
					  {sarvi} | [{höyhen}|{sulka}] ({peite}) | {sulkasato} | {juoksuaika} |
					  {pesä} | {karsina} | {viserrys} | {poikue} | {ruokakuppi} | {vasa} |
					  {kaulapanta} ) ] - lemma_exact( {kuolinpesä} | {konkurssipesä} ) ] ) ;

Define AnimalNameColloc2
       [ CapMisc::0.60 | PropFirstLast::0.20 ]
       RC( [ WSep PosAdv | WSep AuxVerb ]*
       	     WSep lemma_exact_morph( {naukua} | {ammua} | {nelistää} | {naukaista} | {haukahtaa} | {vinkaista} |
	     	  		     {kehrätä} | {murista} | {ulvahtaa} | {kiekua} | {kiekaista} | {poikia} |
				     {varsoa}, {VOICE=ACT} ) ) ;

Define AnimalNameColloc3
       LC( lemma_exact_sg( AnimalType | AnimalOther ) WSep
       	   ( wordform_exact({nimeltä} ({än}|{nsä})) WSep ) )
       ( CapMisc::0.30 WSep )
       [ CapName::0.60 | PropFirstLast::0.20 ] ;

Define AnimalNameColloc4
       LC( lemma_exact_sg( {sekarotuinen} | {puhdasrotuinen} ) WSep )
       ( CapMisc::0.30 WSep )
       [ CapName::0.60 | PropFirstLast::0.20 ] ;

Define AnimalNameGaz1
       Lst(AlphaUp) lemma_exact( DownCase( {Heluna} | {Mansikki} | {Musti} | {Fifi} | {Asteri} | {Tessu} | {Peni} |
       		    		 	   {Ressu} | {Rekku} | {Turre} | {Muppe} ) )::0.20 ;

Define AnimalNameGaz2
       LC( NoSentBoundary )
       Lst(AlphaUp) lemma_exact_morph( DownCase( {Musti} | {Ystävä} | {Ruusu} | {Omena} | {Kielo} |
       		    		       		 {Kirjo} | {Lemmikki} ), {NUM=SG} )::0.30 ;

Define AnimalNameGaz3
       [ m4_include(`gaz/gAnimalBeast.m4') ] ;

Define AnimalName
       [ Ins(AnimalNameHyphen1)
       | Ins(AnimalNameHyphen2)
       | Ins(AnimalNameHyphen3)
       | Ins(AnimalNameColloc1)
       | Ins(AnimalNameColloc2)
       | Ins(AnimalNameColloc3)
       | Ins(AnimalNameGaz1)
       | Ins(AnimalNameGaz2)
       | Ins(AnimalNameGaz3)
       ] EndTag(EnamexPrsAnm) ;

!!----------------------------------------------------------------------
!! <EnamexPrsMyt>:
!! Deities, fictional and mythical beings
!! NB: May be limited to deities and spirits in the future
!!----------------------------------------------------------------------

Define PrsMytTentative DownCase( @txt"gaz/gTentativePrsMyt.txt" ) ;

Define PersMythType
       [ Field [ {jumala} | {jumalatar} | {kääpiö} | {hirviö} | {peikko} | {menninkäinen} | {maahinen} | {keiju} |
       	       	 {kääpiö} | {tonttu} | {lohikäärme} | {traakki} | {peto} | {olento} | {paholainen} | {velho} |
		 {noita} | {velhotar} | {vetehinen} | {syöjätär} | {hengetär} | {satyyri} | {avaruusolio} |
		 {kentauri} | {enkeli} | {demoni} ] ]
       - [ Field [ {kapeikko} | {älykääpiö} | {sanahirviö} | {herrajumala} ] ] ;

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
       LC( lemma_exact_morph(PersMythType, {NUM=SG}) WSep )
       [ ( CapMisc WSep )
       	 wordform_exact( CapNameStr Capture(PrsMytCpt3) )::0.50 | lemma_exact(PrsMytTentative)::0.10 ] ;

!* "[viisauden jumalatar] Xxx"
Define PersMythColloc1B
       LC( NounGen WSep lemma_exact_morph( AlphaDown* {jumala} | {jumalatar}, {NUM=SG} ) WSep )
       [ ( CapMisc WSep )
       	 wordform_exact( CapNameStr Capture(PrsMytCpt4) )::0.50 | lemma_exact(PrsMytTentative)::0.10 ] ;

Define PersMythColloc1 [ PersMythColloc1A | PersMythColloc1B ] ;

!* "Xxx:n [kultti/palvonta/ylipappi]"
Define PersMythColloc2
       ( CapMisc WSep )
       [ LC( NoSentBoundary) wordform_exact( CapNameStr Capture(PrsMytCpt5) Ins(GenSuff) )::0.50 | PropGen::0.55 |
       	 lemma_morph(PrsMytTentative, {CASE=GEN})::0.10 ]
       RC( WSep lemma_exact( Field [ {kultti} | {temppeli} | {ylipappi} | {pappi} | {papitar} | {profeetta} |
       	   		     	     {palvonta} | {palvominen} | {palvontameno}("t") | {kulttipaikka} |
				     {palvontapaikka} | {epiteetti}::0.10 | {kunniaksi}::0.10 | {symboli}::0.10 |
				     {tunnuseläin}::0.10 | {alttari}::0.10 | {jumaluus}::0.10 | {jumalallinen}::0.10]
				     ) ) ;

!* "[uhrata/pyhittää (xxx) ] Xxx:lle"
Define PersMythColloc3
       LC( lemma_exact( {uhrata} | {pyhittää} ) WSep
       ( [ CaseGen | CaseNom | CasePar ] WSep ) )
       [ [ CapMisc WSep ]*
       	 wordform_exact( AlphaUp AlphaDown Field Capture(PrsMytCpt6) SmartSep {lle} )::0.50 |
	 lemma_morph(PrsMytTentative, {CASE=ALL})::0.10 ] ;

!* "[uhri] Xxx:lle"
Define PersMythColloc4
       LC( lemma_morph( {uhri}({lahja}) | {rukous}, {CASE=}[{NOM}|{GEN}|{PAR}|{ESS}|{TRA}]) WSep )
       [ [ CapMisc WSep ]*
       	 wordform_exact( AlphaUp AlphaDown Field Capture(PrsMytCpt7) SmartSep {lle} )::0.50 |
	 lemma_morph(PrsMytTentative, {CASE=ALL})::0.10 ] ;

!* "[rukoilla] Xxx:ää"
Define PersMythColloc5
       LC( lemma_exact( {rukoilla} | {palvoa} ) WSep )
       [ ( CapMisc WSep ) ( CapMisc WSep )
       	 wordform_exact( AlphaUp AlphaDown Field Capture(PrsMytCpt8) Ins(ParSuff) )::0.50 |
	 lemma_morph(PrsMytTentative, {CASE=PAR})::0.10 ] ;

Define PersMythCaptured
       inflect_sg( PrsMytCpt1 | PrsMytCpt2 | [ PrsMytCpt3 | PrsMytCpt4 | PrsMytCpt5 | PrsMytCpt6 |
       		   PrsMytCpt7 | PrsMytCpt8 ] (AddI) ) ;

!* _Kaikki_ "Jumala"-sanan yksikölliset isolla alkukirjaimella kirjoitetut
! muodot tulkitaan erisnimiksi
Define PersMythAbrahamicGod
       "J" lemma_exact_sg({jumala}) ;

Define PersMythGaz
       [ m4_include(`gaz/gPersFictional.m4') ] ;

Define PersFictional
       [ Ins(PersMythHyphen1)::0.20
       | Ins(PersMythHyphen2)::0.20
       | Ins(PersMythColloc1)::0.00
       | Ins(PersMythColloc2)::0.00
       | Ins(PersMythColloc3)::0.00
       | Ins(PersMythColloc4)::0.00
       | Ins(PersMythColloc5)::0.00
       | Ins(PersMythCaptured)::0.60
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
!! - Words marked with GEO tag in morphology and internal locative case
!! - Virtually always LocPpl:s and therefore tagged as such
!!----------------------------------------------------------------------

!* Word in locative case marked as GEO
Define LocGeneral1
       [ PropGeoLocInt | PropGeoLocExt::0.50 ];

!* Word in genitive marked as GEO followed by a GEO in locative
Define LocGeneral2
       PropGeoGen
       RC( WSep PropGeoLocInt ) ;

!* Word only marked as GEO not in sentence-initial position
Define LocGeneral3
       [ LC( NoSentBoundary ) AlphaUp AlphaDown semtag_exact({[PROP=GEO]}) ] ;

!* Word only marked as GEO or FIRST/LAST not in sentence-initial position
Define LocGeneral4
       LC( NoSentBoundary ) AlphaUp AlphaDown semtag_exact( ({[PROP=LAST]}) {[PROP=GEO]} ({[PROP=LAST]}) ) ;


!* pohjoinen Xxx
Define LocGeneralPrefixed
       LC( lemma_ends( [{pohjo}|{etelä}|{länt}|{itä}|{koill}|{kaakko}|{louna}|{luote}|{kesk}] {inen} ) WSep )
       [ CapMisc WSep ]*
       CapName ;

!* Xxx:n eteläpuolella
Define LocGeneralColloc1
       [ CapMisc WSep ]*
       [ CapNameGenNSB::0.50 | PropGeoGen::0.30 | wordform_exact({Nokian}) ]
       RC( WSep lemma_exact([ {pohjois} | {etelä} | {itä} | {länsi} | {koillis} | {kaakkois} | {lounais} | {luoteis} ]
       	   		      [ {osa} | {pää} ({ty}) | {puoli} ({nen}) ] | {asutus} Field | {alue} | {asukas} ) ) ;

!* matkustaa Xxx:ään
Define LocGeneralColloc2
       LC( lemma_exact( Field [ {hyökätä} | {matkustaa} | {lentää} | {purjehtia} | {lähteä} | {saapua} | {muuttaa} |
       	   	       	      	{siirtyä} | {palata} | {levitä} | {soutaa} | {paeta} | {asettua} | {vetäytyä} |
		       		{lähettää} | {ratsastaa} | {hyökkäys} | {muutto} | {retki} | {kyyti} |
				{matka} | {reissu} | {takaisin} | {luota} | {luokse} | {luo} | {kotiin} | {kotoa} ] |
			{ajaa} | {isku} ) WSep
		       ( PosAdv WSep ) )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.50 | {nokia}::0.10 |
       DownCase(LocOrPer)::0.10 ], {CASE=ILL}|{CASE=ELA}|{CASE=ALL}|{CASE=ABL} ) ;

!* sijaita Xxx:ssä / koti Xxx:ssä
Define LocGeneralColloc3
       LC( lemma_exact( {asua} | {sijaita} | {opiskella} | {piileksiä} | {piileskellä} | {varttua} | {syntyä} |
       	   	       	{käydä} | {pysähtyä} | {asuinpaikka} | {asunto} | {koti} | {kotona} | {talo} | {piipahtaa} |
		       	{matkustaa} | {matkustella} | {vierailla} | {sotatoimi} | {luona} | {maanjäristys} ) WSep
       ( PosAdv WSep ) )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {CASE=INE}|{CASE=ADE} ) ;


!* Xxx:n Xxx Xxx:ssä
Define LocGeneralColloc4
       LC( morphtag_semtag({CASE=GEN}, {PROP=GEO}) WSep )
       [ CapMisc WSep ]*
       AlphaUp AlphaDown morphtag({CASE=}[{ILL}|{INE}|{ELA}]) ;

!* "Agincourtissa [ vuonna 1415 ]"
Define LocGeneralColloc5
       [ AlphaUp AlphaDown morphtag({CASE=INE})::0.75 | wordform_exact({Nokialla})::0.10 ]
       RC( ( WSep wordform_exact({vuonna}) )
       	   WSep wordform_exact( [ "1" 0To9 | {20} ] 0To9 0To9 (".") ) ) ;

!* Xxx:sta itään / Xxx:ltä pohjoiseen
Define LocGeneralColloc6
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {NUM=SG} Field [{CASE=ELA}|{CASE=ABL}])
       RC( WSep wordform_exact( {pohjoiseen} | {etelään} | {itään} | {länteen} | {koilliseen} | {kaakkoon} |
       	   			{luoteeseen} ) ) ;

!* pitkin Xxx:ää
Define LocGeneralColloc7
       LC( lemma_exact( {pitkin} | {ympäri} | {keskellä} ) WSep )
       AlphaUp AlphaDown lemma_exact_morph([ Field::0.75 | {nokia}::0.10 ], {CASE=PAR}) ;

!* Any proper name in internal locative case
Define LocGeneralBackoff
       wordform_morph(CapNameStr [Ins(IllSuff)|Ins(IneSuff)|Ins(ElaSuff)], {PROPER} Field {CASE=}[{ILL}|{INE}|{ELA}]) ;

! Category HEAD
Define LocGeneral
       [ Ins(LocGeneral1)::0.45
       | Ins(LocGeneral2)::0.45
       | Ins(LocGeneral3)::0.45
       | Ins(LocGeneral4)::0.45
       | Ins(LocGeneralPrefixed)::0.60
       | Ins(LocGeneralColloc1)::0.00
       | Ins(LocGeneralColloc2)::0.00
       | Ins(LocGeneralColloc3)::0.00
       | Ins(LocGeneralColloc4)::0.75
       | Ins(LocGeneralColloc5)::0.00
       | Ins(LocGeneralColloc6)::0.00
       | Ins(LocGeneralColloc7)::0.00
       | Ins(LocGeneralBackoff)::1.00
       ] EndTag(EnamexLocPpl) ;

!!----------------------------------------------------------------------
!! <EnamexLocAst>: Astronomical places
!!----------------------------------------------------------------------

Define ClstBody
       {Merkurius} | {Venus} | {Mars} | {Jupiter} | {Saturnus} | {Uranus} | {Neptunus} | {Pluto} |
       {Kepler} Dash 0To9+ Alpha+ | {Ceres} | {Ganymede} | {Vesta} | {Maapallo} | {Sedna} ;

!* "Maa", "Kuu", "Aurinko"
Define LocAst1
       LC( NoSentBoundary )
       UppercaseAlpha lemma_exact_morph( {maa} | {kuu} | {aurinko}, {NUM=SG}) ;

!* "Xxx-planeetta", "Xxxgalaksi", "Xxxsumu M27"
Define LocAst2
       LC( NoSentBoundary )
       [ UppercaseAlpha lemma_ends( Dash [ AlphaDown* {planeetta} | {tähti} | {asteroidi} | {komeetta} | {kuu} |
       	 			    	   {sumu} | {galaksi} | {tähtisumu} ] ) ] |
       [ UppercaseAlpha lemma_ends( AlphaDown AlphaDown AlphaDown+ [ {sumu}::0.25 | {galaksi} ] ) ( WSep Abbr ) ] ;

!* "136472 Makemake"
Define LocAst3
       wordform_exact( {13} 0To9 0To9 0To9 0To9 ) WSep CapWord ;

!* "Xxx:n [ilmakehä/kuu/kiertorata]
Define LocAstColloc1
       [ LC( NoSentBoundary ) wordform_exact( CapNameStr Capture(AstroCpt4) Ins(GenSuff)) |
       	 wordform_exact({Maan}) ]
       RC( WSep AlphaDown lemma_exact( {kuu} | {kiertolainen} | {sisarplaneetta} | {kiertorata} |
       	   		  	       {pyörähdysaika} | {kaasukehä} | {ilmakehä} | {keskilämpötila} ) ) ;

!* "Xxx:n [tähtikuvio/tähdistö]
Define LocAstColloc2
       [ LC( NoSentBoundary ) wordform_exact( CapNameStr Capture(AstroCpt5) Ins(GenSuff)) ]
       RC( WSep AlphaDown lemma_ends( {planeetta} | {galaksi} | {tähtikuvio} | {tähdistö} | {tähtisumu} |
       	   		  	      {aurinkokunta} ) ) ;

!* "[Yyy:n kuu] Xxx"
Define LocAstColloc3
       LC( lemma_exact({kuu}) WSep )
       CapName ;

!* eksoplaneetta Xxx:n
Define LocAstColloc4A
       LC( lemma_ends( {planeetta} | {asteroidi} | {komeetta} | {galaksi} | {tähtisumu} |
       	   	       {tähtikuvio} | {tähdistö} | {aurinkokunta} ) WSep )
       wordform_exact( Field AlphaUp Field Capture(AstroCpt1) ) ;

!* eksoplaneetta nimeltä Xxx
Define LocAstColloc4B
       LC( lemma_ends( {planeetta} | {asteroidi} | {komeetta} | {galaksi} | {tähtisumu} |
       	   	       {tähtikuvio} | {tähdistö} | {aurinkokunta} ) WSep
	   wordform_exact({nimeltä}) WSep )
       wordform_exact( Field AlphaUp Field Capture(AstroCpt2) ) ;

!* Xxx-niminen eksoplaneetta
Define LocAstHyphen1
       AlphaUp Field Capture(AstroCpt3) Dash lemma_ends( Dash {niminen} ) WSep
       AlphaDown lemma_ends( {planeetta} | {galaksi} | {tähtikuvio} | {tähdistö} | {tähtisumu} | {aurinkokunta} ) ;

Define LocAstGazMWordW
       wf_lemma_x2( {Pikku}, {karhu} ) |
       wf_lemma_x2( {Etelän}, {risti} ) |
       wf_lemma_x2( {Kuiperin}, {vyöhyke} ) |
       wf_lemma_x2( {Halleyn}, {komeetta} ) |
       wf_lemma_x2( {Lyyran}, {rengassumu} ) |
       wf_lemma_x2( {Andromedan}|{Kolmion}, {galaksi} ) |
       wf_lemma_x2( {Hillsin}|{Oortin}, {pilvi} ) ;

Define LocAstGazMWordL
       [ LC(NoSentBoundary) "I" lemma_sg_x2({iso}, {karhu}) ] |
       lemma_sg_x2( {hajanainen}, {kiekko} ) |
       lemma_sg_x2( {pieni}, {nostopainosumu} ) |
       lemma_exact_sg({pieni}) WSep wf_lemma_x2( {Jousimiehen}, {tähtipilvi} ) ;

Define LocAstCaptured
       inflect_sg( AstroCpt1::0.80 | AstroCpt2::0.10 | AstroCpt3::0.10 | [ AstroCpt4::0.60 | AstroCpt5::0.60 ] (AddI) ) ;

Define LocAstGaz1
       UppercaseAlpha lemma_exact( DownCase( ClstBody )) ;

Define LocAstGaz2
       UppercaseAlpha lemma_exact_morph( {linnunrata} | {aurinkokunta} | {andromeda} | {nostopainosumu}, {NUM=SG}) ;

Define LocAstGaz3
       inflect_sg( @txt"gaz/gLocAstCelestialBody.txt" | ClstBody ) ;

Define LocAstGaz
       [ Ins(LocAstGaz1) | Ins(LocAstGaz2) | Ins(LocAstGaz3) | Ins(LocAstGazMWordW) | Ins(LocAstGazMWordL) ] ;

! Category HEAD
Define LocAstro
       [ Ins(LocAst1)::0.20
       | Ins(LocAst2)::0.20
       | Ins(LocAst3)::0.30
       | Ins(LocAstHyphen1)::0.20
       | Ins(LocAstColloc1)::0.50
       | Ins(LocAstColloc2)::0.50
       | Ins(LocAstColloc3)::0.60
       | Ins(LocAstColloc4A)::0.80
       | Ins(LocAstColloc4B)::0.20
       | Ins(LocAstCaptured)::0.00
       | Ins(LocAstGaz)::0.20
       ] EndTag(EnamexLocAst) ;

!!----------------------------------------------------------------------
!! <EnamexLocGpl>: Geographical places
!!----------------------------------------------------------------------

Define GeoType [ ( AlphaDown+ | Field Dash )
       	       	 [ {joki} | {laakso} | {vuono} | {saari} | {rannikko} | {järvi} | {lahti} | {tunturi} | {vuori} |
		   {vaara} | {luoto} | {kumpu} | {lampi} | {lammi} | {luola} | {lompolo} | {suvanto} | {niittu} |
		   {niitty} | {kallio} | {korpi} | {mäki} | {koski} | {jäätikkö} | {vuoristo} | {saaristo} |
		   {geysir} |{ylänkö} | {kukkula} | {kraatteri} | {kraateri} | {kaldera} | {pohja} | {harju} |
		   {ranta} | Dash {virta} ] ] -
	         [ Field [ {seuranta} | {veranta} | {basaari} | {husaari} | {pessaari} | {janitsaari} | {kvasaari} |
		   	   {komissaari} | {peliluola} | {huumeluola} | {oopiumiluola} | {miesluola} | {pornoluola} ]
			   ] ;

!* Xxx Xxx -niminen saari
Define LocGeoHyphen1
       [ CapMisc WSep ]*
       ( CapName WSep )
       wordform_exact( CapNameStr Capture(GeoCpt1) ) WSep
       DashExt lemma_exact( (Dash) Ins(GeoType) ) ;

!* Xxx-saari
Define LocGeoHyphen2      
       AlphaUp AlphaDown Field Capture(GeoCpt4) Dash lemma_ends( Dash [ {vuori} | {saari} | {joki} | {järvi} |
       	       		       			     		      	{tunturi} ]) ;

!* "Saharan autiomaa", "Jukatanin niemimaa", "Yosemiten kansallispuisto"
Define LocGeoSuffixed1
       ( [ CapName WSep AndOfThe | CapMisc ] WSep )
       [ PropGen | CapNameGenNSB | PropGeoGen ] WSep
       lemma_exact_morph( {tasanko} | {niemimaa} | {aavikko} | {sademetsä} | {alanko} | {ylänkö} |
       			  [{erä}|{autio}]{maa} | {putous} | {massiivi} | {jäätikkö} | {ylänkö} |
			  [{kansallis}|{luonnon}]{puisto} | {luonnonsuojelualue} | {lintuvesi} |
			  {linnavuori} | {sola} | {tekojärvi} | {tekolampi} , {NUM=SG} ) ;

!* "Vienanmeri", "Pohjanlahti", "Hyväntoivoinniemi", "Harveynjärvi", "Tokoinranta", "Labradorinvirta"
Define LocGeoSuffixed2
       AlphaUp lemma_ends( "n" [ {meri} | {meressä} | {merellä} | {lahti} | {niemi} | {salmi} | {putous} |
       	       		       	 {järvi} | {ranta} | {koski} | {kangas} | {selkä} | {huippu} | {salo} | {mäki} |
				 {laakso} | {haara} | {virta} ] ) ;

!* Xxxsaari, Xxxmeri
Define LocGeoSuffixed3
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact( ( AlphaDown AlphaDown+ Dash ) [ Ins(GeoType) | {meri} ]) ;

!* Xxx Canyon, Xxx Mountains
Define LocGeoSuffixed4
       ( CapMisc WSep ) CapMisc WSep
       inflect_sg( {Otok} | {Lake}("s") | {Mountains} | {Glacier} | {Basin} | {Plain}("s") | {Grotto} | {Cave}("s") |
       		   {Cavern}("s") | {Volcano}({es}) | {River}::0.25 | {Creek} | {Canyon} | {Valley} | {Island}("s") |
		   {Gunto}("u") | {Guntō} | {Bay} | {Beach} | {Mesa} | {Vrh} | {Brdo} | {Vrelo} | {Izvor} | {Spring} |
		   {Ridge} | {Tuff}::0.25 | {Peak} | {Rock}("s")::0.25 | {Butte} | {Moors} | {Bluff} | {Riza} |
		   {Taung} | {Bum} | {Kyun} | {Lagoon} | {Char} | {ostrov} | {ostrvo} | {otok} ) ;

!* Aurajoki
Define LocGeoSuffixedRiver
       AlphaUp AlphaDown lemma_exact_morph( [ Field - [ Field [{lasku}|{lisä}|{pää}|{lohi}|{sivu}|{vesi}|{raja}]]] {joki},
       	       		 		    [ {NUM=SG} | {PARTICLE} ]) ;

!* Xxxoja (but only if marked as GEO)
Define LocGeoSuffixedBrook
       AlphaUp AlphaDown lemma_semtag( AlphaDown AlphaDown {oja}, {PROP=GEO}) ;

!* Xxxvuoret
Define LocGeoSuffixedMountain
       AlphaUp AlphaDown lemma_exact( [ Field AlphaDown [{vuori}|{vuoret}] ]
       	       		 	      - [ Field [ {linnavuori} | {betonivuori} | {pyykkivuori} | {tiskivuori} |
				      	  	  {jäävuori} | {tulivuori} | {lämpövuori} | {voivuori} | {välivuori} |
						  {kangasvuori} | {irtovuori} | {poimuvuori} | {pöytävuori} |
						  {viljavuori} | {fleecevuori} | {sisävuori | {jätevuori} ]]) ;

!* Xxx Xxx:n putoukset
Define LocGeoSuffixedFalls
       ( [ CapName WSep AndOfThe | CapMisc ] WSep )
       [ CapNameGenNSB | PropGen | PropGeoGen ] WSep
       lemma_exact_morph( {putous}, {NUM=PL} ) ;

!* Itä-Aasia, Pohjois- ja Etelä-Amerikka
Define LocGeoPrefixed1
       ( wordform_exact( OptCap( GeoPfx Dash ) ) WSep
       lemma_exact({ja}) WSep )
       wordform_exact( OptCap( GeoPfx Dash AlphaUp AlphaDown+ ) ) ;

! "Serra de Estrela"
Define LocGeoPrefixed2
       wordform_exact( {Mont} ("e") | {Mt.} | {Mount} | {Lake} | {Lago} | {Loch} | {Cerro} | {Sierra} | {Serra} |
       		       {Costa} | {Côte} | {Île}("s") | {Isla}("s") | {Ilha} | {Rio} | {Río} | {Pulau} | {Tesik} |
		       {Val}("l") | {Grotte} | {Grotto} | {Vrh} | {Brdo} | {Vrelo} | {Izvor} | {Jabal} | {Koh} |
		       {Ko} | {Char} | {Ostrov} | {Cape} | {Massif} | {Puy} | {Forêt} | {Quebrada} | {Cueva} |
		       {Gran} ) WSep
       ( DeLa WSep )
       [ CapName | CapMisc ] ;

!* Bahr al-Arab
Define LocGeoPrefixed3
       wordform_exact( {Baḩr} | {Bahr} | {Nahr} | {Umm} ) WSep
       ["a"|"e"]["s"|"l"|"z"|"n"] [ Dash | FSep Word WSep ]
       CapWord ;

!* Suuri Klimetskoinsaari, Iso Iiluoto, Pieni Vasikkasaari
!* Pikku Leikosaari, Pikku Huopalahti
Define LocGeoCircumfixed
       AlphaUp lemma_exact( {pikku} | {pieni} | {iso} | {suuri} ) WSep
       AlphaUp lemma_exact( AlphaDown+ [ {järvi} | {saari} | {luoto} | {lammi} | {lahti} ] ) ;

!* Xxxsbirge, Xxxfjärd, Xxxvík
Define LocGeoGuessed
       inflect_sg( AlphaUp AlphaDown+ @txt"gaz/gLocGeoSfx.txt" ) ;

!* Xxxvuoret, Xxxsaaret
Define LocGeoGuessedPl
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact_morph( AlphaDown AlphaDown+ (Dash) [ {vuori} | {saari} | {saaret} ], {NUM=PL} ) ;

!* Xxx National Park
Define LocGeoNationalPark1
       [ CapMisc WSep ]+
       inflect_x2({National}, {Park}) ;

!* Parc national de Xxxx
Define LocGeoNationalPark2
       wordform_x2({Parc}, OptCap( {national}("e") | {naturel} )) WSep
       ( CapMisc WSep )
       ( DeLa WSep )
       CapName ;

!* "Atlantin valtameri"
Define LocGeoOcean1
       [ {Tyyn} | {Intian} | {Atlan} ] Word WSep
       lemma_exact( {valtameri} ) ;

!* "Tyynenmeren", "Alantti"
Define LocGeoOcean2
       UppercaseAlpha lemma_exact( [ {tyyn} AlphaDown+ | {punai} AlphaDown+ | {väli} | {etelä} | {koralli} |
       		      		     {musta} | {itä} | {jää} | {perä} ] {meri} | (Ins(GeoPfx) Dash) {atlantti} ) ;

!* "Pohjoinen jäämeri"
Define LocGeoOcean3
       lemma_exact( {pohjoinen} | {eteläinen} ) WSep
       lemma_exact( {jäämeri} ) ;

!* Itä-Kiinan meri
Define LocGeoOcean4
       wordform_exact( [{Etelä}|{Itä}] Dash {Kiinan} ) WSep
       lemma_exact( {meri} ) ;       

!* Mariaanien hauta
Define LocGeoOceanTrench
       wordform_exact( {Caymanin} | {Mariaanien} | {Syvänmeren} | {Filippiinien} | {Kalypson} | {Kermadecin} |
       		       {Romanchen} | {Uuden-Britannian} ) EndTag(EnamexLocGpl2) WSep
       lemma_exact( {hauta} | {syvänne} ) ;

!* Golfvirta
Define LocGeoOceanCurrent1
       lemma_exact( {golfvirta} ) ;

!* Pohjois-Atlantin merivirta
Define LocGeoOceanCurrent2
       wordform_exact( {Länsituulten} | {Itä-Australian} | {Länsi-Australian} | {Itä-Grönlannin} |
       		       {Päiväntasaajan} | {Pohjois-Atlantin} ) WSep
       lemma_exact_morph( ({meri}) {virta}, {NUM=SG} ) ; 

!* "Amazonin [suisto]", "Hispaniolan [saari]"
Define LocGeoColloc1
       [ LC(NoSentBoundary) wordform_exact( CapNameStr Capture(GeoCpt2) Ins(GenSuff) )::0.50 |
       	 wordform_morph( CapNameStr Capture(GeoCpt3) Ins(GenSuff), {PROPER} )::0.50 |
       	 PropGeoGen::0.30 | wordform_exact({Amazonin}) ]
       RC( WSep AlphaDown lemma_exact( [ AlphaDown* [ {ranta} | {virtaus} | {valuma-alue} | {suisto}({alue}) | {uoma} |
       	   		  	       	 	      {luola} | {laakso} | {joki} | {vuoristo} | {vuori} | {saari} |
						      {niemi} | {saaristo} | {rannikko} | {metsä} | {laguuni} |
						      {rinne} | {jyrkänne} | {atolli} | {kasvillisuus} | {eläimistö} |
						      {ilmasto} | {kraatteri} | {kraateri} ] | {aro} | {ruohoaro} ]
					- [ Field [ {seuranta} | {veranta} | ["t"|"l"|"j"|"s"]{uoma} | {perinne} ] ] )
					) ;

Define gazLocGeoRegion     @txt"gaz/gLocGeoRegion.txt" ;
Define gazLocGeoIsland     @txt"gaz/gLocGeoIsland.txt" ;
Define gazLocGeoMountain   @txt"gaz/gLocGeoMountain.txt" ;
Define gazLocGeoReserve    @txt"gaz/gLocGeoReserve.txt" ;
Define gazLocGeoIslandPl   @txt"gaz/gLocGeoIslandPl.txt" ;
Define gazLocGeoMountainPl @txt"gaz/gLocGeoMountainPl.txt" ; 
Define gazLocGeoHydro      @txt"gaz/gLocGeoHydro.txt" ; ! NB: Excluded Amazon for now (-> ORG)

Define LocGeoGaz1A
       Field AlphaUp lemma_exact( ( Ins(GeoPfx) Dash::0.05 )
       	     	     		    DownCase([ gazLocGeoRegion | gazLocGeoIsland | gazLocGeoHydro | gazLocGeoReserve |
				    	       gazLocGeoMountain ]) ) ;

Define LocGeoGaz1B
       inflect_sg( ( Ins(GeoPfx) Dash::0.05 ) Cap([ gazLocGeoRegion | gazLocGeoIsland | gazLocGeoHydro |
       		     		 	      	    gazLocGeoReserve | gazLocGeoMountain ]) ) ;

Define LocGeoGazMWordW
       [ m4_include(`gaz/gLocGeoMWordW.m4') ] ;

Define LocGeoGazMWordL
       [ m4_include(`gaz/gLocGeoMWordL.m4') ] ;

Define LocGeoGazPl
       Field AlphaUp lemma_morph( DownCase([ gazLocGeoIslandPl | gazLocGeoMountainPl ]), {NUM=PL} ) ;

Define LocGeoGaz
       [ Ins(LocGeoGaz1A) | Ins(LocGeoGaz1B) | Ins(LocGeoGazMWordW) | Ins(LocGeoGazMWordL) | Ins(LocGeoGazPl) ] ;

Define LocGeoCaptured
       inflect_sg( GeoCpt1 | GeoCpt4 | [ GeoCpt2 | GeoCpt3 ] (AddI) ) ;

! Category HEAD
Define LocGeogr
       [ Ins(LocGeoHyphen1)::0.20
       | Ins(LocGeoHyphen2)::0.30
       | Ins(LocGeoSuffixed1)::0.20
       | Ins(LocGeoSuffixed2)::0.35
       | Ins(LocGeoSuffixed3)::0.40
       | Ins(LocGeoSuffixed4)::0.40
       | Ins(LocGeoSuffixedRiver)::0.25
       | Ins(LocGeoSuffixedBrook)::0.40
       | Ins(LocGeoSuffixedMountain)::0.60
       | Ins(LocGeoSuffixedFalls)::0.50
       | Ins(LocGeoPrefixed1)::0.50
       | Ins(LocGeoPrefixed2)::0.35
       | Ins(LocGeoPrefixed3)::0.20
       | Ins(LocGeoCircumfixed)::0.20
       | Ins(LocGeoGuessed)::0.75
       | Ins(LocGeoGuessedPl)::0.50
       | Ins(LocGeoNationalPark1)::0.25
       | Ins(LocGeoNationalPark2)::0.25
       | Ins(LocGeoOcean1)::0.25
       | Ins(LocGeoOcean2)::0.25
       | Ins(LocGeoOcean3)::0.25
       | Ins(LocGeoOcean4)::0.25
       | Ins(LocGeoOceanTrench)::0.25
       | Ins(LocGeoOceanCurrent1)::0.25
       | Ins(LocGeoOceanCurrent2)::0.25
       | Ins(LocGeoColloc1)
       | Ins(LocGeoGaz)::0.20
       | Ins(LocGeoCaptured)::0.75
       ] EndTag(EnamexLocGpl) ;

!!----------------------------------------------------------------------
!! <EnamexLocPpl>: Political areas
!!----------------------------------------------------------------------

!* Xxx-shogunaatti
Define LocPolHyphen1
       AlphaUp lemma_ends( AlphaDown Dash [ {kylä} | {kaupunki} | {shogunaatti} | {shōgunaatti} ] ) ;

!* Xxx-niminen kaupunki
Define LocPolHyphen2
       AlphaUp lemma_ends( Dash {niminen} ) WSep
       lemma_ends( {kylä} | {kaupunki} ) ;

!* Xxx Xxx -niminen kaupunki
Define LocPolHyphen3
       [ CapMisc WSep ]*
       Word WSep Word WSep
       (Dash) lemma_exact( (Dash) {niminen} ) WSep
       lemma_ends( {kylä} | {kaupunki} ) ;

!* "Puerto Xxx", "Ciudad de Xxx", "New Xxx"
Define LocPolPrefixed
       wordform_exact( {Sant} Apostr AlphaUp AlphaDown+ | AlphaUp AlphaDown+ {abad} ({-e}) |
       		       @txt"gaz/gLocPolPfxWord.txt" ) WSep
       ( [ DeLa | wordform_exact( OptCap(["a"|"e"]["s"|"l"|"z"|"n"])) ] WSep )
       ( CapNameNom WSep::0.20 )
       [ PropGeo | CapName::0.10 ]::0.20 ;

!* "Xxx City", "Xxx Bystrica"
Define LocPolSuffixed1
       ( CapMisc::0.20 WSep )
       CapMisc::0.30 WSep
       inflect_sg( @txt"gaz/gLocPolSfxWord.txt" ) ;

!* "Ruotsin kuningaskunta", "Korean demokraattinen kansantasavalta", "Venäjän federaatio", "Suomen suuriruhtinaskunta"
!* NB: "liittovaltio" ei kuulu tänne vaan gazetteeriin, tuottaa tässä enimmäkseen virheitä
Define LocPolSuffixed2
       [ CapNameGenNSB | PropGeoGen ] WSep
       ( lemma_exact( {demokraattinen} | {sosialistinen} | {kommunistinen} | {federatiivinen} |
       	 	      {kuninkaallinen} | {keisarillinen} | {islamilainen} ) WSep )
       lemma_morph( {tasavalta} | {kuningaskunta} | {keisarikunta} | {federaatio} | {emiraatti} | {kalifaatti} |
       		    {sulttaanikunta} | {ruhtinaskunta} | {herttuakunta} | {vapaaherrakunta} | {shogunaatti} |
		    {shōgunaatti}, {NUM=SG} ) ;

!* "Xxx im Xxx", "Frankfurt am Main", "Kostanjevica na Krki"
Define LocPolInfixed1
       CapName WSep
       wordform_exact( {im} | {am} | {pri} | {na} | {ob} | {pod} ) WSep
       CapName ;

!* "Statford-on-Avon", "Aix-en-Provence", "Saint-André-de-Cubzac"
Define LocPolInfixed2
       wordform_exact( [ AlphaUp AlphaDown+ Dash ]+ AlphaDown+ [ Dash AlphaUp AlphaDown+ ]+ ) ;

!* Xxxkylä, Xxxkaupunki, Xxxkortteli,
!* Xxxpelto, Xxxmarkku, Xxxikkala, Xxxvesi
Define LocPolGuessed1
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact( AlphaDown+ [ {kylä} | {kaupunki} | {kortteli} | {nlinna} | {lanti} |
       	       		 	      		   {ikkala} | {markku} | {kulma} | {pelto} | {hamina} |
						   {nisto} | {vesi} ] ) ;

!* Xxxburg, Xxxdorff, Xxxgrad, Xxxingen, Xxxabad
Define LocPolGuessed2
       inflect_sg( (AlphaUp AlphaDown+ Dash) AlphaUp AlphaDown AlphaDown+ @txt"gaz/gLocPolSfx.txt" ) ;

!* "Aix-xx-Xxx", "Niederxxx"
Define LocPolGuessed3
       inflect_sg( [ {Peña} | {Nieder} | {Ober} | {Mont} | {Saint} Dash AlphaUp | {Roche} | {Châte} |
                     {Fleury} | {Champ} | {Aix} Dash AlphaDown+ Dash AlphaUp ] AlphaDown AlphaDown+ ) ;

Define LocPolGuessed
       [ Ins(LocPolGuessed1) | Ins(LocPolGuessed2) | Ins(LocPolGuessed3) ]::0.40 ;

!* Xxxx:n piirikunta / Fukuin prefektuuri / Leningradin oblasti
Define LocPolSubdivision
       ( CapMisc WSep )
       [ CapNameGenNSB | AlphaUp PropGen ] EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_exact_morph( {lääni} | {maalaiskunta} | {mlk} (".") | {kihlakunta} | {seutukunta} |
       			  	    {prefektuuri} | {kanton}("i") | {volost}("i") | {oblast}("i") | {piirikunta} |
			  	    {sairaanhoitopiiri} | {vaalipiiri} | {hiippakunta} | {kirkonkylä}, {NUM=SG} ) ;

!* Xxx:n kadut, Xxx:in kuvernööri, Xxx:n kansalainen
Define LocPolColloc1
       ( CapMisc WSep ) ( CapMisc WSep )
       [ LC(NoSentBoundary) wordform_exact( CapNameStr Capture(LocPolCpt1) Ins(GenSuff) )::0.50 |
       	  AlphaUp AlphaDown [ PropGen::0.55 | PropGeoGen::0.30 ] |
	  AlphaUp lemma_exact_morph( DownCase(LocOrPer) | {nokia}, {[NUM=SG][CASE=GEN]})::0.10 ]
       RC( WSep ( PosAdj WSep )
       	   lemma_exact( (AlphaDown+ - [{koti}]) {kylä} | {pitäjä} | {asemakaava} | {asukas} ({luku}|{määrä}) |
       	      	     	{edustusto} | {esikaupunki} | {ilmatila} | {kalifi} | {kansalainen} | {kansalaisuus} |
			{kansallispäivä} | {kansanäänestys} | {katu} | {kauppala} | {puisto} |
			[{kaupungin}|{kunnan}] [{valtuutettu}|{valtuusto}|{johtaja}] | {kaupunkikulttuuri} |
			{keskusta} | {kirkkokylä} | {kirkonkylä} | {konttori} | {kortteli} |
			{kuningas} | {kuningatar} | {kuvernööri} | {lääni} | {lähettyvil}[{lä}|{le}|{tä}] |
			{lähetystö} | {lähiö} | {lähistö} | {lähistölle} | {lähistö} | {maanjäristys} | {maantie} |
			{maisema} | {hallitsija} | {markkina}("t") | {miehitys} | {ministeri} |
			{olympialai}[{nen}|{set}] | {patriarkka} | {perustuslaki} | {piispa} | {poliisilaitos} |
			{pommitus} | {pormestari} | {prinssi} | {puisto} | {seutu} | {seudulla} | {sotilasjuntta} |
			{sulttaani} | {suurlähettiläs} | {taajama} | {ulkoministeri} | {väestö} | {valloitus} |
			{verilöyly} | {viranomainen} | {virasto} | {ympäryskunta} ) ) ;

!* Xxx:n pikkukaupungissa (muttei: "Xxx:n kotikaupungissa")
Define LocPolColloc2
       ( CapMisc WSep ) ( CapMisc WSep )
       [ AlphaUp AlphaDown PropGen::0.30 |
       	 LC(NoSentBoundary) wordform_exact( CapNameStr Capture(LocPolCpt2) Ins(GenSuff) )::0.50 |
       	 PropGeoGen | AlphaUp lemma_exact_morph( DownCase(LocOrPer) | {nokia}, {[NUM=SG][CASE=GEN]} ) ]::0.10
       RC( WSep lemma_exact([ (AlphaDown+ - [{koti}|{synnyin}|{syntymä}]) {kaupunki} | {valtio} | {osavaltio} |
       	   		      {kaupunginosa} | ({maalais}|{pikku}){kunta} | {raion}("i") | {piirikunta} |
			      {departementti} | {valtakunta} | {maakunta} | {provinssi} | {pitäjä} ]) ) ;

!* "[Yyy:n pääkaupungissa] Xxx:ssä"
Define LocPolColloc3A
       LC( CaseGen WSep
       lemma_exact( AlphaDown+ [ {kaupunki} | {kylä} ] ) WSep )
       [ CapMisc WSep ]* 
       CapWord::0.40 ;

!* "[pääkaupunki] Xxx"
Define LocPolColloc3B
       LC( wordform_ends( AlphaDown+ [ {kaupunki} | {kylä} ] ) WSep )
       ( CapMisc WSep )
       CapName::0.40 ;

!* "[kotoisin/syntyisin] Xxx:stä"
Define LocPolColloc4A
       LC( wordform_exact( {kotoisin} | {syntyisin} ) WSep )
       [ CapMisc WSep ]*
       wordform_exact( CapNameStr Capture(LocPolCpt3) SmartSep [{sta}|{stä}] | {Nokialta} ) ;

!* "Xxx:stä [kotoisin]"
Define LocPolColloc4B
       [ CapMisc WSep ]*
       wordform_exact( CapNameStr Capture(LocPolCpt4) SmartSep [{sta}|{stä}] | {Nokialta} )
       RC( WSep wordform_exact( {kotoisin} ) ) ;

!* "Xxx:n [suurin]" 
Define LocPolColloc5
       [ CapMisc WSep ]*
       [ PropGeoGen ]::0.60
       RC( ( WSep wordform_ends({ksi}) )
       	     WSep lemma_morph({suuri}, {CMP=SUP}) ) ;

!* "[klo 00:00] Xxx:n [aikaa]"
Define LocPolColloc6
       LC( lemma_exact( {klo} (".") | {kello} ) WSep 
       Word WSep ( Word WSep ) )
       [ CapNounGenNSB | PropGeoGen ]
       RC( WSep wordform_exact({aikaa}) ) ;

!* "Xxx:ssä [sijaitseva/asuva/vieraillut/järjestetyt]"
Define LocPolColloc7
       [ CapMisc WSep ]*
       [ CapNounIneNSB | CapNounAdeNSB | PropGeoIne | PropGeoAde ]::0.40
       RC( WSep wordform_exact( 
       	   [ {sijaitsev}
	   | {sijainn}
	   | {asuv}
	   | {varttun}
	   | {oleskelev}
	   | {olev}
	   | {vierailev}
	   | {vieraill}
	   | {toimiv}
	   | {järjestet}
	   | {tapahtuv}
	   | {tapahtun}
	   ] FinVowel Field ) ) ;

!* "Uusimaa" : "Uudenmaan"
Define LocPolMisc1
       lemma_exact( {iso} Field Dash {britannia} ) |
       lemma_exact( {uu}["d"|"t"] AlphaDown+ {maa} ) |
       lemma_exact( {uu}["d"|"t"] AlphaDown+ Dash [ {seelanti} | {guinea} | {kaledonia} ]) ;

!* "Koski TL"
Define LocPolMisc2
       lemma_exact( {lappi} | {koski} | {pyhäjärvi} | {uusikirkko} | {uusikylä} ) WSep
       lemma_exact( {hl} | {tl} | {ol} | {ul} | {vpl} ) ;

!* (names with frequent erroneous analyses)
!* NB: this may no longer be needed
Define LocPolMisc3
       wordform_ends( {Kiinaan} | {Venäjään} | {Japaniin} | {Roomaan} | {Yhdysvalloille} |
       	       {Filippiine} Field ) ;

!* "Brittiläinen Xxx"
Define LocPolMisc4
       LC( NoSentBoundary )
       "B" lemma_exact( {brittiläinen} ) WSep
       AlphaUp AlphaDown lemma_exact( AlphaDown AlphaDown+ (Dash) AlphaDown AlphaDown+ ) ;

!* "Xxxisten", "Kauniaisissa", "Kaustisilla", "Pornaisten"
Define LocPolMisc5
       LC( NoSentBoundary )
       [ [ AlphaUp AlphaDown+ FSep Field {inen} FSep Field {NUM=PL} Field FSep Field FSep ] - CaseNom ]::0.60 ;

!* "Pietarissa" (muttei: "Pietarilla")
Define LocPolDisamb
       AlphaUp lemma_exact_morph( DownCase(LocOrPer), {NUM=SG} Field {CASE=}[{ILL}|{INE}]) ;

Define LocPolCaptured
       inflect_sg([ LocPolCpt1 | LocPolCpt2 | LocPolCpt3 | LocPolCpt4 ] (AddI))::0.60 ;

Define gazLoc [ @txt"gaz/gLocPol1Part.txt" | @txt"gaz/gLocPol1PartFin.txt" | @txt"gaz/gLocCountry.txt" ] ;

Define LocPolGazSgA
       Field AlphaUp lemma_exact( ( Ins(GeoPfx) Dash ) DownCase(gazLoc) ("i") ) ;

Define LocPolGazSgB
       wordform_exact( ( OptCap(GeoPfx) Dash ) Ins(gazLoc) ) ;

Define LocPolGazSgC
       inflect_sg( ( OptCap(GeoPfx) Dash ) Ins(gazLoc) ) ;
       
Define LocPolGazPl
       lemma_morph( ( Ins(GeoPfx) Dash ) @txt"gaz/gLocPolPl.txt", {NUM=PL}) ;

Define LocPolMultiPart
       [ m4_include(`gaz/gLocPolMWord.m4') ] ;

Define LocPolMultiPartFin
       [ m4_include(`gaz/gLocPolMWordFin.m4') ] ;

Define LocPolGaz
       [ Ins(LocPolGazSgA) | Ins(LocPolGazSgB) | Ins(LocPolGazSgC) | Ins(LocPolGazPl) |
       	 Ins(LocPolMultiPart) | Ins(LocPolMultiPartFin) ]::0.20 ;

!* Category HEAD
Define LocPolit
       [ Ins(LocPolHyphen1)
       | Ins(LocPolHyphen2)
       | Ins(LocPolHyphen3)
       | Ins(LocPolPrefixed)
       | Ins(LocPolSuffixed1)
       | Ins(LocPolSuffixed2)
       | Ins(LocPolInfixed1)
       | Ins(LocPolInfixed2)
       | Ins(LocPolGuessed)
       | Ins(LocPolSubdivision)
       | Ins(LocPolColloc1)
       | Ins(LocPolColloc2)
       | Ins(LocPolColloc3A) | Ins(LocPolColloc3B)
       | Ins(LocPolColloc4A) | Ins(LocPolColloc4B)
       | Ins(LocPolColloc5)
       | Ins(LocPolColloc6)
       | Ins(LocPolColloc7)
       | Ins(LocPolMisc1)
       | Ins(LocPolMisc2)
       | Ins(LocPolMisc3)
       | Ins(LocPolMisc4)
       | Ins(LocPolMisc5)
       | Ins(LocPolDisamb)
       | Ins(LocPolCaptured)
       | Ins(LocPolGaz)
       ] EndTag(EnamexLocPpl) ;

!!----------------------------------------------------------------------
!! <EnamexLocStr>: Streets, city squares
!!----------------------------------------------------------------------

Define StreetSfxFin
       FinVowel ("s"|"n"|"l"|"r") {tie}({ltä}|{lle}|{llä}) | {katu} | {kuja} | {polku} | {väylä} | {bulevardi} |
       {esplanadi} | {puistikko} | {tanhua} ;

Define StreetSfxMisc
       {väg} ({en}) | {gata} ("n") | {gränd} ({en}) | {stig} ({en}) | {veien} | {straat} |
       {avenue} | {boulevard} | {bulevard}({en}) | {stra}[{ss}|"ß"]"e" | {gasse} | {uli}[{ts}|"c"]"a" |
       {storg} | {torget} | {gade}::0.10 | {gate} ("n")::0.10 ;

Define StreetSfxWord
       {street} | {lane} | {avenue} | {boulevard} | {row} | {route} | {driveway} | {parkway} | {gardens} | {circle} |
       {turnpike} | {gate} | {court} | {walk} | {terrace} | {highway} | {freeway} | {road} | {strasse} | {straße} | 
       {alley} | {gasse} | {ulica} | {ulice} | {ulitsa} | {sokak} | {prospekt} | {rd} | {str.} | {pkwy} | {plz} |
       {trg} | {dvor} | {ploštšad} | {ploščad} | {platz} | {parken} ;


! "Unioninkatu", "Länsiväylä", "Läntinen Linjakatu", "Vanha Turuntie"
! "Pieni Robertinkatu"
Define LocStreet1
       ( AlphaUp lemma_exact( GeoAdj | {pikku} | {pieni} | {iso} | {vanha} | {vähä} ) WSep )
       AlphaUp lemma_morph([ Alpha+ Ins(StreetSfxFin) ] - [ {kulkuväylä} ], {NUM=SG}) ;

! "Brändovägen", "Motzstraße"
Define LocStreet2
       inflect_sg( UppercaseAlpha Field StreetSfxMisc ) ;

! "Urho Kekkosen katu"
Define LocStreet3
       [ AlphaUp AlphaDown PropNom WSep AlphaUp PropGen |
       	 PropFirstNom WSep CapNameGen EndTag(EnamexPrsHum2) ] WSep
       lemma_exact( Ins(StreetSfxFin) ) ;

! "Downing Street", "Gleiwitzer Straße"
Define LocStreet4
       ( CapMisc WSep ) ( CapMisc WSep ) [ CapMisc | CapNameNSB ] WSep
       inflect_sg( OptCap(StreetSfxWord) ) ;

!* "Rue Xxx" "Avenue de Xxx"
Define LocStreet5
       wordform_exact( {Rue} | {Rua} | {Avenue} | {Boulevard} | {Bulevardul} | {Bulevar} | {Estrada} | {Calea} |
       		       {Strada} | {Via} | {Viale} | {Calle} | {Paseo} | {Av.} | {Tv.} | {Estr.} | {Parque} | {Plaza} |
		       {Place} | {Piazza} | {Trg} | {Ulica} | {Ulitsa} | {Jalan} | {Jl.} | {Lorong} |
		       {Lebuh}({raya}) | {Prospekt} ) WSep
       ( NameInitial WSep )
       ( CapNameNom WSep )
       ( DeLa WSep )
       ( CapNameNom WSep )
       CapName ;

!* Sörnäisten puistotie, Läntinen rantakatu
Define LocStreet6
       [ wordform_exact({Sörnäisten}) | AlphaUp lemma_exact(GeoAdj) | PropGeoGen ] WSep
       lemma_exact_morph( {rantatie} | {puistotie} | AlphaDown+ {katu} , {NUM=SG}) ;

Define AddressNbr
       lemma_exact( 1To9 (0To9 (0To9)) (Dash 1To9 (0To9 (0To9))) ( Alpha (Alpha) (1To9 (0To9 (0To9)))) )
       ( WSep lemma_exact( Alpha )
	 ( WSep lemma_exact( 1To9 (0To9 (0To9)) ) )
	 ) ;

! "Unioninkatu 40", "Motzstraße 25 B 69"
Define LocStreetNbr1
       [ Ins(LocStreet1) | Ins(LocStreet2) | Ins(LocStreet3) | Ins(LocStreet4) | Ins(LocStreet5) | Ins(LocStreet6) ]
       ( WSep Ins(AddressNbr) ) ;

!* Xxxpenger 35
Define LocStreetNbr2
       AlphaUp wordform_ends( {rinne} | {penger} | {ranta} | {portti} | {laita} | {reuna} | {syrjä} | {tori} |
       	       		      {laituri} | {tunneli} | {silta} | {taival} | {puistikko} ) WSep
       Ins(AddressNbr) ;

Define LocStreetNbr3
       LC( lemma_exact({osoite}) WSep )
       CapWord WSep
       Ins(AddressNbr) ;

Define LocStreetNbr
       [ Ins(LocStreetNbr1) | Ins(LocStreetNbr2) | Ins(LocStreetNbr3) ] ;

! "Kehä I", "Kehä kolmonen"
Define LocStreetNoNbr
       wordform_exact( {Kehä} | {kehä} ) WSep
       lemma_exact( "i" ("i") ("i") | {ykkönen} | {kakkonen} | {kolmonen} ) ;

!* Xxx-katu
Define LocStreetHyphen1
       AlphaUp Field Dash lemma_ends( Dash [ {katu} | {aukio} | {tori} ] ) ;

!* Xxx Xxx -katu
Define LocStreetHyphen2
       [ CapMisc WSep ]*
       ( CapName WSep )
       CapWord WSep
       DashExt lemma_exact( (Dash) [ AlphaDown* {katu} | {aukio} | {tori} ] ) ;

! "Piritori", "Alppipuisto", "Vaasanaukio", "Varsapuistikko", "Vanha Suurtori"
Define LocStreetSquare
       [ LC( NoSentBoundary ) AlphaUp | AlphaUp lemma_exact( GeoAdj | {pikku} | {pieni} | {iso} | {vanha} ) WSep ]
       lemma_exact( [ AlphaDown AlphaDown+ [ {tori} | {puisto} | {puistikko} | {aukio} ] ]
       	       	    - [ Field [ {ttori} | {ptori} | {htori} | {ktori} | {pastori} | {nsistori} | {kompostori} |
		      	      	{editori} | {monitori} | {zetori} | {haukio} ] | {mentori} | {nestori} ] ) ;

!* valtatie 3
Define LocStreetHighway
       lemma_exact( {valtatie} | {yhdystie} ) WSep
       lemma_exact( 1To9 0To9* (".") ) ;

!* 7th Avenue, 23rd Street
Define LocStreetNth
       wordform_exact( 1To9 (0To9) [{st}|{nd}|{rd}|{th}] ) WSep
       inflect_sg( OptCap( {street} | {avenue} ) ) ;

Define LocStreetGaz
       [ LC( NoSentBoundary ) AlphaUp lemma_exact_morph([ {esplanadi} | {bulevardi} | {kurvi} ], {NUM=SG}) ] |
       [ AlphaUp lemma_exact_morph([ {espa} | {mansku} | {freda} | {rotuaari} | {länäri} | {länsiväylä} |
       	 	 		     {turuntie} ], {NUM=SG} ) ] |
       [ inflect_sg( {Broadway} | {Cheapside} | {Champs-Élysées} | {Champs-Elysees} | {Rautatientori} |
       	 	     {Elielinaukio} | {Senaatintori} | {Baščaršija} | {Bascarsija} ) ] |
       [ wf_lemma_x3({Taivaallisen}, {rauhan}, {aukio}) ] ;

!* Category HEAD
Define LocStreet
       [ Ins(LocStreetNbr)::0.50
       | Ins(LocStreetNoNbr)::0.50
       | Ins(LocStreetHyphen1)::0.50
       | Ins(LocStreetHyphen2)::0.50
       | Ins(LocStreetSquare)::0.40
       | Ins(LocStreetHighway)::0.40
       | Ins(LocStreetNth)::0.25
       | Ins(LocStreetGaz)::0.25
       ] EndTag(EnamexLocStr) ;

!!----------------------------------------------------------------------
!! <EnamexLocFnc>: Buildings, infrastructure, facilities, real estate/property
!!----------------------------------------------------------------------

Define LocReligiousType
       {kirkko}::0.20 | {kappeli} | [{tuomio}|{puu}|{kivi}|{paanu}|{sauva}|{suur}] {kirkko} | {katedraali} |
       {basilika} | {moskeija} | {synagoga} | {temppeli} | {luostari} ;

Define LocStructType
       {pato} | {kaivos} | {linna} | {kartano} | {linnoitus} | {linnake} | {palatsi} | {muuri} | {aukio} | {torni} |
       {majakka} | {stadion} | {areena} | {riemukaari} | {paviljonki} | {tunneli} | {allas} |
       [ [ Dash | Vowel "n" | [ FinVowel - Apostr ] ("s"|"l"|"r") ] {silta} ] ;

!* Xxx-kirkko, Xxxkirkko
Define LocPlaceOfWorship1A
       LC( NoSentBoundary )
       AlphaUp lemma_ends( AlphaDown (Dash) Ins(LocReligiousType) ) ;

!* Xxxnkirkko
Define LocPlaceOfWorship1B
       AlphaUp lemma_exact_sg( AlphaDown+ AlphaDown [ {nkirkko} | {nkappeli} ] ) ; 

Define LocPlaceOfWorship1
       [ Ins(LocPlaceOfWorship1A) | Ins(LocPlaceOfWorship1B) ] ;

!* Pyhän Henrikin katedraali, Pyhän ristin/kolminaisuuden kirkko, Helsingin tuomiokirkko,
!* Sikstuksen kappeli, [Helsingin] Saksalainen kirkko, Šeikki Lotfallahin moskeija
!* muttei: Kristuksen kirkko
Define LocPlaceOfWorship2
       ( wordform_exact( Cap( {sulttaani} | {kuningas} | {pyhän} | {shaahi} | {šaahi} | {pašša} | {pasha} |
       	 		      ["š"|{sh}]{eikki} ) ) WSep )
       ( CapName WSep )
       [ [ CapNounGen - lemma_exact( {kristus} | {jeesus} | {jumala} ) ]::0.10 |
       	 [ PropGeoGen EndTag(EnamexLocPpl2) ] |
       	 [ LC( NoSentBoundary ) AlphaUp AlphaDown PosAdj ]
	 ] WSep
       lemma_exact_morph( Ins(LocReligiousType), {NUM=SG}) ;

!* S:t Mikaelskyrkan, Mátyás-templom, Todai-ji
Define LocPlaceOfWorship3
       ( wordform_exact({St.}|{S:t}|{St}) WSep )
       inflect_sg( AlphaUp AlphaDown+ [ {kyrka}("n") | {kirke}("n") | {kyrkja}("n") | {kirkja}("n") | {kirche} |
       		   	   	      	{kerk} | {kathedraal} | {münster} | (Dash) {templom} | Dash {ji} ] ) ;

!* Helsingin tuomiokirkko
Define LocPlaceOfWorship4
       AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_morph( {katedraali} | {tuomiokirkko} | {moskeija} | {synagoga} , {NUM=SG}) ;

!* Xxx Xxx -niminen rakennus, Xxx-niminen rakennus
Define LocPlaceHyphen1
       ( CapMisc WSep )
       [ AlphaUp AlphaDown+ [ Word WSep (Dash) | Dash ] ]
       lemma_exact( (Dash){niminen} ) WSep
       lemma_morph( Ins(LocStructType) | Ins(LocReligiousType) | {talo} | {huone} | {sali} | {halli} | {linna} |
       		    {kiinteistö} | {hotelli} | {pilvenpiirtäjä} | {rakennus}, {NUM=SG}) ;

!* Xxx Xxx -pilvenpiirtäjä
Define LocPlaceHyphen2
       ( CapMisc WSep )
       CapName WSep
       Field Alpha Word WSep
       Dash AlphaDown lemma_exact_morph( Ins(LocStructType) | Ins(LocReligiousType) | {talo} | {huone} | {sali} |
       	    	      			 {halli} | {linna} | {hotelli} | {pilvenpiirtäjä} | {teemapuisto} |
					 {allas}, {NUM=SG}) ;

! Ritarihuone, Makkaratalo, Aikatalo, Olavinlinna, Suomenlinna, Ylioppilastalo, Näsinsilta, Puutarhakanava, Kaivopiha,
! Barona-areena, Iisakinkirkko, Länsisatama, Itkumuuri
Define LocPlaceGuessed1
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_morph( AlphaDown (Dash) [ {talo} | {huone} | {sali} | {halli} | {linna} | {nportti} |
       	       		 	      		       	 {kauppahalli} | {piha} | {tarha} | {satama} | Dash {keskus} |
							 Dash {kampus} | {hovi} | Ins(LocStructType) |
							 Ins(LocReligiousType) ], {NUM=SG}|{POS=ADVERB}) ;

!* "Itämerentorni", "Vanajanlinna" (muttei: "Laiskanlinna", "Kirkontorni")
Define LocPlaceGuessed2
       AlphaUp AlphaDown lemma_exact( [ Field AlphaDown [ {ntorni} | {npirtti} | {nkartano} | {nlinna} | {portti} ] ]
       	       		 	      - [ Field [ {laiskanlinna} | {kirkontorni} | {asuintorni} | {stadiontorni}  |
				      	  	  {pakastintorni} | {lauhdutintorni} | {kaiutintorni} | {sportti} |
						  {puhelintorni} | {raportti} | {takaportti} | {rautaportti} |
						  {kotiportti} | {tähtiportti} ] ] ) ;

!* Xxxhuset, Xxxstugan
Define LocPlaceGuessed3
       inflect_sg( AlphaUp AlphaDown+ [ {stugan} | {huset} | {gården} ] ) ;

! Suezin kanava, Tammerkosken silta, Puijon torni, Haukilahden vesitorni, Berliinin muuri, Houtskarin majakka,
! Ishtarin portti, Valamon luostari, Auschwitz-Birkenaun keskitysleiri
Define LocPlaceGenAttr1
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_exact_morph( Field [ Ins(LocStructType) | Ins(LocReligiousType) ] |
       		 		    [[ Field {portti}] - [ Field {raportti} ]] | {keskitysleiri}, {NUM=SG} ) ;

Define LocPlaceGenAttr2
       [ AlphaUp PropGeoGen | wordform_exact( {Suezin} | {Panaman} | {Saimaan} | {Taipaleen} |
       	 	 	      		      {Liverpoolin} ) ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( {kanava}, {NUM=SG} ) ;

Define LocPlaceGenAttr3
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( {tori} | {portti} , {NUM=SG} ) ;

!* Xxxin teollisuusalue, Helsingin kaupungintalo
Define LocPlaceGenAttr4
       [ CapMisc WSep ]*
       [ PropGeoGen EndTag(EnamexLocPpl2) | [CapNameGenNSB - PropOrg]::0.60 ]  WSep 
       lemma_morph(
            {lentokenttä} |
	    {lentoasema} |
            {satama} |
	    {teollisuusalue} |
            {kaupungintalo} |
            {kunnantalo} |
	    {pappila} |
            {puisto} |
	    {postitalo} |
	    {torppa} |
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
	    {voimala} | {voimalaitos} |
	    AlphaDown {tehdas} |
	    {poliisiasema} |
	    {vedenpuhdistamo} |
            {rautatie}(Dash){asema} |
	    {messukeskus} |
	    {kulttuurikeskus} |
	    [{kisa}|{jää}|{uima}|{jääkiekko}|{tennis}]{halli} |
	    {vankila} |
	    {golfkenttä} |
	    {golfrata} |
	    {uintikeskus} |
	    {uimala} |
            {juna-asema} |
            {terminaali},
       {NUM=SG} ) ;

!* Xxx Hotel, Xxx Arena
Define LocPlaceSuffixed
       ( Ins(WordsNom) )
       [ CapNameNSB | CapMiscExt ] WSep
       inflect_sg( {Hotel} | {Park} | {Station} | {Garden} | {Castle} | {Building} | {Abbey} | {Palace} | {Square} |
       		   {Stadium} | {Cathedral} | {Church}::0.25 | {Stadion} | {House}::0.25 | {Temple} | {Arena} |
		   {Areena} | {Hall} | {Studio} | {Place} | {Plaza} | {Ranch} | {Center}::0.25 | {Zoo} | {Speedway} |
		   {Cemetery} | {Statehouse} | {Bridge} | {Kerk} | {Dom} | {Minster} | {Memorial} | {Monument} |
		   {Capitol} | {Tower}("s") | {Arch} | {Gate} | {Circuit} | {Aquarium} | {Münster} | {most} |
		   {Most} | {Shrine} | {Fountain} | {Lodge} | {Zamok} | {Complex} | {Observatory} | {Circuit} ) ;

!* Château Xxx, Estadio de Xxx
Define LocPlacePrefixed1
       wordform_exact( {Casa} | {Maison} | {Palazzo} | {Basilica} | {Loggia} | {Villa} | {Château} | {Chateau} |
       		       {Palais} | {Monasterio} | {Osservatorio} | {Pont} | {Porta} | {Puerta} | {Canal} | {Castel} |
		       {Castello} | {Certosa} | {Santuario} | {Nôtre-Dame} | {Notre-Dame}| {Gare} | {Estació}("n") |
		       {Stazione} | {Convento} | {Catedral} | {Cathédrale} | {Cathedrale} | {Torre} | {Panagía} |
		       {Panagia} | {Cappella} | {Battistero} | {Stift} | {Scala} | {Escalier} | {Fuente} |
		       {Gabinetto} | {Camp} | {Crkva} | {Hospits} | {Templo} | {Tempio} | {Burj} | {Arena} | {Centro} |
		       {Estádio} | {Estadio} | {Marina} | {Circuit} ) WSep
       [ ( CapWord WSep ) [ AndOfThe WSep ]+ ( CapNameNom WSep ) ]*
       ( CapMisc WSep )
       CapName ;

!* "Notre Dame de la Garde", "Santa Maria dell'Anima", "Santa María de Óvila", "Santa Maria Maggiore"
Define LocPlacePrefixed2
       [ wordform_x2( {Notre}|{Nôtre}, {Dame}) |
       	 wordform_x2( {Santa}, {Maria}|{María}|{Cruz}) |
       	 [ wordform_exact({San}|{São}) WSep [ PropNom | CapNameNom ]] ] WSep
       [ [ DeLa | AndOfThe ] WSep CapName | wordform_exact( "M" AlphaDown+ ) ] ;

!* Mannilan tila [RN:o 17:15]
Define LocPlaceProperty1
       [ AlphaUp PropGen | CapNameGenNSB ] Capture(PropertyNameGen) WSep
       [ lemma_exact_morph( {tila}, {NUM=SG} ) | lemma_exact( {tilalla} | {tilalle} ) ]
       RC( WSep [ lemma_exact({rn:o}) | PropGeoIne ]) ;

Define LocPlaceProperty2
       [ CapName - lemma_exact( {tila} ({lla}|{lle}) ) ]
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

!* Xxx-Xxx:n rata, Lahden oikorata
Define LocPlaceRailroadDefense
       [ ( CapNameGen WSep wordform_exact( Dash ) WSep ) PropGeoGen |
       	 wordform_ends( AlphaUp AlphaDown+ Dash AlphaUp AlphaDown+ "n") ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_sg(({oiko}|{kehä}) {rata} | {rautatie} | {linja} ) ;

!* "Valkoisessa talossa"
Define LocPlaceWhiteHouse
       "V" lemma_exact_morph({valkoinen}, {NUM=SG} Field {CASE=}[{NOM}|{GEN}|{INE}|{ILL}|{ELA}|{TRA}]) WSep
       lemma_exact_morph({talo}, {NUM=SG} Field {CASE=}[{NOM}|{GEN}|{INE}|{ILL}|{ELA}|{TRA}]) ;

!* "Vankileiri 5"
Define LocPlacePrisonCamp
       AlphaUp lemma_ends( {vankileiri} ) WSep
       wordform_exact( 0To9+ (".") (":" AlphaDown+ ) ) ;

!* "Xxx:n [julkisivu/sisäpiha/]"
Define LocPlaceColloc1
       ( CapMisc WSep )
       [ CapNameGenNSB | AlphaUp PropGen | infl_sg_gen(CorpOrLoc) ]
       RC( WSep lemma_ends( {julkisivu} | {pääty} | {katto} | {sisäänkäynti} | {parkkipaikka} | {pihalla} | {seinä} |
       	   		    {sisäpiha} | {porras} | {portaat} | {portaikko} | [{rauta}|{piha}] {portti} | {piha-aita} |
			    {terassi} | {pihamuuri} | {uloskäynti} | {ikkuna} | {pohjakerros} | {hissi} | {käytävä} |
			    {korkeus} | {rakentaminen} | {rakentaja} | {rakennuttaja} | {purkaminen} | {purku} |
			    {sijainti} | {auditorio} | {valmistumisvuosi} | {remontti} | {peruskorjaus} |
			    {asemakaava} | {vuokra} | {vuokraaja} | {sisäpuoli} |{yläkerros} | {kattokerros} |
			    {ullakko} | {alakerros} | {yläkerta} | {alakerta} | {kunnostus} |
			    {purkukustannu}["s"|{kset}] | {rakennuskustannu}["s"|{kset}] |
			    {tuulikaappi} | {ympäristö} | {tilus} ) ) ;

!* "Xxx:n [ylin/kolmas kerros]"
Define LocPlaceColloc2
       ( CapMisc WSep )
       [ CapNameGenNSB | AlphaUp PropGen | infl_sg_gen(CorpOrLoc) ]
       RC( WSep [ lemma_exact({alin}|{ylin}) | PosNumOrd ] WSep lemma_exact({kerros}) ) ;

!* kulttuurikeskus Xxx
Define LocPlaceColloc3
       LC( lemma_morph( {kulttuurikeskus} | {hotelli} | {pilvenpiirtäjä}, {[NUM=SG][CASE=NOM]} ) WSep )
       ( CapMiscExt WSep )
       CapWord ;

Define LocPlaceGaz
       [ m4_include(`gaz/gLocPlace.m4') ] ;

!* Category HEAD
Define LocPlace
       [ Ins(LocPlaceOfWorship1)::0.50
       | Ins(LocPlaceOfWorship2)::0.10
       | Ins(LocPlaceOfWorship3)::0.50
       | Ins(LocPlaceOfWorship4)::0.50
       | Ins(LocPlaceHyphen1)::0.25
       | Ins(LocPlaceHyphen2)::0.25
       | Ins(LocPlaceGuessed1)::0.50
       | Ins(LocPlaceGuessed2)::0.50
       | Ins(LocPlaceGuessed3)::0.40
       | Ins(LocPlaceGenAttr1)::0.50
       | Ins(LocPlaceGenAttr2)::0.50
       | Ins(LocPlaceGenAttr3)::0.50
       | Ins(LocPlaceGenAttr4)::0.50
       | Ins(LocPlaceSuffixed)::0.40
       | Ins(LocPlacePrefixed1)::0.30
       | Ins(LocPlacePrefixed2)::0.20
       | Ins(LocPlaceProperty1)::0.25
       | Ins(LocPlaceProperty2)::0.25
       | Ins(LocPlaceProperty3)::0.25
       | Ins(LocPlaceProperty4)::0.25
       | Ins(LocPlaceProperty5)::0.25
       | Ins(LocPlaceRailroadDefense)::0.50
       | Ins(LocPlaceWhiteHouse)::0.30
       | Ins(LocPlacePrisonCamp)::0.50
       | Ins(LocPlaceColloc1)::0.60
       | Ins(LocPlaceColloc2)::0.60
       | Ins(LocPlaceColloc3)::0.60
       | Ins(LocPlaceGaz)::0.25
       ] EndTag(EnamexLocFnc) ;

!!----------------------------------------------------------------------
!! <EnamexLocMyt>:
!! Fictional places
!! Classify these as EnamexLocPpl for now
!!----------------------------------------------------------------------

Define LocFictional
       [ m4_include(`gaz/gLocFictional.m4') ]
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

Define CorpSuffixAbbrStr [ {oy} | {ky} | {ab} | {AB} | {abp} | {oyj} | {ag} | {AG} | {KG} | {as.} | {AS} | {A/S} |
       			   {ASA} | {BV} | {Co} | {Corp} | {GmbH} | {Gmbh} | {inc} | {ltd} | {llc} | {sa} | {SA} |
			   {Lp} | {NV} | {OÜ} | {Oü} | {plc} | {SpA} | {SE} | {SA} | {sia} ] (".") ;

Define CorpSuffixAbbrList [ OptCap(CorpSuffixAbbrStr) | UpCase(CorpSuffixAbbrStr) ] ;

Define CorpSuffixAbbr [ wordform_exact( Ins(CorpSuffixAbbrList) (":" AlphaDown+ )) ] ;
Define CorpSuffixAbbrNom wordform_exact( Ins(CorpSuffixAbbrList) ) ;

Define NpoSuffixAbbr lemma_exact( [ {ry} | {rf} | {rs} | {r.y} | {r.f} | {r.s.} ] (".") ) ;

Define PolPtySuffixAbbr lemma_exact( [{rp}] (".") ) ;

Define gazCorpSuffixWord    inflect_sg( OptCap(@txt"gaz/gCorpSuffWord.txt") ) ;
Define gazCorpSuffixWordFin UppercaseAlpha lemma_ends( @txt"gaz/gCorpSuffWordFin.txt" ) ;
Define gazCorpSuffixPart    lemma_ends( @txt"gaz/gCorpSuffPart.txt" ) ;
Define gazCorpSuffixPart2   lemma_ends( [\"ä"][\"r"]{yhtiö} | {Yhtiö} ) ;
Define gazCorpSuffixPartCap lemma_exact( UppercaseAlpha Field @txt"gaz/gCorpSuffPartCap.txt" ) ;
Define gazCorpSuffixPartSg  lemma_morph( @txt"gaz/gCorpSuffPartSg.txt", {[NUM=SG]} ) ;
Define gazCorpSuffixPartPl  UppercaseAlpha lemma_morph( @txt"gaz/gCorpSuffPartPl.txt", {[NUM=PL]} ) ;
Define gazNpoSuffixPart	    [ lemma_morph(
       [ {instituutti} | {säätiö} | {järjestö} | {yhdistys} | {vartiosto} | {esikunta} | {kilta} | {klubi} |
       	 {osakunta} | {kansanliike} | {liitto} | {kehittämiskeskus} | {unioni} | {komissio} | {arkisto} |
	 {laitos}::0.50 | {terveyskeskus} | {käräjä} | {lääninhallitus} | {rajavartiosto} | AlphaDown {konttori} |
	 {prikaati} | {rykmentti} | {divisioona} | {pataljoona} | {sotilaslääni} | {nimismiespiiri} |
	 {hovioikeuspiiri} | {työvoimapiiri} | {vesipiiri} | {rakennuspiiri} | {hovioikeuspiiri} |
	 {maanmittauspiiri} | {koululautakunta} | {tiepiiri} | {sotilaspiiri} | {sairaala} | {vanhainkoti} | {tulli} |
	 {maistraatti} | AlphaDown {virasto} | {kauppakamari} | {lautakunta} | {nimismiespiiri} | {valtuuskunta} |
	 {palokunta} | {poliisilaitos} | {hätäkeskus} | AlphaDown {toimisto} | {työvoimapiiri} | {tuomiokunta} |
	 {ritarikunta} | {tutkimuskeskus} | {suojeluskunta} ], {NUM=SG} )
       	 - lemma_ends( {vaaliliitto} | {salaliitto} | {avioliitto} | {avoliitto} | {homoliitto} | {lesboliitto} |
	   	       {neuvostoliitto} | {tuotantolaitos} | {oikeuslaitos} | {koululaitos} | {voimalaitos} |
		       {oppilaitos} | {kastilaitos} | {tuontitulli} | {valtioliitto} | {pääkonttori} |
		       {sivukonttori} |{haarakonttori} | {avokonttori} | {maisemakonttori} ) ] ;

Define OrgSuffixAbbr   [ CorpSuffixAbbr | NpoSuffixAbbr | PolPtySuffixAbbr ] ;
Define OrgSuffixNoAbbr [ gazCorpSuffixPart | gazCorpSuffixPart2 |
                       	 Ins(gazCorpSuffixPartSg) | Ins(gazCorpSuffixPartPl) |
			 Ins(gazNpoSuffixPart) ] ;

!Define NgoSuffix [ NpoSuffixAbbr | gazNpoSuffixPart ] ;

!!----------------------------------------------------------------------
!! <EnamexOrgAth>: Athletic/sports organizations
!!----------------------------------------------------------------------

Define gazAthTentative @txt"gaz/gTentativeOrgAth.txt" ;

! "Ajax", "Inter", "Pelicans"
Define AthleticOrgListSgA
       ( AlphaUp PropGeoGen WSep )
       AlphaUp lemma_exact( DownCase( {Blues} | {HIFK} | {HJK} | {TPS} | {SJK} | {JYP} | {Pelicans} | {Tappara} |
       	       		    	      {SaiPa} | {KeuPa} | {KalPa} | {MyPa} | {Lukko}({on}) | {Kärppä} | {Ilves} |
				      {Kiekko-Espoo} | {Juventus} | {Ajax} | {Inter} | {KooKoo} | {Jäähonka} |
				      {Buffalo} | {Turku-pesis} )) ;

Define AthleticOrgListSgB
       ( AlphaUp PropGeoGen WSep )
       inflect_sg( {Blues} | {Pelicans} | {Buffalo} | {SaiPa} | {KeuPa} | {KalPa} | {MyPa} | {Ilves} | {Ajax} ) ;

! "Ässät", "Kärpät", "Jokerit"
Define AthleticOrgListPl
       AlphaUp lemma_exact_morph([ {ässä} | {kärppä} | {haukka} | {jokeri} ("t") | {pallokissa} |
       	       			   {karhu-kissa} ("t") ], {NUM=PL} ) ;

!* Ykkösessä / Kakkosesta / Kolmoseen (ei: Ykkösellä -> OrgTvr) 
Define AthleticOrgYkkonen
       LC( NoSentBoundary )
       [ "Y" | "K" ] lemma_exact_morph( {ykkönen} | {kakkonen} | {kolmonen} ,
       	       	     			{NUM=SG} Field {CASE=}[{INE}|{ILL}|{ELA}] ) ;

Define AthleticOrgListGaz
       [ m4_include(`gaz/gOrgAthTeam.m4') ] ;

! "FC Blaablaa"
Define AthleticOrgPrefixed1
       wordform_exact( {FC} | {FF} | {JJK} | {AC} | {BC} | {HC} | {SC} | {LP} | {IF} ("K") | {AC} | {BIK} | {FBC} |
       		       {VfL} | {VfB} | {Basket} | {Idrottsföreningen} | {Real} | {Inter} | {Dinamo} ) WSep
       [ CapWord | CapNameNom WSep [PropGeo - PropCountry] ] ;

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
       AlphaUp lemma_exact( [ {pallo}|{luistin}|{hiihto}|{urheilu}|{jalkapallo}] ( Dash ) [{seura}|{kerho}|{klubi}] |
       	       		    {dynamo} | {pallo} ( Dash ) {kerho} | [{pallo}|{jää} ({kiekko})] ( Dash ) {klubi} |
			    Field {veikko} | NoFSep* {toveri} | Field {poika} | {urheilija} |
			    Field {palloilija} | {pallo} | {kiekko} | {maila} | {kuula} | {aura} | {tappara} |
			    {lukko}({on}) | {haka} | {hanka} | Field {volley} | {honka} | {kataja} | {suunta} |
			    {viesti} | {veto} | {kiri} | {kilpa} | {kisa} | ["v"|"w"]{isa} | {vesa} | {pamaus} |
			    {lentopallo} | {salama} | {ponsi} | {ponnistus} | {tempaus} | {nopsa} | {jymy} |
			    {rivakka} | {ponteva} | {luja} | {jäntevä} | {reipas} | {ketterä} |
			    {reima} | {roima} | {huima} | {virkiä} | {vilpas} | {ahkera} |
			    {puhti} | {tarmo} | {into} | {sisu} | {pyrintö} | {ässä} | {pyrkivä} |
			    {riento} | {ura} | {parma} | {karhu} | {kissa} | {kärppä} | {ilves} |
			    {tiikeri} | {nmky} | {ifk} | {namika} )
			    ( WSep NpoSuffixAbbr ) ;

! "Blues", "Canucks", "75ers", "Seagulls"
Define AthleticOrgXxxers
       inflect_sg( [ 1To9 0To9 {ers} ] | @txt"gaz/gOrgAthSfxWord.txt" ) ;

! "Manchester United", "Helsinki Seagulls"
Define AthleticOrgSuffixed2
       ( [ AbbrNom | AlphaUp PunctWord ] WSep )
       ( CapMiscExt WSep )
       [ CapMisc | CapNameNSB ] EndTag(EnamexLocPpl2) WSep
       [ inflect_sg( {FC} | {IF} | {IK} | {HC} | {HK} | {BK} | {HF} | {Bollklubb} | {United} ) |
       	 	     Ins(AthleticOrgXxxers) ] ;

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

! "ManU", "TamU", "RoPS", "JJK"
Define AthleticOrgCamelCase
       inflect_sg( AlphaUp AlphaDown* [ "U" | {PS} | {PK} | {JK} | {Pa} | {To} ] ) |
       inflect_sg( AlphaUp+ {IFK} ) ;

Define AthleticOrgDivision
       inflect_sg( (AlphaUp AlphaDown+) {Allsvenskan} | AlphaUp AlphaDown+ {serien} | {Bundesliga} ) ;

Define AthleticOrgLeague0
       AlphaUp PropGeoGen WSep
       lemma_exact( {veikkausliiga} | {valioliiga} | {superliiga} ) ;

Define AthleticOrgLeague1
       AlphaUp lemma_exact( {veikkausliiga} | {valioliiga} | {superliiga} | {mestis} | {sm-liiga} |
        	       	    {futisliiga} | {bundesliiga} | {vaahteraliiga} | {superpesis} ) ;

Define AthleticOrgLeague2
       [ CapMiscExt WSep ]+
       wordform_exact( {League} ) WSep
       CapWord ;

Define AthleticOrgLeague3
       [ CapMiscExt WSep ]+
       inflect_sg( {League} ) ;

Define AthleticOrgLeague4
       inflect_sg( UppercaseAlpha [ {HL} | {FL} | {FC} ]) ;

Define AthleticOrgLeague5
       UppercaseAlpha UppercaseAlpha UppercaseAlpha lemma_exact( Alpha+ {hl} Dash {sarja} ) ;

Define AthleticOrgSerieX
       wordform_exact( {Serie} ) WSep
       [ "A" | "B" | "C" ] lemma_exact( "a" | "b" | "c" ) ; 

Define AthleticOrgColloc1
       LC( lemma_morph( AlphaDown+ (Dash) [ {joukkue} | {talli} | {seura} ] ) WSep )
       ( AlphaUp [ AbbrNom | PunctWord ] WSep )
       ( Ins(CapMiscExt) WSep )
       CapWord ;

!* pelata Xxx:ssa
Define AthleticOrgColloc2
       LC( lemma_exact( {pelata} ) WSep )
       [ [ CapMiscExt WSep ]* AlphaUp AlphaDown morphtag_semtag({CASE=INE}, {PROP=GEO})::0.40 |
       	 infl_sg_ine( Ins(gazAthTentative) ) ] ;

Define AthleticOrgColloc3
       [ Ins(CapMiscExt) WSep ]* 
       [ CapNameGenNSB::0.40 | PropGen::0.30 | PropGeoGen::0.10 | infl_sg_gen( Ins(gazAthTentative) ) |
       	 wordform_exact( Field AbbrStr ["i"|":"] "n" )::0.20 ]
       RC( WSep lemma_exact([ Field [ {manageri} | {hyökkääjä} | {maalivahti} | {päävalmentaja} | {pelityyli} |
       	   		      	      {valmentaja} | {voittomaali} | {tasoitusmaali} | {kokoonpano} | {kotikenttä} |
				      {maalitykki} | {kapteeni} | {kasvatti} | {liigottelu} | {liigajoukkue} |
			    	      {laitapakki} | {edustusjoukkue} | {farmijoukkue} | {kenttäpelaaja} | {pelipaita} |
				      {laitahyökkääjä} | {alkukausi} | {kotipeli} | {loppukausi} | {liigakausi} |
				      {matsi} | {ottelu} | {pakki}::0.25 | {kannattaja}::0.25 |
			    	      {pelaaja}::0.25 ] | {rivi} | {maali} ] - [ Field {jaottelu} ]) ) ;

Define AthleticOrgColloc4
       [ AlphaUp PropGeoPar::0.50 | infl_sg_par( Ins(gazAthTentative) ) | AbbrPar::0.80 |
       	 LC(NoSentBoundary) AlphaUp AlphaDown morphtag({NUM=SG} Field {CASE=PAR})::0.80 ]
       RC( WSep wordform_exact({vastaan}) ) ;

Define AthleticOrgColloc5
       infl_sg_nom( Ins(gazAthTentative) )
       RC( WSep lemma_exact( {voittaa} | {pelata} | {hävitä} | {päihittää} ) ) ;

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
       | Ins(AthleticOrgSuffixed1)::0.20
       | Ins(AthleticOrgSuffixed2)::0.30
       | Ins(AthleticOrgSuffixed3)::0.30
       | Ins(AthleticOrgSuffixed4)::0.30
       | Ins(AthleticOrgSuffixed5)::0.30
       | Ins(AthleticOrgSuffixed6)::0.30
       | Ins(AthleticOrgCamelCase)::0.40
       | Ins(AthleticOrgDivision)::0.50
       | Ins(AthleticOrgLeague0)::0.50
       | Ins(AthleticOrgLeague1)::0.50
       | Ins(AthleticOrgLeague2)::0.50
       | Ins(AthleticOrgLeague3)::0.50
       | Ins(AthleticOrgLeague4)::0.50
       | Ins(AthleticOrgLeague5)::0.50
       | Ins(AthleticOrgSerieX)::0.50
       | Ins(AthleticOrgColloc1)::0.70
       | Ins(AthleticOrgColloc2)::0.10
       | Ins(AthleticOrgColloc3)::0.10
       | Ins(AthleticOrgColloc4)::0.10
       | Ins(AthleticOrgColloc5)::0.10
       ] EndTag(EnamexOrgAth) ;

!!----------------------------------------------------------------------
!! <EnamexOrgClt>: Cultural organizations
!!----------------------------------------------------------------------

Define CultGroupType
       [ {orkesteri} | {yhtye} | {kuoro} | {bändi} | {duo} | {trio} | {soittokunta} |
       	 [{tanssi}|{teatteri}|{baletti}|{solisti}|{komedia}|{sketsi}][{ryhmä}|{seurue}] |
       	 {kollektiivi} | {sirkus}({ryhmä}) ] ;

!* Olarin kuoro / Radion sinfoniaorkesteri / Berliinin filharmonikot
!* Ylioppilaskunnan Laulajat
Define CultGroupSuffixed1
       [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 | AlphaUp PropGen::0.05 ] WSep
       ( CapWordGen WSep )
       ( lemma_exact( {filharmoninen} ) WSep )
       [ lemma_ends( {orkesteri} | AlphaDown+ {yhtye} | {kuoro} | {soittokunta} ) |
       	 ["f"|"F"|"L"] lemma_exact( {filharmonikko} | {laulaja}, {NUM=PL}) ] ;

!* Xxx xxx xxx -yhtye
Define CultGroupSuffixed2A
       CapWord WSep
       [ LowerWord WSep ]+
       NotConj WSep
       DashExt lemma_ends( Ins(CultGroupType) ) ;

!* Xxx Xxx Xxx -yhtye
Define CultGroupSuffixed2B
       [ CapName WSep AndOfThe WSep | CapMiscExt WSep ]*
       Field [ AlphaUp | 0To9 ] ( Word WSep )
       Word WSep
       DashExt lemma_ends( Ins(CultGroupType) ) ;

!* Xxx-yhtye
Define CultGroupSuffixed3A
       [ [ AlphaUp Field ] - Cap( {rap} | Field (Dash) {rock} | Field {pop} | {jazz} | {eurodance} | {ambient} |
       	   	   	     	  {house} | {studio} | {radio} | {punk} | {hiphop} | {hip-hop} ) ]
				  Capture(CltCpt1) Dash AlphaDown Field FSep Field [ {orkesteri} |
				  {soittokunta} | {yhtye} | {kuoro} | {bändi} | {duo} | {trio} ] FSep Word ;

Define CultGroupSuffixed3B
       AlphaUp Field Capture(CltCpt2) Dash lemma_ends( Dash {niminen} ) WSep
       lemma_ends( Ins(CultGroupType) ) ;

! "Adolf Fredriks flickkör", "Bo Kaspers orkester", "Espoo Big Band"
! "UMO Jazz Orchestra", "EMO Ensemble"
Define CultGroupSuffixed4
       [ CapMiscExt WSep ]+
       inflect_sg( Field [ {Band} | {Ensemble} | {Orchestra} | ["o"|"O"]{rkester} | {kör} | {Kör} | {Duo} |
       		   	   {Sinfonietta} | {Trio} | {Quartet} | {Quintet} | {Singers} | {Dancers} | {Ballet} |
			   {Staatsballet} | {Girls} | {Boys} | {Dolls} | {Lads} | {Men} | {Ballerinas} | {Ladies} |
			   {Sisters} | {Gentlemen} | {Brothers}::0.10 ] ) ;

Define CultGroupSuffixed6
       ( CapMisc WSep )
       CapName WSep
       wordform_exact( {Dance} | {Ballet} | {Theater} | {Theatre} ) WSep
       inflect_sg( {Company} ) ;

Define CultGroupSuffixed5
       [ CapMisc WSep ]*
       inflect_sg( AlphaUp Field [ {orkester}("n") | {kör}({en}) | {sångförening}({en}) | {teater}("n") |
       		   	   	   {ballett} ] ) ;

!* "Tanssiorkesteri Helmenkalastajat", "Soitinyhtye Savonia"
Define CultGroupPrefixed1
       LC( NoSentBoundary )
       AlphaUp ( TruncPfx WSep lemma_exact({ja}) WSep )
       wordform_exact( AlphaDown+ [ {yhtye} | {trio} | {orkesteri} ]) WSep
       CapWord ;

Define CultGroupPrefixed2
       wordform_exact( {Ensemble} ) WSep
       ( CapMisc WSep )
       CapWord ;

Define GroupCommonNoun [ {lordi} | {mamba} | {aikakone} | {valvomo} | {alivaltiosihteeri} | {yö} | {tehosekoitin} |
       		       	 {värttinä} | {rajaton} | {raptori} | {järjestyshäiriö} | {teräsbetoni} | {dingo} |
			 {nirvana} ] ;

!* xxx Lordi / xxx Aikakone / xxx Yö / xxx Rajattomien
Define CultGroupCommonNoun
       LC( NoSentBoundary )
       Lst(AlphaUp) lemma_exact( GroupCommonNoun ) ;

! "Kansallismuseo"
Define CultOrgSuffixed1
       LC( NoSentBoundary )
       AlphaUp lemma_exact_morph( AlphaDown+ [ {museo} | {galleria} | {teatteri} | ("o" Dash){ooppera} | {kirjasto} ],
       	       			  {NUM=SG}) ;

Define CultOrgNational
       AlphaUp ( PropGeoGen WSep )
       lemma_exact( [ {kansallis} | {kansallinen} | {kaupungin} ] [ {ooppera} | {baletti} | {teatteri} | {museo} ]) ;

! "KOM-teatteri", "Kaisa-kirjasto", "Lenin-museo"
Define CultOrgSuffixed2
       AlphaUp lemma_ends( Dash [ AlphaDown* {museo} | {teatteri} | {kirjasto} | {galleria} ] ) ;
       !! Excluded "ooppera", e.g. "Aida-ooppera, Tosca-ooppera"

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
       wordform_exact( {Thêatre} | {Galleria} | {Théatre} | {Teatro} | {Opera} | {Opéra} | {Galleri}["a"|"e"] |
       		       {Bibliothéque} | {Theatre} | {Gallery} | {Musée} | {Muzej} | {Musei} | {Museum} | {Muzeum} |
		       {Museu} | {Museo} | {Library} | {Circo} | {Cirque} | {Sirkus} | {Ballet} ) WSep
       ( CapMisc WSep )
       [ ( CapWord WSep ) [ AndOfThe WSep ]+ ( CapNameNom WSep ) ]*
       [ CapMisc WSep ]*
       CapName ;

!* "Espoo Museum of Modern Art", "Tate Gallery", "Deutsche Oper Berlin", "National Gallery of British Art"
Define CultOrgSuffixed6
       [ Ins(CapMiscExt) WSep ]+
       inflect_sg( {Theatre} | {Gallery} | {Museum} | {Library}::0.25 | {Oper}("a") | {Teatern} | {Teater} )
       ( WSep [ AndOfThe WSep ]+ [ CapMisc WSep ]* CapName ) ;

Define CultOrgColloc1
       LC( lemma_morph( CultGroupType | {teatteri} , {CASE=NOM} ) WSep ( wordform_exact({nimeltä}) WSep ) )
       [ CapMiscExt WSep ]*
       wordform_exact( Field [ CapNameStr | AbbrStr ] Capture(CltCpt3) ) ;

Define CultOrgColloc2
       [ CapMisc WSep ]*
       [ PropGen | AbbrGen | CapNameGenNSB | lemma_exact_morph(GroupCommonNoun, {[CASE=GEN]}) ]
       RC( WSep lemma_ends( {single} | {albumi} | {fani} | [{hitti}|{uutuus}]{sinkku} | {kiertue} |
       	   		    {comeback} | {keikka} | {konsertti} | {laulaja} | {solisti} | {kitaristi} |
			    {basisti} | {rumpali} | {keikkatauko} | {roudari} ) ) ;

Define CultOrgColloc3
       [ CapMisc WSep ]*
       [ PropGen | AbbrGen | CapNameGenNSB ]
       RC( WSep lemma_ends( {kävijä}({määrä}) | {näyttely} | {kokoelma} | {intendentti} | {pääsymaksu} ) ) ;

Define CultGroupCaptured
       inflect_sg( CltCpt1 | CltCpt2 | CltCpt3 ) ;

Define CultGazMacro1
       [ m4_include(`gaz/gOrgCult.m4') ] ;

Define CultGazMacro2
       [ m4_include(`gaz/gOrgCultCongr.m4') ] ;

Define CultSemtag
       semtag({PROP=CULTGRP}) ;

! Category HEAD
Define CultOrg
       [ Ins(CultGroupSuffixed1)::0.25
       | Ins(CultGroupSuffixed2A)::0.25
       | Ins(CultGroupSuffixed2B)::0.25
       | Ins(CultGroupSuffixed3A)::0.60
       | Ins(CultGroupSuffixed3B)::0.25
       | Ins(CultGroupCaptured)::0.75
       | Ins(CultGroupSuffixed4)::0.30
       | Ins(CultGroupSuffixed5)::0.30
       | Ins(CultGroupSuffixed6)::0.25
       | Ins(CultGroupPrefixed1)::0.25
       | Ins(CultGroupPrefixed2)::0.40
       | Ins(CultOrgNational)::0.30
       | Ins(CultGroupCommonNoun)::0.50
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

Define SchoolType
       lemma_morph( {koulu} | {opisto} | {koulutuskeskus} | {koulukoti} | {akatemia} | {lyseo} | {lukio} |
       		    {oppilaitos} | {instituutti} | {instituutinen} | [{ala-}|{ylä}]{aste} | "k"["y"|"i"]{mnaasi} |
		    {koulutoimisto} | {konservatorio}, {NUM=SG}) ;

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

!* "Helsingin yliopisto"
Define SchoolName2A
       ( CapMisc WSep )
       [ CapNameGenNSB | AlphaUp PropGen ] EndTag(EnamexLocPpl2) WSep
       AlphaDown Ins(SchoolType)
       ( WSep Ins(SchoolFacultyDept) ) ;

!* "Teknillinen korkeakoulu",
Define SchoolName2F
       [ LC( NoSentBoundary) AlphaUp morphtag({POS=ADJECTIVE}) |
       	 AlphaUp lemma_ends({llinen}|{lainen}|{läinen}|{stinen}|{loginen}) ] WSep
       Alpha Ins(SchoolType) ;
       
!* Helsingin Suomalainen Yhteiskoulu, Turun Steiner-koulu
!* Savon ammatti- j aikuisopisto
!* "Porin seudun työväenopisto", "Tukholman kuninkaallinen yliopisto"
!* "Hämeen Rykmentin Urheilukoulu"
Define SchoolName2E
       AlphaUp PropGen EndTag(EnamexLocPpl2) WSep
       ( [ wordform_ends( OptCap( {seudun} | {rykmentin} )) | lemma_ends({inen}) ] WSep )
       ( TruncPfx WSep lemma_exact({ja}) WSep )
       Alpha Ins(SchoolType) ;

!* "Tekniikan Akatemia"
Define SchoolName2C
       CapWordGen WSep
       AlphaUp AlphaDown Ins(SchoolType) ;

!* "Chalmers tekniska högskola", "Svenska social- och kommunalhögskolan",
!* "Kirchliche Hochschule"
Define SchoolName2B
       CapMisc WSep
       ( ( TruncPfx WSep ) wordform_ends( LowercaseAlpha+ ) WSep )
       inflect_sg( Field [ {skol}[{an}|"a"|"e"] | {universitet} | {schule} | {akademi} ] ) ;

!* ""Yrkeshögskolan Novia"
Define SchoolName2G
       AlphaUp AlphaDown wordform_ends( Alpha+ [ (Dash) {opisto} | {skolan}] ) WSep
       CapName ;

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
       CapMiscExt WSep
       ( CapMiscExt WSep )
       ( wordform_exact( {High} | {Secondary} | {Primary} ) WSep )
       inflect_sg( {School} | {College} | {University} | {Academy} | {Institute} | {Gimnazija} | {Schule} )
       ( WSep wordform_exact({of})
       WSep CapWord
       ( ( WSep wordform_exact({and}) ) WSep CapWord ) )
       ( WSep DashExt AlphaDown Ins(SchoolType) ) ;

Define SchoolPrefixed
       wordform_exact( {École} | {Université} | {Università} | {Universidad} | {Lycée} | {Gimnasio} | {Gimnazija} |
       		       {Accademia} ) WSep
       ( Ins(WordsNom) )
       CapName ;

Define SchoolName5
       ( PropGeoGen WSep )
       AlphaUp [ wordform_ends( AlphaDown [ {ian} | {tieteen} | {logian} | {opin} | {iikan} ]) |
       	       	 lemma_ends( {inen} ) ] WSep
       lemma_exact( {laitos} | {tiedekunta} | {instituutti} ) ;

Define SchoolHyphen1
       ( Ins(WordsNom) )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt AlphaDown Ins(SchoolType) ;

!* Helsingin Rudolf Steiner -koulu
Define SchoolHyphen2
       PropGeo EndTag(EnamexLocPpl2) WSep
       [ CapMisc WSep ]*
       CapWord WSep
       Dash lemma_ends({koulu}) ;

Define SchoolNameGaz1
       wordform_exact({Carnegie}) WSep wordform_exact({Mellon}) WSep inflect_sg({University}) |
       inflect_sg( {Yale} | {Harvard} | {Stanford} | {MIT} | {TKK} | {MPKK} | {HY} | {UCL} | {Metropolia} | {Diak} |
       		   {Laurea} | {Tylypahka} | {Haaga-Helia} | {Arcada} | UppercaseAlpha {SU}::0.50 | {Humak} | {HUMAK} ) ;

Define SchoolNameGaz2
       lemma_exact( {aalto} Dash {yliopisto} | {maanpuolustuskorkeakoulu} | {aleksanteri} Dash {instituutti} |
       		    [ {metropolia} | {savonia} ] Dash {ammattikorkeakoulu} ) ;

Define SchoolNameGaz [ Ins(SchoolNameGaz1) | Ins(SchoolNameGaz2) ] ;

!* Category HEAD
Define EduOrg
       [ Ins(SchoolName1A)::0.25
       | Ins(SchoolName1B)::0.25
       | Ins(SchoolName2A)::0.25
       | Ins(SchoolName2B)::0.50
       | Ins(SchoolName2C)::0.30
       | Ins(SchoolName2D)::0.25
       | Ins(SchoolName2E)::0.25
       | Ins(SchoolName2F)::0.20
       | Ins(SchoolName2G)::0.25
       | Ins(SchoolName3)::0.25
       | Ins(SchoolName4)::0.25
       | Ins(SchoolName5)::0.25
       | Ins(SchoolHyphen1)::0.25
       | Ins(SchoolHyphen2)::0.25
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
       [ PropGeoGen | wordform_exact({Suomen}) | AlphaUp lemma_exact({kansainvälinen}) ] WSep
       lemma_morph({pankki} | AlphaDown {rahasto}, {NUM=SG}) ;

!* Postipankki Oy:n, Helsingin Osuuspankki Oy:n, Xxxxn Seudun Säästöpankki Oy:n
Define OrgFinBank2B
       ( [ [ CapNameGen EndTag(EnamexLocPpl2) WSep lemma_exact_morph( {seutu}, {CASE=GEN} ) ] |
       PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 ] WSep )
       AlphaUp lemma_morph( {pankki} , {CASE=NOM} ) WSep
       lemma_ends( {oy}("j") | {ky} ) ;

!* Lappeenrannan Osuuspankin
Define OrgFinBank2C
       [ [ CapNameGen EndTag(EnamexLocPpl2) WSep lemma_exact_morph( {seutu}, {CASE=GEN} ) ] |
       PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 ] WSep
       AlphaUp lemma_ends( {pankki} ) ;

!* "Handelsbanken", "Ålandsbanken", "Sparkasse", "Citibank"
Define OrgFinBank3
       ( Ins(CapMiscExt) WSep )
       inflect_sg( AlphaUp Field [ {banken} | {bank} | {kasse} ] ) ;

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
       [ Ins(CapMiscExt) | wordform_exact({Danske}) ] WSep
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

Define morphlem_p1(LEMMA, NUM)  [ Field FSep LEMMA FSep Field NUM ] ;
Define morphlem_p2(LEMMA, CASE) [ LEMMA Field CASE Field FSep Word ] ;

Define PublType     [ Field [ {lehti} | {julkaisu} | {blogi} | {blog} | {verkkomedia} | {uutissivusto} |
       		      	      {uutisportaali} ] ]
       		    - [ Field [ {välilehti} | {uudelleenjulkaisu} ] ] ;
Define MediaOrgType [ Field [ {uutistoimisto} | {yleisradioyhtiö} | {yleisradio} | {lehtitalo} | {kanava} ] ]
       		    - [ Field [ {murtautumiskanava} | {jakelukanava} ] ] ;  

Define SemMediaGen morphtag({SEM=MEDIA} Field {CASE=GEN}) ;

!* Helsingin Sanomat, Taloussanomat, Kansan Uutiset, Ilta-Sanomat, MTV Uutiset
!* Taloussanomat, Verkkouutiset
Define MediaFinSuffixed1
       [ [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB | AbbrNom ] WSep |
       	 LC( NoSentBoundary ) Lst(AlphaUp) AlphaDown ]
       morphlem_p1( Field [ {sanoma}("t") | {uutinen} | {uutiset} ], {NUM=PL}) ;

Define MediaFinSuffixed2
       [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB ] WSep
       AlphaUp morphlem_p1( {viikko} | AlphaDown* [ {seutu} | {lehti} ], {NUM=SG}) ;

Define MediaFinSuffixed3
       [ LC( NoSentBoundary ) Field | NoFSep+ ]
       Lst(AlphaUp) morphlem_p1( AlphaDown+ [ {lehti} | {aviisi} | {seutu} ], {NUM=SG}) Capture(MediaCpt0) ;

Define MediaFinSuffixed4
       ( PropGeoGen EndTag(EnamexLocPpl2) WSep )
       [ CapNounGenNSB | Lst(AlphaUp) lemma_ends({inen}) ] WSep
       morphlem_p1( {aikakauskirja} | {aikakauslehti}, {NUM=SG} ) ;

Define MediaFinHyphen1
       Field Lst(AlphaUp) Field Capture(MediaCpt1) Dash (lemma_ends(Dash {niminen}) WSep)
       AlphaDown morphlem_p1( Ins(PublType) | Ins(MediaOrgType) , {NUM=SG}) ;

Define MediaFinHyphen2
       ( Ins(WordsNom) )
       Field Lst(AlphaUp) Field Capture(MediaCpt2) FSep Word WSep
       Dash morphlem_p1( Ins(PublType) | Ins(MediaOrgType) , {NUM=SG}) ;

Define MediaFinHyphen3
       CapName WSep
       ( LowerWord WSep ) ( LowerWord WSep )
       [ [ Field Capture(MediaCpt3) FSep Word ] - CoordConj ] WSep
       Ins(DashExt) morphlem_p1( Ins(PublType) | Ins(MediaOrgType) , {NUM=SG}) ;

Define MediaFinHyphen4
       InQuotes WSep
       Ins(DashExt) morphlem_p1( Ins(PublType) | Ins(MediaOrgType) , {NUM=SG}) ;

Define MediaFinHyphen
       [ MediaFinHyphen1 | MediaFinHyphen2 | MediaFinHyphen3 | MediaFinHyphen4 ] ;

Define MediaSuffixed1
       [ Ins(CapMiscExt) WSep |
       Lst(AlphaUp) ] Field OptCap(@txt"gaz/gMediaSfxPart.txt") ;

Define MediaSuffixed2
       [ Ins(WordsNom) | Ins(CapMiscExt) WSep ]
       @txt"gaz/gMediaSfxWord.txt" ;

Define MediaPrefixed1
       ( wordform_exact( {La}("s") | {Le}("s") | {Il} | {El} | "O" | {Os} | "A" | {As} ) WSep | ["L"|"l"] Apostr )
       wordform_exact( @txt"gaz/gMediaPfxWord.txt" ) WSep
       ( ( CapName WSep ) Ins(DeLa) WSep )
       CapNameStr ;

Define MediaPrefixed2
       ( wordform_exact( {The} ) WSep )
       ( CapMisc WSep )
       wordform_exact( {Journal} | {Times} | {Annals} ) WSep
       [ [ Ins(AndOfThe) WSep ]+ ( CapName WSep ) ]+
       CapNameStr ;

Define MediaPrefixed3
       wordform_exact( {Canal} | {Channel} | {Chaîne} | {Kanal} | {TV} | {Canale} ) WSep
       1To9 (0To9) ;

Define MediaPrefixed4
       {TV} 1To9 ;

Define MediaCpt
       [ MediaCpt1 | MediaCpt2 | MediaCpt3 ] ;

Define MediaFinGaz [ m4_include(`gaz/gOrgMediaFin.m4') ] ;

Define MediaFinSuffixedGaz
       [ MediaFinSuffixed1 | MediaFinSuffixed2 | MediaFinSuffixed3 | MediaFinSuffixed4 | MediaFinGaz ] ;

Define MediaFin
       [ Ins(MediaFinHyphen) | OptQuotes( Ins(MediaFinSuffixedGaz) ) ] ;

Define MediaGaz [ m4_include(`gaz/gOrgMedia.m4') ] ;

Define MediaForeign
       [ MediaCpt | MediaSuffixed1 | MediaSuffixed2 |
       	 Ins(MediaPrefixed1) | Ins(MediaPrefixed2) | Ins(MediaPrefixed3) | Ins(MediaPrefixed4) | Ins(MediaGaz) ] ;

!--------------------------------------------------------

Define OrgMediaColloc1
       [ PropOrgGen | ( Ins(WordsNom) ) [ CapNameGenNSB | PropGen ]::0.50 ]
       RC( WSep lemma_exact( ({pää}){toimittaja} | {toimitus} | {toimituskunta} | {uutinen} | {uutiset} |
       	   		     {journalismi} | {pääkirjoitus} ) ) ;

Define OrgMediaColloc2
       LC( lemma_exact_morph( PublType | MediaOrgType, {[NUM=SG][CASE=NOM]}) WSep )
       ( Ins(WordsNom) )
       Field [ CapName | Abbr ] ;

Define OrgMediaColloc3
       LC( PosAdjOrd WSep lemma_exact_morph( PublType | MediaOrgType, {NUM=SG}) WSep )
       ( Ins(WordsNom) )
       Field [ CapName | Abbr ] ;

! Xxx:n otsikko, Hesarin otsikko
Define ProMediaColloc1
       [ morphlem_p2(Ins(MediaFin), {CASE=GEN}) | infl_sg_gen(Ins(MediaForeign)) |
      	 PropOrgGen | ( Ins(WordsNom) ) [ CapNameGenNSB | PropGen ]::0.50 ]
       RC( WSep lemma_exact( {kestotilaaja} | {lukija} | {lukijakunta} | {levikki} | {keskiaukeama} | {erikoisnumero} |
       	   		     {yleisönosasto} | {lööppi} | {otsikko} | {ilmestyminen} ) ) ;

!* Hesarin [kestotilaaja/erikoisnumero]
Define ProMediaDisamb1
       [ morphlem_p2(Ins(MediaFin), {CASE=GEN}) | infl_sg_gen(Ins(MediaForeign)) ]
       RC( WSep lemma_ends( {tilaaja} | {numero} | {sivu} | {ilmestyminen} | {liite} ) ) ;

!* [lukee] Hesaria
Define ProMediaDisamb2
       LC( lemma_exact( Field {tilata} | {lukea} | {lueskella} | {selailla} | {selata} ) WSep )
       [ morphlem_p2(Ins(MediaFin), {CASE=PAR}) | infl_sg_par(Ins(MediaForeign)) ] ;

Define OrgMedia
       OptQuotes( inflect_sg( Ins(MediaForeign) ) ) ;

Define OrgMediaFin
       morphlem_p2(Ins(MediaFin) | MediaCpt0, {CASE}) ;

!* Category HEAD
Define MediaOrg
       [ Ins(OrgMediaFin)::0.20
       | Ins(OrgMedia)::0.20
       | Ins(OrgMediaColloc1)
       | Ins(OrgMediaColloc2)
       | Ins(OrgMediaColloc3)
       ] EndTag(EnamexOrgTvr) |
       [ Ins(ProMediaColloc1)
       | Ins(ProMediaDisamb1)
       | Ins(ProMediaDisamb2)
       ] EndTag(EnamexProXxx) ;

!!----------------------------------------------------------------------
!! <EnamexOrgCrp>: Corporation
!! - Capitalized words followed by a common suffix "Inc.", "Group" etc.
!! - Capitalized words followed by another word typical for organizations
!! - Funder organizations: capitalized word(s) preceded by
!! the lemma "rahoittaja". Recognize all names in a list, separated by
!! commas, "ja" or "sekä".
!! ...
!!----------------------------------------------------------------------

!* "Supercell", "Vodafone"
Define CorpGuessedA
       inflect_sg( AlphaUp Alpha+ [ OptCap( @txt"gaz/gCorpSuff.txt" ) | {Media} ] ) ;

Define CorpGuessedB
       LC( NoSentBoundary )
       inflect_sg( AlphaUp Alpha+ [ {tel} | {media} ] ) ;

!-----------------------------------------------------------------------

Define AbbrInfl Abbr ;
Define AbbrBase AbbrNom ;

Define CorpSfxWordFin @txt"gaz/gCorpSuffWordFin.txt" ;

!-----------------------------------------------------------------------

! "Turku Energialle"
! "Yrittäjäin Vakuutukselle"
Define CorpSuffixedFin1A
       ( wordform_exact( {Oy} | {OY} | {Kommandiittiyhtiö} | {Ky} | {KY} ) WSep )
       [ AbbrBase | PropGeoGen EndTag(EnamexLocPpl2) ( WSep wordform_exact( OptCap({seudun}) ) ) |
       	 PropGeoNom EndTag(EnamexLocPpl2) | CapMisc | CapNameGenNSB ] WSep
       AlphaUp Alpha+ (Dash AlphaUp AlphaDown+) FSep ( Alpha+ Dash ) Alpha* Ins(CorpSfxWordFin) FSep Word ;

! "Turku Energia Oy:lle"
! "Yrittäjäin Vakuutus keskinäiselle yhtiölle"
Define CorpSuffixedFin1B
       [ AbbrBase | PropGeoGen EndTag(EnamexLocPpl2) ( WSep wordform_exact( OptCap({seudun}) ) ) |
       	 PropGeoNom EndTag(EnamexLocPpl2) | CapMiscExt | CapNameGenNSB | AlphaUp AlphaDown NounGen ] WSep
       ( TruncPfx WSep lemma_exact({ja}) WSep )
       AlphaUp Alpha+ (Dash AlphaUp AlphaDown+) FSep ( Alpha+ Dash ) Alpha* Ins(CorpSfxWordFin) FSep Field {CASE=NOM} Word WSep
       [ ( CapMisc WSep )
       	 lemma_exact( {kommandiittiyhtiö} | {osake} (Dash) {yhtiö} | {ky} | {oy} | {oyj} | {ab} | {abp} ) |
	 lemma_exact( {avoin} | {keskinäinen} ) WSep lemma_ends({yhtiö}) |
	 wordform_exact({Oy}) WSep "A" lemma_exact({ab}) ] ;

! "Royal Ravintolat"
Define CorpSuffixedFin1C
       [ CapMiscExt | AlphaUp Prop ] WSep
       Ins(gazCorpSuffixPartPl) ;

Define CorpSuffixedFin1D
       CapMiscExt WSep
       AlphaUp lemma_exact({keskinäinen}) WSep lemma_ends({yhtiö}) ;

!* Suomen Maksuturva Oy
!* HUOM: Esim. "Ihalainen" ei välttämättä tunnistu nimeksi -> lisänä {inen}-sääntö
Define CorpSuffixedFin2A
       ( [ PropGeoGen EndTag(EnamexLocPpl2) | CapNameGenNSB::0.05 | [ [ CapMisc | AbbrBase ] WSep ]* CapMisc |
       	   AbbrBase | NameInitial | CapWord WSep wordform_exact("&") ] WSep )
       [ CapMisc | ( TruncPfx WSep lemma_exact({ja}) WSep ) CapNounNomNSB | AbbrBase |
       	 LC( NoSentBoundary) wordform_exact(AlphaUp AlphaDown AlphaDown+ {inen}) ] WSep
       [ lemma_exact( {oyj} | {oy} | {ky} | {ab} | {abp} | {osake} (Dash){yhtiö} ) |
       	 wordform_exact({Oy}) WSep "A" lemma_exact({ab}) ] ;

!* Tunnista "Xxxx Oy" virkkeen alussa kun seuraava sana	ei ala isolla alkukirjaimella tai yhdysviivalla
Define CorpSuffixedFin2B
       ( [ AbbrBase | NameInitial | CapWord WSep wordform_exact("&") ] WSep )
       Field [ AlphaUp PropNom | CapName | AbbrNom | CapWordNom ] WSep
       [ [ AlphaUp lemma_exact( {oyj} | {oy} ({:öö}) | {ky} | {ab} | {abp} | {osakeyhtiö} )
       	 NRC( WSep [ AlphaUp | Dash AlphaDown ]) ] |
	 [ wordform_exact([ {Oy} | {Ab} | {OY} | {Ky} ] ":" CaseSfx ) ] ] ;

!* "Kymen Atk ja tekstinkäsittely Ky", Kymen Leikkaus- ja anestesiapalvelut Oy"
!* "Suomen nestesokeri Oy"
Define CorpSuffixedFin2C
       [ CapNameGenNSB | PropGeoGen ] ( WSep AlphaUp AlphaDown [ NounNom | TruncPfx ] ) WSep
       [ AlphaDown Word WSep ]^{1,3}
       lemma_exact( {oyj} | {oy} | {ky} | {osake} (Dash) {yhtiö} ) NRC( WSep [ AlphaUp | Dash AlphaDown ]) ;

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
		       {ravintola} | {autotalo} | {pesula} | {kiinteistö} | {autokoulu} |
		       AlphaDown (Dash) [ {kauppa} | {palvelu} | {yhtiö} | {tukku} | {liike} | {kone} | {toimisto} |
		       {myynti} ]
		       ]) ) WSep
       ( ( CapMisc WSep ) [ NameInitial WSep ]* | CapMisc WSep | CapWord WSep wordform_exact("&") WSep )
       [ CapName - lemma_exact({oy}) | AbbrInfl |
       	 [ CapMisc | AlphaUp AlphaDown [ NounNom | PosAdjNom ] | AbbrBase ] WSep
	 lemma_exact( {kommandiittiyhtiö} | {ky} | {oy} ) |
	 lemma_exact( {avoin} | {keskinäinen} ) WSep lemma_ends({yhtiö}) ] ;

Define CorpPrefixedFin2A
       ( CapNameGenNSB WSep )
       AlphaUp lemma_exact( {avoin} | {keskinäinen} ) WSep
       ( PropGeoGen WSep )
       lemma_ends( {yhtiö} ) WSep
       ( [ CapNameGen | CapMiscExt | (CapMisc WSep) PropFirstNom wordform_exact( {ja} | "&" ) PropFirstNom ] WSep )
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
       ( CapMisc WSep )
       CapName WSep
       wordform_exact( {Ab} | "&" ) WSep
       CapName ;

!* Xxx Xxx Technologies
Define CorpSuffixedMisc1
       [ Ins(CapMiscExt) WSep ]*
       ( CapWord WSep [ Ins(AndOfThe) WSep ]+ ( CapWord WSep ) )
       [ Ins(CapMiscExt) WSep ]*
       [ Ins(CapMiscExt) | LC(NoSentBoundary) [CapName - PropGeoGen] ] WSep ( Ins(AndOfThe) WSep )
       Ins(gazCorpSuffixWord)
       ( ( WSep AndOfThe ) WSep Ins(gazCorpSuffixWord) )
       NRC( WSep ( Word WSep ) Dash AlphaDown ) ;

!* Xxx Xxx Ltd.
Define CorpSuffixedMisc2
       [ Ins(CapMiscExt) WSep ]^{0,2}
       ( CapWord WSep [ Ins(AndOfThe) WSep ]+ ( CapWord WSep ) )
       [ Ins(CapMiscExt) WSep ]^{0,2}
       ( CapWord WSep [ Ins(AndOfThe) WSep ]+ ( CapWord WSep ) )
       [ Ins(CapMiscExt) | CapNameNSB | Prop ] WSep
       ( Ins(CorpSuffixAbbrNom) WSep )
       Ins(CorpSuffixAbbr) ;

!* "X. Xxxx & Xxxx" "Xxx Xxxx [ & | ja] Kumpp./Kumppanit/K:ni"

Define CorpAffixed
	[ Ins(CorpSuffixedFin1A) | Ins(CorpSuffixedFin1B) | Ins(CorpSuffixedFin1C) | Ins(CorpSuffixedFin1D) |
	  Ins(CorpSuffixedFin3)  |
	  Ins(CorpSuffixedFin2A) | Ins(CorpSuffixedFin2B) | Ins(CorpSuffixedFin2C) |
	  Ins(CorpPrefixedFin1)  | Ins(CorpPrefixedFin2A) | Ins(CorpPrefixedFin2B) |
	  Ins(CorpPrefixedFin3)  | Ins(CorpPrefixedFin4)  | 
	  Ins(CorpCircumfixed1)  | Ins(CorpCircumfixed2)  |
	  Ins(CorpInfixed1)::0.25 |
	  Ins(CorpSuffixedMisc1) | Ins(CorpSuffixedMisc2) ] ;

!-----------------------------------------------------------------------

!* "Asunto Oy Vuohikkalan Harhapolku 5", "Kiinteistöosakeyhtiö Blaa"
!* "As. Oy Jyväskylän maalaiskunnan Norolankuja 1", "As. Oy Neljäs linja 3"
Define CorpCondominium1
       [ "A" | "K" ] [ lemma_exact( {asunto} | {as.} | {kiinteistö} ) WSep
       	       	       lemma_exact_morph( {oy} | {osakeyhtiö}, {CASE=NOM})
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

Define OrgTypeStr [ {konserni} | {yritys} | {startup}(("p")"i") | {ketju} | {operaattori} | AlphaDown {valmistaja} |
       		    {yhtiö} | {osuuskunta} | {osuuskauppa} | {yhtymä} | {firma} | {pelitalo} | {varustamo} ] ;

Define OrgType lemma_morph( Ins(OrgTypeStr), {NUM=SG} ) ;

!-----------------------------------------------------------------------

Define CorpHyphen1A
       LC( NoSentBoundary )
       [ [ Field AlphaUp Field ] - [ {EU} | {LVI} | {IT} ] ] Capture(CorpCpt1) Dash ( lemma_ends( Dash {niminen} ) WSep ( PosAdjOrd WSep ) ) AlphaDown Ins(OrgType) ;

!* not: Levy-yhtiö, Öljy-yhtiö, see Exception below
Define CorpHyphen1B
       Field AlphaUp Field Capture(CorpCpt2) Dash AlphaDown Field FSep Field Ins(OrgTypeStr) FSep Field {NUM=SG} Word ;

Define CorpHyphen1C
       Field AlphaUp Field Dash Capture(CorpCpt3) AlphaUp lemma_ends( Dash [ {yhtymä} | {yhtiö} ]) ;

! Xxx Xxx -sijoitusyhtiö
Define CorpHyphen2A
       [ ( PropOrgNom WSep )
       ( CapWord WSep AndOfThe WSep ( CapWord WSep ))
       ( CapWord WSep AndOfThe WSep ( CapWord WSep ))
       ( CapWord WSep )
       wordform_exact( Field AlphaUp Field Capture(CorpCpt4) ) | InQuotes ] WSep
       DashExt [ Ins(OrgSuffixNoAbbr) | Ins(OrgType) ] ;

Define CorpHyphen2B
       ( CapMiscExt WSep )
       CapWord WSep
       ( wordform_exact([ AlphaDown | AlphaUp | 0To9 ] Field Capture(CorpCpt5)) WSep )
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
Define CorpSuffixedMisc3
       [ [ CapMiscExt WSep ]+ | PropOrg WSep ]
       inflect_sg( {Finland} | {Sweden} | {Europe} | {France} | {International} | {Worldwide} | {Global} | {Nordic} |
       		   {Scandinavia} | {China} | {Deutschland} | {UK} | {US}::0.20 | {Federal} |
		   @txt"gaz/gOrgRestaurantSfx.txt" )
       ( WSep OrgSuffixAbbr ) ;

!** "TKD Suomi", "Yara Suomi" (muttei: Sara Suomessa)
Define CorpSuffixedSuomi1
       [ PropOrgNom | AbbrNom ] WSep
       "S" lemma_exact_morph( {suomi}, {NUM=SG} Field {CASE=}[{NOM}|{PAR}|{PAR}|{ALL}|{ADE}|{ABL}|{TRA}] ) ;

Define CorpSuffixedSuomi2
       AbbrBase WSep
       "S" lemma_exact_morph( {suomi}, {NUM=SG}) ;

Define CorpPrefixedMisc
       wordform_exact( @txt"gaz/gCorpPfxWord.txt" ) WSep
       ( OptCap(DeLa) WSep )
       ( CapMisc WSep )
       CapName ;

Define CorpAffixedMisc
     [ Ins(CorpSuffixedMisc3) | Ins(CorpSuffixedSuomi1) | Ins(CorpSuffixedSuomi2) |
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
       ( wordform_exact( UppercaseAlpha) WSep )
       [ CapMiscExt WSep ]*
       Field [ Abbr | CapName | inflect_sg(UppercaseAlpha) ] ;

!  "Xxxx:n [markkinaosuus]"
Define CorpWithEconomy
       [ CapMisc WSep ]*
       [ [ CapNounGen - [ lemma_ends( {vuosi} | {firma} | {yksikkö} | {hetkinen} | {euro} | {dollari} | {neljännes} |
       	   	      	  	      {kuu} | {jakso} | {laite} | {yhtiö} | {yritys} | {miljardi} | {miljoona} ) ] ] |
	 Field CapNameGenNSB | Field AbbrGen ]
       RC( WSep lemma_ends( {osake} | {kurssi} | {liikevaihto} | {liiketappio} | {markkinaosuus} | {markkina-arvo} |
       	   		    {konkurssipesä} ) );

! "Xxxxxx:n [toimitusjohtaja/tytäryhtiö]"
! NB! "konttori" usually follows a LocPpl, not an OrgCrp
Define CorpWithEmployment
       ( CapMiscExt::0.20 WSep )
       Field [ CapNameGenNSB::0.30 | AbbrGen::0.20 ]
       RC( WSep lemma_ends(
		AlphaDown {johtaja} | {vetäjä} | {puuhamies} | {analyytikko} |
		{työntekijä} | {jäsen} | {jäsenmäärä} | {virkamies} |
		{toimihenkilö} | {henkilökunta} | {henkilöstö} | {mainostiimi} |
		{toimi}[{paikka}|{piste}] | {pääkonttori} | {asiakaspalvelu} | {pörssitiedote} |
		{tavaratalo} | {myymälä} | {asiakaspalvelija} | {telakka} | {tehdas} | 
		{tytäryhtiö} | {emoyhtiö} | [{huvi}|{teema}]{puisto} | {perustaja} |
		!! Establishments:
       		{tarjoilija} | {vastaanottovirkailija} | {respa} | {ravintolapäällikko} |
       	  	{siivooja} | {keittiömestari} | {ruokalista} | {menyy} | {viinilista} | {buffet} |
		{buffa} | {brunssi} ) ) ;

Define CorpWithXxx
       [ Ins(CorpWithEconomy)
       | Ins(CorpWithEmployment)
       ] ;

! Xxx [ lanseeraa / julkisti / on irtisanonut / ... ]
Define OrgColloc1
       [ [ CapMiscExt::0.20 WSep ]* CapMiscExt::0.50 | PropOrgNom::0.20 ]
       RC( [ WSep AuxVerb ]* WSep
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

Define CorpCaptured
       inflect_sg( [ CorpCpt1 | CorpCpt2 | CorpCpt3 | CorpCpt4 ] ) ;

Define CorpMWord
       [ m4_include(`gaz/gOrgCorpAll.m4') ] | inflect_sg( Ins(VehicleBrand) ) ;

!* Category HEAD
Define CorpOrgRules
       [ Ins(CorpGuessedA)::0.50 | Ins(CorpGuessedB)::0.75
       | Ins(CorpAffixed)::0.30
       | Ins(CorpAffixedMisc)::0.30
       | Ins(CorpCondominium)::0.25
       | Ins(CorpHyphen)::0.25
       | Ins(CorpColloc)::0.25
       | Ins(CorpCaptured)::0.50
       | Ins(CorpMWord)::0.15
       ] EndTag(EnamexOrgCrp) ;

!* Block "Öljy-yhtiö" and "Levy-yhtiö" in sentence-initial positions
Define ExceptionCorp1
       LC( SentBoundary )
       AlphaUp AlphaDown+ ADashA Ins(OrgType) ;

Define ExceptionCorp
       [ ExceptionCorp1 ] EndTag(Exc000) ;

Define CorpOrg
       [ CorpOrgRules | ExceptionCorp ] ;

!!----------------------------------------------------------------------
!! <EnamexOrgPlt>: Political parties, also when abbreviated and capitalized
!! NB: lowercase abbreviations stand for adjectives (kok. = kookomuslainen)
!!----------------------------------------------------------------------

! SDP, Kok., RKP
! NB: removed, these are adjectives
!Define PolitPartyAbbr1
!       LC( wordform_exact(LPar) WSep )
!       PartyMemberAbbr
!       RC( WSep wordform_exact(RPar) ) ;

Define PolitPartyAbbr2
       AlphaUp lemma_exact([ {sdp} | {skp} | {rkp} | {skdl} | {smp} | {nkp} | {lkp} | {ml} ]) ;

! "Kokoomus", "Vasemmistoliitto", "Perussuomalaiset"
Define PolitParty1A
       ["K"|"P"] lemma_exact( {kokoomus}({puolue}) | {vasemmisto}({liitto}) ) ;

! "Keskusta", "Kipu"
Define PolitParty1B
       LC( NoSentBoundary )
       [ ["K"|"P"] lemma_exact( {keskusta} | {kipu} | {perussuomalainen} | {perussuomalaiset} ) |
       	 wordform_exact({Keskusta}) ] ;

! "Keskustan [äänestäjät]" (muttei: "Keskustan [kävelykadut]")
Define PolitParty1C
       wordform_exact( {Keskustan} ({kin}|{kaan}) )
       RC( WSep lemma_ends( [ {eduskunta} | {puolue} | {valtuutettu} | {valtuusto} | {edustaja} |
	                     {äänestäjä} | {kannattaja} | {rivi} ] Field ) ) ;

! "Viskipuolue", "Piraattipuolue", "Oliivipuukoalitio"
Define PolitParty1D
       AlphaUp [ lemma_morph( AlphaDown [ (Dash) {puolue} | {koalitio} ], {NUM=SG} )
       - lemma_ends( [{hallitus}|{oppositio}|{valta}|{sisar}|{veljes}|{populisti}]{puolue} ) ];

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
       AlphaUp ( lemma_exact_morph(Ins(CountryName), {CASE=GEN}) EndTag(EnamexLocPpl2) WSep )
       lemma_exact( {vihreä} | {kirjava} ) WSep
       lemma_exact( {puolue} | {liitto} | {koalitio} ) ;

! "ruotsidemokraatit", "demarit", "?Ruotsin vihreät" (muttei: "Ruotsin vihreät niityt")
Define PolitParty3A
       AlphaUp lemma_exact_morph( AlphaDown+ {demokraatti} | {republikaani} | {perus} (?) {suomalainen} |
       	       			  {demari} ("t") | {moderaatti}, {NUM=PL} ) ;

! "ruotsidemokraatit", "demarit", "?Ruotsin vihreät" (muttei: "Ruotsin vihreät niityt")
Define PolitParty3B
       [ AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep | [ LC(NoSentBoundary) AlphaUp ] ]
       lemma_exact_morph( [ {demari} | {moderaatti} | {vihreä} | AlphaDown+ {demokraatti} ], {NUM=PL} )
       NRC( WSep morphtag({NUM=PL} Field {CASE=}) ) ;

! "Suomen työväenpuolue" (muttei: "Suomen puolue")
!
Define PolitParty4
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph([[ Field AlphaDown [ {puolue} | {liittouma} | {koalitio} ]]
       			    - [[{hallitus}|{oppositio}]{puolue}]], {NUM=SG})  ;

! "Ruotsin feministinen puolue", "Suomen ruotsalainen kansanpuolue" !! NB: PosAdj should congruate
Define PolitParty5A
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       [ [PosAdjSg - PosAdjCmp] | lemma_ends( AlphaDown AlphaDown AlphaDown {inen} ) ] WSep
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
       wordform_exact( {Alleanza} | {Alianza} | {Partia} | {Partido} | {Stranka} | {Democratici} | {Frente} |
       		       {Propuesta} ) WSep
       [ AndOfThe WSep ]*
       CapName ;

Define PolitWithAttribute
       LC( lemma_morph( {oikeistolainen} | {vasemmistolainen} | {konservatiivinen} | {maahanmuuttovastainen} |
       	   		{nationalistinen} | [{kansallis}| AlphaDown Dash ]{mielinen} | {populistinen} | {puolue},
			{NUM=SG}) WSep )
       ( CapMiscExt WSep )
       CapWord ;

Define PolitGenWithX
       [ CapNounGenNSB | CapNameGenNSB | AlphaUp PropGen | "K" lemma_exact_morph({keskusta}, {CASE=GEN}) ]
       RC( WSep lemma_ends( {kannattajakunta} | {äänestäjä} | {puheenjohtaja} | {äänenkannattaja} |
       	   		    {puoluesihteeri} | {kansanedustaja} | {äänimäärä} | {nuorisojärjestö} |
			    {jäsenmäärä} | {vaalimenestys} | {puoluejohto} | {presidenttiehdokas} |
			    {kannatus} | {valtuutettu} | {vaalimainos} | {puoluekirja} | {vaalityö} |
			    {eduskuntaryhmä} | {puolueohjelma} ) ) ;

Define PolitGaz1
       [ m4_include(`gaz/gOrgPartyMisc.m4') ] ;

Define PolitGaz2
       [ m4_include(`gaz/gOrgPartyFin.m4') ] ;
       

! "Ranskan parlamentti"
Define PolitLegislature1
       [ CapNameGenNSB | PropGeoGen ] EndTag(EnamexLocPpl2) WSep
       lemma_exact( {eduskunta} | {parlamentti} | {senaatti} | {kongressi} | {riigikogu} | {duuma} |
       		    [{folk}|{stor}]{ting}({et}) | {liittokokous} | {liittoneuvosto} | {kansalliskokous} ) ;

Define PolitLegislature2
       [ CapNounGen | PropGeoGen ] WSep
       ( NounGen WSep )
       lemma_exact( {edustajainhuone} ) ;

Define PolitLegislature3
       lemma_morph( {ruotsi} | {saksa}, {NUM=SG} Field {CASE=GEN} ) WSep
       lemma_morph( {liittopäivä} | {valtiopäivä}, {NUM=PL} ) ;

! "Suomen hallitus" (ei: Sipilän hallitus)
Define PolitGovernment
       [ AlphaUp lemma_exact_morph(Ins(CountryName), {CASE=GEN}) ] EndTag(EnamexLocPpl2) WSep
       lemma_exact( {hallitus} ) ;

! Category HEAD
Define PolitOrg
       [ Ins(PolitParty1A)::0.40
       | Ins(PolitParty1B)::0.40
       | Ins(PolitParty1C)::0.40
       | Ins(PolitParty1D)::0.40
       | Ins(PolitParty2A)::0.40
       | Ins(PolitParty2B)::0.40
       | Ins(PolitParty2C)::0.40
       | Ins(PolitParty3A)::0.40
       | Ins(PolitParty3B)::0.40
       | Ins(PolitParty4)::0.40
       | Ins(PolitParty5A)::0.40 | Ins(PolitParty5B)::0.40
       | Ins(PolitYouth)
       | Ins(PolitPartyAbbr2)
       | Ins(PolitWithAttribute)::0.75
       | Ins(PolitGenWithX)::0.75
       | Ins(PolitHyphen1)::0.25 | Ins(PolitHyphen2)::0.25
       | Ins(PolitSuffixedP)::0.25
       | Ins(PolitSuffixedWA)::0.50 | Ins(PolitSuffixedWB)::0.25
       | Ins(PolitPrefixed)::0.25
       | Ins(PolitGaz1)::0.10
       | Ins(PolitGaz2)::0.10
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
       [ [ lemma_morph( AlphaDown AlphaDown AlphaDown AlphaDown AlphaDown {inen}, {POS=ADJ}) - PosAdjCmp] |
       	 NounGen ] WSep
       lemma_morph( {seura} | {kannatusyhdistys} | {kerho}, {NUM=SG} ) ;

!** "Suomen Saunaseura", "Turun Ratagolfseura", "Suomi-Nigeria Ystävyysseura"
!** "Helsingin Pörssiklubi"
Define OrgSociety2
       [ CapWordGen EndTag(EnamexLocPpl2) | CapWordNomNSB ] WSep
       ( TruncPfx WSep lemma_exact({ja}) WSep )
       lemma_morph( AlphaDown [ {seura} | {klubi} | {kerho} ], {NUM=SG} ) ;

!** "Aleksis Kiven Seura", "Lauri Viita -seura", "Suomi-Unkari Seura" [!] (but not "Väinö Linnan seura")
!** "Suomen Urheilutoimittajien	Kerho"
Define OrgSociety3
       [ CapNameGen EndTag(EnamexLocPpl2) | CapMiscExt ] WSep
       (CapWordNomGen WSep)
       [ Dash | UppercaseAlpha ] lemma_morph([ {seura} | {klubi} | {kerho} ], {NUM=SG} ) ;

Define OrgSociety4
       AlphaUp AlphaDown lemma_morph( Dash [ {seura} | {yhdistys} ], {NUM=SG} ) ;
       
Define OrgSociety5
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_morph( AlphaDown [ {seura} | {yhdistys} | {klubi} | {kerho} ], {NUM=SG} ) ;

!** "Suomen Veturimiesyhdistys",
Define OrgSociety6
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_morph( AlphaDown [ {yhdistys} | {kerho} ], {NUM=SG}) ;

Define OrgSocietyPrefixed
       wordform_exact( {Société} | {Society} | {Societas} | {Associazione} | {Assemblée} | {Ordre} ("s") |
       		       {Unión} ) WSep
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

!* "Auto- ja kuljetusalan työtekijäliitto ry"
Define OrgSocietySuffixed3
       AlphaUp ( TruncPfx WSep lemma_exact({ja}) WSep )
       NounGen WSep
       Alpha lemma_ends( {liitto} ) WSep
       Ins(NpoSuffixAbbr) ;

!* Kuopion Yrittäjät
Define OrgSocietySuffixed4
       AlphaUp PropGeoGen EndTag(EnamexLocPpl2) WSep
       ( AlphaUp lemma_morph( {seutu} | {alue} , {CASE=GEN} ) WSep )
       AlphaUp lemma_exact_morph( AlphaDown+ [{aja}|{äjä}|{ija}|{ijä}], {NUM=SG})::0.25 ;

!** Länsi-Suomen metsänomistajain liitto
Define OrgUnion1
       AlphaUp ( [ PropGeoGen EndTag(EnamexLocPpl2) |
       [ NounGen EndTag(EnamexLocPpl2) WSep lemma_morph( {seutu} | {alue} , {CASE=GEN} ) ] ] WSep )
       ( NounGenPl | wordform_ends( AlphaDown [ {ajain} | {äjäin} | {ijain} | {ijäin} ] ) WSep )
       NounGen WSep
       lemma_exact( {liitto} ) WSep
       Ins(NpoSuffixAbbr) ;

Define OrgUnion2
       AlphaUp ( [ PropGeoGen EndTag(EnamexLocPpl2) |
       [ NounGen EndTag(EnamexLocPpl2) WSep lemma_morph( {seutu} | {alue} , {CASE=GEN} ) ] ] WSep )
       TruncPfx WSep lemma_exact({ja}) WSep
       NounGen WSep
       Alpha lemma_ends( {liitto} ) ;

Define OrgSociety
       [ Ins(OrgSociety1) | Ins(OrgSociety2) | Ins(OrgSociety3) |
       	 Ins(OrgSociety4) | Ins(OrgSociety5) | Ins(OrgSociety6) |
       	 Ins(OrgSocietyPrefixed)  | Ins(OrgSocietySuffixed1) |
	 Ins(OrgSocietySuffixed2) | Ins(OrgSocietySuffixed3) |
	 Ins(OrgSocietySuffixed4) |
	 Ins(OrgUnion1) | Ins(OrgUnion2) ]::0.25 ;

!-----------------------------------------------------------------------

!** "Päivän Nuoret", "Suomen Kristillisen Liiton Nuoret", "Suomen Keskustanuoret"
Define OrgYouth1
       [ PropGeoGen EndTag(EnamexLocPpl2) WSep [ CapWordGen::0.05 WSep ]* AlphaUp | [ LC(NoSentBoundary) AlphaUp ] ]
       lemma_morph( AlphaDown+ AlphaDown+ (Dash) {nuori}, {NUM=PL}) ;

!** Kalpaveljet, Ruusuritarit, Keskustanuoret
Define OrgCollective
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_ends( AlphaDown [ {nuori} | {veli} | {sisko} | {sisar} | {nainen} | {mies} |
       	       		 	     	       	 {poika} | {tyttö} | {ritari} ], {NUM=PL} ) ;

Define OrgYouth
       [ Ins(OrgYouth1) | Ins(OrgCollective) ] ;

!-----------------------------------------------------------------------

! "Itä-Suomen hovioikeus", "Helsingin raastuvanoikeus"
Define OrgJurid1
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       ( lemma_morph({piiri}, {CASE=GEN}) WSep )
       lemma_morph( [{hovi}|{käräjä}|{maa}|{raastuvan}|{hallinto-}|{kihlakunnan}|{vesi}|{ali}|{sota}] {oikeus},
       		    {NUM=SG}) ;

!* Euroopan ihmisoikeustuomioistuin
!* Helsingin KO/käräjäoikeus
Define OrgJurid2
       [ PropGeoGen ] EndTag(EnamexLocPpl2) WSep
       [ lemma_ends( {tuomioistuin} ) | ["H"|"M"|"K"|"R"] "O" lemma_exact( [ {ho} | {mo} | {ko} | {ro} ] (".") ) ] ;
       
! "Ranskan korkein oikeus"
Define OrgJurid3
       [ PropGeoGen ] EndTag(EnamexLocPpl2) WSep
       "k" lemma_exact({korkea}|{korkein}|{korkee}) WSep lemma_exact(({hallinto-}){oikeus}) ;

Define OrgJurid4
       wordform_exact( {Korkei}["n"|"m"] Field ) WSep 
       lemma_ends({oikeus}) ;

Define OrgJurid5
       LC( NoSentBoundary )       
       AlphaUp lemma_morph( Dash {oikeus}, {NUM=SG}) ;

Define OrgJurid
       [ Ins(OrgJurid1)::0.05 | Ins(OrgJurid2)::0.05 | Ins(OrgJurid3) | Ins(OrgJurid4) | Ins(OrgJurid5) ] ;

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
Define OrgMunicipalityB
       ( CapMisc WSep )
       [ AlphaUp PropGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph([ {kunta} | {kaupunki} ], {NUM=SG} Field {CASE=GEN})
       NRC( WSep ( [CapNameGen | PosNumOrd | PosAdj | wordform_exact( NumRoman ) ] WSep )
       	    [ lemma_ends( {asukas}({luku}|{määrä}) | {väki}({luku}|{äärä}) | {ulkopuol} Field | {väestö} | {katu} |
	      		  {läpi} | {lävitse} | {keskusta} | {lähiö} | {taajama} | {alue} | {esikaupunki} | {kylä} |
			  {kaupunginosa} | AlphaDown {puoli} | {pommitus} | {verilöyly} | {etelä} Field |
			  {pohjoi} Field | {länsi} Field | {itä} Field ) | wordform_exact(".") ] ) ;

! "Helsingin/Espoon/Rovaniemen kaupunki" -> kyseessä käytännössä aina ORG, paitsi
! 1) sisäpaikallissijoissa ja
! 2) genetiivissä, jos sitä seuraa tietty substantiivi tai postpositio (ks. yllä)
Define OrgMunicipalityC
       wordform_exact( {Helsingin} | {Turun} | {Espoon} | {Tampereen} | {Kuopion} | {Oulun} | {Rovaniemen} |
       		       {Jyväskylän} | {Lahden} | {Kajaanin} | {Hämeenlinnan} | {Savonlinnan} | {Mikkelin} | {Joensuu}
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
       ( wordform_exact( {US} | {American} | {British} | {Finnish} | {National} | {Federal} | {International} |
       	 		 {Global} ) WSep
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
		   {Consortium} |
		   {Federation} |
		   {Union} )
       [ [ WSep AndOfThe ]+ [ WSep CapMisc ]* WSep CapWord ]* ;

! Department of Homeland Security
Define OrgAgencyPrefixed
       wordform_exact( {Department} | {Society} )
       [ [ WSep AndOfThe ]+ [ WSep CapMisc ]* WSep CapWord ]+ ;

! "Suomen olympiakomitea", "Yhdysvaltain turvallisuusvirasto NSA", Helsingin syyttäjänvirasto"
Define OrgAgencyFin
       ( CapMisc WSep )
       [ PropGeoGen | CapNounGenNSB ] EndTag(EnamexLocPpl2) WSep
       ( lemma_exact( {kansallinen} | {kuninkaallinen} | {keisarillinen} ) WSep )
       ( wordform_ends(Dash) WSep wordform_exact({ja}) WSep )
       lemma_morph( AlphaDown [ {komitea} | {komissio} | {instituutti} | {virasto} | {viranomainen} | {ministeriö} |
       		    	      	{neuvosto} | {iedustelupalvelu} | {urvallisuuspalvelu} ], {NUM=SG}) ;

Define OrgAgencyGaz
       lemma_exact(DownCase(@txt"gaz/gOrgGovernm.txt")) ;

Define OrgAgency
       [ Ins(OrgAgencySuffixed) | Ins(OrgAgencyPrefixed) | Ins(OrgAgencyFin) | Ins(OrgAgencyGaz) ] ;    


!-----------------------------------------------------------------------

!* Suomen Leijonan Ritarikunta, Kultaisen taljan ritarikunta, Pyhän Yrjön ritaristo
Define OrgMiscOrderOf
       AlphaUp ( PropGeoGen EndTag(EnamexLogPpl2) WSep )
       ( LC( NoSentBoundary ) PosAdjGen WSep )
       [ LC( NoSentBoundary ) NounGen ] WSep
       lemma_exact_morph( {ritarikunta} | {ritaristo} ) ;

!-----------------------------------------------------------------------

Define OrgMiscTypeStr
       [ {virasto} | {ryhmä} | {yksikkö} | {liiga} | {verkkosivusto} | {organisaatio} | {uutiskanava} |
       	 {start} (Dash) {up} (("p")"i") | {ketju} | {mafia} | {järjestö} | {liike} | {ryhmä} | {aivoriihi} | {liiga} |
	 {kopla} | {divisioona} | {tiimi} | {säätiö} | {yhteisö} | {yksikkö} | {operaattori} | {jengi} | {ajatuspaja} |
	 {järjestö} | {organisaatio} | {laboratorio} | {tutkimuslaitos} | {kultti} | {lahko} | {komitea} ] ;

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
       ( CapWord WSep )
       wordform_exact( Field AlphaUp Field Capture(OrgXxxCpt1) )WSep
       DashExt lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

!* "Syrian Electronic Army", "Lizard Squad"
Define OrgMiscGuessed2
       ( wordform_exact({The}) WSep ( CapWord WSep) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ )
       [ CapMiscExt | CapNameNSB ] WSep
       inflect_sg( {Army} | {Squad} | {Team} | {Community} | {Brigade} )
       ( WSep wordform_exact({of}) WSep CapWord ) ;

Define OrgMiscHyphen2
       [ CapMisc WSep ]*
       ( CapWord WSep )
       wordform_exact( Field AlphaUp Field Capture(OrgXxxCpt2) ) WSep
       Dash lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

Define OrgMiscHyphen3
       LC( NoSentBoundary )
       Field AlphaUp [ ? - Dash ] Field Capture(OrgXxxCpt3) Dash lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

Define OrgMiscHyphen4
       [ [ AlphaUp Field ] - ADashAField ] FSep Field Dash Capture(OrgXxxCpt4) AlphaDown* Ins(OrgMiscTypeStr) FSep Field {NUM=SG} Word ;

Define OrgMiscHyphen5
       AlphaUp Field Dash Capture(OrgXxxCpt5) lemma_ends( Dash {niminen} ) WSep
       AlphaDown lemma_ends( Ins(OrgMiscTypeStr) ) ;

Define OrgMiscHyphen6
       CapName WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
         NotConj WSep )
       DashExt lemma_morph( Ins(OrgMiscTypeStr), {NUM=SG}) ;

Define OrgMiscCaptured
       inflect_sg( OrgXxxCpt1 | OrgXxxCpt2 | OrgXxxCpt3 | OrgXxxCpt4 | OrgXxxCpt5 ) ;

Define OrgMiscSuffixed1
       ( CapMisc WSep ) ( CapMisc WSep )
       inflect_sg( AlphaUp Field @txt"gaz/gOrgMiscSuff.txt" ) ;

Define OrgMiscSuffixed2
       ( CapMisc WSep ) CapMisc WSep
       inflect_sg( OptCap( AlphaDown* @txt"gaz/gOrgMiscSuff.txt" ) )
       ( WSep AndOfThe WSep CapWord ) ;

Define BoardType
       lemma_exact_morph([ Field AlphaDown [ {ministeriö} | {virasto} | {lautakunta} | {hallinto} ] ] -
       			   [ {hirmuhallinto} | {itsehallinto} | {paikallishallinto} | {feodaalihallinto} ], {NUM=SG}) ;

!* Viestintävirasto
!* Liikenne- ja viestintäministeriö
!* Suomen liikenne- ja viestintäministeriö
Define OrgMiscBoard
       AlphaUp ( [ PropGeoGen ] EndTag(EnamexLocPpl2) WSep )
       ( TruncPfx WSep
       lemma_exact({ja}) WSep )
       Ins(BoardType)
       ( WSep Abbr ) ;

!Define OrgMiscSpace
!       [ PropGeoGen ] EndTag(EnamexLocPpl2) WSep
!       lemma_exact( {avaruusjärjestö} | {avaruushallinto} )
!       ( WSep Abbr ) ;

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
	       AlphaDown+ [ {hallitus} ]
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
       [ PropGeoGen | CapNounGenNSB ] EndTag(EnamexLocPpl2) WSep
       ( [ PosAdj | NounGen ] WSep ) 
       [ lemma_exact_morph(({suojelu}|({keskus}){rikos}|{siveys}|{turvallisuus}|{huume}|{ratsu}){poliisi}, {NUM=SG}) |
       	 lemma_exact({salainen}) WSep lemma_exact( {palvelu} | {poliisi} ) ] ;

Define OrgMiscMafia
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_exact_sg({mafia}) ;

Define OrgMiscInstitute1
       LC( NoSentBoundary )
       AlphaUp Ins(gazNpoSuffixPart) ;

! Helsingin ja Uudenmaan sairaanhoitopiiri
Define OrgMiscInstitute2
       ( CapMisc WSep )
       ( PropGeoGen EndTag(EnamexLocPpl2) WSep lemma_exact({ja}) WSep ) 
       [ PropGeoGen EndTag(EnamexLocPpl2) | CapNounGenNSB |
       CapNameGen EndTag(EnamexLocPpl2) WSep
       lemma_exact_morph( [{maalais}]{kunta} | {kaupunki} |({osa}|{liitto}){valtio} | {prefektuuri} | {kanton}("i") |
       			  {lääni} | {seutu}, {[NUM=SG][CASE=GEN]}) ] WSep
       ( AlphaDown wordform_ends( AlphaDown Dash ) WSep lemma_exact({ja}) WSep )
       Ins(gazNpoSuffixPart)
       ( WSep Abbr ) ;

!
Define OrgMiscInstitute3
       [ CapNameGenNSB | PropGeoGen ] EndTag(EnamexLocPpl2) WSep
       ( AlphaDown TruncPfx WSep lemma_exact({ja}) WSep )
       Ins(gazNpoSuffixPart)
       ( WSep Abbr ) ;

Define OrgMiscInstitute4
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_ends({ainen}|{äinen}) WSep
       Ins(gazNpoSuffixPart)
       ( WSep Abbr ) ;

Define OrgMiscChurch
       [ lemma_exact_morph(Ins(CountryName), {CASE=GEN}) ] EndTag(EnamexLocPpl2) WSep
       ( lemma_ends( {evankelinen} | {katolinen} | {luterilainen} | {ortodoksinen} | {koptilainen} |
       	 	     {apostolinen} ) WSep )
       lemma_exact_morph([Field - [ Field [{kivi}|{tuomio}|{puu}|{paanu}|{sauva}] ]] {kirkko}, {NUM=SG}) ;

!-------------

! "Olarin seurakunta", "Helsingin juutalainen seurakunta", "Pyhän Paavalin luterilainen seurakunta", "Autuaan Hemmingin seurakunta"
Define OrgMiscCongregation1
       [ PropGeoGen EndTag(EnamexLocPpl2) | wordform_exact({Pyhän}|{Autuaan}) WSep CapNameGen ] WSep 
       ( lemma_ends( {evankelinen} | {katolinen} | {ortodoksinen} | {apstolinen} |
       	 	     AlphaDown AlphaDown AlphaDown [{lainen}|{läinen}] ) WSep )
       lemma_morph( {seurakunta}({yhtymä}), {NUM=SG} ) ;

!* "Turun Islamilainen Yhdyskunta"
Define OrgMiscCongregation2
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_ends( {evankelinen} | {katolinen} | {ortodoksinen} |
       		   AlphaDown AlphaDown AlphaDown [{lainen}|{läinen}] ) WSep
       lemma_morph( {yhdyskunta} ) ;

! "Xxx:n helluntaiseurakunta"
Define OrgMiscCongregation3
       [ CapNameGen | PropGeoGen ] EndTag(EnamexLocPpl2) WSep
       lemma_ends( AlphaDown {seurakunta} ) ;

Define OrgMiscCongregation4
       LC( NoSentBoundary )
       AlphaUp AlphaDown lemma_exact( AlphaDown+ {seurakunta} ) ;

Define OrgMiscCongregation
       [ OrgMiscCongregation1 | OrgMiscCongregation2 | OrgMiscCongregation3 | OrgMiscCongregation4 ] ;

!-------------

Define OrgMiscCathChapter
       [ CapNameGenNSB | PropGeoGen ] EndTag(EnamexLocPpl3) WSep
       ( lemma_morph({hiippakunta} , {NUM=SG} Field {CASE=GEN}) EndTag(EnamexLocPpl2) WSep )
       lemma_exact({tuomiokapituli}) ;

Define OrgMiscMilitary
       AlphaUp ( [ PropGeoGen ] EndTag(EnamexLocPpl2) WSep )
       lemma_exact_morph( [{puolustus}|{ase}|{ilma}|{meri}|{maa}]{voima}("t"), {NUM=PL} ) ;

Define OrgDynastyClan1
       CapNameStr lemma_morph( Dash [ {dynastia} | {klaani} ], {NUM=SG}) ;

Define OrgDynastyClan2
       [ PropGen | CapNameGenNSB ] EndTag(EnamexPrsHum2) WSep
       lemma_exact( [ {dynastia} | {klaani} ], {NUM=SG}) ;

Define OrgDynastyClan
       [ OrgDynastyClan1 | OrgDynastyClan2 ] ;

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
       infl_sg_locext( Ins(CorpOrPro) ) ;

!* "YouTuben [mukaan]"
Define OrgDisamb2
       [ infl_sg_gen( Ins(CorpOrPro) | Ins(CorpOrLoc) ) | Ins(PropOrgGen)::0.11 | Ins(WhiteHouseGen) |
       	 	      Field AbbrGen::0.50 ]
       RC( WSep wordform_exact( {mukaan} | {mielestä} | {kanssa} | {kannalta} ) ) ;

!* "YouTuben [perustaja/omistaja/pääkonttori/lakimies]"
Define OrgDisamb3
       [ infl_sg_gen( Ins(CorpOrPro) | Ins(CorpOrLoc) ) | Ins(PropOrgGen) | Ins(WhiteHouseGen) | Field AbbrGen::0.50 ]
       RC( WSep ( PosAdj WSep )
       	   lemma_ends( {edustaja} | {perustaja} | {työntekijä} |
	   	       [{toimitus}|{talous}|{markkinointi}|{myynti}|{hallinto}|{osaston}|{pää}|{laki}] {johtaja} |
	   	       {omistaja} | {konttori} | {osake} | {liikevaihto} | AlphaDown {mies} | {kurssi} | {liikevaihto} |
		       {liiketappio} | {markkinaosuus} | {listautuminen} | {palvelus} | {sijoittaja} | {blogi} |
	  	       {raportti} | {tiedote} | [{lehdistö}|{tiedotus}]{tilaisuus} | {suhtautuminen} | {lausunto} |
		       {syyte} | {anteeksipyyntö} | {reaktio} | {omaisuus} | {hallitus} | {suunnitelma} | {insinööri} |
		       {asiakaspalvelu} )) ;

Define OrgDisamb3B
       [ infl_sg_gen( Ins(CorpOrPro) | Ins(CorpOrLoc) ) | Ins(PropOrgGen) | Field AbbrGen::0.50]
       RC( WSep ( PosAdj WSep ) lemma_ends( {johtaja} ) ) ;

!* "[syyttää/moittii/arvostelee/uhkailee] Facebookia"
Define OrgDisamb4
       LC( lemma_exact( {syyttää} | {uhkailla} | {painostaa} | {moittia} | {arvostella} | {rahoittaa} |
       	   		{vaatia} ) WSep )
       [ infl_sg_par( Ins(CorpOrPro) ) | Ins(PropOrgPar) | Ins(WhiteHousePar) ]  ;

Define OrgDisamb5
       [ infl_sg_par( Ins(CorpOrPro) ) | Ins(PropOrgPar) | Ins(WhiteHousePar) ]
       RC( WSep wordform_exact( [ {syyttäv} | {uhkailev} | {moittiv} | {arvostelev} | {rahoittav} |
       	   			{sponsoroiv} ] Alpha+ | {vastaan} ) ) ;

Define MunicipalityNom
       ( CapMisc WSep )
       [ AlphaUp PropGen | CapNameGenNSB ] WSep
       lemma_exact_morph( ({maalais}){kunta} | {kaupunki}, {NUM=SG} Field {CASE=NOM} ) ;

!* Facebook [syyttää/uhkailee/arvostelee]
Define OrgDisamb6
       [ wordform_exact( Ins(CorpOrPro) | Ins(CorpOrLoc) ) | Ins(MunicipalityNom) | PropOrgNom | Ins(WhiteHouseNom) |
       	 CapMiscExt::0.80 ]
       RC( [ WSep AuxVerb | WSep PosAdv ]* WSep lemma_exact_morph(VerbOrg , {VOICE=ACT} ) ) ;

Define OrgDisamb7
       [ infl_sg_gen( Ins(CorpOrPro) ) | Ins(PropOrgGen) | Ins(WhiteHouseGen) | AbbrGen::0.50 ]
       RC( WSep wordform_exact( [ {sponsoroi} | {rahoitta} | {osta} | {omista} | {johta} | {kerto} ]
       	   			[{ma}|{mi}] AlphaDown* ) ) ;

Define OrgDisamb8
       [ infl_sg_gen( Ins(CorpOrPro) ) | Ins(PropOrgGen) | Ins(WhiteHouseGen) ]
       RC( WSep morphtag( {PROP=} [{FIRST}|{LAST}] ) ) ;

Define OrgDefStr @txt"gaz/gStatORG.txt" ;

Define OrgDefault
       inflect_sg( Ins(OrgDefStr) ) ;

Define OrgMiscGaz1 [ m4_include(`gaz/gOrgMisc.m4') ] ;
Define OrgMiscGaz2 [ m4_include(`gaz/gOrgMiscFin.m4') ] ;

!* Category HEAD
Define MiscOrg
       [ Ins(OrgSociety)
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
       | Ins(OrgMiscHyphen6)::0.60
       | Ins(OrgMiscCaptured)::0.50
       | Ins(OrgMiscSuffixed1)::0.25
       | Ins(OrgMiscSuffixed2)::0.25
       | Ins(OrgMiscBoard)::0.50
       | Ins(OrgMiscPolice)::0.50
       | Ins(OrgMiscMafia)::0.50
       | Ins(OrgMiscState)::0.50
       | Ins(OrgMiscCommon)::0.50
       | Ins(OrgMiscHospital)::0.50
       | Ins(OrgDisamb1)::0.10
       | Ins(OrgDisamb2)::0.10
       | Ins(OrgDisamb3)::0.10
       | Ins(OrgDisamb3B)::0.13
       | Ins(OrgDisamb4)::0.10
       | Ins(OrgDisamb5)::0.10
       | Ins(OrgDisamb6)::0.10
       | Ins(OrgDisamb7)::0.10
       | Ins(OrgDisamb8)::0.10
       | Ins(OrgMiscGaz1)::0.15
       | Ins(OrgMiscGaz2)::0.15
       | Ins(OrgDefault)::0.15
       | Ins(OrgMiscInstitute1)::0.50
       | Ins(OrgMiscInstitute2)::0.50
       | Ins(OrgMiscInstitute3)::0.50
       | Ins(OrgMiscInstitute4)::0.50
       | Ins(OrgMiscChurch)::0.25
       | Ins(OrgMiscCongregation)::0.50
       | Ins(OrgMiscCathChapter)::0.50
       | Ins(OrgDynastyClan)::0.50
       | Ins(OrgWhiteHouseExt)::0.50
       | Ins(OrgMiscMilitary)::0.50
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
!! <EnamexProXxx>: Products
!!----------------------------------------------------------------------

!!----------------------------------------------------------------------
!! Groceries & other food products and beverages
!!----------------------------------------------------------------------

Define FoodDrinkOrNot [ @txt"gaz/gTentativeFoodDrink.txt" | @txt"gaz/gProdFoodDrinkBrand.txt" ] ;
Define FoodDrinkType  [ Field @txt"gaz/gProdFoodDrinkType.txt" ] ;

Define ProdFoodDrinkHyphen1
       Field AlphaUp Field Capture(FoodCpt1) Dash lemma_exact( Field Dash Ins(FoodDrinkType) )::0.20 ;

Define ProdFoodDrinkHyphen2
       ( CapMisc WSep )
       [ CapWordNom | CapName | CapMisc ] WSep
       ( [ CapWordNom | CapMisc ] WSep )
       DashExt AlphaDown lemma_exact( (Dash) Ins(FoodDrinkType) )::0.20 ;

Define ProdFoodDrinkHyphen3
       Field AlphaUp Field Capture(FoodCpt2) Dash lemma_exact_sg( Field AlphaDown Dash {niminen} ) WSep
       lemma_exact_sg( Ins(FoodDrinkType) )::0.20 ;

Define ProdFoodDrinkColloc1
       LC( lemma_exact( {syödä} | {juoda} | {nauttia} | {kitata} ) WSep )
       [ ( CapMisc::0.20 WSep ) [ wordform_exact( Field AlphaUp Field Capture(FoodCpt3) Ins(ParSuff) ) ]::0.50 |
       	 infl_sg_par(FoodDrinkOrNot)::0.10 ] ;

Define ProdFoodDrinkColloc2
       LC( lemma_ends( {kylmä} | {kuuma} | {lämmin} | {haalea} | {makea} | {suolainen} | {kirpeä} | {hapan} |
       	   	       {huurteinen} | {virkistävä} | {makuinen} | {raikas} | {alkoholiton} | {pitoinen} ) WSep )
       [ ( CapMisc::0.20 WSep ) wordform_exact( Field AlphaUp Field Capture(FoodCpt4) )::0.50 |
       	 inflect_sg( Ins(FoodDrinkOrNot) )::0.10 ] ;

Define ProdFoodDrinkColloc3
       [ ( CapMisc::0.20 WSep ) CapMisc::0.50 | infl_sg_nom( Ins(FoodDrinkOrNot) )::0.10 ]
       RC( WSep lemma_exact( {maistua} | {sisältää} | {ravita} | {virkistää} ) ) ;

Define ProdFoodDrinkColloc4
       [ ( CapMisc::0.20 WSep ) CapMisc::0.50 | infl_sg_nom( Ins(FoodDrinkOrNot) )::0.10 ]
       RC( WSep lemma_exact({olla}) WSep wordform_exact( {hyvää} | {pahaa} | {halpaa} | {kallista} ) ) ;

Define ProdFoodDrinkColloc5
        [ ( CapMisc::0.20 WSep )
	  [ LC( NoSentBoundary) wordform_exact( Field AlphaUp Field Capture(FoodCpt5) Ins(GenSuff) ) ]::0.50 |
	  PropGen::0.55 | infl_sg_gen( Ins(FoodDrinkOrNot) )::0.10 ]
	RC( WSep ( PosAdj WSep ) lemma_exact( {maku} | {sivumaku} | {ainesosa} | {koostumus} | {makeus} | {resepti} |
	    	   	       	 	      {aromi} | {hapokkuus} | {ph} | {keksijä} | {valmistaja} | {suutuntuma} |
					      {suolaisuus} | {rasva} | {rasvaisuus} | {ravintosisältö} )) ;

Define ProdFoodDrinkCaptured
       inflect_sg( [ FoodCpt1 | FoodCpt2 | FoodCpt3 | FoodCpt4 | FoodCpt5 ] ( AddI ) )::0.60 ;

Define ProdFoodDrinkGaz1 [ m4_include(`gaz/gProdFoodDrinkMisc.m4') ]::0.20 ;
Define ProdFoodDrinkGaz2 [ m4_include(`gaz/gProdFoodDrinkFin.m4') ]::0.20 ;

Define ProdFoodDrink
       [ Ins(ProdFoodDrinkHyphen1)
       | Ins(ProdFoodDrinkHyphen2)
       | Ins(ProdFoodDrinkHyphen3)
       | Ins(ProdFoodDrinkColloc1)
       | Ins(ProdFoodDrinkColloc2)
       | Ins(ProdFoodDrinkColloc3)
       | Ins(ProdFoodDrinkColloc4)
       | Ins(ProdFoodDrinkColloc5)
       | Ins(ProdFoodDrinkCaptured)
       | Ins(ProdFoodDrinkGaz1)
       | Ins(ProdFoodDrinkGaz2)
       ] EndTag(EnamexProXxx) ;

!!----------------------------------------------------------------------
!! Fruit and vegetable cultivars (mostly grapes)
!!----------------------------------------------------------------------

Define CultivarType [ ({viini}) {rypäle} ({lajike}) | {lajike} ] ;

Define ProdCultivarHyphen1
       AlphaUp AlphaDown+ Capture(CvarCpt1) Dash lemma_exact( Field Dash CultivarType )::0.20 ;

Define ProdCultivarHyphen2
       ( CapMisc WSep )
       CapName WSep
       ( [ CapName | LowerWord ] WSep )
       DashExt lemma_exact( (Dash) CultivarType )::0.20 ;

Define ProdCultivarHyphen3
       AlphaUp Field Capture(CvarCpt2) Dash lemma_exact_sg( Field AlphaDown Dash {niminen} ) WSep
       lemma_exact_sg( CultivarType )::0.20 ;

Define ProdCultivarCaptured
       inflect_sg( CvarCpt1 | CvarCpt2 )::0.60 ;

Define ProdCultivarGaz [ m4_include(`gaz/gProdCultivar.m4') ]::0.20 ;

Define ProdCultivar
       [ Ins(ProdCultivarHyphen1)
       | Ins(ProdCultivarHyphen2)
       | Ins(ProdCultivarHyphen3)
       | Ins(ProdCultivarCaptured)
       | Ins(ProdCultivarGaz)
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Video games
!------------------------------------------------------------------------

Define GameSfx  [ {3D} | {DX} | {Plus} | {Deluxe} | {64} ] ;
Define GameType lemma_ends( {peli} | {pelisarja} | {räiskintä} | {taso}[{hyppely}|{loikka}] | {seikkailu} |
       			    ["j"|{mmo}]{rpg} | {simulaattori} | {pelikokoelma} ) ;

Define gazProGame [ m4_include(`gaz/gProdGame.m4') ] ;

Define ProGameHyphen1
       AlphaUp Field Capture(GameCpt1) Dash Ins(GameType) ;

Define ProGameHyphen2
       ( [ CapMisc WSep ]*
       	 [ AlphaUp | 0To9 ] Word WSep lemma_exact(":") WSep )
       [ CapMiscExt WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ [ CapWord WSep ]* )
       Field [ AlphaUp | 0To9 ] ( Word WSep )
       [ NoFSep - SentencePunct ] Field Capture(GameCpt2) FSep Word WSep
       DashExt Ins(GameType) ;

Define ProGameHyphen3
       InQuotes WSep
       DashExt Ins(GameType) ;

Define ProGameGaz
       ( CapMisc WSep )
       gazProGame
       ( WSep AlphaUp AlphaDown+ FSep Word )
       ( WSep wordform_exact([ Ins(NumRoman) | Ins(GameSfx) | 0To9 ]) )
       ( WSep wordform_exact([ Ins(NumRoman) | Ins(GameSfx) | 0To9 ](":" AlphaDown+)) )
       ( WSep lemma_exact(":")
       	 WSep CapWord ( [ WSep CapWord ]* [ WSep AndOfThe ]+ WSep CapWord )
       	 [ WSep CapName ]* )
       ( WSep Dash Ins(GameType) )
       NRC( WSep Dash Word ) ;

Define ProGameColloc
       LC( lemma_exact( {pelata} ) WSep )
       ( Ins(WordsNom) )
       wordform_exact( Field [ AbbrStr | CapNameStr ] Capture(GameCpt3) Ins(ParSuff) )
       NRC( WSep wordform_exact( {vastaan} ) ) ;

Define ProGameCaptured
       inflect_sg( GameCpt2 ) ;
       !inflect_sg( GameCpt1 | GameCpt2 | GameCpt3 (AddI) ) ;

Define ProGame
       [ Ins(ProGameHyphen1)::0.30
       | Ins(ProGameHyphen2)::0.25
       | Ins(ProGameHyphen3)::0.25
       | OptQuotes(Ins(ProGameGaz))::0.25
       | Ins(ProGameColloc)::0.60
       | Ins(ProGameCaptured)::0.60
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Film & Television
!------------------------------------------------------------------------

Define FilmTVType
       lemma_ends( [{elokuva}|{leffa}]({sarja}) |
       		   [{tv-}|{televisio}|{kultti}|{animaatio}|{draama}|{komedia}|{sketsi}|
		   {piirros}| {scifi-}|{sci-fi}|{scifi}|{tieteis}|{reality}|{jännitys}] {sarja} | {jatko-osa} |
		   {trilogi} ("a") | {tetralogi} ("a") | {sketsi} | {talkshow} | {spinoff} | {spin} (Dash) {off} |
		   {komedia} | {draama} | {animaatio} | {trilleri} | {anime} | {telenovela} | {dokkari} | {show} |
		   {dokumentti} | {epookki} | {tragedia} | {musikaali} | {tieteisfantasia} |
		   {avaruusooppera} | {saippuaooppera} | {reality} | {tosi-tv-}[{kilpailu}|{kisa}] | {tietovisa} |
		   {ooppera} | {näytelmä} | {klassikko} | {operetti} | {baletti} | {farssi} | {satiiri} ) ;

Define gazProFilmTV [ m4_include(`gaz/gProdFilmTvMWordW.m4') ] ;

Define ProFilmTVGazL
       [ m4_include(`gaz/gProdFilmTvMWordL.m4') ] ;

Define ProFilmTVGazW
       gazProFilmTV
       ( WSep CapName )
       ( WSep wordform_exact([ NumRoman | 0To9 ](":" AlphaDown+)) )
       ( WSep lemma_exact( ":" | Dash )
       	 WSep CapWord ( [ WSep CapWord ]* [ WSep AndOfThe ]+ WSep CapWord )
	 [ WSep CapName ]* )
       ( WSep DashExt Ins(FilmTVType) )
       NRC( WSep Dash AlphaDown ) ;

Define ProFilmTVSuffixed1
       AlphaUp Field Capture(FilmCpt1) Dash lemma_ends( Ins(FilmTVType) ) ;

Define ProFilmTVSuffixed2
       ( [ CapMisc WSep ]*
	 [ AlphaUp | 0To9 ] Word WSep lemma_exact(":") WSep )
       [ CapMisc WSep ]*
       ( CapWord WSep [ AndOfThe WSep ]+ [ CapWord WSep ]* )
       [ CapMisc WSep ]*
       [ AlphaUp | 0To9 ] Field Capture(FilmCpt2) FSep Word WSep
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
       RC( WSep lemma_exact( {ensi-ilta} | {katsojaluku} | {tuottaja} | {käsikirjoittaja} | {ohjaaja} |
       	   		     {käsikirjoitus} | AlphaDown* {pääosa} | {kuvaus} | ["o"|"ö"]{skausi} | {pilottijakso} |
			     {päätösjakso} | {pääosa} | {päähenkilö} | {tarina} | {prologi} ) ) ;

! X:n elokuva Y, elokuvassa Y
Define ProFilmColloc
       LC( WSep [ ? - Dash ] [ FilmTVType | lemma_ends( {ohjelma} ) ] WSep ( wordform_exact({nimeltä}) WSep ) )
       [ [ CapMisc WSep ]* CapName ( ( WSep CapWord ) WSep [ AndOfThe WSep ]+ CapWord )::0.75 | InQuotes ] ;

Define ProFilmTvCaptured
       inflect_sg( FilmCpt1 | FilmCpt2 )::0.60 ;

Define ProFilmTV
       [ Ins(ProFilmTVSuffixed1)::0.25
       | Ins(ProFilmTVSuffixed2)::0.25
       | Ins(ProFilmTVSuffixed3)::0.25
       | OptQuotes(Ins(ProFilmTVGazW))::0.25
       | OptQuotes(Ins(ProFilmTVGazL))::0.25
       | Ins(ProFilmTVWith)::0.60
       | Ins(ProFilmColloc)::0.20
       | Ins(ProFilmTvCaptured)
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Books & Literature
!------------------------------------------------------------------------

Define LitType [ [ ( AlphaDown Field ) [ {kirja}({sarja}) | {elämäkerta} | {teos} | {romaani}({sarja}) | {novelli} |
       	       	    	      	      	{dekkari}({sarja}) | [{runo}|{novelli}|{essee}]{kokoelma} | {essee} | {runo} |
					{sarjakuva} | {sarjis} | {manga} | {jännäri} | {trilleri} | {näytelmä} |
					{ooppera} | {klassikko} ] ]
	      	- [ Field [ {asiakirja} | {väitöskirja} | {opaskirja} | {pöytäkirja} ] ] ] ;

Define ProLitHyphen1
       [ CapMisc WSep ]*
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       Dash lemma_exact( (Dash) Ins(LitType) ) ;

Define ProLitHyphen2
       LC( NoSentBoundary )
       AlphaUp Field Capture(LitCpt1) Dash lemma_ends( Dash Ins(LitType) ) ;

Define ProLitHyphen3
       InQuotes WSep
       DashExt lemma_exact( (Dash) Ins(LitType) ) ;

Define ProLitHyphen4
       ( wordform_exact({The}) WSep ( CapWord WSep ) ( CapWord WSep ) )
       [ CapMisc WSep ]*
       [ CapWord WSep [ AndOfThe WSep ]+ (CapWord WSep) ]+
       [ CapMisc WSep ]*
       ( CapWord WSep )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt lemma_ends( Ins(LitType) ) ;

Define ProLitColloc
       LC( lemma_exact(LitType) WSep ( wordform_exact({nimeltä}) WSep ) )
       [ ( Ins(WordsNom) ) CapNameStr Capture(LitCpt2) FSep Word | InQuotes ] ;

Define ProLitCaptured
       inflect_sg( LitCpt1 | LitCpt2 )::0.60 ;

Define ProLitGaz
       [ m4_include(`gaz/gProdLitMWord.m4') ] ;

Define ProLiterature
       [ Ins(ProLitHyphen1)::0.250
       | Ins(ProLitHyphen2)::0.250
       | Ins(ProLitHyphen3)::0.250
       | Ins(ProLitHyphen4)::0.250
       | Ins(ProLitCaptured)
       | Ins(ProLitColloc)::0.750
       | OptQuotes(Ins(ProLitGaz))::0.100
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Artwork, Paintings
!------------------------------------------------------------------------

Define ArtType {taideteos} | {maalaus} | AlphaDown {värityö} | {performanssi} | {kollaasi} | {installaatio} |
       	       {potretti} | {muotokuva} | {litografia} | {fresko} | {muraali} | {triptyykki} | {musiikkivideo} ;

Define ProArtSuffixed1
       Ins(WordsNom)
       CapName WSep
       ( [ NoFSep - SentencePunct ] Word WSep )
       DashExt lemma_ends(Ins(ArtType)) ;

Define ProArtSuffixed2
       LC( NoSentBoundary )
       AlphaUp Field ( Word WSep ) Dash lemma_ends(Ins(ArtType)) ;

Define ProArtSuffixed3
       InQuotes WSep
       DashExt lemma_ends(Ins(ArtType)) ;

Define ProArtSuffixed4
       CapName WSep
       ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep
       DashExt lemma_ends(Ins(ArtType)) ;

Define ProArtColloc
       LC( lemma_exact(ArtType) WSep ( wordform_exact({nimeltä}) WSep ) )
       [ CapName ( ( WSep CapWord ) WSep [ AndOfThe WSep ]+ CapWord ) | InQuotes ] ;

Define ProArtSemtag
       OptQuotes( semtag({PROP=ARTWORK}) ) ;

Define ProArtwork
       [ Ins(ProArtSuffixed1)::0.25
       | Ins(ProArtSuffixed2)::0.25
       | Ins(ProArtSuffixed3)::0.25
       | Ins(ProArtSuffixed4)::0.25
       | Ins(ProArtSemtag)::0.50
       | Ins(ProArtColloc)::0.75
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Vehicles & Vessels
! - ships, boats, jachts
! - airplanes, helicopters, airships
! - automobiles, motorcycles, bikes
! - trains, locomotives
! - armored and military vehicles
! - space shuttles
!------------------------------------------------------------------------

Define VehicleBrandNom wordform_exact(Ins(VehicleBrand)) ;
Define VehicleType lemma_ends( @txt"gaz/gProdVehicleType.txt" ) ;

Define ProVehicleSuffixed1A
       LC( NoSentBoundary )
       [ AlphaUp | 0To9 ] Field Capture(VehicCpt1) Dash Ins(VehicleType) ;

Define ProVehicleSuffixed1B
       [ [ AlphaUp Field Dash AlphaDown ] - ADashAField ] Ins(VehicleType) ;

Define ProVehicleSuffixed1
       [ Ins(ProVehicleSuffixed1A) | Ins(ProVehicleSuffixed1B) ] ;

Define ProVehicleSuffixed2
       [ CapMiscExt WSep ]*
       ( [ AlphaUp | 0To9 ] Word WSep )
       [ NoFSep - SentencePunct ] Field Capture(VehicCpt3) FSep Word WSep
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
       inflect_sg( @txt"gaz/gProdVehicleModel.txt" ) ;

Define ProVehicleBrandPl
       [ inflect_pl( VehicleBrand | @txt"gaz/gProdVehicleModel.txt" ) - lemma_exact({kiina}|{kiista}) ] ;

Define ProVehicleBrandLocInt
       infl_sg_locint( Ins(VehicleBrand) ) ;

Define ProVehicleColloc1
       [ PropGen::0.40 | LC( NoSentBoundary) wordform_exact( CapNameStr Capture(VehicCpt4) Ins(GenSuff) )::0.60 |
       	 infl_sg_gen( Ins(VehicleBrand) )::0.10 ]
       RC( WSep lemma_exact( [{taka}|{etu}|{nahka}]{penkki} | {istuin} | {moottori} | {tuulilasi} | {ratti} |
       	   		     {konepelti} | {pakoputki} | {takakontti} | {verhoilu} | {rengas} | {vaihteisto} |
			     {ohjattavuus} | {ohjaustuntuma} | {käyntiääni} | {tankkaaminen} | {tankkaus} | {takalasi} |
			     {sivupeili} | {poljin} | {kytkin} | {kojelauta} | {bensamittari} | {mittari} |
			     {ohjekirja} | {kuljettaja} | {kuski} | {kyyti} | {kyydissä} | {kyytiin} | {kyydistä} |
			     {bensatankki} | {polttoainetankki} | {takaveto} | {takavalo} | {vaihdelaatikko} |
			     {varoitusvalo} | {merkkivalo} | {runko} | {keula} | {huoltaminen} | {vuosihuolto} |
			     {katsastus} | {vilkku} | {ohjaamo} | {hansikaslokero} | {vaihdekeppi} | {käsivaihde} |
			     {hylky} | {haaksi} )) ;

Define ProVehicleColloc2
       LC( lemma_exact( {uusi} | {upouusi} | {kiiltävä} | {tuliterä} | Field Color ) WSep )
       inflect_sg( Ins(VehicleBrand) ) ;

Define ProVehicleColloc3
       LC( lemma_exact( {tankata} | {virittää} | {huoltaa} | {pestä} | {katsastaa} | {vuokrata} | {kiillottaa} ) WSep )
       [ ( CapMisc WSep ) CapWord::0.50 |
       	 wordform_exact( Ins(VehicleBrand) [ Ins(GenSuff) | Ins(NomSuff) | Ins(ParSuff) ] ) ] ;

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

Define ProVehicleCaptured
       inflect_sg( VehicCpt1 | VehicCpt3 | VehicCpt4 (AddI) )::0.60 ;

Define ProVehicle
       [ Ins(ProVehicleSuffixed1)::0.25
       | Ins(ProVehicleSuffixed2)::0.25
       | Ins(ProVehicleSuffixed3)::0.25
       | Ins(ProVehicleColloc1)::0.00
       | Ins(ProVehicleColloc2)::0.00
       | Ins(ProVehicleColloc3)::0.00
       | OptQuotes(Ins(ProVehiclePrefixed1)::0.60)
       | OptQuotes(Ins(ProVehicleMisc1)::0.30)
       | OptQuotes(Ins(ProVehicleShipNameA)::0.25)
       | OptQuotes(Ins(ProVehicleShipNameB)::0.25)
       | Ins(ProVehicleShipSpecial)::0.20
       | Ins(ProVehicleQuotes)::0.75
       | Ins(ProVehicleBrandPl)::0.20
       | Ins(ProVehicleBrandLocInt)::0.10
       | Ins(ProVehicleCaptured)
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Music
!------------------------------------------------------------------------

Define MusicType
       lemma_exact( Field [ {laulu} | {kappale} | {biisi} | {single} | {sinkku} | {albumi} | {cd} | {pitkäsoitto} |
       		    	    {älppäri} | {levy} | {tango} | {valssi} | {vinyyli} | {hitti} | {renkutus} ] |
			    (Dash) [ {ep} | {trilogia} | {sinfonia} | {tetralogia} | {konsertto} | {menuetti} |
			    {aaria} | {avausraita} | {lopetusraita} | {päätösraita} ] ) ;

Define ProMusicSuffixed1
       ( wordform_exact( {A} | {The} | {Of} | {From} | {In} ) WSep )
       [ [ CapMisc | ( CapName WSep ) AndOfThe ] WSep ]*
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
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Awards, Prizes, Scholarships
!------------------------------------------------------------------------

Define AwardType
       {palkint} ["o"|"a"] | {mitali} | {pokaali} | {pysti} | [{kunnia}|{ansio}]{merkki} | {kunniamaininta} |
       {tunnustus} | {suurristi} | {ansioristi} | {stipendi} ;

Define ProAwardSuffixed1
       AlphaUp Field Dash lemma_ends( Ins(AwardType) ) ;

Define ProAwardSuffixed2
       ( Ins(WordsNom) )
       CapName WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       Dash lemma_ends( Ins(AwardType) ) ;

Define ProAwardSuffixed3
       [ CapMiscExt WSep | (CapName WSep) AndOfThe WSep ]* 
       CapName WSep
       inflect_sg( {Award} | {Prize} | {Medal} | {Trophy} )
       [ WSep [ AndOfThe WSep ]+ CapWord ( WSep CapMisc ) ]*
       ( WSep inflect_sg( {Finland} | {Sweden} ) ) ;

Define ProAwardSuffixed4
       InQuotes WSep
       DashExt lemma_ends( Ins(AwardType) ) ;

Define ProAwardSuffixed5
       AlphaUp lemma_exact(Ins(CountryName), {NUM=SG} FSep {CASE=GEN} ) EndTag(EnamexLocPpl3) WSep
       [ AlphaUp ( PosAdjGen WSep ) NounGen | CapNameGen ] EndTag(EnamexOrgCrp2) WSep
       ( wordform_exact( {ritarikunnan} ) )
       lemma_exact( {suurristi} | {ansioristi} ) ;

! "Jussit", "Nobelit", "Oscarit"
Define ProAwardGazPl
       AlphaUp lemma_exact_morph(
       	       [ {jussi} | {emma} | {emmy} | {oscar} | {venla} | {nobel} ], {NUM=PL} ) ;

Define ProAwardGaz1
       AlphaUp lemma_exact( {grammy} | {emmy} | {telvis} | {razzie} | {effie} | {pulitzer} | {guldbagge} | {bafta} |
       	       		    {aacta} ) ;

Define ProAwardGaz2
       inflect_sg( {Grammy} | {Razzie} | {Bafta} | {Pulitzer} | {Guldbagge} | {Aacta} | {BAFTA} | {AACTA} ) ;

Define ProAwardGaz3
       wordform_exact({Golden}) WSep inflect_sg( {Globe} | {Raspberry} ) |
       wordform_exact({Nobelin}) EndTag(EnamexPrsHum2) WSep lemma_ends( {palkinto} ) ;

Define ProAwardCommemorative1
       [ CapMisc WSep ]* 
       CapName WSep
       [ CapNameGen | PropGen ] EndTag(EnamexPrsHum2) WSep
       lemma_exact( {muistopalkinto} ) ;

Define ProAwardCommemorative2
       PropFirst WSep
       PropLast EndTag(EnamexPrsHum2) WSep
       Dash lemma_ends( {palkinto} ) ;
       
Define ProAward
       [ Ins(ProAwardSuffixed1)
       | Ins(ProAwardSuffixed2)
       | Ins(ProAwardSuffixed3)
       | Ins(ProAwardSuffixed4)
       | Ins(ProAwardSuffixed5)
       | Ins(ProAwardGazPl)
       | Ins(ProAwardGaz1)
       | Ins(ProAwardGaz2)
       | Ins(ProAwardCommemorative1)
       | Ins(ProAwardCommemorative2)
       | Ins(ProAwardGaz3)
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Pharmaceuticals & narcotics
!------------------------------------------------------------------------

Define ProDrugType lemma_ends( @txt"gaz/gProdDrugType.txt" ) ;

Define ProDrugHyphen1A
       LC( NoSentBoundary )
       AlphaUp Field Capture(DrugCpt1) Dash Field Ins(ProDrugType) ;

Define ProDrugHyphen1B
       [ [ AlphaUp Field Dash AlphaDown Field Ins(ProDrugType) ] - ADashAField ] ;

Define ProDrugHyphen2
       AlphaUp Field Capture(DrugCpt3) Dash lemma_ends( Dash {niminen} ) WSep
       Ins(ProDrugType) ;

Define ProDrugHyphen3
       ( CapMisc WSep )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt Ins(ProDrugType) ;

!* Xxx:n vaikuttava aine
Define ProDrugColloc1
       [ PropGen | LC( NoSentBoundary ) wordform_exact( Field CapNameStr Capture(DrugCpt4) Ins(GenSuff) ) ]::0.50
       RC( WSep [ lemma_exact( {sivuvaikutus} | {kauppanimi} | {viihde}[{käyttö}|{käyttäjä}] ) |
       	   	  wordform_exact({vaikuttav} Field) WSep lemma_exact({aine}) ] ) ;

!* Xxx [25 mg]
Define ProDrugColloc2
       wordform_exact( Field CapNameStr Capture(DrugCpt5) )::0.75
       RC( WSep wordform_exact( 1To9 ("0") ["0"|"5"] )
       	   WSep wordform_exact( {mg} | {mcg} | {µg} ) ) ;

Define ProDrugColloc3
       LC( lemma_exact( {määrätä} | {napsia} | {syödä} ) WSep )
       wordform_exact( Field CapNameStr Capture(DrugCpt6) Ins(ParSuff) )::0.75 ;

Define ProDrugCaptured
       inflect_sg( DrugCpt1 | DrugCpt3 | DrugCpt5 | [ DrugCpt4 | DrugCpt6 ] (AddI) )::0.60 ;

Define gazProDrug
       [ m4_include(`gaz/gProdDrug.m4') ] ;

Define ProDrugGaz
       OptQuotes( Ins(gazProDrug) )
       ( WSep DashExt Ins(ProDrugType) ) ;

Define ProDrug
       [ Ins(ProDrugHyphen1A)::0.25
       | Ins(ProDrugHyphen1B)::0.25
       | Ins(ProDrugHyphen2)::0.25
       | Ins(ProDrugHyphen3)::0.25
       | Ins(ProDrugColloc1)
       | Ins(ProDrugColloc2)
       | Ins(ProDrugColloc3)
       | Ins(ProDrugGaz)
       | Ins(ProDrugCaptured)
       ] EndTag(EnamexProXxx) ;

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
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Projects & Operations
!------------------------------------------------------------------------

Define ProjectType
       lemma_ends( {projekti} | {hanke} | {avaruusohjelma} | {operaatio} | {kampanja} ) ;

Define ProProjectHyphen1
       AlphaUp Field Dash Field Ins(ProjectType) ;

Define ProProjectHyphen2
       ( CapMisc WSep )
       CapName WSep
       ( ( CapWord WSep )
       	 ( ( LowerWord WSep ) ( LowerWord WSep )
	   NotConj WSep ) )
       DashExt Ins(ProjectType) ;

Define ProProjectHyphen3
       InQuotes WSep
       DashExt Ins(ProjectType) ;

Define ProProjectSuffixed
       [ CapMisc WSep ]*
       [ CapMisc ] WSep
       inflect_sg( {Project} | {Operation} | {Program}({me}) ) ;

! "Project MKUltra", "Operation Desert Storm"
Define ProProjectPrefixed1
       wordform_exact( {Project} | {Operation} | {Projekti} | OptCap({operaatio}) ) WSep
       ( CapMisc WSep ) ( CapMisc WSep )
       CapWord ;

! "operaatio Valettu lyijy"
Define ProProjectPrefixed2
       wordform_exact( OptCap({operaatio}) ) WSep
       AlphaUp ( PosAdj WSep )
       PosNoun ;

Define ProProject
       [ Ins(ProProjectHyphen1)::0.25
       | Ins(ProProjectHyphen2)::0.25
       | Ins(ProProjectHyphen3)::0.25
       | OptQuotes(Ins(ProProjectPrefixed1)::0.50)
       | Ins(ProProjectPrefixed2)::0.50
       | OptQuotes(Ins(ProProjectSuffixed)::0.50)
       ] EndTag(EnamexProXxx) ; 


!------------------------------------------------------------------------
!* Agreements
!------------------------------------------------------------------------

!* Geneven sopimus, Daytonin rauhansopimus
Define ProAgreementSuffixed1
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       [ lemma_ends( {sopimus} ) - lemma_ends( {työsopimus} ) ] ;

!* 
Define ProAgreementHyphen1
       [ CapMisc WSep ]*
       ( CapWord WSep )
       Word WSep
       Dash AlphaDown lemma_ends( {sopimus} ) ;

!* Dayton-Pariisi-sopimus
Define ProAgreementHyphen2
       AlphaUp lemma_morph( Dash {sopimus}, {NUM=SG} ) ;

!*
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
       ] EndTag(EnamexProXxx) ;

!------------------------------------------------------------------------
!* Technology: Hardware, Software, Electronics, Social Media, Internet
!* Weapons: firearms, explosives
!------------------------------------------------------------------------

Define VersNum	wordform_exact( 0To9+ ["." [ 0To9 | "x" | "X" ]+ ]* ) ;
Define VersSeq 	[ lemma_exact( {v.} | (Dash) {versio} ) WSep
       		  [ VersNum WSep wordform_exact({ja}|Comma|"&"|Dash) WSep ]* VersNum ] ;

Define ModelString
       ([ AlphaUp | 0To9 ]+ Field) [ AlphaUp 0To9 | 0To9 AlphaUp ] (Field [ AlphaUp | 0To9 ]) ;

Define MiscTechName 	 [ m4_include(`gaz/gProdTechMisc.m4') ] ;
Define BrowserName	 [ m4_include(`gaz/gProdBrowser.m4') ] ;
Define DeviceName	 [ m4_include(`gaz/gProdDevice.m4') ] ;
Define OSName		 [ m4_include(`gaz/gProdOS.m4') ] ;
Define AppStoreName	 [ m4_include(`gaz/gProdAppStore.m4') ] ;
Define SearchEngineName	 [ m4_include(`gaz/gProdSearchEngine.m4') ] ;

Define DeviceType   [ @txt"gaz/gProdDeviceType.txt" ] ;
Define OSType	    [ {käyttöjärjestelmä} ({versio}) | {käyttis} | {ympäristö} | {alusta} ] ;
Define SoftwareType [ @txt"gaz/gProdSoftwareType.txt" ] ;

Define ProdTechSfx  [ @txt"gaz/gProdTechSfx.txt" ] ;
Define ProdTechPfx  [ @txt"gaz/gProdTechPfx.txt" ] ;

Define ProdTechType [ Ins(OSType) | Ins(DeviceType) | Ins(SoftwareType) | @txt"gaz/gProdTechType.txt" ] ;

Define ProdTechTentative [ @txt"gaz/gTentativeProdTech.txt" ] ;

!!----------------------------------------------------------------------

Define ProdTechHyphen1A
       LC( NoSentBoundary )
       UppercaseAlpha LowercaseAlpha+ Capture(TechCpt1) Dash LowercaseAlpha Field FSep Field Ins(ProdTechType) FSep Word ;

Define ProdTechHyphen1B
       [ [ AlphaUp Field Dash AlphaDown Field ] - [ ADashAField ] ] FSep Field Ins(ProdTechType) FSep Word::0.10 ;

Define ProdTechHyphen1C
       Field [ Alpha | 0To9 ] Field [ AlphaUp ] Field Capture(TechCpt2) Dash lemma_ends( Dash Field Ins(ProdTechType) ) ;

Define ProdTechHyphen1D
       Field Alpha Field 0To9 Field Capture(TechCpt3) Dash lemma_ends( Dash Field Ins(ProdTechType) ) ;

Define ProdTechHyphen1E
       Field [ AlphaUp | 0To9 ] Field Capture(TechCpt4) Dash ["n"|"m"] lemma_ends( Dash {niminen} | {merkkinen} ) WSep
       lemma_ends( Ins(ProdTechType) ) ;

Define ProdTechHyphen1
       [ [ [ CapMisc | Serial ] WSep ]* TruncPfx WSep Coord WSep ]*
       [ Ins(ProdTechHyphen1A) | Ins(ProdTechHyphen1B) | Ins(ProdTechHyphen1C) | Ins(ProdTechHyphen1D) |
       	 Ins(ProdTechHyphen1E) ]::0.20 ;

Define ProdTechHyphen2
       [ [ CapMisc | Serial ] WSep ]+
       ( VersNum WSep )
       [ [ CapMisc | Serial ] WSep ]*
       ( Field CapName WSep )
       ( VersNum WSep )
       DashExt lemma_ends( Ins(ProdTechType) )::0.20 ;

Define ProdTechHyphen3
       [ CapMisc | Serial | Field CapName | NumNom ] WSep
       ( [ VersNum | Serial ] WSep )
       DashExt lemma_ends( Ins(ProdTechType) )::0.20 ;

Define ProdTechHyphen4
       [ CapMisc | Serial | Field CapNameNom ] WSep
       ( [ CapMisc | Serial | Field CapName ] WSep )
       DashExt lemma_ends( Ins(ProdTechType) )::0.20 ;

Define ProdTechHyphen5
       [ [ CapMisc | ( CapName WSep ) AndOfThe ] WSep ]*
       CapWord WSep
       DashExt lemma_ends( Ins(ProdTechType) )::0.20 ;

Define ProdTechHyphen6
       InQuotes WSep
       DashExt lemma_ends( Ins(ProdTechType) )::0.20 ;

Define ProdTechHyphen7
       [ [ [ CapMisc | Serial ] WSep ]* TruncPfx WSep Coord WSep ]+
       [ [ CapMisc | Serial | VersNum ] WSep ]+
       DashExt lemma_ends( Ins(ProdTechType) )::0.20 ;

Define ProdTechHyphenAppStore
       Ins(AppStoreName) ( FSep Word WSep )
       Dash lemma_ends( {kauppa} ) ;

Define ProdTechPrefixed
       ( CapMisc WSep )
       wordform_exact( Ins(ProdTechPfx) ) EndTag(EnamexOrgCrp2) WSep
       [ [ CapMisc | Serial ]::0.10 WSep ]* 
       [ ( VersNum WSep ) Field CapWord |
       	 ( CapMisc WSep ) 1To9 Word ]::0.35
       ( DashExt lemma_ends( Ins(ProdTechType) ) ) ;

Define ProdTechSuffixed1
       [ [ CapMisc | Serial ] WSep ]+
       inflect_sg( ( AlphaUp Field ) Ins(ProdTechSfx) )::0.30 ;

Define ProdTechSuffixed2
       [ [ CapMisc | Serial ] WSep ]+
       wordform_exact( ( AlphaUp Field ) Ins(ProdTechSfx) ) WSep
       [ Serial WSep ]*
       [ CapWord::0.10 | 1To9 Word ]::0.30 ;

Define ProdTechSuffixed3
       [ [Field CapName] - PropOrgGen] WSep
       inflect_sg( Ins(ProdTechSfx) )::0.30 ;

Define ProdTechSuffixed4
       [ [Field CapName] - PropOrgGen] WSep
       wordform_exact( Ins(ProdTechSfx) ) WSep
       lemma_exact( 0To9 0To9 0To9 (0To9) | 0To9 [ "." 0To9 ]+ )::0.30 ;

Define ProdTechSuffixed5
       ( CapMisc WSep )
       [ CapMisc | Serial ] WSep
       ( [ CapMisc | Serial ] WSep )
       [ lemma_exact( 0To9 [ "." 0To9 ]+ ) | inflect_sg( Ins(ModelString) ) ]::0.30 ;

Define ProdTechGuessed
       wordform_exact( Alpha+ Ins(ProdTechSfx) )::0.50 ;

Define ProdTechVersion
       [ [ CapMisc | Serial ] WSep ]*
       [ Field CapNameGenNSB | wordform_ends( UppercaseAlpha Ins(GenSuff) ) | CapMisc | Serial ] WSep
       [ (Dash) VersSeq | VersNum Dash lemma_ends( Dash {versio} ) | lemma_exact({beta} (Dash) {versio}) ] ;

Define ProdTechColloc1
       [ ( CapMiscExt WSep ) [ CapNameGenNSB | AbbrGen ]::0.50 | infl_sg_gen( Ins(ProdTechTentative) )::0.10 ]
       RC( WSep ( PosAdj WSep )
       	   AlphaDown lemma_ends( {akku} | {anturi} | {asennus} | {asentaminen} | {asetus} | {beta} | {estäminen} |
	   	     		 {haavoittuvuus} | {hinta} | {julkaisija} | {julkaisu} | {julkistus} | {kaatuminen} |
				 {kamera} | {käyttäjä} | {käyttäjäkunta} | {käyttö} | {käyttöehto} |
				 {käyttöjärjestelmä} | {käyttöliittymä} | {kehittäjä} | {kuvake} | {laajenuus} |
				 {lähdekoodi} | {laitteisto} | {lanseeraus} | {lisenssi} | {menekki} | {myyntimäärä} |
				 {näppäimistö} | {näppäin} | {laturi} | {näppämistö} | {näyttö} | {ominaisuus} |
				 {päivitys} | {painike} | {prosessori} | {prototyyppi} | {ruutu} | {sammuttaminen} |
				 {sovellus} | {suoritin} | {suosio} | {tallennustila} | {toimitusmäärä} | {valikko} |
				 {valmistaja} | {varuste} | {versio} | {yhteensopivuus} | {ylläpitäjä} | {tyyppivika} |
				 {algoritmi} ) ) ;

Define ProdTechColloc2
       [ ( CapMisc WSep ) [ CapNameGenNSB | AbbrGen ]::0.50 | infl_sg_gen( Ins(ProdTechTentative) )::0.10 ]
       RC( WSep wordform_exact( {avulla} | {välityksellä} | {kautta} ) ) ;

Define ProdTechColloc3
       LC( [ lemma_exact_morph( {käyttää} | {asentaa} | {ladata} | {hyödyntää} | {kehittää} | {päivittää} | {poistaa} |
       	     			{julkaista}, {VOICE=ACT}) - morphtag({PCP=VA}) ] WSep ( PosAdv WSep ) )
       [ [ CapMisc WSep ]* [ Field infl_sg_par(CapNameStr) ]::0.50 | infl_sg_par( Ins(ProdTechTentative) ) ] ;

Define ProdTechColloc4
       LC( [ lemma_exact_morph( {asentaa} | {ladata} | {kehittää} | {päivittää} | {julkistaa} )
       	     - morphtag({PCP=VA}) ] WSep ( PosAdv WSep ) )
       [ [ CapMisc WSep ]* [ Field CapName | Abbr ]::0.50 |
       	 wordform_exact( Ins(ProdTechTentative) [ Ins(GenSuff) | Ins(NomSuff) ]) ] ;

Define ProdTechDisamb
       infl_sg_locint( Ins(ProdTechTentative) ) ;

Define ProdTechCaptured
       inflect_sg( TechCpt1 | TechCpt2 | TechCpt3 | TechCpt4 ) ;

Define ProdTechGaz1
       wordform_exact( Ins(DeviceName) | Ins(OSName) | Ins(BrowserName) | Ins(MiscTechName) | Ins(AppStoreName) ) WSep
       ( [ CapMisc | Serial ] WSep )
       ( VersNum::0.20 WSep )
       [ CapWord::0.20 | ( CapMisc WSep ) 1To9 Word ]::0.20 ;

Define ProdTechGaz2
       inflect_sg( Ins(DeviceName) | Ins(OSName) | Ins(AppStoreName) |
       	 	   Ins(BrowserName) | Ins(MiscTechName) | Ins(SearchEngineName)::0.10 ) ;

Define ProdTechGazPl
       inflect_pl( DeviceName | OSName | BrowserName | MiscTechName )::0.10 ;

Define ProdTechRules
       [ Ins(ProdTechHyphen1)
       | Ins(ProdTechHyphen2)
       | Ins(ProdTechHyphen3)
       | Ins(ProdTechHyphen4)
       | Ins(ProdTechHyphen5)
       | Ins(ProdTechHyphen6)
       | Ins(ProdTechHyphen7)
       | Ins(ProdTechHyphenAppStore)
       | OptQuotes(Ins(ProdTechPrefixed))
       | OptQuotes(Ins(ProdTechSuffixed1))
       | OptQuotes(Ins(ProdTechSuffixed2))
       | OptQuotes(Ins(ProdTechSuffixed3))
       | OptQuotes(Ins(ProdTechSuffixed4))
       | OptQuotes(Ins(ProdTechSuffixed5))
       | Ins(ProdTechVersion)
       | Ins(ProdTechGuessed)
       | Ins(ProdTechColloc1)
       | Ins(ProdTechColloc2)
       | Ins(ProdTechColloc3)
       | Ins(ProdTechColloc4)
       | Ins(ProdTechDisamb)
       | Ins(ProdTechCaptured)::0.60
       | OptQuotes(Ins(ProdTechGaz1))
       | Ins(ProdTechGaz2)::0.16	!! NB! OptCap() voi vääristää painoa!
       | Ins(ProdTechGazPl)
       ] EndTag(EnamexProXxx) ;

Define ExceptionProd1
       [ Ins(OSName) | Ins(BrowserName) ] Dash lemma_ends( Dash Field [ Ins(DeviceType) | {päivitys} ]) ;

Define ExceptionProd2
       wordform_exact( Ins(OSName) | Ins(BrowserName) ) WSep
       ( VersNum WSep )
       Dash lemma_ends( Ins(DeviceType) ) ;

Define ExceptionProd3
       [ Ins(DeviceName) | Ins(OSName) | Ins(AppStoreName) ]
       Dash lemma_ends( Dash Field [ Ins(SoftwareType) | {päivitys} | {peli} ]) ;

Define ExceptionProd4
       wordform_exact( Ins(OSName) ) WSep
       ( VersNum WSep )
       Dash lemma_ends( Ins(SoftwareType) | {päivitys} | {peli} ) ;

Define ExceptionProd5
       wordform_exact( Ins(DeviceName) | Ins(AppStoreName) ) WSep
       Dash lemma_ends( Ins(SoftwareType) | {päivitys} | {peli} ) ;

Define ExceptionProd6
       lemma_exact([{facebook}|{twitter}] Dash [{päivitys}|{sovellus}|{ryhmä}|{yhteisö}]) ;

Define ExceptionProd7
       lemma_exact([{mars}|{pluto}] Dash [{luotain}|{mönkijä}]) ;

Define ExceptionProd
       [ Ins(ExceptionProd1)
       | Ins(ExceptionProd2)
       | Ins(ExceptionProd3)
       | Ins(ExceptionProd4)
       | Ins(ExceptionProd5)
       | Ins(ExceptionProd6)
       | Ins(ExceptionProd7)
       ] EndTag(Exc000) ;

Define ProdTech
       [ Ins(ProdTechRules)
       | Ins(ExceptionProd)
       ] ;


!!-----------------------------------------------------------------------
!! Artifacts & Miscellanea
!!-----------------------------------------------------------------------

! "Xxx Xxx" (1992)
Define ProdMiscQuotesAndYear
       InQuotes
       RC( WSep wordform_exact(LPar)
       	   WSep wordform_exact( ["1"|"2"] 0To9 0To9 0To9 ( Dash ( ["1"|"2"] 0To9 0To9 0To9 ) ) )
	   ( WSep wordform_exact( Dash ) )
	   WSep wordform_exact(RPar) ) ;

! Xxx-niminen tuote, Xxx-nimninen taikasine
Define ProdMiscHyphen
       AlphaUp lemma_ends( Dash {niminen} ) WSep
       ( PosAdj WSep )
       lemma_ends( {tuote} | {tarvike} | {esine} | @txt"gaz/gArtifactType.txt" ) ;

! Xxx Mono, Xxx Sans Serif
Define ProdMiscTypeface
       Ins(CapMiscExt) WSep Ins(CapMiscExt) WSep
       inflect_sg( {Serif} | {Sans} | {Sans-Serif} | {Bold} | {Blackletter} | {Gothic} | {Mono} ) ;

!* Xxx-merkkinen xxx
Define ProdMiscWithBrand1
       Field [ AlphaUp | 0To9 ] lemma_ends( Dash {merkkinen} ) WSep
       ( PosAdj WSep )
       PosNoun::0.50 ;

!* Xxx Xxx -merkkinen xxx
!* Xxx merkkinen xxx
Define ProdMiscWithBrand2
       [ CapMiscExt WSep ]*
       Word WSep
       lemma_exact( (Dash) {merkkinen} ) WSep
       ( PosAdj WSep )
       PosNoun::0.50 ;

!* hopeinen Xxx, tuliterä Xxx
Define ProdMiscColloc1
       LC( lemma_exact( {uusi} | {upouusi} | {kiiltävä} | {tuliterä} | Field Color ) WSep )
           [ [ [ [ [ Field CapNameNom | Field AlphaUp PropNom | CapMisc ] WSep ]* [ CapName | Abbr ]::0.50 ] ] |
	       [ [ [ Field CapNameNom | Field AlphaUp PropNom | CapMisc ] WSep ]+ NumWord ] ] ;

!! Slogans, mantras, prayers

!* Xxxin käyttö / Xxxin valmistaja / Xxxin alkuperämaa
Define ProdMiscColloc2
       ( CapMisc WSep ) [ CapNameGenNSB::0.50 | PropGen::0.50 ] 
       RC( WSep lemma_ends( {käyttö} | {käyttäjä} | {käyttäjäkunta} | {käyttäminen} | {kahva} | {runko} | {pakkaus} |
       	   		    {valmistaja} | {käyttäjäystävällisyys} | {alkuperämaa} | {saatavuus} | {hinta} ) ) ;

Define ProdMiscSemtag
       semtag({PROP=PRODUCT})::0.90 ;

!! Artifacts and misceallanea
!* Koh-i-Noor / Graalin malja
Define ProMiscMWord
       [ m4_include(`gaz/gProdMWord.m4') ] ;

Define ProdMisc
       [ Ins(ProdMiscQuotesAndYear)
       | Ins(ProdMiscHyphen)
       | Ins(ProdMiscTypeface)
       | Ins(ProdMiscWithBrand1)
       | Ins(ProdMiscWithBrand2)
       | Ins(ProdMiscColloc1)
       | Ins(ProdMiscColloc2)
       | Ins(ProdMiscSemtag)
       | OptQuotes(Ins(ProMiscMWord))::0.20
       ] EndTag(EnamexProXxx) ;

!!----------------------------------------------------------------------

!* Category HEAD

Define Product
       [ Ins(ProLaw)::0.00
       | Ins(ProAgreement)::0.00
       | Ins(ProAward)::0.25
       | Ins(ProGame)::0.25
       | Ins(ProFilmTV)::0.25
       | Ins(ProLiterature)::0.25
       | Ins(ProVehicle)
       | Ins(ProProject)
       | Ins(ProMusic)
       | Ins(ProArtwork)
       | Ins(ProDrug)
       | Ins(ProdFoodDrink)
       | Ins(ProdCultivar)
       | Ins(ProdTech)
       | Ins(ProdMisc)
       ] ;

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
       [ lemma_exact( {toinen} | {ensimmäinen} | {kolmas} ) |
       	 wordform_exact( "I" | {II} | {III} | {1.} | {2.} | {3.} ) ] WSep
       lemma_exact( {maailmansota} ) ;

Define EvtConflict2
       lemma_exact( [ {jatko} | {talvi} ] {sota} ) ;

!* "Falklandin sota", "Isänmaallinen sota"
Define EvtConflict3
       [ ( AlphaUp PropGeoGen WSep wordform_exact(Dash) WSep )
	 AlphaUp PropGeoGen EndTag(EnamexLocPpl2) | [ LC( NoSentBoundary ) AlphaUp PosAdj ] ] WSep
       lemma_exact_morph({sota}, {NUM=SG})
       NRC( WSep Word ( WSep Word ) ( WSep Word ) WSep wordform_exact( {vastaan} ) ) ;

!* "Yhdysvaltain vapaussota", "Espanjan sisällissota"
Define EvtConflict4
       [ lemma_morph(Ins(CountryName), {[NUM=SG][CASE=GEN]}) | PropGeoGen ] EndTag(EnamexLocPpl2) WSep
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
       lemma_ends( {tapahtuma} | {tilaisuus} | {tapaaminen} | {seminaari} | {gaala} | {konsertti} | {kilpailu} |
       		   {turnaus} | {kiertue} | {festivaali} | {festari} | {messu}("t") | {karnevaali} | {regatta} |
		   {konferenssi} | {kongressi} | {näyttely} | {biennaali} | {kurssi} | [{ilmasto}|{huippu}]{kokous} |
		   {marssi} | {rieha} | {jamboree} | {puolimaraton} ) ;

Define EvtRockFestival
       [ LC( NoSentBoundary ) AlphaUp lemma_exact( AlphaDown AlphaDown+ {rock} | {cup} ) ] |
       [ LC( NoSentBoundary ) AlphaUp Field Ins(EvtType) ] ;

!* "Pori Jazz -festivaali"
Define EvtHyphen1
       ( Ins(WordsNom) )
       CapWord WSep
       ( ( LowerWord WSep ) ( LowerWord WSep )
       NotConj WSep )
       DashExt Ins(EvtType) ;

!* "Weekend-festivaali"
Define EvtHyphen2
       AlphaUp Field Capture(EvtCpt6) Dash Ins(EvtType) ;

Define EvtSocialQuoted
       InQuotes WSep
       DashExt Ins(EvtType) ;

!* "Tallinnan laulujuhlat", "Helsingin juhlaviikot"
!* NB: excluded "markkina(t)" for too many false alarms
Define EvtSocialSuffixed1
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       ( lemma_exact_morph( {kansainvälinen} | {valtakunnallinen}, {NUM=PL}) WSep )
       Alpha AlphaDown lemma_morph( AlphaDown+ [ {viikko} | {juhla} | {päivä} | {messu} | AlphaDown AlphaDown {ajo} |
       	     	       		    	       	 {festivaali} | {festari} | {tanssi} | {kisa} | {kilpailu} ("t") ] |
						 {syysmarkkina} ("t") | {suurmarkkina} ("t"), {NUM=PL} ) ;

!* "[Turun] Silakkamarkkinat"
Define EvtSocialSuffixed2
       [ PropGeoGen WSep AlphaUp ] | [ LC( NoSentBoundary) AlphaUp ] 
       Alpha AlphaDown lemma_morph( AlphaDown+ [ {viikko} | {juhla} | {päivä} | {messu} | AlphaDown AlphaDown {ajo} |
       	     	       		    	       	 {juoksu} | {festivaali} | {festari} | {tanssi} | {kisa} |
						 {markkina} ] ("t"), {NUM=PL} ) ;

!* "Tuomaan markkinat", "Xxx:n keskiaikaiset markkinat"
Define EvtSocialSuffixed3
       [ [ AlphaUp PropFirstGen | wordform_exact( {Tuomaan} | {Heikin} ) ]
       | [ PropGeoGen WSep lemma_exact_morph({keskiaikainen}, {NUM=PL}) ] ] WSep
       lemma_exact_morph( {markkina}, {NUM=PL} ) ;

Define EvtSocialSuffixed4
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       AlphaDown lemma_morph( {konferenssi} | {kongressi} | AlphaDown (Dash) {näyttely}, {NUM=SG} ) ;

Define EvtDate
       lemma_exact( [{19}|{20}|Apostr] 0To9 0To9 ) EndTag(TimexTmeDat2) ;

Define EvtOlympics0
       PropGeoGen EndTag(EnamexLocPpl2) WSep
       lemma_morph( {olympialainen} | {olympialaiset} | {olympiakisa}("t") ) ;

Define EvtOlympics1
       ( CapMisc WSep )
       [ PropGeoGen | CapNameGenNSB ] EndTag(EnamexLocPpl2) WSep
       lemma_morph( {olympialainen} | {olympialaiset} | {olympiakisa}("t") ) WSep
       Ins(EvtDate) ;

Define EvtOlympics2
       lemma_morph([ {kesä} | {talvi} ][ {olympialainen} | {olympialaiset} ]) WSep
       Ins(EvtDate) ;

Define EvtOlympics3
       wordform_exact( ["v"|"V"]{uoden} ) WSep
       lemma_exact( [{19}|{20}|Apostr] 0To9 0To9 ) EndTag(TimexTmeDat2) WSep
       lemma_morph( {olympialainen} | {olympialaiset} | {olympiakisa}("t") | {maailmannäyttely} ) ;

!* "Jalkapallon EM-kisat 2017"
Define EvtChampionships1
       Alpha AlphaDown [NounGenSg - Prop] WSep
       ( AlphaDown morphtag({CASE=GEN}) WSep )
       [ lemma_morph( AlphaDown+ ( Dash AlphaDown* ) [ {kilpailu}("t") | {kisa}("t") ], {NUM=PL}) |
       	 lemma_exact( {maailmancup} ) ] WSep
       Ins(EvtDate) ;

Define EvtChampionships2
       wordform_exact( ["v"|"V"]{uoden} ) WSep
       lemma_exact( [{19}|{20}|Apostr] 0To9 0To9 ) EndTag(TimexTmeDat2) WSep
       AlphaDown morphtag({[NUM=SG][CASE=GEN]}) WSep
       [ lemma_morph( AlphaDown+ ( Dash AlphaDown* ) [ {kilpailu}("t") | {kisa}("t") ], {NUM=PL}) |
         lemma_exact( {maailmancup} ) ] ;

Define EvtChampionships3
       Alpha AlphaDown NounGenSg WSep
       wordform_exact( ["v"|"V"]{uoden} ) WSep
       Ins(EvtDate) WSep
       [ lemma_morph( AlphaDown+ ( Dash AlphaDown* ) [ {kilpailu}("t") | {kisa}("t") ], {NUM=PL}) |
       	 lemma_exact( {maailmancup} ) ] ;

!* "Electronic Entertainment Expo 2017", "New York Fashion Week", "Golden Globe Awards"
Define EvtSocialSuffixed5
       [ CapMiscExt WSep ]*
       [ CapMiscExt | CapNameNSB ] WSep
       inflect_sg( {Festival}("s") | {Week}({end}) | {Celebration} | {Party}::0.50 | {Contest} | {Concert} | {Gala} |
       		   {Competition} | {Convention} | {Conference} | {Congress} | {Reunion} | {Awards} | {Parade} |
       		   {Expo} | {Exhibition} | {Fair} | {Ball}::0.25 | {Gathering} | {Show} | {Concert} | {Meeting} |
		   {Summit} | {Tournament} | {Championship}("s") | {Cup} | {Challenge} | {Marathon} | {Tour} |
		   {Pride} | {Jazz} | {Race} | {Biennal} | {Piknik} | {Picnic} | {Festivála} | {Fest} | {Ralli} )
       ( WSep Ins(EvtDate) )
       ( WSep Dash Ins(EvtType) ) ;

Define EvtSocialSuffixed6
       ( CapMisc WSep )
       CapWord WSep
       [ inflect_x2({Open}, {Air}) |
       	 inflect_x2({Film}, {Festival}) ] ;

Define EvtSocialSuffixed7
       [ CapNameGenNSB | PropGeoGen ] WSep
       "Y" lemma_exact( {yö} ) ;

Define EvtGrandPrix1
       [ CapNameGen EndTag(EnamexLocPpl2) | CapMisc ] WSep
       wordform_exact({Grand}) WSep
       inflect_sg({Prix})
       ( WSep Ins(EvtDate) ) ;

Define EvtGrandPrix2
       [ CapNameGen EndTag(EnamexLocPpl2) | CapMisc ] WSep
       {GP} lemma_exact( {gp} ) ;

Define EvtSocialSuffixed8
       inflect_sg( AlphaUp Field @txt"gaz/gEventSuff.txt" ) ;

Define EvtChampionsLeague1
       ( wordform_exact( AlphaUp AlphaUp+ ) WSep )
       wordform_exact( {Champions} ) WSep
       ( [ CapMisc | CapName ] WSep )
       inflect_sg( {League} ) ;

Define EvtChampionsLeague2
       AlphaUp ( NounGen WSep )
       lemma_exact_morph( {mestari} ("t") | {eurooppa}, {CASE=GEN}) WSep
       lemma_exact_morph({liiga}, {NUM=SG}) ;

Define EvtChampionsLeague3
       "E" lemma_exact( {eurooppa} Dash {liiga} ) ;

Define EventGaz1
       [ m4_include(`gaz/gEventMisc.m4') ] ;

Define EventGaz2
       [ m4_include(`gaz/gEventFin.m4') ] ;

Define EvtPrefixed
       wordform_exact( {Tour} ) WSep
       wordform_exact( {de} ) WSep
       CapName ;

Define EvtSemtag
       semtag({PROP=EVENT}) ;

! Xxx järjestetään/on peruttu
Define EvtColloc1
       ( Ins(WordsNom) )
       wordform_exact([ LC(NoSentBoundary) Field CapNameStr | Field AbbrStr | Field 0To9 ] Capture(EvtCpt1) )::0.50
       RC( [ WSep AuxVerb | WSep PosAdv ]* WSep lemma_exact_morph( {järjestää} | {perua}, {VOICE=PSS} ) ) ;

! Xxx:n yleisö/järjestäjä/osallistumismaksu
Define EvtColloc2A
       ( Ins(WordsNom) )
       wordform_exact([ LC(NoSentBoundary) Field CapNameStr | Field AbbrStr |
       			Field 0To9 ] Capture(EvtCpt2) Ins(GenSuff))::0.50
       RC( WSep lemma_exact( {järjestäjä} | {järjestäminen} | {puuhamies} | {yleisö} | {osallistumismaksu} |
       	   		     {järjestelyt} | {juontaja} ) ) ;

! Xxx:n	liput/kävijät/järjestelyt
Define EvtColloc2B
       ( Ins(WordsNom) )
       wordform_exact([ LC(NoSentBoundary) Field CapNameStr | Field AbbrStr |
       			Field 0To9 ] Capture(EvtCpt3) Ins(GenSuff))::0.50
       RC( WSep lemma_exact_pl( {osallistuja} | {kävijä} | {lippu} | {pääsylippu} | {järjestely} ) ) ;

! liput/osallistua Xxx:iin
Define EvtColloc3
       LC( lemma_ends( {lippu} | {osallistua} ) WSep )
       ( Ins(WordsNom) )
       wordform_exact([ Field CapNameStr | Field AbbrStr | Field 0To9 ] Capture(EvtCpt4) Ins(IllSuff))::0.50 ;

Define EvtColloc4
       LC( lemma_exact( {jokavuotinen} | {järjestettävä} ) WSep )
       ( Ins(WordsNom) )
       inflect_sg([ Field CapNameStr | Field AbbrStr | Field 0To9 ] Capture(EvtCpt5) )::0.50 ;

!* "hirmumyrsky Katrina", "hurrikaani Mitch"
Define EvtStorm
       wordform_exact(OptCap( {hirmumyrsky} | {hurrikaani} )) WSep
       AlphaUp PropFirstLast ;

Define EvtCaptured
       inflect_sg( EvtCpt1 | EvtCpt6 | [ EvtCpt2 | EvtCpt3 | EvtCpt4 | EvtCpt5 ] (AddI) )::0.50 ;

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
       | Ins(EvtHyphen1)::0.50
       | Ins(EvtHyphen2)::0.50
       | Ins(EvtSocialQuoted)::0.50
       | Ins(EvtSocialSuffixed1)::0.50
       | Ins(EvtSocialSuffixed2)::0.50
       | Ins(EvtSocialSuffixed3)::0.50
       | Ins(EvtSocialSuffixed4)::0.50
       | Ins(EvtOlympics0)::0.50
       | Ins(EvtOlympics1)::0.50
       | Ins(EvtOlympics2)::0.50
       | Ins(EvtOlympics3)::0.50
       | Ins(EvtChampionships1)::0.50
       | Ins(EvtChampionships2)::0.50
       | Ins(EvtChampionships3)::0.50
       | Ins(EvtSemtag)::0.75
       | OptQuotes(Ins(EvtSocialSuffixed5)::0.25)
       | OptQuotes(Ins(EvtSocialSuffixed6)::0.25)
       | OptQuotes(Ins(EvtSocialSuffixed7)::0.30)
       | OptQuotes(Ins(EvtSocialSuffixed8)::0.50)
       | EvtGrandPrix1::0.20
       | EvtGrandPrix2::0.20
       | OptQuotes(Ins(EvtPrefixed)::0.20)
       | OptQuotes(Ins(EvtChampionsLeague1)::0.50)
       | Ins(EvtChampionsLeague2)::0.50
       | Ins(EvtChampionsLeague3)::0.25
       | OptQuotes(Ins(EventGaz1)::0.40)
       | OptQuotes(Ins(EventGaz2)::0.40)
       | Ins(EvtColloc1)
       | Ins(EvtColloc2A) | Ins(EvtColloc2B)
       | Ins(EvtColloc3)
       | Ins(EvtColloc4)
       | Ins(EvtStorm)::0.25
       | Ins(EvtCaptured)
       ] EndTag(EnamexEvtXxx) ;

!!----------------------------------------------------------------------
!! <TimexTmeDat>: Dates
!!----------------------------------------------------------------------

Define DashSpc	[ " " Dash " " | Dash ] ;
Define YearNum	[ 1To9 0To9 0To9 0To9 ] ;
Define YearWord	wordform_exact( YearNum (".") ) ;
Define YearAny 	wordform_exact( 1To9 0To9 0To9 (0To9) (".") ) ;
Define DayStr 	DayNum ( ( "." ) DashSpc DayNum ) "." ;
Define DayWord 	wordform_exact( DayStr ) | PosNumOrd ;
Define Paiva 	[ {päivä} | {päivänä} | {p.} | {pvä} (".") | {pnä} (".") | "p" ] ; 

Define Era 	wordform_exact( {jaa.} | {eaa}(".") | ["j"|"e"]["k"|"K"] "r" (".") | {AD} ) |
       		wordform_exact({jälkeen}) WSep wordform_exact({ajanlaskun}) WSep wordform_exact({alun}) |
       	   	wordform_exact({ennen}) WSep wordform_exact({ajanlaskun}) WSep wordform_exact({alkua}) |
		wordform_exact( OptCap({anno})) WSep wordform_exact( OptCap({domini})) ; 

!----------

Define NumDate0
       wordform_exact( DayNum "." MonthNum "." ) ;

! dd.mm.yyyy
Define NumDate1
       wordform_exact( DayNum "." MonthNum "." YearNum (".") ) ;

! dd.-dd.mm.yyyy
! dd.mm.-dd.mm.yyyy
! dd.mm.yyyy-dd.mm.yyyy
Define NumDate2
       ( DayNum "." ( MonthNum "." ( YearNum ) ) DashSpc ) NumDate1 ;

! dd.mm. - dd.mm.yyyy
! etc.
Define NumDate3
       wordform_exact( DayNum "." ( MonthNum "." ( YearNum ) ) ) WSep
       wordform_exact( Dash ) WSep
       NumDate1 ;

Define NumDate
       [ NumDate0 | NumDate1 | NumDate2 | NumDate3 ] ;

! dd. mm. yyyy
! dd. - mm. yyyy.
Define NumDateSpaced
       ( wordform_exact( DayNum "." ) WSep
       ( wordform_exact( MonthNum "." ) WSep
       ( wordform_exact( YearNum (".") ) WSep ) )
       	 wordform_exact( Dash ) WSep )
       wordform_exact( DayStr ) WSep
       wordform_exact( MonthNum "." ) WSep
       wordform_exact( YearNum (".") ) ;

! 2016-10-09
! 2016/10/09
! 2016 / 10 / 09
Define NumDateISO
       wordform_exact( YearNum Dash MonthNum Dash DayNum ) |
       wordform_exact( YearNum "/" MonthNum "/" DayNum ) |
       [ wordform_exact( YearNum ) WSep Slash WSep
       	 wordform_exact( MonthNum ) WSep Slash WSep
       	 wordform_exact( DayNum ) ] ;

!----------

! "Xxx Xxx" (YYYY)
Define NumYear1
       LC( wordform_exact(Quote) WSep lemma_exact(LPar) WSep )
       wordform_exact( [ "1" 1To9 | {20} ] 0To9 0To9 )
       RC( WSep lemma_exact(RPar) ) ;

! YYYY jKr.
Define NumYear2
       ( wordform_exact( OptCap({vuonna}|{vuosina}) ) WSep )
       wordform_exact( [ 1To9 0To9 (0To9) (0To9) ( Dash 1To9 0To9 (0To9) (0To9) ) ] |
       		       [ 1To9 0To9 (0To9) { 000} ] ) WSep Ins(Era) ;

! 1981, 1980 (muttei: yhteensä 1981, 1980 kertaa)
Define NumYear3
       NLC( lemma_exact( {yhteensä} | {noin} | {sunnilleen} | {tasan} | {täsmälleen} | {vain} | {jopa} |
       	    		 {kaikkiaan} | {alle} | {yli} | {miltei} | {vajaa} ) WSep )
       [ wordform_exact( [ "1" 0To9 | {20} ] 0To9 1To9 (".") ) |
       	 wordform_exact( [ "1" 0To9 | {19} | {20} ] 1To9 0To9 (".") ) NRC( WSep morphtag({[NUM=SG][CASE=PAR]}) ) ] ;

! syksyllä YYYY, kuoli YYYY 
Define NumYear4
       LC( lemma_exact( AlphaDown* [ {syksy} | {kevät} | {kesä} | {talvi} | {kausi} | AlphaDown {vuosi} ] |
       	   		{syntyä} | {kuolla} | {perustaa} | {valmistua} | {aikaisin}({taan}) | {viimeistään} |
			{myöhään} | {jo} | {alkaa} | {päättyä} | {joulu} | {vappu} | {juhannus} | {pääsiäinen} |
			{vuosimalli} | {synt.} | {s.} | {v.} ) WSep )
       wordform_exact( [ "1" 1To9 | {20} ] 0To9 0To9 (".")) ;

!* YYYY lähtien
Define NumYear5
       wordform_exact( [ {18} | {19} | {20} ] 0To9 0To9 )
       RC( WSep lemma_exact( {aika} | {loppu} | {alku} | {puoliväli} | {jälkeen} | {aikana} | {asti} | {mennessä} |
       	   		     {lähtien} | {alkaen} | {kisa}("t") | {saakka} | {kesä} | {kevät} | {syksy | {talvi} ) ) ;

Define NumYear
       ( lemma_exact( {v.} ) WSep )
       [ NumYear1 | NumYear2 | NumYear3 | NumYear4 | NumYear5 ] ;

Define NumYears1
       wordform_exact( YearNum DashSpc YearNum (".") ) ;

Define NumYears2
       wordform_exact( YearNum ) WSep
       wordform_exact( {ja} | Dash ) WSep
       wordform_exact( YearNum (".") ) ;

Define NumYears
       [ NumYears1 | NumYears2 ] ;

!----------

! vuonna 205
! vuonna 550 eaa.
! muttei: vuodessa 550
Define DateYear1
       wordform_exact( OptCap({vuosi}|{vuoden}|{vuotta}|{vuoteen}|{vuodesta}|{vuodelta}|{vuodelle}|{vuodeksi}|{vuonna}) ) WSep
       ( 1To9 0To9 0To9+ DashSpc ) YearAny ( WSep Ins(Era) ) ;

! vuosina 2006 - 2007
! vuosina 205-203 ennen ajanlaskun alkua
Define DateYear2
       [ lemma_exact_morph({vuosi}, {NUM=PL}) | lemma_exact({vuosina}) ] WSep
       [ 1To9 0To9+ DashSpc | YearAny WSep wordform_exact( Dash ) WSep ]
       YearAny ( WSep Ins(Era) ) ;

! vuosina 2001, 2002 ja 2003
Define DateYear3
       [ lemma_exact_morph({vuosi}, {NUM=PL}) | lemma_exact({vuosina}) ] WSep
       [ YearAny WSep Coord WSep ]+
       YearAny ( WSep Ins(Era) ) ;

Define DateYear
       [ DateYear1 | DateYear2 |  DateYear3 ] ;

Define DateMonth1
       ( lemma_exact( MonthPfx Dash ) WSep wordform_exact({ja}) WSep )
       lemma_exact(( MonthPfx Dash ) MonthPfx [{kuu}|{k.}])
       ( WSep [ wordform_exact({vuonna}) WSep YearAny | YearWord ]
       ( WSep Ins(Era) ) ) ;

Define DateMonth2
       wordform_exact( OptCap({vuoden}) ) WSep
       YearAny WSep 
       ( lemma_exact( MonthPfx Dash ) WSep wordform_exact({ja}) WSep )
       lemma_exact(( MonthPfx Dash ) MonthPfx {kuu} ) ;

Define DateMonthDefect
       wordform_exact( OptCap(MonthPfx) ( Dash MonthPfx ) {kuu} ["n"|{ta}|{ssa}|{sta}|{hun}|{lle}|{lta}] ) ;

Define DateMonth
       [ DateMonth1 | DateMonth2 | DateMonthDefect ] ;

Define DateDay1
       wordform_exact( OptCap(MonthPfx) [{kuun}|{k.}]) WSep
       DayWord
       ( WSep wordform_exact( {ja} | Dash ) WSep DayWord )
       ( WSep lemma_exact( Paiva ) ) ;

Define DateDay2
       DayWord WSep
       ( wordform_exact( {ja} | Dash ) WSep
       	 DayWord WSep )
       ( lemma_exact( Paiva ) WSep )
       wordform_exact( MonthPfx {kuuta} ) ;

!* tammikuun ensimmäinen päivä 2015
!* tammik. 1. vuonna 2015
!* ensimmäinen tammikuuta
!* ensimmäisenä päivänä tammikuuta
Define DateDay
       [ Ins(DateDay1) | Ins(DateDay2) ]
       ( WSep [ wordform_exact({vuonna}) WSep YearAny | YearWord ]
              ( WSep Ins(Era) ) ) ;

!----------

Define PPhrase
       wordform_exact({välisenä}) WSep wordform_exact({aikana}) |
       wordform_exact( {välillä} | {aikana} ) ;

Define DateYearRange1
       wordform_exact( OptCap({vuosien}) ) WSep
       YearAny WSep
       wordform_exact( {ja} | Dash ) WSep
       YearAny WSep
       Ins(PPhrase) ;

Define DateYearRange2
       ( wordform_exact( OptCap({vuosien}) ) WSep )
       Ins(NumYears) WSep
       Ins(PPhrase) ;

Define DateYearRange3
       wordform_exact( OptCap({vuodesta}) ) WSep
       YearAny WSep
       ( wordform_exact( {lähtien} | {alkaen} ) WSep )
       ( PosAdv WSep )
       wordform_exact({vuoteen}) WSep
       YearAny
       ( WSep wordform_exact( {saakka} | {asti} ) ) ;

Define DateMonthRange1
       wordform_exact( OptCap(MonthPfx) {kuusta} ) WSep
       ( YearAny WSep )
       ( wordform_exact( {lähtien} | {alkaen} ) WSep )
       ( PosAdv WSep )
       wordform_exact( MonthPfx {kuuhun} )
       ( WSep YearAny )
       ( WSep wordform_exact( {saakka} | {asti} ) ) ;

Define DateMonthRange2
       wordform_exact( OptCap(MonthPfx) ( Dash MonthPfx ) {kuun} ) WSep
       ( YearAny WSep )
       wordform_exact({ja}) WSep
       wordform_exact( MonthPfx ( Dash MonthPfx ) {kuun} ) WSep
       ( YearAny WSep )
       Ins(PPhrase) ;

Define DateMonthRange3
       lemma_exact( MonthPfx Dash ) WSep
       wordform_exact({ja}) WSep
       wordform_exact( MonthPfx {kuun} ) WSep
       ( YearAny WSep )
       Ins(PPhrase) ;

Define DateMonthRange4
       wordform_exact( OptCap(MonthPfx) Dash MonthPfx {kuun} ) WSep
       ( YearAny WSep )
       Ins(PPhrase) ;

Define DateMonthRange5
       wordform_exact( OptCap({vuoden}) ) WSep
       YearAny WSep
       wordform_exact( MonthPfx {kuusta} ) WSep
       wordform_exact({vuoden}) WSep
       YearAny WSep
       wordform_exact( MonthPfx {kuuhun} ) ;

Define DateDayRange1
       [ Ins(DateDay) | Ins(NumDate) ] WSep
       wordform_exact({ja}) WSep
       [ Ins(DateDay) | Ins(NumDate) | DayWord ( WSep wordform_exact({päivän}) ) ] WSep
       Ins(PPhrase) ;

Define DateDayRange2
       [ Ins(DateDay) | Ins(NumDate) ] WSep
       wordform_exact( {lähtien} | {alkaen} ) WSep
       ( PosAdv WSep )
       [ Ins(DateDay) | Ins(NumDate) ] WSep
       wordform_exact( {saakka} | {asti} ) ;

Define DateDayRange3
       wordform_exact( MonthPfx [{kuun}|{k.}]) WSep
       DayWord WSep
       ( wordform_exact({päivästä}|{p:stä}) WSep )
       ( wordform_exact( {lähtien} | {alkaen} ) WSep )
       ( PosAdv WSep )	      
       wordform_exact( MonthPfx [{kuun}|{k.}]) WSep
       DayWord WSep
       wordform_exact({päivään}|{p:ään})
       ( WSep wordform_exact( {saakka} | {asti} ) ) ;

Define DateDayRange4
       Ins(DateDay) WSep
       wordform_exact(Dash) WSep
       Ins(DateDay)
       ( WSep Ins(PPhrase) ) ;

Define DateMonthRange
       [ DateMonthRange1 | DateMonthRange2 | DateMonthRange3 | DateMonthRange4 | DateMonthRange5 ] ;

Define DateYearRange
       [ DateYearRange1 | DateYearRange2 | DateYearRange3 ] ;

Define DateDayRange
       [ DateDayRange1 | DateDayRange2 | DateDayRange3 | DateDayRange4 ] ;

! Category HEAD
Define Date
       [ Ins(NumDate)
       | Ins(NumDateSpaced)
       | Ins(NumDateISO)
       | Ins(NumYear)
       | Ins(NumYears)
       | Ins(DateYear)
       | Ins(DateMonth)
       | Ins(DateDay)
       | Ins(DateYearRange)
       | Ins(DateMonthRange)
       | Ins(DateDayRange)
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
       [ {yksi} | {kaksi} | {kolme} | {neljä} | {viisi} | {kuusi} | {seitsemän} | {kahdeksan} | {yhdeksän} |
       	 {kymmenen} | [{yksi}|{kaksi}]{toista} ] ;
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
       [ [ lemma_exact_morph( {vartti}, {[NUM=SG][CASE=PAR]} ) |
       	   morphtag_exact( {[POS=NUMERAL][SUBCAT=CARD]}({[NUM=SG][CASE=]}[{NOM}|{PAR}|{GEN}] ?)) ] WSep 
       	 lemma_exact( {vaille} | {yli} ) |
       	 lemma_exact( {puoli} ) ] WSep
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

Define CurrencySymbol [ "€" | "$" | "¥" | "£" | "₽" | "¢" | {mk} | {eur} | {snt} |
       		      	{EUR} | {USD} | {JPY} | {RUB} | {GBP} | {BTC} | {XBT} ] ;

Define Currency [ Lst(AlphaDown) morphorsemtag({CURRENCY}) |
       		  Lst(AlphaDown) lemma_exact( @txt"gaz/gCurrency.txt" ) ] ;

Define MoneyAmount1
       ( lemma_exact({puoli}|{pari}|{muutama}) WSep )
       PosNumCard ( WSep [ Alpha PosNumCard | lemma_exact( [{milj}|{mrd}](".") ) ]) WSep
       [ define( PropGeoGen EndTag(EnamexLocPpl2) ) WSep Ins(Currency) |
       	 Ins(Currency) | wordform_exact( CurrencySymbol ( ":" AlphaDown+ ) ) ] ;

Define MoneyAmount2
       ( lemma_exact({puoli}|{pari}|{muutama}) WSep )
       PosNumCard [ WSep [ Alpha PosNumCard | lemma_exact( [{milj}|{mrd}](".") ) ]]
       RC( WSep lemma_ends( {tulos} | {liikevaihto} | {voitto} | {tappio} | {korvaus} | {velka} | {vahinko} |
       	   		    {palkkio} | {käteinen} | {luotto} | {laina} | {kustannus} ) ) ;

!* "maksaa viisi tonnia, kustantaa noin 4,5 miljardia"
Define MoneyAmount3
       LC( lemma_exact( {maksaa} | {kustantaa} ) WSep ( PosAdv WSep ) )
       PosNumCard WSep
       [ lemma_exact( [{milj}|{mrd}](".") ) |
       	 lemma_exact_morph({miljoona}|{miljardi}|{tuhat}|{tonni}, {NUM=SG} Field [{CASE=PAR}|{CASE=NOM}]) ] ;

Define CurrencyExpr [ Ins(MoneyAmount1) | Ins(MoneyAmount2) | Ins(MoneyAmount3) ] EndTag(NumexMsrCur) ;

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
       [ {metri} | {gramma} | {litra} | {watti} | {joule} | {hertsi} | {bitti} | {voltti} | {ampeeri} |
       	 {ampeeritunti} | {wattitunti} | {kandela} ] ;

!Define UnitTimeLiteral
!       [ ({milli}|{nano}) {sekunti} | {minuutti} | {tunti} | {vartti} ({tunti}) | {vuorokausi} | {kuukausi} | {vuosi}
!         {viikko} | {päivä} | {gigavuosi} | {megavuosi} | {minsa} | {sekka} ] ;
!
!Define UnitTimeSymbol
!	[ {ns} | {ms} | {s} | {sek} | {sec} | {min} | {h} | {t} | {vrk} | {Ma} | {mvs} | {Ga} ] ;

Define UnitSymbol
       [ {ml} | {ha} | {cl} | {dl} | "l" | {AU} | {mol} | {mph} | "K" | {rkl} | {tl} | "°" | UnitSymbolSI | {Mt} |
       	 {Gt} | {mm.} | ("k"){cal} | {°F} ] ;

Define UnitLiteral
       [ {mooli} | {kelvin} | {kilo} | {desi} | {kalori} | {valovuosi} | {parsek}({ki}) | {peninkulma} | {kyynärä} |
       	 {maili} | {virsta} | {tuuma} | {jaardi} | {meripeninkulma} | {aste}({essa}) | {celsius} | {celsiusaste} |
	 {fahrenheit} | {kelvinaste} | {radiaani} | {steradiaani} | {aari} | {hehtaari} | {pauna} |
	 ({kilo}|{mega}|{giga}|{tera}|{peta}){tavu} | {sentti} | {milli} | {kilsa} | {mega} | {giga} | UnitLiteralSI ] ;

Define UnitPhrase
       [ ( wordform_exact( Ins(UnitSymbol) ) WSep wordform_exact("/") WSep )
       	 wordform_exact( Ins(UnitSymbol) (":" AlphaDown+)) ] |
       [ lemma_exact( Ins(UnitLiteral) ) ( WSep wordform_ends( {tunnissa} | {sekunnissa} | {minuutissa} ) ) ] ;

Define MeasureUnitAcro
       morphorsemtag({[SUBCAT=ACRONYM]} NoWSep* {[SEM=MEASURE]}) ;

Define Multiply wordform_exact( "x" | "X" | "×" ) ;

!* NNN:n neliön asunto/pinta-ala/suurinen/kokoinen

!* 17°
!* Define LengthUSCustomary

Define NumFraction
       [ lemma_exact( (1To9 0To9*) ["½"|"¼"] ) ] |
       [ lemma_exact(1To9 0To9*) WSep lemma_exact("½"|"¼") ] ;

Define MeasureExpr
       [ PosNumCard | Ins(NumFraction) ] WSep
       [ [ Multiply | lemma_exact(Dash) ] WSep
       	 [ PosNumCard | Ins(NumFraction) ] WSep ]*
       [ LowercaseAlpha PosNumCard WSep ]*
       [ Ins(UnitPhrase) | Ins(MeasureUnitAcro) ]
       EndTag(NumexMsrXxx) ;

!!----------------------------------------------------------------------
!! <Backoff>
!! Backoff rules: Default tagging for individual words
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
       inflect_sg([ "0" | 0To9 0To9 ] 0To9+ 1To9 ":" ) 
       EndTag(EnamexProXxx) ;

! Initialisms are probably Organizations
Define BackoffInitialism
       inflect_sg( AlphaUp^{2,4} ":" )
       EndTag(EnamexOrgCrp) ;

! Capital letter followed by a string of numbers is probably a product
Define BackoffSerial
       inflect_sg( AlphaUp 0To9+ )
       EndTag(EnamexProXxx) ;

! Web domains are generally organizations
Define BackoffDomain
       inflect_sg( AlphaUp WebDomain )
       EndTag(EnamexOrgCrp) ;

Define BackoffTheXxx
       OptQuotes(
       wordform_exact( {The} | {From} | {Of} ) WSep
       ( [ CapMisc | wordform_exact( AlphaUp Field Apostr "s" ) ] WSep )
       ( ( CapWord WSep ) AndOfThe WSep ( CapMisc WSep ) )
       CapWord )
       RC( WSep [ ? - [ AlphaUp | Dash ] ] )
       EndTag(EnamexProXxx) ;

Define Backoff
       [ Ins(BackoffLowerCamelCase)::2.00
       | Ins(BackoffNumWithColon)::2.00
       | Ins(BackoffInitialism)::2.00
       | Ins(BackoffSerial)::2.00
       | Ins(BackoffDomain)::2.00
       | Ins(BackoffTheXxx)::2.00
       ] ;


!!----------------------------------------------------------------------
!! <Sandbox>
!!----------------------------------------------------------------------

!Define Sandbox
!       [ ... ] EndTag(EnamexXxxXxx) ;

!!----------------------------------------------------------------------
!! <Exceptions>: Words that shouldn't get tagged by other rules
!! (in phase 2 or by shorter matches in this rule set)
!!----------------------------------------------------------------------

Define OrdinalWord wordform_exact( 0To9 (0To9) (0To9) "." ) ;

Define ExceptKorko
       wordform_exact( {Korot} )
       RC( WSep lemma_ends( {nousu} | {lasku} | {nousta} | {laskea} | {painua} | {pysy} ({tell}) "ä" |
       	   		    {kasva} ({tt}) {aa} ) )
       EndTag(Exc001) ;

Define ExceptJosKun
       LC( SentBoundary | OrdinalWord WSep )
       wordform_exact( [ {Jos} | {Sen} | {Liian} |{Mutta} | {Jotta} | {Kun} | {Toki} | {Joissakin} | {Myös} | {Heistä} |
       		       	 {Vaikka} | {Jopa} | {Jo} | {Luin}] ({pa}|{pä}|{kin}) | {But} | {Perin} | {Perillä} |
			 {Periltä} | {Perille} )
       EndTag(Exc002) ;

Define ExceptCommonNoun1
       LC( SentBoundary | OrdinalWord WSep )
       wordform_ends( [ {Aina} ({kin}) | {Lunasta} | {Meri} | {Pian} | {Ainoa} | {Mai}[{ssa}|{hin}|{sta}|{lle}|{lta}] |
       		      {Halpa} | {Alun} | {Jo} | {Alla} | {Ole}("n") | {Onne} ? | {onnekse} AlphaDown+ | {Rauha} |
		      {Toivo} | {Lintu} | {Alan} | {Portin} | {Hiljaa} | {Vappu} | {Anna}("n"|"t"|{mme}|{tte}) |
		      {Aku}["n"|{ssa}|{sta}] ] ({pa}|{kin}|{han}|{kaan}) )
       EndTag(Exc003) ;

Define ExceptCommonNoun2
       LC( SentBoundary | OrdinalWord WSep )
       lemma_exact(
		{aina} ({kin}) | {alla} | {antaa} | {hiljaa} | {aarre} | {meri} | {saari} | {hoikka} | {levy} |
		{rannikko} | {tuuli} | {siru} | {voitto} | {taisto} | {arvo} | {myrsky} | {syksy} | {rauha} |
		{toivo} | {toivoa} | {jolla} | {lintu} | {lumi} | {vanha} | {lima} | {mäki} | {kallio} | {linna} |
		{eli} | {elää} | {aamu} | {meri} | {lahja} | {kukka} | {maili} | {mainio} | {oiva} | {mimmi} |
		{poika} | {pilvi} | {rauha} | {sade} | {säde} | {satu} | {syksy} | {usko} | {usva} | {vadelma} |
		{unelma} | {vilja} | {taisto} | {taimi} | {taika} | {ilta} | {into} | {junior} | {kaisla} | {kaari} |
		{suvi} | {tuuli} | {meri} | {vappu} | {taito} | {lukko} | {kärppä} | {ilves} | {mieli} |
		{miele} AlphaDown+ | {motti} | {mantere} | {manner} | {lehti} | {tästedes} | {vastedes} | {valo} |
		{toimi} | {kärki} | AlphaDown+ [{lainen}|{läinen}] | {aurinko} | {ankara} | {elastinen} | {kirkas} |
		{blondi} | {elo} | {itä} | {länsi} | {rautatie} | {sisarus} | {asevoima}("t") | {kai} | {tuska} |
		{ukko} | {provinssi} | {suurlähettiläs} | {manifesti} | {paavius} | {naiivius} | {määrä} | {miina} |
		{ansa} | {alanko} | {media} | {kiista} | {vuori} | {laakso} | {tori} | {areena} | {flow} (Apostr) |
		{pitkä} | {kylä} | {merituuli} | {hovi} | {etelä} | {kuola} | Field {bisnes} | {erikseen} | {palava} |
		{urakka} | {siksi} | {sitä} | {provinssi} | {luola} | {runko} | {hummeri} | {tarkka} |
		{vaara} | {summa} | {lähde} | {pitkä} | {halpa} | {valmis} | {karhu} | {onni} | {nova} | {tori} |
		{tora} | {linja-auto} | {kallo} | {yleinen} | {evä} | {liuta} | {liata} | {lauta} | {sarja} | {veli} |
		{mies} | {he} | {liika} |{pian} | {lista} | {avain} | {joki} | {kohta} | {avata} | {se} | {senkin} |
		{olla} | {ainoa} | {poika} | {monet} | {moni} | {muu} | {jokin} | {jotta} | {ainakin} | {vanha} |
		{laina} | {ryhmä} | {jatkettu} | {linkki} | {internet} | {hakkeri} | {ainakaan} | {talo} | {tuleva} |
		{harva} | {tietty} | {miljoon}("a") | {oma} | {viisi} | {korke}("e") | {jakaa} | {metropoli} |
		{imago} | {varhaisteini} | {peitsi} | {erä} | {karhu} | {aita} | {peura} | {haara} | {peura} | {uni} |
		{kivinen} | {hummeri} | GeoAdj )
       EndTag(Exc005) ;

Define LangOrLoc @txt"gaz/gMiscLanguage.txt" ;

Define ExceptInLanguage
       lemma_exact_morph( Ins(LangOrLoc), {[NUM=SG][CASE=TRA]})
       EndTag(Exc006) ;

Define ExceptLanguage1
       lemma_exact_morph( Ins(LangOrLoc), {[NUM=SG]}[{[CASE=GEN]}|{[CASE=INE]}] ) WSep
       ( AlphaDown PosAdj WSep )
       lemma_exact( ({kirja}|{yleis}|{puhe}) {kieli} | {syntaksi} | {kielioppi} | {lauseoppi} | {ääntämys} |
       		    {äännejärjestelmä} | {sanajärjestys} | {ortografia} | {oikeinkirjoitus} | {essee} | {fonologia} |
		    {sana} | Field {taivutus} | Field {verbi} | {adjektiivi} | {sanaluokka} | {sijamuoto} |
		    {kirjaimisto} | {kirjoitusjärjestelmä} ) EndTag(Exc007) ;

Define ExceptLanguage2
       lemma_exact_morph( Ins(LangOrLoc), {[NUM=SG][CASE=PAR]})
       RC( [ WSep AuxVerb | WSep PosAdv ]*
       	   WSep lemma_exact_morph( {puhua} | {kirjoittaa} | {lukea} | {käyttää} | {lausua} | {ääntää} |
       	     	  	  	   {opettaa} | {opiskella} | {harjoitella} )) EndTag(Exc008) ;

Define ExceptNotTurkey
       wordform_exact( {Turkin} ) WSep
       lemma_exact( {hoito} | {hoitaminen} | {laatu} | {kiilto} | {väri} | {harjaus} | {harjaaminen} | {hiha} |
       		    {kunto} | {pituus} | {leikkaaminen} | {hoitaa} | {pesu} | {harjata} | {kasvu} | {trimmaus} |
		    {väritys} | {hilseily} | {paksuus} | {likaisuus} | {kampaaminen} | {leikkuu} | {värjääminen} )
		    EndTag(Exc010) ;

!----------------

!* "TV-kanava", "Youtube-kanava"
Define ExceptChannel
       lemma_exact(
		[ {tv} | {youtube} ]
       		Dash [ {kanava} | {video} ] )
       EndTag(Exc011) ;

!* "Netflix-sarja", "Hollywood-elokuva" ≠ "Netflix-niminen sarja", "Hollywood-niminen elokuva"
Define ExceptFilm
       lemma_exact(
		["b"|"h"]{ollywood} Dash AlphaDown* [{elokuva}|{leffa}|{filmi}|{filmatisointi}|{sovitus}] |
       		[{netflix}|{tv}|{youtube}|{hbo}] Dash AlphaDown*
		[{sarja}|{elokuva}|{leffa}|{filmi}|{filmatisointi}|{sovitus}] |
       		{spotify-kappale}
       ) EndTag(Exc012) ;

!* "4G:n", "3G-verkko", "MP3-soitin", "Wlan-asema", "DVD-elokuva"
Define ExceptMisc
       [ 1To9 [ "g" | "G" ] | {4K} | {GSM} | {5K} | {HD} | {RnB} | {R&B} | {EDM} | {ATK} | {HIV} | {AIDS} | {Atk} |
       	 {IT} | {It} | {pH} | {WC} | {UV} | {AU} | {LSD} | {TV} | {Tv} | {LTE} | {LVI} | {BKT} | {MP3 } | {mp3} |
	 {jp2} | {JPG} | {JP2} | {PNG} | {DJ} | {MC} | {GIF} | {SVG} | {XML} | {Xml} | {Https} | {SSH} | {PC} |
	 {GUI} | {API} | ("X"){HTML}(1To9) | ("x"){html}(1To9) | {Dvd} | {DVD} | {VHS} | {3d} | {3D} | {Blu-ray} |
	 ("J"|{MMO}){RPG} | {DIY} | {VPN} | {Web} | {Tdd} | {Wlan} | {Telnet} | {Internet} | {Televisio}  [ {LGBT} |
	 {HLBT} ] UppercaseAlpha* | {F1} | {F2} | {F3} | {Startup} | {LED} | {LP} | {GPS} | {Adware} |
	 {Wi}(Dash)[{fi}|{Fi}] | {IoT} ] [ Dash | ":" ] Word
       EndTag(Exc013) ;

Define ExceptChampionship1
       lemma_exact( [ {sm} | {em} | {mm} ] Dash AlphaDown* [ {kisa} | {kilpailu} | {sarja} | {ottelu} | {hopea} |
       		      	     	    	   		     {pronssi} | {kulta} | {mitali} ] ) EndTag(Exc014) ;

! "1024 x 860 -näyttö", "30 x 40 x 50"
Define ExceptDimensions
       ( NumNom WSep wordform_exact( "x" | "X" | "×" | {kertaa} ) WSep )
       NumNom WSep wordform_exact( "x" | "X" | "×" | {kertaa} ) WSep
       NumNom
       ( WSep Dash AlphaDown Word )
       EndTag(Exc015) ;

Define MiscWord @txt"gaz/gMiscSuffixWord.txt" ;

Define ExceptMiscMWord1
       ( Field CapNameNomNSB WSep )
       ( Word WSep )
       ( Word WSep )
       Dash lemma_ends( Ins(MiscWord) )
       EndTag(Exc016) ;

Define ExceptMiscMWord2
       Field AlphaUp Field Dash lemma_ends( Ins(MiscWord) )
       EndTag(Exc016) ;

Define ExceptPicture
       [ ( Word WSep ) Word WSep |
       ( Field AlphaUp Field ) ] Dash lemma_exact( ( Field Dash ) {kuva} )
       EndTag(Exc017) ;

Define ExceptUnit
       ( NumNom WSep wordform_exact(Dash) WSep )
       NumNom WSep
       lemma_ends( {prosentti} | {miljoona} | {miljardi} | {mrd.} )
       EndTag(Exc018) ;

Define ExceptNotYear
       wordform_exact( OptCap( {tänä} | {ensi} | {viime} | {edellisenä} | {kuluvana} | {seuraavana} |
       		       	       {tulevana} ) ) WSep
       lemma_exact( {vuonna} | {vuosi} )
       RC( WSep wordform_exact( 1To9 0To9+ ( Dash 1To9 0To9+ ) ) )
       EndTag(Exc019) ;

Define ExceptStorm
       lemma_exact_morph( {hurrikaani} | {hirmumyrsky} | {taifuuni} ) WSep
       CapName
       EndTag(Exc020) ;

!* Exclude dates that do not refer to a specific month (of a specific year)
Define ExceptNotDate
       LC( [ lemma_exact( {aina} | {yleensä} | {ennen} | {viettää} | {vuosittain} | {tavallisesti} ) |
       wordform_exact( {vietetään} ) ] WSep )
       lemma_exact( MonthPfx {kuu} )
       EndTag(Exc021) ;

Define ExceptNotPlanetEarth
       LC( SentBoundary | OrdinalWord WSep )
       wordform_exact( {Maan} ) WSep
       lemma_exact( {pääkaupunki} | {asukasluku} | {väestö} | {väkiluku} )
       EndTag(Exc022) ;

Define ExceptProductCommunity
       @txt"gaz/gStatPRO.txt" Dash lemma_ends( Dash [ {ryhmä} | {yhteisö} | {tiimi} | {projekti} ] )
       EndTag(Exc023) ;

Define ExceptChampionship2
       lemma_exact([ {mm} | {em} ] ( Dash [{kisa}|{kilpailu}] ("t") )) WSep
       wordform_exact([ {18} | {19} | {20} ] 0To9 0To9 ("."))
       EndTag(Exc024) ;

!* Block prefixes erroneously – they may sometimes be tagged as proper names
Define ExceptPrefixProp
       wordform_exact( Alpha Field Dash )
       EndTag(Exc025) ;

Define ExceptChurch
       lemma_exact( {katolinen} | {ortodoksinen} | {luterilainen} ) WSep
       lemma_exact({kirkko}) ;

!* Category HEAD
Define Exceptions
       [ Ins(ExceptKorko)::0.00
       | Ins(ExceptJosKun)::0.00
       | Ins(ExceptCommonNoun1)::0.00
       | Ins(ExceptCommonNoun2)::0.00
       | Ins(ExceptChannel)::0.00
       | Ins(ExceptFilm)::0.00
       | Ins(ExceptMisc)::0.00
       | Ins(ExceptUnit)::0.00
       | Ins(ExceptChampionship1)::0.00
       | Ins(ExceptChampionship2)::0.00
       | Ins(ExceptLanguage1)::0.00
       | Ins(ExceptLanguage2)::0.00
       | Ins(ExceptNotTurkey)::0.00
       | Ins(ExceptInLanguage)::0.00
       | Ins(ExceptMiscMWord1)::0.00
       | Ins(ExceptMiscMWord2)::0.00
       | Ins(ExceptPicture)::0.00
       | Ins(ExceptDimensions)::0.00
       | Ins(ExceptNotYear)::0.00
       | Ins(ExceptStorm)::0.00
       | Ins(ExceptNotDate)::0.00
       | Ins(ExceptNotPlanetEarth)::0.00
       | Ins(ExceptProductCommunity)::0.00
       | Ins(ExceptPrefixProp)::0.00
       | Ins(ExceptChurch)::0.00
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
