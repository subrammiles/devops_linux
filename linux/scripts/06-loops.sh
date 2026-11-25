#!/usr/bin/env bash
# 06-loops.sh — repeating things with for and while.
#
# Run: ./06-loops.sh

echo "== for over a list"
for fruit in apple banana cherry; do
    echo "I like $fruit"
done

echo
echo "== for over a range"
for i in {1..5}; do
    echo "Count: $i"
done

echo
echo "== C-style for"
for (( i = 10; i > 0; i -= 3 )); do
    echo "i = $i"
done

echo
echo "== for over files (first 5 .conf files in /etc)"
count=0
for file in /etc/*.conf; do
    echo "$(basename "$file")"
    (( ++count >= 5 )) && break          # break leaves the loop early
done

echo
echo "== while with a counter"
n=1
while (( n <= 3 )); do
    echo "Attempt $n"
    (( n++ ))
done

echo
echo "== while reading a file line by line (first 3 users)"
head -n 3 /etc/passwd | while IFS=: read -r user _ uid _ _ home shell; do
    echo "user=$user uid=$uid home=$home shell=$shell"
done
