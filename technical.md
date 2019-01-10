## Overview of methodology

### Input structure and rule structure

FiNER’s Pmatch patterns are designed for token-per-line input, where the token (i.e. plain word form), lemma, morphological tags and potential lexical semantic tags from the morphological analysis are contained in their respective tab-separated fields: 

	Yrityksen	yritys	[POS=NOUN][NUM=SG][CASE=GEN]	_
	pääkonttori	pääkonttori	[POS=NOUN][NUM=SG][CASE=NOM]	_
	sijaitsee	sijaita	[POS=VERB][VOICE=ACT][MOOD=INDV][TENSE=PRESENT][PERS=SG3]	_
	Espoossa	espoo	[POS=NOUN][PROPER=PROPER][PROP=GEO][NUM=SG][CASE=INE]	[PROP=GEO]
	.	.	[POS=PUNCTUATION]	_

Words with certain morphological features can be matched by formulating a regular expression that matches lines containing the desired morphological tags. For instance, a capitalized, pluralized noun is a line that starts with an uppercase letter and whose third field contains the substrings `[POS=NOUN]` and `[NUM=PL]`. In Pmatch, this can be matched with the following regular expression:

      UppercaseAlpha Field FSep Field FSep Field {[POS=NOUN]} Field {[NUM=PL]} Field FSep Field FSep

Here, `FSep` stands for the field separator i.e. the tab `\t`, while `Field` matches a (potentially empty) field i.e. zero or more characters that are not field separators (`[ ? - FSep]*`). The curly brackets denote strings of symbols.

The HFST Pmatch formalism allows the user the user to name certain regular expressions and use these defined sets of strings to formulate more complex patterns. This is particularly useful when writing NER rules for Finnish, since the formalism allow regular expression meant for matching strings tab-separated token-per-line input with morhological and lexical semantic information to be expressed as legible rules that are easy to modify.

User-defined pmatch functions can used as shorthands for expressions that refer to specific parts of a line. For instance, the function `lemma_exact(S)` is a shorthand for the expression `Field FSep S FSep Field FSep Field FSep`, which matches all inflected forms of the word `S` in the input. 

In Pmatch, a regular expression can be assigned a tag with the function `EndTag()`, in which case input sequences matched by said regular expression are enclosed in XML-style tags corresponding the assigned tag. For instance, expressions that match names of companies end with the function `EndTag(EnamexOrgCrp)`.

