#!/usr/bin/env bash
# 03-arguments.sh — reading values passed on the command line.
#
# Run: ./03-arguments.sh apple banana "cherry pie"

echo "Script name:          $0"
echo "Number of arguments:  $#"
echo "First argument:       ${1:-<none>}"
echo "Second argument:      ${2:-<none>}"

# ${1:-default} means "use $1, or 'default' if it's empty"

if [[ $# -eq 0 ]]; then
    echo
    echo "Tip: try  $0 apple banana \"cherry pie\""
    exit 0
fi

echo
echo "All arguments, one per line:"
for arg in "$@"; do           # "$@" keeps "cherry pie" as one argument
    echo "  - $arg"
done
