#!/usr/bin/env bash
# 10-disk-alert.sh — warn when any filesystem is fuller than a threshold.
#
# Run:  ./10-disk-alert.sh          (default threshold 80%)
#       ./10-disk-alert.sh 50       (custom threshold)
#
# Exit code: 0 = all OK, 1 = at least one filesystem over the threshold.
# That makes it easy to use from cron or another script:
#   ./10-disk-alert.sh 90 || echo "Disk problem!"

set -euo pipefail

THRESHOLD="${1:-80}"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD > 100 )); then
    echo "Usage: $0 [percent 0-100]" >&2      # >&2 sends errors to stderr
    exit 2
fi

status=0
while read -r usage mount; do
    pct="${usage%\%}"                         # Remove the trailing % sign
    if (( pct >= THRESHOLD )); then
        echo "WARNING: $mount is ${pct}% full (threshold ${THRESHOLD}%)"
        status=1
    else
        echo "OK:      $mount is ${pct}% full"
    fi
done < <(df --output=pcent,target -x tmpfs -x devtmpfs -x squashfs -x overlay -x efivarfs | tail -n +2)

exit "$status"
