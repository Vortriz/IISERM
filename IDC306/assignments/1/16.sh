#!/bin/bash

echo -e "\nQ. Write a program to find an input string that is palindrome.\n"

read -p "Give input string: " input

len=${#input}
revd=""

for (( i=$len-1; i>=0; i-- )); do
    revd=$revd${input:$i:1}
done

if [[ $input == $revd ]]; then
    echo -e "\nIt is a palindrome!"
else
    echo -e "\nNot a palindrome"
fi