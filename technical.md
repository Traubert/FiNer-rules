## Overview of methodology

### Input structure and rule formalization

FiNER’s Pmatch patterns are designed for token-per-line input, where the token (i.e. plain word form), lemma, morphological tags and potential pre-existing semantic tags imparted by the morphological analysis are contained in their respective tab-separated fields. 

	Yrityksen	yritys	[POS=NOUN][NUM=SG][CASE=GEN]	_
	toimipiste	toimipiste	[POS=NOUN][NUM=SG][CASE=NOM]	_
	sijaitsee	sijaita	[POS=VERB][VOICE=ACT][MOOD=INDV][TENSE=PRESENT][PERS=SG3]	_
	Espoossa	espoo	[POS=NOUN][PROPER=PROPER][PROP=GEO][NUM=SG][CASE=INE]	[PROP=GEO]
	.	.	[POS=PUNCTUATION]	_
	

Words with certain morphological features can be matched by formulating a regular expression that matches lines containing the desired morphological tags. For instance, a capitalized, pluralized noun equals a regular expression that matches lines starting with an uppercase letter whose third field contains the substrings `[POS=NOUN]` and `[NUM=PL]`.

In Pmatch, a regular expression can be assigned a tag, in which case input sequences matched by said regular expression are enclosed in XML-style tags corresponding the assigned tag. The formalism also allows the user the user to name certain regular expressions and use these definitions like variables or functions to formulate more complex patterns. This is particularly useful for FiNER, as these features allow rules meant for tab-separated token-per-line input with contains morphological and semantic information to be legible and easy to modify. 

### Rule types

FiNER makes use of several strategies in identifying names as well as determining whether a name-like string is markable or not. In simplistic terms, they can be described as follows:

- **Hyphenated qualifiers**: Some names are followed by trailing qualifiers that essentially describe the category to which the name belongs, e.g. _Xxx-sanomalehti_ ’the newspaper Xxx’, _Xxx-yritys_ ’the company Xxx’, _Xxx-niminen mies_ ’a man called Xxx’, _Xxx-merkkinen puhelin_ ’a phone of the brand Xxx’. However, sometimes this structure may also signify a loose association between two things instead, and weeding out any false alarms is necessary in order to achieve good precision.
- **Affixes and string shape**, e.g. _Xxxsoft_, _Xxxcell_ (→ companies), _Xxxskolan_, _Xxx University_ (→ schools), _Xxxförening_ (→ society), _Xxx Ltd._, _Xxx Inc._, _Xxx GmbH_, _Xxx Kabushiki Kaisha_, _Xxx Technologies_ (→ companies), _Xxx Monthly_, _Xxx Times_, _Xxx Shimbun_, _Xxx dnevnik_ (newspapers, magazines). The overall string shape may also provide a hint to its categorization; for instance, a string of the form _AaaAaa_ is most likely to be either a product or an organizatios.
- **Context clues & collocations**: For instance, capitalized subjects of verbs such as _lanseerata_ ’launch, release’, _rekrytoida_ ’hire, recruit’, _työllistää_ ’employ’, or _markkinoida_ ’market’ are most likely to be companies i.e. organizations, as are capitalized genitive attributes of nouns such as _toimitusjohtaja_ ’CEO’, _pääkonttori_ ’headquarters’, _osake_ ’stock’, _liikevaihto_ ’revenue’. In some cases, a preceding qualifier can be found: _teknologiajätti Xxx,_ _tietoturvayhtiö Xxx,_ _talouslehti Xxx_.
- **Disambiguation**: Context rules can also be used to disambiguate names that can be classified differently in different contexts, e.g. _Facebookin työntekijä_ ’a Facebook employee’ (→ organization) vs. _Facebookin yksityisyysasetukset_ ’Facebook privacy settings’ (→ product).  Sometimes all that is needed for reasonable disambiguation is a difference in grammatical case or number: _Pietarissa_ ’in St. Petersburg’ (→ location) vs. _Pietarille_ ’to Peter’ (→ person).
- **Semantic tags**: OMorFi, which constitutes a component of the morphlogical analyzer, already contains some built-in information on proper names which it includes in its analyses. This information is encoded in the tab-separated data by semantic tags indicating the broad category to which said names belong.
- **Capturing**: A recently added feature of the HFST implementation of Pmatch, `Capture()` makes if possible to "capture" a substring of a matched input sequence and reuse it in another regular expression. This allows FiNER to learn new names on the fly. For instance, if the pattern _Xxx Inc. _ matches a string and tags it as an organization, the string matched  by _Xxx_ can be stored and used in another pattern that matches all subsequent occurrences of said string and tags them as organizations (even when not followed by the string _Inc._).
- **Gazetteers** are lists names that have been compiled ahead of time. FiNER’s gazetteers generally contain common cases (e.g. names of famous people, commonly known place names), as well as cases that are exceptions to other rules. The line between a list of prefixes and a gazetteer may not always be clear-cut. This is particularly true for person names and products: a given name can be used as a prefix element in a persons full name, but it also constitutes a personal name on its own. The gazetteers used by FiNER have mostly compiled the Finnish Wikipedia and the development corpus, and then manually edited and extended with similar cases from various other sources.
- **Exceptions** are a group of rules whose sole purpose is to block other rules whenever necessary by matching undesirable sequences with a lower weight (see below). They use the same strategies as those listed above, but are formulated for cases hat are not markable names.

### Weights

The patterns are weighted; thus, if several patterns match the same sequence, more specific and reliable patterns over fallback options. For instance, names listed in gazetteers are are largely unambiguous and are thus assigned lower weights, which allows them to take precedence over broader patterns that rely on suffixed elements or overall string shape. The system can therefore reliably identify _MacBook Air_ as a product and not as an airline, or match _Bollywood-elokuva_ ’a Bollywood film’ without tagging it as a product. A pattern's weight is thus largely determined by its structure, but they were fine-tuned to maximize the system's performance on development corpora.

### Nested annotations

FiNER performs nested annotation in tandem with surface-level annotation, as many elements which a pattern can already be defined as names belonging to a specific category and can be tagged immediately whenever said pattern matches a surface-level string. Thus, nested tagging is no more computationalle expensive than non-nested tagging, an no additonal tagging stages are required. By default, the nested tags are discarded in the final output, but FiNER also givers the user the option to keep them if they so wish.

## Previous technical documentation

These links contain documentation on earlier versions of FiNER: 

- [http://www.helsinki.fi/~jkuokkal/finer_dist/](http://www.helsinki.fi/~jkuokkal/finer_dist/)
- Kettunen, Kimmo & Mäkelä, Eetu & Ruokolainen, Teemu & Kuokkala, Juha. & Löfberg, Laura (2017). Old Content and Modern Tools: Searching Named Entities in a Finnish OCRed Historical Newspaper Collection 1771–1910. _Digital Humanities Quarterly_. DOI: [http://www.digitalhumanities.org/dhq/vol/11/3/000333/000333.html](http://www.digitalhumanities.org/dhq/vol/11/3/000333/000333.html).

## Name hierarchy: main differences from SweNER

- FiNER features an additional subcategory of organizations, namely `EnamexOrgEdu` for schools
- categories `OBJ` (`EnamexObj_`) and `WRK` (`EnamexArt_`) are subsumed under Products (`EnamexProXxx`) without futher subcategorization.  
- all events (`EnamexEvn_`) are tagged as `EnamexEvtXxx` without further subcategorization.
