from numpy import random

def base(mono) :
    monos = {'A', 'T', 'G', 'C'} - {mono}
    return (list(monos))[random.randint(3)]


fasta_path = input('Path to fasta file: ')
with open(fasta_path, "r") as f:
    seq = f.read().splitlines()[1]
initial_length = len(seq)

Pinsert = float(input("Probability of insertion: "))
Psubst = float(input("Probability of substitution: "))
Pdel = float(input("Probability of deletion: "))
Ngen = int(input("No. of generations: "))

mutation_count = 0

for gen in range (Ngen) :

    new_seq = ''

    for pos in range (len(seq)) :
        if random.rand() < Pinsert :
            new_seq += base('Q')
            new_seq += seq[pos]
            mutation_count += 1
        elif random.rand() < Psubst :
            new_seq += base(seq[pos])
            mutation_count += 1
        elif random.rand() < Pdel : mutation_count += 1
        else : new_seq += seq[pos]

    seq = new_seq

print('Final DNA strand - ', seq)
print('Number of Mutations - ', mutation_count)
print('Difference in length - ', len(seq)-initial_length)
