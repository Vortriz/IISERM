#!/bin/bash

echo -e "\nQ. Shell program to check for name and password match input by a user (the input text for password will not be visible) \n"

# Define the correct username and password
username="admin"
password="somepassword"

# Get the username and password from the user
read -p "Enter username: " input_username
read -sp "Enter password: " input_password

# Check if the username and password match
if [ $input_username == $username ] && [ $input_password == $password ]; then
    echo -e "\n\nUsername and password match"
else
    echo -e "\n\nUsername and password do not match!"
fi