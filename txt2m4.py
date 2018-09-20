from sys import argv

uppercase = 'ABCDEFGHJKLMNOPQRSTUVWXYZÅÄÖ'

# Allow variants with different apostrophes
def check_apostrophe(s):
    if s == "'":
        return s
    elif s[0] == "'":
        return s
    elif s[-1] == "'":
        return s
    elif "'" in s:
        return s.replace("'", "} Apostr {")
    return s

#------------------------------------------
    
def wordform_exact(s):
    s = check_apostrophe(s)
    if s == "'":
        return "wordform_exact(Apostr)"
    if s.endswith('%pl') or s.endswith('%sg'):
        return lemma_exact(s)
    if s in [ "and", "of", "the", "to", "for", "in", "from", "or" ]:
        return 'wordform_exact(OptCap({'+s+'}))'
    if s == '#':
        return 'Ins(CapNum)'
    if s == ",":
        return 'wordform_exact( Comma )'
    return 'wordform_exact({'+s+'})'

def lemma_exact(s):
    s = check_apostrophe(s)
    pfx = ''

    if s.endswith('%wf'):
        return wordform_exact(s[:-3])
    
    if s == '#':
        return 'Ins(CapNum)'

    if s[0] in uppercase:
        pfx = '"'+s[0]+'" '

    s = s.lower()
    if s == 'yhdistynyt' or s == 'yhdistynyt%sg':
        return pfx+'lemma_exact_morph({yhdistyä}, {[VOICE=ACT][PCP=NUT]})'
    if s == 'yhdistynyt%pl':
        return pfx+'lemma_exact_morph({yhdistyä}, {[VOICE=ACT][PCP=NUT]} Field {NUM=PL})'
    if s.endswith('%pl'):
        return pfx+'lemma_exact_morph({'+s[:-3]+'}, {NUM=PL})'
    if s.endswith('%sg'):
        return pfx+'lemma_exact_morph({'+s[:-3]+'}, {NUM=SG})'
    return pfx+'lemma_exact({'+s+'})'
   
def inflect_sg(s):
    s = check_apostrophe(s)
    if s == '#':
        return 'Ins(CapNum)'
    if s.endswith('%pl') or s.endswith('%sg'):
        return lemma_exact(s)
        
    return 'inflect_sg({'+s+'})'

#--------------------

def inflects(word):
    if word.endswith('%sg') or word.endswith('%pl'):
        return True
    return False

#--------------------

def lemmas2regex(list):
    if len(list) == 0:
        return []
    return [ 'lemma_exact( ' + ' | '.join([ '{'+s.lower()+'}' for s in list ]) + ' )' ]

def wforms2regex(list):
    if len(list) == 0:
        return []
    return [ 'inflect_sg( ' + ' | '.join([ '{'+s+'}' for s in list ]) + ' )' ]

def mword2regex_f(words):
    return ' WSep '.join([ wordform_exact(word) for word in words[:-1]] + [ lemma_exact(words[-1]) ])      

def mword2regex_0(words):
    return ' WSep '.join([ wordform_exact(word) for word in words[:-1]] + [ inflect_sg(words[-1]) ])

mword_names_f = []
mword_names_0 = []

nword_names_f = []
nword_names_0 = []

for filename in argv[1:]:
    
    lines = [ l for l in open(filename, 'r').read().strip().split('\n') if l != '' ]
    
    nword_names = [ line for line in lines if ' ' not in line and '%' not in line ]
    mword_names = [ line.split(' ') for line in lines if ' ' in line or '%' in line ]

    if filename.endswith('Fin.txt') or filename.endswith('Congr.txt'):
        mword_names_f += mword_names
        nword_names_f += nword_names
    else:
        mword_names_0 += mword_names
        nword_names_0 += nword_names
        
first_lemma_caps =  lemmas2regex([ name for name in nword_names_f if name[0] in uppercase])
first_lemma_caps += [ mword2regex_f(name) for name in mword_names_f if name[0][0] in uppercase and inflects(name[0]) ]
first_lemma_caps += [ mword2regex_0(name) for name in mword_names_0 if name[0][0] in uppercase and inflects(name[0]) ]

first_lemma =  lemmas2regex([ name for name in nword_names_f if name[0] not in uppercase])
first_lemma += [ mword2regex_f(name) for name in mword_names_f if name[0][0] not in uppercase and inflects(name[0]) ]
first_lemma += [ mword2regex_0(name) for name in mword_names_0 if name[0][0] not in uppercase and inflects(name[0]) ]

first_other =  wforms2regex([ name for name in nword_names_0 ])
first_other += [ mword2regex_0(name) for name in mword_names_0 if inflects(name[0]) == False ]
first_other += [ mword2regex_f(name) for name in mword_names_f if inflects(name[0]) == False ]

regexes = first_other

if first_lemma_caps != []:
    flc = [ r.lstrip(' "'+uppercase) for r in first_lemma_caps ]
    regexes.append('Ins(AlphaUp) [ ' + ' |\n  '.join(flc) + ' ]')
if first_lemma != []:
    regexes.append('[ ' + ' |\n  '.join(first_lemma) + ' ]')

print(' |\n'.join(regexes))