Further information on finite-state pattern matching and HFST Pmatch operators can be found in [Lauri Karttunen's Pmatch tutorial](https://web.stanford.edu/~laurik/publications/pmatch.pdf) and on [HFST Wiki](https://github.com/hfst/hfst/wiki/Regular-Expression-Operators).

### Rule types

FiNER makes use of several strategies in identifying names as well as determining whether a name-like string is markable or not. In simplistic terms, they can be described as follows:

- **Hyphenated qualifiers**: Occasionally, a name followed by a qualifier with a leading dash that effectively gives away the category to which the name belongs, e.g. _Xxx-sanomalehti_ ’the newspaper Xxx’, _Xxx-yritys_ ’the company Xxx’, _Xxx-niminen mies_ ’a man called Xxx’, _Xxx-merkkinen puhelin_ ’a phone of the brand Xxx’. However, this structure may also signify a looser association between two things instead (e.g. _Android-laite_ ’an Android device’ i.e. ’a device that uses the Android operating system’), and weeding out any false alarms is necessary in order to achieve good precision.
- **Affixes and string shape**, e.g. _Xxxsoft_, _Xxxcell_ (→ companies), _Xxxskolan_, _Xxx University_ (→ schools), _Xxxförening_ (→ society), _Xxx Ltd._, _Xxx Inc._, _Xxx GmbH_, _Xxx Kabushiki Kaisha_, _Xxx Technologies_ (→ companies), _Xxx Monthly_, _Xxx Times_, _Xxx Shimbun_, _Xxx dnevnik_ (newspapers, magazines). The overall string shape may also provide a hint to its categorization; for instance, a string of the form _AaaAaa_ is most likely to be either a name of a product or an organization.
- **Context clues & collocations**: For instance, capitalized subjects of verbs such as _lanseerata_ ’launch, release’, _rekrytoida_ ’hire, recruit’, _työllistää_ ’employ’, or _markkinoida_ ’market’ are most likely to be companies i.e. organizations, as are capitalized genitive attributes of nouns such as _toimitusjohtaja_ ’CEO’, _pääkonttori_ ’headquarters’, _osake_ ’stock’, _liikevaihto_ ’revenue’. In some cases, a neme may be preceded by an unambiguous qualifier: _teknologiajätti Xxx,_ _tietoturvayhtiö Xxx,_ _talouslehti Xxx_.
- **Disambiguation**: Context rules can also be used to disambiguate names that can be classified differently in different contexts, e.g. _Facebookin työntekijä_ ’a Facebook employee’ (→ organization) vs. _Facebookin yksityisyysasetukset_ ’Facebook privacy settings’ (→ product).  Sometimes all that is needed for reasonable disambiguation is a difference in grammatical case or number: _Pietarissa_ ’in St. Petersburg’ (→ location) vs. _Pietarille_ ’to Peter’ (→ person).
- **Semantic tags**: OMorFi, which constitutes a component of the morphlogical analyzer, already contains some built-in information on proper names which it includes in its analyses. This information is encoded in the tab-separated data by semantic tags indicating the broad category to which said names belong.
- **Capturing**: A recently added feature of the HFST implementation of Pmatch, `Capture()` makes if possible to "capture" a substring of a matched input sequence and reuse it in another regular expression. This allows FiNER to learn new names on the fly. For instance, if the pattern _Xxx Inc._ matches a string and tags it as an organization, the string matched  by _Xxx_ can be stored and used in another pattern that matches all subsequent occurrences of said string and tags them as organizations (even when not followed by the string _Inc._).
- **Gazetteers** are lists names that have been compiled ahead of time. FiNER’s gazetteers generally contain common cases (e.g. names of famous people, commonly known place names), as well as cases that are exceptions to other rules. The line between a list of prefixes and a gazetteer may not always be clear-cut. This is particularly true for person names and products: a given name can be used as a prefix element in a persons full name, but it also constitutes a personal name on its own. The gazetteers used by FiNER have mostly compiled the Finnish Wikipedia and the development corpus, and then manually edited and extended with similar cases from various other sources.
- **Exceptions** are a group of rules whose sole purpose is to block other rules whenever necessary by matching undesirable sequences with a lower weight (see below). They use the same strategies as those listed above, but are formulated for cases hat are not markable names.

### Weights

The patterns are weighted; thus, if several patterns match the same sequence, more specific and reliable patterns over fallback options. For instance, names listed in gazetteers are are largely unambiguous and are thus assigned lower weights, which allows them to take precedence over broader patterns that rely on suffixed elements or overall string shape. The system can therefore reliably identify _MacBook Air_ as a product and not as an airline, or have an exception rule prevent _Bollywood-elokuva_ (’a Bollywood film’) from being tagged as a product name. A pattern's weight is thus largely determined by its structure, but they were fine-tuned to maximize the system's performance on development corpora.

### Nested annotations

FiNER performs nested annotation in tandem with surface-level annotation, as many elements within larger surface-level patterns can already be reliably tagged as names belonging to a specific category. Pmatch allows the input string correspoding to said sub-patterns to be tagged immediately whenever the larger pattern matches a surface-level string. Thus, nested tagging is no more computationally expensive than non-nested tagging, nor are additonal tagging stages required. By default, the nested tags are discarded in the final output, but FiNER also givers the user the option to keep them if needed.

---

## Previous technical documentation

These links contain documentation on earlier (pre v. 1.1 ) versions of FiNER from 2011-2017: 

- [http://www.helsinki.fi/~jkuokkal/finer_dist/](http://www.helsinki.fi/~jkuokkal/finer_dist/)
- Kettunen, Kimmo & Mäkelä, Eetu & Ruokolainen, Teemu & Kuokkala, Juha. & Löfberg, Laura (2017). Old Content and Modern Tools: Searching Named Entities in a Finnish OCRed Historical Newspaper Collection 1771–1910. _Digital Humanities Quarterly_. DOI: [http://www.digitalhumanities.org/dhq/vol/11/3/000333/000333.html](http://www.digitalhumanities.org/dhq/vol/11/3/000333/000333.html).

## Name hierarchy: main differences from SweNER

- FiNER features an additional subcategory of organizations, namely `EnamexOrgEdu` for schools
- SweNER categories `OBJ` (`EnamexObj_`) and `WRK` (`EnamexArt_`) are subsumed under Products (`EnamexProXxx`) without futher subcategorization
- all events (`EnamexEvn_` in SweNER) are tagged as `EnamexEvtXxx` without further subcategorization.
