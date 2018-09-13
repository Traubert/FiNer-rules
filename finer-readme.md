# FiNER – Finnish Named-Entity Recognizer

FiNER is a rule-based named-entity recognition tool for Finnish. It uses tools based on the CRF-based tagger [FinnPos](https://github.com/mpsilfve/FinnPos), the Finnish morphology package [OmorFi](https://github.com/flammie/omorfi), and the FinnTreeBank corpus for tokenization and morphological analysis, and a set of pattern-matching (`pmatch`) rules for recognizing and categorizing proper names and other expressions in plaintext input.

Additional technical documentation is available [here](technical.md).

## Ontology & Name hierarchy

FiNER primarily identifies proper names belonging to different categories, most of which are further divided into more specific subcategories. Its name hierarchy is loosely based on that used by the Swedish Named-Entity Recognizer (SweNER) and consists of five categories for proper names (`Enamex`) – namely, locations, organizations, people, products, and events – as well as two additional categories for temporal and numerical expressions, respectively.

A general overview of the categories and their respective subcategories (as of September 2018) are shown in the tables below:

**LOCATION**

| Subcategory  | Tag            | 
|--------------|----------------|
| Political    | `EnamexLocPpl` |
| Geography    | `EnamexLocGpl` |
| Street       | `EnamexLocStr` |
| Structure    | `EnamexLocFnc` |
| Astrology    | `EnamexLocAst` |

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
  - **EnamexLocAst**: Astrology
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
- **EnamexPrs**: People & Beings
  - **EnamexPrsHum**: (Human) persons
    - personal names (including given names, family names, patronymics etc.)
    - families and family names
    - aliases, pseudonyms, nicknames, usernames
  - **EnamexPrsMyt**: Mythical beings
    - deities
    - mythical and fictional creatures
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
  - weapons
  - vehicles and vessels (cars, trains, ships, aircraft, space shuttles...) 
  - rare instances of food
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
- plaintext, (e.g. `.txt`, `.tsv`, `.csv`). XML (`.html`, `.xml`) is also allowed if the element tags only occupy a single line, e.g. using HTML-style tags to structure the text is perfectly acceptable.
- preferably untokenized – the rules are designed for a specific tokenization where e.g. abbreviations ending in full stops are single tokens
- written in Standard Modern Finnish (although historical and colloquial/dialectal Finnish may also work to a limited extent)
- preferably be running text consisting of full sentences.
- should follow Finnish orthographic and typographic rules i.e. use proper punctuation and capitalization
- divided so that each independent text should be given as a separate input; this can be done either by giving each input text as a separate file, or by submitting a single file where each individual text is enclosed in the HTML-style tags `<text>...</text>` – this prevents the content of one text from affecting the analyses of any subsequent texts in the input.

## Output

The input given to FiNER is first tokenized, with punctuation such as commas and full stops (except those marking an abbreviation) and neighboring words separated into tokens, and printed in a token-per-line format. Empty lines are added to mark sentence boundaries. This tokenized text is then passed on to a morphological analyzer and finally to the NER rules, which identify entities in the tokenized and morphologically analyzed input.

The final output consists of two tab-separated columns, the first of which contains the tokenized input text (one token per line). The second contains XML-style tags that mark the beginning and the end of each named-entity, with the start tag denoting the first word/token in a name and the end tag denoting the last word/token. Single-token entities are marked by a closed tag. For instance, given the input `Pernoossa asuva Heikki Anttonen on ostanut Outokummun osakkeita.` FiNER should output

    Pernoossa	<EnamexLocPpl/>
    asuva	
    Heikki	<EnamexPrsHum>
    Anttonen	</EnamexPrsHum>
    on	
    ostanut	
    Outokummun	<EnamexOrgCrp/>
    osakkeita	
    .	
    	

**Note that the FiNER rules only match whole words, not parts of words or truncated names**; this also entails that 1) some of the neighboring tokens such as quotation marks or truncated names may be included in the match for consistency's and readability's sake and 2) the number of matches does not necessarily equal the number of matched references/mentions in the text (more detailed information about FiNER's annotation practices coming soon).

## Availability & Use

The most recent distribution (v.1.1, May 2018) can be found [here](http://korp.csc.fi/download/finnish-tagtools/v1.1/). This package includes `finnish-nertag`, which implements a pipeline in which FiNER is the ner-tagging stage.

A dated online demo version with limited functionality is available for use [here](http://korp.csc.fi/cgi-bin/fintag/fintag.py).

[CSC](http://csc.fi/) users can also use a pre-installed version of FiNER on the [Taito](http://research.csc.fi/taito-user-guide) supercluster and [Mylly](http://www.kielipankki.fi/tuki/mylly/).

## Known issues
- FiNER may slow down considerably or get stuck altogether if the input contains several consecutive strings written in all caps. These should be converted into lowercase or split into sequences of e.g. four strings.
- The transducers compiled from the pmatch rules are large (approx. 600 MB in total).
