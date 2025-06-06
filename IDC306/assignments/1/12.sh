#!/bin/bash

echo -e "\nQ. User can input password only a fixed number of times (3) or until it gets correct\n"

# Define the correct username and password
username="admin"
password="somepassword"

# Get the username and check if it is correct
read -p "Enter username: " input_username

if [ $input_username != $username ]; then
    echo -e "\n\nUsername is incorrect. Exiting..."
    exit 1
fi

# Get the password from the user
read -sp "Enter password: " input_password

tries=1
max_tries=3
while [[ $input_password != $password ]]; do
    if [ $tries -lt $max_tries ]; then
        echo -e "\n\nPassword is incorrect. You have $((max_tries - tries)) tries left."
        ((tries++))

        read -sp "Enter password: " input_password
    else
        echo -e "\n\nYou have exceeded the maximum number of tries. Exiting..."
        exit 1
    fi
done