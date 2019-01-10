# FiNER – Finnish Named-Entity Recognizer
### v. 1.3.1 / 2018-12-11

**NOTE: This page documents FiNER as found in v. 1.3.1 of `finnish-tagtools` (December 2018). For the documentation of the latest version of FiNER + links to up-to-date distributions, click [here](https://github.com/Traubert/FiNer-rules/blob/master/finer-readme.md).**

FiNER is a rule-based named-entity recognition tool for Finnish, developed at the University of Helsinki for the FIN-CLARIN consortium. It uses tools based on the CRF-based tagger [FinnPos](https://github.com/mpsilfve/FinnPos), the Finnish morphology package [OmorFi](https://github.com/flammie/omorfi), and the FinnTreeBank corpus for tokenization and morphological analysis, and a set of pattern-matching (`pmatch`) rules for recognizing and categorizing proper names and other expressions in plaintext input.

The pattern-matching rules are built and compiled using the [Helsinki Finite-State Technology](https://hfst.github.io/) toolkit.

## Technical documentation

Technical documentation (including a rough overview of the formalization of Finnish NER rules as well as the various strategies used by FiNER to identify names) can be found [here](https://github.com/Traubert/FiNer-rules/blob/master/technical.md).

Information on rule compilation and gazetteer usage is available [here](files-readme.md).

## Ontology & Name hierarchy

FiNER primarily identifies proper names belonging to different categories, most of which are further divided into more specific subcategories. Its name hierarchy is loosely based on that used by the Swedish Named-Entity Recognizer (HFST-SweNER) and consists of five categories for proper names (`Enamex`) – namely, locations, organizations, people, products, and events – as well as two additional categories for temporal and numerical expressions, respectively.

A general overview of the categories and their respective subcategories (as of September 2018) are shown in the tables below:

**LOCATION**

| Subcategory  | Tag            | 
|--------------|----------------|
| Political    | `EnamexLocPpl` |
| Geography    | `EnamexLocGpl` |
| Street       | `EnamexLocStr` |
| Structure    | `EnamexLocFnc` |
| Astronomy    | `EnamexLocAst` |

**ORGANIZATION**

| Subcategory  | Tag            |
|--------------|----------------|
| Political    | `EnamexOrgPlt` |
| Cultural     | `EnamexOrgClt` |
| Media        | `EnamexOrgTvr` |
| Financial    | `EnamexOrgFin` |
| School       | `EnamexOrgEdu` |
| Athletic     | `EnamexOrgAth` |
| Corporation  | `EnamexOrgCrp` |

**PERSON**

| Subcategory  | Tag            |
|--------------|----------------|
| People       | `EnamexPrsHum` |
| Animals      | `EnamexPrsAnm` |
| Mythical     | `EnamexPrsMyt` |
| Title        | `EnamexPrsTit` |

**OTHER**

| Category     | Tag            |
|--------------|----------------|
| Product      | `EnamexProXxx` |
| Event        | `EnamexEvtXxx` |

In addition to proper names, FiNER can also identify certain temporal (`Timex`) and numerical expressions (`Numex`).

**TEMPORAL EXPRESSIONS**

| Subcategory  | Tag            |
|--------------|----------------|
| Dates        | `TimexTmeDat`  |
| Clock        | `TimexTmeHrm`  |

**NUMERICAL EXPRESSIONS**

| Subcategory  | Tag            |
|--------------|----------------|
| Units        | `NumexMsrXxx`  |
| Money        | `NumexMsrCur`  |

A more detailed description of each category is given below. It should be noted that the the boundaries between these categories are far from clear-cut. The definition and contents of each subcategory may be subject to changes in the future.

- **EnamexLoc**: Locations / Place names
  - **EnamexLocPpl**: Politically defined locations
    - countries, states
    - federal states and self-governing territories
    - provinces (historical and modern)
    - administrative subdivisions (cantons, prefectures, municipalities, districts; dioceses, electorates...)
    - settlements, i.e. cities, towns, villages
    - neighborhoods, residential areas
  - **EnamexLocGpl**: Geography
    - geographical, geopolitical and cultural regions
    - continents, landmasses
    - islands, archipelagoes
    - mountains, mountain ranges, summits
    - bodies of water (oceans/seas, lakes, rivers, springs, gulfs...)
    - deserts, wastelands
    - forests
    - national parks (these may be moved to `EnamexLocFnc` later)
  - **EnamexLocStr**: Streets & Roads
    - street names
    - city squares and plazas
    - roads, highways
    - addresses
  - **EnamexLocFnc**: Structures, facilities, areas
    - buildings (city halls, stadiums, temples, castles...)
    - infrastructure (bridges, tunnels, canals, dams...)
    - fortications (city walls, gates...)
    - other structures, large monuments and landmarks
    - facilities (factories, power plants...)
    - rooms and spaces (auditoriums, halls...)
    - designated areas and zones (military bases, garrisons, cemeteries...)
    - harbors, airports, railway and bus stations
  - **EnamexLocAst**: Astronomy
    - _Maa_, _Aurinko_, _Kuu_ ('Earth', 'Sun', 'Moon') when capitalized
    - other celestial bodies: planets, planetoids, moons/satellites, asteroids, comets etc.
    - solar systems
    - stars and suns, constellations
    - galaxies
    - nebulae
    - other regions and parts of the universe
- **EnamexOrg**: Organizations
  - **EnamexOrgPlt**: Political organizations
    - political parties
    - political youth organizations
    - legislatures (parliaments)
    - governments
  - **EnamexOrgClt**: Cultural organizations
    - bands, choirs, orchestras
    - theatre, ballet, and opera companies
    - other perfoming groups and troupes
    - museums, galleries
  - **EnamexOrgTvr**: Media
    - news agencies
    - broadcasting companies
    - television channels
    - radio stations
    - newspapers, magazines, journals, periodicals and other publications
    - news portals and sites
  - **EnamexOrgFin**: Financial organizations
    - banks
    - funds
    - stock exchanges
  - **EnamexOrgEdu**: Schools
    - all schools and educational institutes, including universities
    - faculties and departments within schools
    - seminaries
  - **EnamexOrgAth**: Athletic organizations
    - sports clubs
    - racing teams
    - sports leagues (not competitions)
  - **EnamexOrgCrp**: Corporations & Miscellaneous
    - corporations, companies, businesses
    - societies, associations, fraternities/sorotities, orders of chivalry etc.
    - boards, councils, committees
    - comissions
    - judiciaries, courts
    - internationa/supranational organizations and unions
    - public administration and authorities (ministries, bureaus, agencies, offices etc.)
    - various groups, alliances, leagues etc.
    - dynasties
    - states and municipalities (as organizations)
    - criminal, terrorist, and paramilitary organizations
    - law enforcement
    - military, armed forces
    - religious organizations (churches, congregations, cults, sects...)
- **EnamexPrs**: People & Beings
  - **EnamexPrsHum**: (Human) persons (real or fictional)
    - personal names (including given names, family names, patronymics etc.)
    - families and family names
    - aliases, pseudonyms, nicknames, usernames
  - **EnamexPrsAnm**: Animals
    - pets, domestic animals etc. with names
  - **EnamexPrsMyt**: Mythical beings
    - deities
    - mythical and fictional creatures (may be moved to `EnamexPrsAnm` in the future)
  - **EnamexPrsTit**: Titles
    - titles that precede personal names; not actually proper names
- **EnamexProXxx**: Products (including artwork and artifacts), e.g.
  - software
  - services and websites
  - hardware, consumer electronics
  - literature and poetry
  - artwork
  - films, plays, television programs
  - video games
  - pharmaceuticals and narcotics
  - agreements and treaties
  - legislation (laws, acts...)
  - projects, operations
  - weapons (mostry firearms and explosives)
  - awards, prizes, trophies
  - vehicles and vessels (cars, trains, ships, aircraft, space shuttles...) 
  - food & beverages
  - fruit and vegetable cultivars (capitalized)
  - rare instances or relics and artifacts
- **EnamexEvtXxx**: Events
  - wars, conflicts, battles
  - uprisings, revolutions
  - crises
  - concerts
  - exhibitions, biennals, and other cultural events
  - sports competitions, Olympic games and other sporting events
  - festivals, fairs, conventions, expos
  - conferences, meetings, summits

- **TimexTmeDat**: Dates & Years
  - years (not decades, centuries or millenia)
  - months (of a certain year)
  - days of said months
  - combinations of above (full or partials dates)
  - date formats DD.MM.YYYY, YYYYMMDD, YYYY-MM-DD, YYYY/MM/DD
- **TimexTmeHrs**: Clock
  - hours of the day + time zone (if specified)
- **NumexMsrXxx**: Units of measurement
  - numbers followed by SI units (with prefixes) and certain common nonstandard units
  - includes expressions of dimension, e.g. 10 × 15 × 8 cm
  - **NB!** most units of time as well as Imperial and US customary units are not supported
- **NumexMsrCur**: Sums of money
  - all sums of money (including currencies if specified)

## Input

FiNER accepts **plaintext** input written in **Standard Finnish**. More precisely, the input should be
- plaintext, (e.g. `.txt`, `.tsv`, `.csv`). XML (`.html`, `.xml`) is also allowed if the element tags only span a single line, e.g. using HTML-style tags to structure the text is perfectly acceptable.
- preferably untokenized – the pipeline handles both tokenization and morphological analysis. The rules are designed for morphologically analyzed token-per-line input where
  - sentences are separated by empty lines
  - abbreviations ending in full stops are single tokens (_esim._, _mm._, _j.n.e._)
  - numbers that use spaces as digit group separators are single tokens (_50 000_)
- written in Standard Modern Finnish (although historical and colloquial/dialectal Finnish may also work to a limited extent)
- preferably be running text consisting of full sentences.
- should follow Finnish orthographic and typographic rules i.e. use proper punctuation and capitalization
- divided so that each independent text should be given as a separate input; this can be done either by giving each input text as a separate file, or by submitting a single file where each individual text is enclosed in the HTML-style tags `<text>...</text>` – this prevents the content of one text from affecting the analyses of any subsequent texts in the input.

## Output

The input given to FiNER is first tokenized, with punctuation such as commas and full stops (except those marking an abbreviation) and neighboring words separated into tokens, and printed in a token-per-line format. Empty lines are added to mark sentence boundaries. This tokenized text is then passed on to a morphological analyzer and finally to the NER rules, which identify entities in the tokenized and morphologically analyzed input.

The final output consists of two tab-separated columns, the first of which contains the tokenized input text (one token per line). The second contains XML-style tags that mark the beginning and the end of each named-entity, with the start tag denoting the first word/token in a name and the end tag denoting the last word/token. Single-token entities are marked by a closed tag. For instance, given the input `Pernoossa asuva Heikki Anttonen on ostanut Outokummun osakkeita.` FiNER should output

    Pernoossa	<EnamexLocPpl/>
    asuva	
    Henrikki	<EnamexPrsHum>
    Anttonen	</EnamexPrsHum>
    on	
    ostanut	
    Outokummun	<EnamexOrgCrp/>
    osakkeita	
    .	
    	

**Note that the FiNER rules only match whole words, not parts of words or truncated names**; this also entails that 1) some of the neighboring tokens such as quotation marks or truncated names may be included in the match for consistency's and readability's sake and 2) the number of matches does not necessarily equal the number of matched references/mentions in the text (more detailed information about FiNER's annotation practices coming soon).

## Availability & Use

A zip package containing **finnish-tagtools 1.3.1** (December 2018) for UNIX/Linux is available for download [here](http://urn.fi/urn:nbn:fi:lb-201811143). Major changes from previous versions are listed in the resource's [Metashare entry](http://urn.fi/urn:nbn:fi:lb-201811141). This package includes `finnish-nertag`, which implements a pipeline in which FiNER is the ner-tagging stage. Users can install the tools on their systems or run them in the local directory without installing.

An online demo version of `finnish-tagtools` is available for use [here](http://195.148.30.97/cgi-bin/fintag.py).

[CSC](http://csc.fi/) users can also use a pre-installed version of FiNER on the [Taito](http://research.csc.fi/taito-user-guide) supercluster and [Mylly](http://www.kielipankki.fi/tuki/mylly/).

### Command line use

`finnish-nertag` can be used on the command line as follows:

    $ finnish-nertag <<< "Helsingin yliopisto"
    Helsingin	<EnamexOrgEdu>
    yliopisto	</EnamexOrgEdu>

The tool has the following options:

- `--no-tokenize`: Turn off automatic input tokenization; this option should be used when tagging per-tokenized token-per-line input.
- `--show-analyses`: Show lemmas, morphological tags and semantic tags in the output; these are diplayed in their respective tab-separated fields. lemma forms and morphological analyses are required if the user wishes to create lemmatized frequency lists from the output. 
- `--show-nested`: Show nested entities i.e. "names within names"

Nested entities are displayed in their respective fields, e.g.

    $ finnish-nertag --show-analyses <<< "Helsingin yliopisto, Mikkelin hiippakunnan tuomiokapituli" 
    Helsingin	<EnamexOrgEdu>	<EnamexLocPpl/>
    yliopisto	</EnamexOrgEdu>
    ,				
    Mikkelin	<EnamexOrgCrp>	<EnamexLocPpl>	<EnamexLocPpl/>	
    hiippakunnan		</EnamexLocPpl>			
    tuomiokapituli	</EnamexOrgCrp>				

## Known issues
- The transducers compiled from the rules have a combined size of ~700 MB