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
!----------------------------------------------------------------------

!* NB: These definitions may be outdated
!Define XmlStartTag
!       Word FSep "<" Alpha+ ">" WSep ;
       
!Define XmlEndTag
!       Word FSep {</} Alpha+ ">" ;

!Define NoTagS
!       Word FSep WSep ;

!Define PerStartTag Word FSep "<" Alpha* {Prs} Alpha* ">" WSep ;
!Define OrgStartTag Word FSep "<" Alpha* {Org} Alpha* ">" WSep ;
!Define ProStartTag Word FSep "<" Alpha* {Pro} Alpha* ">" WSep ;
!Define LocStartTag Word FSep "<" Alpha* {Loc} Alpha* ">" WSep ;

Define FWSep
       FSep* WSep ;

Define Enclose(S)
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


Define PrsHumTag Enclose({EnamexPrsHum}) ;
Define PrsMytTag Enclose({EnamexPrsMyt}) ;

Define LocGplTag Enclose({EnamexLocGpl}) ;
Define LocPplTag Enclose({EnamexLocPpl}) ;
Define LocFncTag Enclose({EnamexLocFnc}) ;
Define LocAstTag Enclose({EnamexLocAst}) ;
Define LocMytTag Enclose({EnamexLocMyt}) ;

Define OrgCrpTag Enclose({EnamexOrgCrp}) ;
Define OrgAthTag Enclose({EnamexOrgAth}) ;
Define OrgPltTag Enclose({EnamexOrgPlt}) ;
Define OrgFinTag Enclose({EnamexOrgFin}) ;
Define OrgEduTag Enclose({EnamexOrgEdu}) ;

Define PrsTag Enclose({EnamexPrs} Alpha*) ;
Define LocTag Enclose({EnamexLoc} Alpha*) ;
Define OrgTag Enclose({EnamexOrg} Alpha*) ;
Define EvtTag Enclose({EnamexEvt} Alpha*) ;
Define ProTag Enclose({EnamexPro} Alpha*) ;

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

Define PersTitleStr [ [ Field @txt"gPersTitle.txt" ] -
                    [ Field [ {digiassistentti} | {verkkolaitetoimittaja} | AlphaDown+ {toimittaja} | {välittäjä} | {markkinajohtaja} ] ] ] ;

Define TitleAdj
       lemma_exact( {johtava} | {vastaava} | {vt.} | {operatiivinen} | {entinen} ) ;

Define PersTitle1
       ( TitleAdj FWSep )
       ( TruncPfx FWSep wordform_exact({ja}) FWSep )
       lemma_exact_morph( PersTitleStr, Field - [ Field [{CASE=ESS}|{CASE=TRA}] Field ]) ;

Define PersTitle2
       ( wordform_ends( AlphaDown+ [ {iikan} | {sofian} | {logian} | {tieteen} | {emian} | {tutkimuksen} | {nomian} ] ) FWSep wordform_exact({ja}) FWSep )
       ( TruncPfx FWSep wordform_exact({ja}) FWSep )
       wordform_ends( AlphaDown+ [ {iikan} | {sofian} | {logian} | {tieteen} | {emian} | {tutkimuksen} | {nomian} ] ) FWSep
       lemma_exact_morph( {opiskelija} | {kandidaatti} | {maisteri} | {dosentti} | {tohtori} | {professori}, Field - [ Field [{CASE=ESS}|{CASE=TRA}] Field ]) ;

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
