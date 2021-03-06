! -*- coding: utf-8 -*-

!======================================================================
!==== Auxiliary definitions
!======================================================================

m4_include(`finer_defs.m4')

!======================================================================
!==== Recognition rule
!======================================================================

!----------------------------------------------------------------------
! Expansion
! Assign identical NE tag to neighbouring untagged proper names in lists
! NB: These rule take input with additional fields and field separators,
! which must be accounted when marking word boundaries.
!----------------------------------------------------------------------

Define FWSep
       FSep* WSep ;

Define MakeTag(S)
       Word FSep "<" ("/") S ("/") ">" ;

Define CompleteList1(Tag)
       LC( Tag FWSep lemma_exact(Comma) FWSep Tag FWSep lemma_exact( Comma | {ja} | {sekä} ) FWSep )
       CapWord ;

Define CompleteList2(Tag)
       LC( Tag FWSep lemma_exact(Comma) FWSep )
       CapWord
       RC( FWSep lemma_exact( Comma | {ja} ) FWSep Tag ) ;

Define CompleteList3(Tag)
       CapWord
       RC( FWSep lemma_exact(Comma) FWSep Tag FWSep lemma_exact( Comma | {ja} | {sekä} ) FWSep Tag ) ;

Define CompleteList(Tag)
       [ CompleteList1(Tag) | CompleteList2(Tag) | CompleteList3(Tag) ] ;


Define PrsHumTag MakeTag({EnamexPrsHum}) ;
Define PrsMytTag MakeTag({EnamexPrsMyt}) ;

Define LocGplTag MakeTag({EnamexLocGpl}) ;
Define LocPplTag MakeTag({EnamexLocPpl}) ;
Define LocFncTag MakeTag({EnamexLocFnc}) ;
Define LocAstTag MakeTag({EnamexLocAst}) ;
Define LocMytTag MakeTag({EnamexLocMyt}) ;

Define OrgCrpTag MakeTag({EnamexOrgCrp}) ;
Define OrgAthTag MakeTag({EnamexOrgAth}) ;
Define OrgPltTag MakeTag({EnamexOrgPlt}) ;
Define OrgFinTag MakeTag({EnamexOrgFin}) ;
Define OrgEduTag MakeTag({EnamexOrgEdu}) ;

Define PrsTag MakeTag({EnamexPrs} Alpha*) ;
Define LocTag MakeTag({EnamexLoc} Alpha*) ;
Define OrgTag MakeTag({EnamexOrg} Alpha*) ;
Define EvtTag MakeTag({EnamexEvt} Alpha*) ;
Define ProTag MakeTag({EnamexPro} Alpha*) ;

Define CompleteListPrsHum CompleteList(PrsHumTag) EndTag(EnamexPrsHum) ;
Define CompleteListPrsMyt CompleteList(PrsMytTag) EndTag(EnamexPrsMyt) ;
Define CompleteListOrgCrp CompleteList(OrgCrpTag) EndTag(EnamexOrgCrp) ;
Define CompleteListOrgAth CompleteList(OrgAthTag) EndTag(EnamexOrgAth) ;
Define CompleteListOrgFin CompleteList(OrgFinTag) EndTag(EnamexOrgFin) ;
Define CompleteListOrgEdu CompleteList(OrgEduTag) EndTag(EnamexOrgEdu) ;
Define CompleteListOrgPlt CompleteList(OrgPltTag) EndTag(EnamexOrgPlt) ;
Define CompleteListLocGpl CompleteList(LocGplTag) EndTag(EnamexLocGpl) ;
Define CompleteListLocPpl CompleteList(LocPplTag) EndTag(EnamexLocPpl) ;
Define CompleteListLocAst CompleteList(LocAstTag) EndTag(EnamexLocAst) ;
Define CompleteListLocFnc CompleteList(LocFncTag) EndTag(EnamexLocFnc) ;
Define CompleteListLocMyt CompleteList(LocMytTag) EndTag(EnamexLocMyt) ;
Define CompleteListOrg CompleteList(OrgTag) EndTag(EnamexOrgCrp) ;
Define CompleteListLoc CompleteList(LocTag) EndTag(EnamexLocPpl) ;
Define CompleteListPrs CompleteList(PrsTag) EndTag(EnamexPrsHum) ;
Define CompleteListPro CompleteList(ProTag) EndTag(EnamexProXxx) ;
Define CompleteListEvt CompleteList(EvtTag) EndTag(EnamexEvtXxx) ;


Define AbbrInParenthesesOrg
       LC( OrgTag FWSep lemma_exact( LPar ) FWSep )
       wordform_exact( AlphaUp+ Field Capture(OrgCpt) )
       RC( FWSep lemma_exact( RPar ) )
       EndTag(EnamexOrgCrp) ;

Define AbbrInParenthesesPro
       LC( ProTag FWSep lemma_exact( LPar ) FWSep )
       wordform_exact( AlphaUp+ Field Capture(ProCpt) )
       RC( FWSep lemma_exact( RPar ) )
       EndTag(EnamexProXxx) ;

Define OrgCaptured
       wordform_exact( OrgCpt (":" AlphaDown ) )
       EndTag(EnamexOrgCrp) ;

Define ProCaptured
       wordform_exact( ProCpt (":" AlphaDown ) )
       EndTag(EnamexProXxx) ;

Define InQPro [
       [ wordform_exact(Apostr) FWSep AlphaUp [ [ ? - Apostr ] Word FSep FWSep ]+ wordform_exact(Apostr) ] |
       [ wordform_exact(DoubleQuote) FWSep AlphaUp [ [ ? - DoubleQuote ] Word FSep FWSep ]+ wordform_exact(DoubleQuote) ]
       ] EndTag(EnamexProXxx1) ;

Define ProQuoteAndQuote
       LC( Quote FSep Word FSep "<" [ "/" Alpha* {Pro} Alpha* | Alpha* {Pro} Alpha* "/" ] ">" FWSep )
       [ lemma_exact( Comma ) FWSep InQPro FWSep ]*
       [ lemma_exact( Comma | {ja} | {sekä} ) FWSep InQPro ] ; 
       

!* HEAD
Define Expand
       [ CompleteListPrsHum
       | CompleteListPrsMyt
       | CompleteListOrgCrp
       | CompleteListOrgAth
       | CompleteListOrgFin
       | CompleteListOrgEdu
       | CompleteListOrgPlt
       | CompleteListLocGpl
       | CompleteListLocPpl
       | CompleteListLocAst
       | CompleteListLocFnc
       | CompleteListLocMyt
       | CompleteListOrg::0.25
       | CompleteListLoc::0.25
       | CompleteListPrs::0.25
       | CompleteListPro::0.25
       | CompleteListEvt::0.25
       | AbbrInParenthesesOrg
       | AbbrInParenthesesPro
       | OrgCaptured
       | ProCaptured
       | ProQuoteAndQuote
       ] ;

Define PersTitleStr [ [ Field @txt"gaz/gPersTitle.txt" ]
                    - [ Field [ {digiassistentti} | {laitetoimittaja} | {järjestelmätoimittaja} |
		      	      	{markkinajohtaja} | {syöjätär} ] ] ] ;

Define TitleAdj
       lemma_exact( {johtava} | {vastaava} | {vt.} | {operatiivinen} | {entinen} ) ;

Define PersTitle1
       [ ( TitleAdj FWSep )
       	 ( TruncPfx FWSep wordform_exact({ja}) FWSep )
       	 [ lemma_exact_morph( PersTitleStr, {[NUM=SG]}) - morphtag({CASE=ESS}|{CASE=TRA}) ] |
       	 lemma_exact( @txt"gaz/gPersTitleAbbr.txt" ) ] ;
	 
Define PersTitle2
       ( wordform_ends( AlphaDown+ [ {iikan} | {sofian} | {logian} | {tieteen} |
       	 		{emian} | {tutkimuksen} | {nomian} ] ) FWSep wordform_exact({ja}) FWSep )
       ( TruncPfx FWSep wordform_exact({ja}) FWSep )
       wordform_ends( AlphaDown+ [ {iikan} | {sofian} | {logian} | {tieteen} |
       		      {emian} | {tutkimuksen} | {nomian} ] ) FWSep
       lemma_exact_morph( {opiskelija} | {kandidaatti} | {maisteri} | {dosentti} | {tohtori} | {professori}, [ Field {NUM=SG} Field ] - [ Field [{CASE=ESS}|{CASE=TRA}] Field ]) ;

Define PersTitle3
       [ wordform_exact(OptCap({hallituksen}|{johtoryhmän})) FWSep lemma_exact({puheenjohtaja}) ] |
       [ lemma_exact(OptCap({luova})) FWSep lemma_exact({johtaja}) ] |
       [ wordform_exact(OptCap({tasavallan}|{istuva})) FWSep lemma_exact({presidentti}) ] |
       [ lemma_exact(OptCap({teollinen}|{graafinen})) FWSep lemma_exact({muotoilija}|{suunnittelija}) ] |
       [ wordform_exact(OptCap({stand} (Dash) {up})) FWSep lemma_exact((Dash) {koomikko}) ] ;

Define PersTitle
       [ Ins(PersTitle1) | Ins(PersTitle2) | Ins(PersTitle3) ] EndTag(EnamexPrsTit1) ;

Define PersTitleRule
       ( Ins(PersTitle) FWSep wordform_exact({ja}) FWSep )
       Ins(PersTitle)
       RC( FWSep PrsTag ) ;

!----------------------------------------------------------------------
! Exceptions
!----------------------------------------------------------------------

!----------------------------------------------------------------------
! TOP: Main entry of the recognizer
!----------------------------------------------------------------------

Define TOP
       LC( WordBoundary )
       [ Expand
       | PersTitleRule 
       ] RC( FSep* WordBoundary ) ;
