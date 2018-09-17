from sys import argv
    
def wordform_exact(s):
    if s == "'":
        return "wordform_exact(Apostr)"
    if s in [ "and", "of", "the", "to", "for", "in", "from", "or" ]:
        return 'wordform_exact(OptCap({'+s+'}))'
    if s == '#':
        return 'Ins(CapNum)'
    if s == ",":
        return 'wordform_exact( Comma )'
    return 'wordform_exact({'+s+'})'

#--------------------

def name_add_wsep(name):
    list = [ wordform_exact(s) for s in name.split(' ')[:-1] ] + [ '{'+name.split(' ')[-1]+'}' ] 
    return ' WSep '.join(list)

regex_list = []

for filename in argv[1:]:
    file = open(filename, 'r')
    lines = file.read().strip().split('\n')
    names = [ line for line in lines if line != '' ]
    regex_list += [ name_add_wsep(name) for name in names ]
        
regex_list = sorted(regex_list)

print(' |\n'.join(regex_list))
