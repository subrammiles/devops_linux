#!/usr/bin/env bash
# 02-variables.sh — storing values in variables.
#
# Run: ./02-variables.sh

# Assign with NO spaces around =
name="Linux learner"
course="DevOps"
year=2026

# Use a variable with $name or ${name}. Always put variables in double quotes.
echo "Hello, $name!"
echo "Welcome to the ${course} course of ${year}."

# Command substitution: store a command's output in a variable
kernel="$(uname -r)"
files_here="$(ls | wc -l)"
echo "Kernel version: $kernel"
echo "Files in this directory: $files_here"

# Arithmetic with $(( ))
a=7
b=3
echo "$a + $b = $((a + b))"
echo "$a * $b = $((a * b))"
echo "$a / $b = $((a / b))   (whole numbers only)"
echo "$a % $b = $((a % b))   (remainder)"

# Environment variables that already exist
echo "Your home directory is $HOME and your shell is $SHELL"

# Single quotes print text literally; double quotes expand variables
echo 'Single quotes: $name'
echo "Double quotes: $name"
