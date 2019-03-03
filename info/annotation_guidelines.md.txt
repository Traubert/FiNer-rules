# Suomen kielen NER-annotointikäytännöistä

Alla on lueteltu keskeiset periaatteet, joita FiNER;in nimentunnistussäännöt pyrkivät noudattamaan. Ne määrittävät sen, mitkä tekstissä esiintyvät kokonaisuudet FiNER katsoo merkitsemiskelpoisiksi entiteeteiksi ja missä entiteetin katsotaan alkavan tai loppuvan. Teknisten rajoitusten ja virheiden vuoksi FiNER saattaa syötettä käsitellessään tehdä ratkaisuja, jotka ovat ristiriidassa ao. ohjeiden kanssa.

Näitä samoja ohjeita voi käyttää ohjenuorana suomenkielisen tekstin käsin annotoinnissa.

##§1 Kokonaiset saneet ja nimet

FiNER tunnistaa tai merkitsee vain 1) kokonaisia saneita ja 2) kokonaisia nimiä. FiNER ei siis tunnista
- nimiä, jotka ovat laajemman saneen osana (*_Android*-käyttäjä_) tai
- nimen palasia yksinään (*_Pohjois-* ja Etelä-Amerikka_, _*Windows-* ja Linux-käyttöjärjestelmät_) – ks. kuitenkin §3.

##§2 Yhdysviivat ja selitteet

Jos nimen loppuun on liitetty yhdysviivalla selite, lauseke merkitään kokonaisuudessaan nimeksi. Nimen ja selitteen yhdistelmä ja pelkkä nimi yksinään ovat keskenään synonyymejä. Esim. kaikki allaolevat tapaukset ovat merkittävissä tuotteiksi (`EnamexProXxx`):

_Netflix_
_Android_
_Netflix-striimauspalvelu_
_Android-käyttöjärjestelmä_

Sen sijaan jos yhdysviivaa seuraa jokin muu kuin selite, lauseketta ei merkitä. Esimerkiksi ao. tapauksia ei merkitä ollenkaan:

*_Netflix-elokuva_
*_Android-puhelin_

Ylläolevissa tapauksissa kyseessä ei ole selite: elokuvan nimi ei ole _Netflix_ eikä _Android-puhelin_ tarkoita Android-nimistä puhelinta.

Nimi ja sitä seuraava selite merkitään kokonaisuudessan entiteetiksi silloinkin, jos nimen ja selitteen välissä on välilyönti (esim. monisanaisen nimen tapauksessa) tai jos nimeä ympäröivät lainausmerkit, kuten alla:

_Windows Vista_
_Windows Vista -käyttöjärjestelmä_
_“Windows Vista” -käyttöjärjestelmä_

Myös _-niminen/-merkkinen_-tapaiset osat ja niitä seuraavat attribuutit kuuluvat entiteettiin. Esimerkiksi kaikki seuraavanlaiset lausekkeet, jotka viittaavat käyttöjärjestelmään nimeltä _Sailfish OS_, merkitään kokonaisuudessaan tuotteiksi (`EnamexProXxx`):

_Sailfish OS_
_"Sailfish OS"_
_Sailfish OS -käyttöjärjestelmä_
_Sailfish OS -niminen käyttöjärjestelmä_
_"Sailfish OS" -niminen avoin käyttöjärjestelmä_

Allaoleva esimerkki havainnollistaa, miten "-merkkinen" toimii pitkälti samalla tavalla kuin "-niminen":

_Ferrarissa_
_Ferrari-merkkisessä autossa_

##§3 Koordinaatio

Isomman nimen osat jotka on tiiveyden vuoksi lueteltu peräkkäin konjunktiolla tai pilkuilla koordinoituna muodostavat yhden entiteetin:

_Pohjois- ja Etelä-Amerikka_ (`EnamexLocGpl`)
_Android-, iOS-, Sailfish OS -käyttöjärjestelmät_ (`EnamexProXxx`)
_Lumia 720, 625, 620 ja 520_ (`EnamexProXxx`)
_Windows XP tai Vista_ (`EnamexProXxx`)

Näin pysytään myös sopusoinnussa §1:n kanssa.

##§4 Lainausmerkit

