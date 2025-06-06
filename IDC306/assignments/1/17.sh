#!/bin/bash

echo -e "\nQ. Write the complement of the sequence in the fasta file.\n"

file=./fasta_file.txt

if ! [ -f $file ]; then
    echo "$file does not exist. Exiting..."
    exit 1
fi

declare -A sequences

while read line; do
    if [[ ${line:0:1} == ">" ]]; then
        seqid=${line:1:14}
    else
        sequences[$seqid]=${sequences[$seqid]}$line
    fi
done < $file

declare -A complements=([A]=T [T]=A [G]=C [C]=G)

for seqid in ${!sequences[@]}; do
    seq=${sequences[$seqid]}
    seqlen=${#seq}
    comp=""

    for i in `seq 0 $seqlen`; do
        ch=${seq:$i:1}

        comp=$comp${complements[$ch]}
    done

    echo -e "Complementary sequence of $seqid is\n$comp"
done