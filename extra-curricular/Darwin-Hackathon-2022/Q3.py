import random

table = {
    'Phe' : ['UUC', 'UUU'],
    'Leu' : ['UUA', 'UUG', 'CUU', 'CUC', 'CUA', 'CUG'],
    'Ile' : ['AUU', 'AUC', 'AUA'],
    'Met' : ['AUG'],
    'Val' : ['GUU', 'GUC', 'GUA', 'GUG'],
    'Ala' : ['GCU', 'GCC', 'GCA', 'GCG'],
    'Thr' : ['ACU', 'ACC', 'ACA', 'ACG'],
    'Pro' : ['CCU', 'CCC', 'CCA', 'CCG'],
    'Ser' : ['UCU', 'UCC', 'UCA', 'UCG'],
    'Gly' : ['GGU', 'GGA', 'GGC', 'GGG'],
    "Tyr" : ['UAC','UAU'],
    "His" : ['CAC','CAU'],
    'Gln' : ['CAA','CAG'],
    'Asn' : ['AAU','AAC'],
    'Lys' : ['AAA','AAG'],
    'Asp' : ['GAU','GAC'],
    'Glu' : ['GAA','GAG'],
    'Cys' : ['UGU','UGC'],
    'Trp' : ['UGG'],
    'Arg' : ['CGU','CGC','CGA','CGA','AGA','AGA'],
    'Ser' : ['AGU', 'AGC']
}


aminos = input('Enter sequence - ').split('-')
if not all(item in table.keys() for item in aminos) :
    print('Invalid sequence, try again') ; quit()

outcomes = 1 ; unique = set() ; msg = ''

for amino in aminos : outcomes *= len(table[amino])

while (len(unique) != outcomes):
    chain = ''
    for amino in aminos :
        chain += random.choice(table[amino])
    unique.add(chain)

for i in unique : msg += f'{i}, '

print(f'There are {outcomes} possible RNA sequences :')
print(msg[:-2])

