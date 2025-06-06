#!/bin/bash

echo -e "\nQ. Using the function, write the complement of the sequence in the fasta file.\n"

complement() {
    local seq="$1"
    local comp_seq=""
    for (( i=0; i<${#seq}; i++ )); do
        ch="${seq:$i:1}"
        case "$ch" in
            A) comp_seq+="T" ;;
            T) comp_seq+="A" ;;
            C) comp_seq+="G" ;;
            G) comp_seq+="C" ;;
            *) comp_seq+="$char" ;;
        esac
    done
    echo "$comp_seq"
}

input_file="./fasta_file.txt"
output_file="./fasta_file_complement.txt"

if ! [ -f $input_file ]; then
    echo "$input_file does not exist. Exiting..."
    exit 1
fi

>$output_file

while read -r line; do
    if [[ $line == ">"* ]]; then
        echo "$line" >> "$output_file"
    else
        complement "$line" >> "$output_file"
    fi
done < "$input_file"

echo "Complement sequence written to $output_file"