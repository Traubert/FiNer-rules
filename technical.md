## Previous technical documentation

These lins contain documentaion on earlier versions of FiNER: 

- [http://www.helsinki.fi/~jkuokkal/finer_dist/](http://www.helsinki.fi/~jkuokkal/finer_dist/)
- Kettunen, Kimmo & Mäkelä, Eetu & Ruokolainen, Teemu & Kuokkala, Juha. & Löfberg, Laura (2017). Old Content and Modern Tools: Searching Named Entities in a Finnish OCRed Historical Newspaper Collection 1771–1910. Digital Humanities Quarterly. DOI: [http://www.digitalhumanities.org/dhq/vol/11/3/000333/000333.html](http://www.digitalhumanities.org/dhq/vol/11/3/000333/000333.html).

## Name hierarchy: main differences from SweNER

- FiNER features an additional subcategory of organizations, namely `EnamexOrgEdu` for schools
- categories `OBJ` (EnemxObj_) & `WRK` (`EnamexArt_`) are subsumed under Products (`EnamexProXxx`) without subcategorization.  
- all events (`EnamexEvn_`) are tagged as `EnamexEvtXxx` without subcategorization.

## Overview of methodology (in Finnish)

FiNER:in pattern matching -säännöt hyödyntävät nimien tunnistuksessa erilaisia tekniikoita, jotka liittyvät:
1. merkkijonon tai lausekkeen rakenteeseen, esim. _Xxx Xxx -yhtiö_, _Xxx Xxx Oy_, _Xxx Interactive_, _Café Xxxx_ ja _Xxxxsoft_ ovat hyvin todennäköisesti yrityksiä.
2. ympäröivään kontekstiin ja kollokaatioihin, esim. lauseke _Xxx_ on todennäköisesti yritys, jos se esiintyy sellaisissa konteksteissa kuin vaikkapa _Xxx:n toimitusjohtaja/pääkonttori/osakkeet_, _Xxx lanseeraa/työllistää/rekrytoi_ tai _teknologiajätti Xxx_ – tai jos se on luettelossa kahden sellaisen nimen tuntumassa, jotka tiedetään ennalta yrityksiksi: _Nokia, Xxx ja Samsung_.
3. morfologisen jäsentimen (OMorFi + FinnPos) valmiiksi sisältämään tietoon merkkijonon semantiikasta (esim. OMorFi hyödyntää erilaisia nimilistoja).
4. ennalta koostettuihin nimilistoihin, joihin on pyritty kokoamaan sellaisia yleisesti tunnettuja tapauksia, joiden tunnistaminen muilla säännöillä ei ole välttämättä mahdollista tai jotka ovat poikkeuksia sääntöihin, esim. säännön mukaan _Xxxcell_-muotoinen merkkijono tunnistetaan oletuksena yrityksen nimeksi mutta sukunimilistassa esiintyvä _Purcell_ merkitään henkilönnimeksi. Listoissa esiintyvät nimet on kerätty FiNER:in kehittämisessä käytetystä käsin annotoidusta aineistosta sekä mm. suomen- ja englanninkielisten Wikipedioiden listauksista.

FiNER kykenee kontekstin ja morfologisen tiedon avulla myös jossain määrin disambiguoimaan nimiä, jotka voivat viitata useampaan eri kategoriaan kuuluviin entiteetteihin, (esim. _Anttilan`[Org]` konkurssi_ vs. _Anttilan`[Prs]` puoliso_, _valittaa Facebookille`[Org]`_ vs. _valittaa Facebookissa`[Pro]`_).

Sääntöihin on liitetty painoja (todennäköisyyksiä), jotka määräävät sen, mitä sääntöä lopulta sovelletaan tapauksessa, johon sopisi useampi sääntö. Nyrkkisääntönä nimilistat ovat tyypillisesti luotettavampia kuin vaikkapa pelkästään nimen alku- tai loppuosaa tarkkailevat säännöt, jotka puolestaan jyräävät yleensä kollokaatio- ja kontekstisäännöt.

