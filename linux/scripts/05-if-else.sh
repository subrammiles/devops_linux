#!/usr/bin/env bash
# 05-if-else.sh — making decisions.
#
# Run: ./05-if-else.sh /etc/passwd
#      ./05-if-else.sh /tmp
#      ./05-if-else.sh /does/not/exist

path="${1:-/etc/hosts}"
echo "Checking: $path"

if [[ -f "$path" ]]; then
    echo "It is a regular file."
    lines=$(wc -l < "$path")
    if (( lines > 20 )); then
        echo "It is long: $lines lines."
    else
        echo "It is short: $lines lines."
    fi
elif [[ -d "$path" ]]; then
    echo "It is a directory containing $(ls -A "$path" | wc -l) items."
else
    echo "Nothing exists at that path."
    exit 1                      # Non-zero exit code = failure
fi

# Checking permissions
[[ -r "$path" ]] && echo "You can read it."
[[ -w "$path" ]] && echo "You can write to it." || echo "You cannot write to it."
[[ -x "$path" ]] && echo "You can execute (or enter) it."

# Checking whether a command succeeded
if command -v docker > /dev/null; then
    echo "Docker is installed."
else
    echo "Docker is not installed."
fi
