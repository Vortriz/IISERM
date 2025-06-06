#!/bin/bash

echo -e "\nQ. Practice loops for performing addition of even/odd numbers.\n"

sum_even=0

for i in {1..10}; do
    if (( i%2 == 0 )); then
        sum_even=$((sum_even + i))
    fi
done

echo "Sum of even numbers from 1 to 10: $sum_even"


sum_odd=0

for i in {1..10}; do
    if (( i%2 != 0 )); then
        sum_odd=$((sum_odd + i))
    fi
done

echo "Sum of odd numbers from 1 to 10: $sum_odd"