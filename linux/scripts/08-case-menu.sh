#!/usr/bin/env bash
# 08-case-menu.sh — a simple interactive menu using case.
#
# Run: ./08-case-menu.sh

while true; do
    echo
    echo "===== System Menu ====="
    echo "1) Show date and time"
    echo "2) Show disk usage"
    echo "3) Show memory usage"
    echo "4) Show logged-in users"
    echo "q) Quit"
    read -rp "Choose an option: " choice

    case "$choice" in
        1)   date ;;
        2)   df -h / ;;
        3)   free -h ;;
        4)   who ;;
        q|Q) echo "Goodbye!"; break ;;
        *)   echo "Invalid choice: '$choice'" ;;
    esac
done
