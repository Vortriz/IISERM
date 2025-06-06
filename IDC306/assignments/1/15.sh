#!/bin/bash

echo -e "\nQ. Write a calculator function to perform addition, and subtraction based on user inputs.\n"

read -p "Enter operation (add or sub): " operation
if [[ $operation != "add" && $operation != "sub" ]]; then
    echo "Invalid operation."
    exit 1
fi

read -p "Enter first number: " num1
read -p "Enter second number: " num2

case "$operation" in
    "add")
        echo "Result: $((num1 + num2))"
    ;;
    "sub")
        echo "Result: $((num1 - num2))"
    ;;
esac