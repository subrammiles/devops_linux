#!/usr/bin/env bash
# 11-backup-folder.sh — make a dated .tar.gz backup of a folder and keep the newest 5.
#
# Run: ./11-backup-folder.sh ~/Documents
#      ./11-backup-folder.sh ~/Documents /mnt/usb/backups
#
# Default destination: ~/backups

set -euo pipefail

SOURCE="${1:?Usage: $0 <folder-to-back-up> [destination]}"
DEST="${2:-$HOME/backups}"
KEEP=5

if [[ ! -d "$SOURCE" ]]; then
    echo "Error: '$SOURCE' is not a directory" >&2
    exit 1
fi

mkdir -p "$DEST"

name="$(basename "$(realpath "$SOURCE")")"
archive="$DEST/${name}-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "Backing up $SOURCE -> $archive"
# -C changes to the parent directory so the archive holds "name/..." not the full path
tar -czf "$archive" -C "$(dirname "$(realpath "$SOURCE")")" "$name"
echo "Done: $(du -h "$archive" | cut -f1)"

# Keep only the newest $KEEP backups of this folder
mapfile -t old < <(ls -1t "$DEST/${name}"-*.tar.gz | tail -n +$((KEEP + 1)))
for f in "${old[@]}"; do
    echo "Removing old backup: $f"
    rm -- "$f"
done

echo "Backups now in $DEST:"
ls -1t "$DEST/${name}"-*.tar.gz
