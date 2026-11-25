#!/usr/bin/env bash
# 09-system-info.sh — print a quick report about this machine.
#
# Run:  ./09-system-info.sh
# Save: ./09-system-info.sh > report.txt

set -euo pipefail

line() { printf '%*s\n' 50 '' | tr ' ' '-'; }

echo "SYSTEM REPORT — $(date '+%F %T')"
line
echo "Hostname:     $(hostname)"
echo "OS:           $(. /etc/os-release && echo "$PRETTY_NAME")"
echo "Kernel:       $(uname -r)"
echo "Uptime:       $(uptime -p)"
echo "CPU cores:    $(nproc)"
echo "Load average: $(cut -d' ' -f1-3 /proc/loadavg)"
line
echo "MEMORY"
free -h | awk 'NR==1 || /^Mem/'
line
echo "DISK (real filesystems only)"
df -h -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs 2>/dev/null || df -h
line
echo "IP ADDRESSES"
hostname -I 2>/dev/null || ip -brief addr
line
echo "TOP 5 PROCESSES BY MEMORY"
ps aux --sort=-%mem | awk 'NR<=6 {printf "%-10s %5s %5s  %s\n", $1, $3, $4, $11}'
