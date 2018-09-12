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

def lemmas2regex(list):
    if len(list) == 0:
        return []
    return [ 'lemma_exact( ' + ' | '.join([ '{'+s.lower()+'}' for s in list ]) + ' )' ]

def wforms2regex(list):
    if len(list) == 0:
        return []
    return [ 'inflect_sg( ' + ' | '.join([ '{'+s+'}' for s in list ]) + ' )' ]


def mword2regex(words, mode=None):
    if mode in [ 'FIN', 'CONGR' ]:
        return ' WSep '.join([ wordform_exact(word) for word in words[:-1]] + [ lemma_exact(words[-1]) ])      
    else:
        return ' WSep '.join([ wordform_exact(word) for word in words[:-1]] + [ inflect_sg(words[-1]) ])


regex_list = []

for filename in argv[1:]:

    mode = None
    if filename.endswith('Fin.txt'):
        mode = 'FIN'
    if filename.endswith('Congr.txt'):
        mode = 'CONGR'

    lines = open(filename, 'r').read().strip().split('\n')
        
    for words in [ line.split(' ') for line in lines if ' ' in line ]:
        regex_list.append(mword2regex(words, mode))
    if mode in [ 'FIN', 'CONGR' ]:
        regex_list += lemmas2regex([ line for line in lines if line != '' and ' ' not in line and '%' not in line ])
    else:
        regex_list += wforms2regex([ line for line in lines if line != '' and ' ' not in line and '%' not in line ])
        
regex_list = sorted(regex_list)
lemma1_list = sorted([ r.lstrip('" '+uppercase) for r in regex_list if r.lstrip('" '+uppercase).startswith('lemma') ])
regex_list  = sorted([ r for r in regex_list if ( r.startswith('wordform_exact') or r.startswith('inflect_sg')) ])

if lemma1_list != []:
    regex_list.append('Ins(AlphaUp) [\n '+' |\n '.join(lemma1_list) + ' ]')

if mode == 'CONGR':
    regex_list = [ 'Ins(AlphaUp) [\n '+' |\n '.join(lemma1_list) + ' ]' ]

print(' |\n'.join(regex_list))
