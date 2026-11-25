#!/usr/bin/env bash
# 07-functions.sh — reusable blocks of code.
#
# Run: ./07-functions.sh

# A function that prints a timestamped message. $* is all its arguments.
log() {
    echo "[$(date '+%H:%M:%S')] $*"
}

# A function with arguments. "local" keeps variables inside the function.
greet() {
    local name="$1"
    local greeting="${2:-Hello}"
    echo "$greeting, $name!"
}

# A function that "returns" a value by printing it
square() {
    echo $(( $1 * $1 ))
}

# A function that returns success (0) or failure (non-zero) for use in if
is_even() {
    (( $1 % 2 == 0 ))
}

log "Script started"
greet "Alice"
greet "Bob" "Good morning"

result=$(square 9)
echo "9 squared is $result"

for n in 3 4; do
    if is_even "$n"; then
        echo "$n is even"
    else
        echo "$n is odd"
    fi
done

log "Script finished"
