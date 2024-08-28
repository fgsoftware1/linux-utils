#!/bin/bash

length=0
num=0
charset="a-zA-Z0-9.-_"

read -p "password lenght: " length
read -p "how many: " num

echo "Select charset:"
echo "1) Alphanumeric + special (default)"
echo "2) Lowercase + numbers"
echo "3) Uppercase + numbers"
echo "4) Alphanumeric only"

read -p "Enter your choice (1-4): " choice

case $choice in
    2) charset="a-z0-9" ;;
    3) charset="A-Z0-9" ;;
    4) charset="a-zA-Z0-9" ;;
    *) charset="a-zA-Z0-9.-_" ;;
esac

cat /dev/urandom | tr -dc $charset | fold -w $length | head -n $num
