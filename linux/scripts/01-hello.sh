#!/usr/bin/env bash
# 01-hello.sh — your first script.
#
# Run it:
#   bash 01-hello.sh              (no permission needed)
#   chmod +x 01-hello.sh          (give execute permission once)
#   ./01-hello.sh                 (then run it directly)

echo "Hello, World!"
echo "You are logged in as: $(whoami)"
echo "Today is: $(date '+%A, %d %B %Y')"
echo "Current directory: $(pwd)"