Esimerkiksi tuotteiden ja organisaatioiden nimiä sekä henkilöiden lempinimiä tai nimimerkkejä ympäröivät lainausmerkit kuuluvat pääasiallisesti entiteettiin, mikäli niiden tarkoituksena on merkitä esim. muotoilemattomassa tekstissä nimen alkua ja loppua:

_Windows Vista_
_“Windows Vista”_

Näin lainausmerkkien käsittely on johdonmukaista ja yhtenevää seuraavanlaisten tapausten kanssa, jotka tulisi joka tapauksessa merkitä kokonaisuudessaan:

_Marko “Fobba” Fors_
_“Windows Vista” -käyttöjärjestelmä_ (ks. §2)

Jos lainausmerkeillä kuitenkin merkitään sitaattia, sarkasmia tai käytetään jollain vastaavalla tavalla (esim. _scare quotes_), niitä ei kuulu (eikä yleensä voikaan) merkitä entieetin osaksi.

_Vastustajat haukkuivat häntä “Darth Vaderiksi”._

##§5 Päivämäärät

Päivämääriin ja niiden koordinaatioon pätee pitkälti pätee samat säännöt kuin nimiin; esimerkiksi seuraavat lausekkeet merkitään kokonaan:

_vuosina 2001, 2002 ja 2003_
_tammi- ja helmikuussa_

##§6 Genetiiviä seuraava selitesana – kuuluuko nimeen vai ei?

Esimerkiksi paikannimen genetiiviä omana sananaan seuraavaa sanaa ei merkitä osaksi entiteettiä, jos kyseessä on puhtaasti selite, jonka tarkoitus on selventää nimen sisältöä. Tällöin pelkän nimen merkitseminen riittää:

_Montanan osavaltio_ (=_Montana_) -> vain _Montana_ merkitään
_Uppsalan kaupungissa_ (=_Uppsalassa_) -> vain _Uppsalan_ merkitään
_Uudenmaan maakunta_ (≈_Uusimaa_) -> vain _Uudenmaan_ merkitään

Jos kyseinen yhdistelmä on kuitenkin vakiintunut paikannimi tai esim. hallinnollisen alueen virallinen nimi (jolloin kyseessä ei ole välttämättä edes selite), se merkitään kokonaan. Tällöin ei ole merkitystä sillä, onko nimen alkuosa synonyymi koko nimen kanssa vai ei:

_Ruotsin kuningaskunta_	(≈ _Ruotsi_)
_Suomen tasavalta_ (≈ _Suomi_)
_Uudenmaan lääni_ (selkeämpi merkintätapa; _Uusimaa_ viittaa yksinään usein maakuntaan)
_Porin lääni_ (≠ _Pori_, kaupunki)

Lauseke merkitään myös kokonaan silloin, jos tarkoitetaan aluetta hallinnoivaa organisaatiota (kategoria `EnamexOrgCrp`):

_Suomen valtio_
_Helsingin kaupungille_

## §7 Urheilukilpailut

Jos urheilukilpailulla ei ole omaa nimeä (kuten _Kalevan kisat_, _Helsinki City Run_ jne.), tapahtuma on kuitenkin merkittävissä, jos siitä selviää
- laji,
- mestaruuden laajuus *tai* paikka ja
- ajankohta,

kuten esimerkiksi alla:

_jalkapallon vuoden 1998 maailmanmestaruuskilpailut_
_jalkapallon vuoden 1998 MM-kisat_
_jalkapallon EM-kilpailut 1998_
_jääkiekon maailmancup 1996_
_vuoden 2002 jalkapallon maailmanmestaruuskipailut_

Olympiakisojen tapauksessa tapahtuma merkitään, jos siitä käy ilmi

- vuosi
- paikka *ja/tai* se, onko kyseessä kesä- vai talviolympialaiset.

Esimerkkejä:

_Helsingin olympialaiset 1952_
_Helsingin kesäolympialaiset 1952_
_kesäolympialaiset 1952_
_vuoden 1952 kesäolympialaiset_

Tämän lisäksi merkitään olympialaiset, ovat yksiselitteisiä myös ilman jotakin vaadittua elementtiä, esim. 

_Helsingin olympiakisat_
_Helsingin kesäolympialaiset_.


