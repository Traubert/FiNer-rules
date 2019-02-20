#! /usr/bin/env python3

from sys import argv

uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖ'

def morphlem(s):
    pfx = ''
    if s[0] in uppercase:
        pfx = 'Lst(AlphaUp) '
    if s.endswith('%sg'):
        s = s.replace('%sg', '')
        return pfx + 'morphlem_p1({'+s.lower()+'}, {NUM=SG})'
    if s.endswith('%pl'):
        s = s.replace('%pl', '')
        return pfx + 'morphlem_p1({'+s.lower()+'}, {NUM=PL})'
    return pfx + 'morphlem_p1({'+s.lower()+'}, {NUM})'
    
def lemma(s):
    pfx = ''
    if s[0] in uppercase:
        pfx = 'Lst(AlphaUp) '
    if s.endswith('%sg'):
        s = s.replace('%sg', '')
        return pfx + 'lemma_exact_morph({'+s.lower()+'}, {NUM=SG})'
    if s.endswith('%pl'):
        s = s.replace('%pl', '')
        return pfx + 'lemma_exact_morph({'+s.lower()+'}, {NUM=PL})'
    return pfx + 'lemma_exact({'+s.lower()+'})'

def wordform_exact(s):
    if s.endswith('%sg') or s.endswith('%pl'):
        return lemma(s)
    if s == "'":
        return "wordform_exact(Apostr)"
    if s in [ "and", "of", "the", "to", "for", "in", "from", "or" ]:
        return 'wordform_exact(OptCap({'+s+'}))'
    if s == '#':
        return 'Lst(CapNum)'
    if s == ",":
        return 'wordform_exact( Comma )'
    return 'wordform_exact({'+s+'})'

#--------------------

def morphlem_add(name):
    name = name.split(' ')
    list = [ wordform_exact(s) for s in name[:-1] ] + [ morphlem(name[-1]) ]
    return ' WSep '.join(list)

def name_add_wsep(name):
    name = name.split(' ')
    list = [ wordform_exact(s) for s in name[:-1] ] + [ '{'+name[-1]+'}' ]
    return ' WSep '.join(list)

regex_list = []

for filename in argv[1:]:
    file = open(filename, 'r')
    lines = file.read().strip().split('\n')
    names = [ line for line in lines if line != '' ]
    if 'Fin.txt' in filename or 'Congr.txt' in filename:
        regex_list += [ morphlem_add(name) for name in names ]
    else:
        regex_list += [ name_add_wsep(name) for name in names ]
        
regex_list = sorted(regex_list)

print(' |\n'.join(regex_list))
