## mmake

This script

1) runs `convert-m4gaz.sh`, which converts gazetteers containing e.g. multi-word names into `m4` files,
2) runs `compile-infl.sh` which compiles inflection rules (`infl_*.txt`) into transducers (`infl_*.hfst`),
3) runs `m4` macro processor to convert the rule sets `proper_tagger.ph1.m4` and `proper_tagger.ph1.m4` files into txt files, and
4) compiles the resulting text files into transducers (`proper_tagger.ph1.pmatch`, `proper_tagger.ph1.pmatch`).

## Rule sets

Note that these files are `m4` files and that most functions are in fact `m4` macros. This is because, until recently, the `m4` format allowed for more flexibity and versatility when it comes to text replacement and file importing than `hfst-pmatch`.

### proper_tagger.ph1.m4

The primary rule set. Contains the overwhelming majority of the pmatch rules used by FiNER.

### proper_tagger.ph2.m4

The secondary rule set. Generally recognizes names in the neighbourhood of names that have already identified by the primary rules set e.g. in lists.

### finer_defs.m4

Lists of basic definitions used by the NER rules.

## Gazetteers (g*.txt, g*.m4)

Gazetteers are lists of names or parts of names. These are mostly common or widely known names, names that cannot generalized into rules, or names that are exceptions to the more general rules.

Gazetteers do not have strict naming conventions. However, the category to which the names in each gazetteer belong is generally indicated by the file name. Most gazetteers can be imported into pmatch rules with the expression `@txt"filename.txt"`.

Gazetteers that list single-word names can be imported into pmatch rules with the expression `@txt"filename.txt"`. However, many also contain multi-word names. These cannot be used directly as such and they have to be converted into pmatch expressions that are saved as `m4` files and imported into the actual rule set. This is done by the scripts `convert-m4gaz.sh` and `txt2m4.py` (see below).

The ending of a gazetteer's filename generally indicates how the names in said gazetteer should be used in the rule set i.e. whether the list contains full names, parts of names, and whether `lemma_exact()`, `wordform_exact()`, or `inflect_sg()` should be used to match the inflected forms. Common endings are listed below:

- `Fin`: the final element of each name is a Finnish word that is subject to Finnish morphophonological processes such as consonant gradation; inflected forms are matched with the function `lemma_exact()`
- `Congr`: all elements in the name inflect like Finnish words and are matched with `lemma_exact()`
- `Misc` / no ending: the final element of each name is foreign proper name; inflected forms are matched with the function `inflect_sg()`
- `Pl`: the name inflects in plural
- `Sfx` or `Suff`: suffix word or element - these do not constitute names in their own right.

If the list is converted into a `m4` with `txt2m4.py`, the script uses the final element in the filename to determine how it should process the names by default.

### txt2m4.py

Converts `txt` files into a set of pmatch expressions that are saved into a `m4` file. Multiple files can be given as input. The way the names are converted is determined by the filename. 

Some names contain special flag symbols that indicate words that inflect (or do not inflect) in a specific way:

- `%sg`: word inflects in singular
- `%pl`: word inflects in plural
- `%wf`: word does not inflect

For instance, the band name _Mariska ja Pahat Sudet_ is formulated in the gazetteer file `gCultPerformingGroupFin.txt` as `Mariska%sg ja Paha%pl Susi%pl`, meaning that the first word in the name inflects in singular and the last two in plural.

A hash in a file name (`#`) stands for any word form that begins with a number.

The resulting `m4` files can be imported into the rule sets with the function `m4_include(`filename.m4')`.y

### convert-m4gaz.sh

Gathers smaller gazetteers belonging to the same subcategory and converts them into larger `m4` files by using `txt2m4.py`. 

### Verb lists (org-verb.txt, per-verb.txt)

Lists of verbs associated with Organizations and Persons, respectively. Used primarily in disambiguation rules.

## Inflection rules (infl_*.txt)

Regular expressions / replacement rules for inflecting names. Used by the function `inflect_sg()` to match inflected forms of foreign names.

### compile-infl.sh

Converts the inflection rules into transducers (infl_*.hfst); these can be composed with gazetteers to generate inflected forms.
