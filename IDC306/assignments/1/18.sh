#!/bin/bash

echo -e "\nQ. Find the the ORF in the input sequence of the fasta file. The ORF starts with 'ATG/GTG' and terminates with TAG/TAA/TGA.\n"

file=./fasta_file2.txt

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

start_codons=("ATG" "GTG")
stop_codons=("TAG" "TAA" "TGA")

for seqid in ${!sequences[@]}; do
    seq=${sequences[$seqid]}
    seqlen=${#seq}

    for frame in 0 1 2; do
        i=$frame

        while [[ $i -lt $((seqlen-2)) ]]; do
            start_codon="${seq:$i:3}"

            if [[ ${start_codons[@]} =~ $start_codon ]]; then

                for (( j=$i; j<=$seqlen-2; j+=3)); do
                    stop_codon="${seq:$j:3}"

                    if [[ ${stop_codons[@]} =~ $stop_codon ]]; then
                        orf="${seq:$i:$((j - i + 3))}"
                        echo -e "\nORF found in $seqid in frame $((frame+1)) from $((i+1)) to $((j+3)):\n$orf"
                        i=$j
                        break
                    fi
                done
            fi
            i=$((i+3))
        done
    done
done