#!/usr/bin/env bash
# 04-user-input.sh — asking the user questions with read.
#
# Run: ./04-user-input.sh

read -rp "What is your name? " name
read -rp "How many years have you used Linux? " years

# Default value if the user just presses Enter
name="${name:-friend}"
years="${years:-0}"

echo "Nice to meet you, $name."

if [[ "$years" =~ ^[0-9]+$ ]] && (( years >= 2 )); then
    echo "With $years years of experience, try the projects folder next."
else
    echo "Welcome! Start with linux/basic/ls.md."
fi

# -s hides what is typed (for passwords); -t sets a timeout in seconds
read -rsp "Type a secret word (hidden): " secret
echo
echo "Your secret has ${#secret} characters."   # ${#var} is the length
