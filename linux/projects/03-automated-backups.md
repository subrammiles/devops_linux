# Project 3: Automated Backups with a systemd Timer

**Goal:** write a backup script that archives important directories (and optionally a MySQL database), keeps only the newest copies, runs every night on a systemd timer, and has been proven to restore.

**Uses:** [shell-scripting](../basic/shell-scripting.md), [archives-and-compression](../intermediate/archives-and-compression.md), [systemd-services](../intermediate/systemd-services.md), [find-grep](../basic/find-grep.md), [permissions](../basic/permissions.md)

**You need:** any Ubuntu machine. If you did [Project 2](02-nginx-https.md), back up `/var/www` and `/etc/nginx`.

> A backup you have never restored is not a backup. Step 6 is the most important step.

---

## Step 1: Decide what to back up

| Item | Path | Why |
|------|------|-----|
| Website files | `/var/www` | Your content |
| Nginx config | `/etc/nginx` | Rebuilding it by hand is slow and error-prone |
| Other config you changed | `/etc/ssh/sshd_config.d`, `/etc/fail2ban/jail.local` | From Project 1 |
| Database | `mysqldump` output | Copying a running database's files directly can give a broken copy |

Backups are stored in `/var/backups/server`.

## Step 2: Write the script

Create `/usr/local/bin/server-backup.sh`:

```bash
sudo tee /usr/local/bin/server-backup.sh > /dev/null <<'EOF'
#!/usr/bin/env bash
# server-backup.sh: archive important paths and keep the newest N backups.
set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-/var/backups/server}"
KEEP_DAYS="${KEEP_DAYS:-7}"
SOURCES=(/var/www /etc/nginx /etc/ssh/sshd_config.d)

STAMP="$(date +%Y%m%d-%H%M%S)"
HOST="$(hostname -s)"
ARCHIVE="$BACKUP_DIR/${HOST}-files-${STAMP}.tar.gz"

log() { echo "[$(date '+%F %T')] $*"; }

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

# Only include sources that exist, so the script works on any machine
existing=()
for src in "${SOURCES[@]}"; do
    if [[ -e "$src" ]]; then
        existing+=("$src")
    else
        log "Skipping missing path: $src"
    fi
done

if (( ${#existing[@]} == 0 )); then
    log "Nothing to back up"
    exit 1
fi

log "Archiving: ${existing[*]}"
tar -czf "$ARCHIVE" "${existing[@]}" 2> >(grep -v 'Removing leading' >&2)

# Optional: MySQL dump if mysqldump is installed and the server is running
if command -v mysqldump > /dev/null && systemctl is-active --quiet mysql; then
    DB_ARCHIVE="$BACKUP_DIR/${HOST}-mysql-${STAMP}.sql.gz"
    log "Dumping MySQL"
    # Write to a temporary name first so a failed dump never looks like a real backup
    if mysqldump --all-databases --single-transaction --routines --events | gzip > "$DB_ARCHIVE.partial"; then
        mv "$DB_ARCHIVE.partial" "$DB_ARCHIVE"
    else
        rm -f "$DB_ARCHIVE.partial"
        log "ERROR: MySQL dump failed"
        exit 1
    fi
fi

# Check that the archive can be read back
tar -tzf "$ARCHIVE" > /dev/null
log "Created $ARCHIVE ($(du -h "$ARCHIVE" | cut -f1))"

# Delete backups older than KEEP_DAYS days
deleted=$(find "$BACKUP_DIR" -maxdepth 1 -type f \( -name '*.tar.gz' -o -name '*.sql.gz' \) \
          -mtime +"$KEEP_DAYS" -print -delete | wc -l)
log "Removed $deleted old backup(s); keeping $KEEP_DAYS days"
EOF

sudo chmod 750 /usr/local/bin/server-backup.sh
```

What the less obvious lines do:

| Line | Purpose |
|------|---------|
| `set -euo pipefail` | Stop on the first error so a failed backup isn't reported as success |
| `${BACKUP_DIR:-/var/backups/server}` | Use the environment variable if set, otherwise the default |
| `chmod 700` | Backups contain config and possibly passwords, so only root may read them |
| `2> >(grep -v ...)` | Hide tar's harmless "Removing leading /" message but keep real errors |
| `--single-transaction` | Consistent MySQL dump without locking InnoDB tables |
| `.partial` then `mv` | A failed dump is deleted instead of leaving a broken file that looks like a backup. Run the script as root: on Ubuntu, root can log in to MySQL without a password |
| `tar -tzf ... > /dev/null` | Check the archive isn't corrupt |
| `-mtime +7 -delete` | Retention: remove files older than 7 days |

## Step 3: Run it by hand

```bash
sudo /usr/local/bin/server-backup.sh
sudo ls -lh /var/backups/server
```

Check the script with shellcheck:

```bash
sudo apt install -y shellcheck
shellcheck /usr/local/bin/server-backup.sh
```

## Step 4: Create the service and timer

```bash
sudo tee /etc/systemd/system/server-backup.service > /dev/null <<'EOF'
[Unit]
Description=Nightly server backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/server-backup.sh
Environment=KEEP_DAYS=7
Nice=10
IOSchedulingClass=idle
EOF

sudo tee /etc/systemd/system/server-backup.timer > /dev/null <<'EOF'
[Unit]
Description=Run server backup every night

[Timer]
OnCalendar=*-*-* 02:30:00
RandomizedDelaySec=15m
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now server-backup.timer
systemctl list-timers server-backup.timer
```

`Nice=10` and `IOSchedulingClass=idle` give the backup a lower priority, so it doesn't slow down the website while it runs.

Run it through systemd once to test, and read its log:

```bash
sudo systemctl start server-backup.service
journalctl -u server-backup.service -n 20 --no-pager
```

## Step 5: Get notified when it fails (optional)

Add a unit that runs only when the backup fails:

```bash
sudo tee /etc/systemd/system/backup-failed.service > /dev/null <<'EOF'
[Unit]
Description=Report a failed backup

[Service]
Type=oneshot
ExecStart=/usr/bin/logger -p user.err "BACKUP FAILED on %H - check: journalctl -u server-backup"
EOF
```

Then add this line to the `[Unit]` section of `server-backup.service`:

```ini
OnFailure=backup-failed.service
```

```bash
sudo systemctl daemon-reload
```

`logger` writes to the system log. You could instead send a message to Slack or a similar chat app with `curl` and a webhook URL.

## Step 6: Prove the restore works

Restore into a temporary directory. Never restore straight over live files while testing.

```bash
LATEST=$(sudo ls -1t /var/backups/server/*-files-*.tar.gz | head -1)
echo "$LATEST"

sudo tar -tzf "$LATEST" | head            # What's inside

mkdir -p /tmp/restore-test
sudo tar -xzf "$LATEST" -C /tmp/restore-test

# Compare with the live files; no output means they're identical
sudo diff -r /etc/nginx /tmp/restore-test/etc/nginx && echo "nginx config matches"

sudo rm -r /tmp/restore-test
```

Restoring one file for real:

```bash
sudo tar -xzf "$LATEST" -C / etc/nginx/sites-available/example.com
```

Restoring MySQL:

```bash
gunzip < /var/backups/server/HOST-mysql-STAMP.sql.gz | sudo mysql
```

## Step 7: Keep a copy on another machine

A backup on the same disk is lost if that disk fails or the server is deleted. Copy backups to another machine with `rsync` over SSH:

```bash
rsync -az --delete /var/backups/server/ backupuser@other-host:/backups/$(hostname -s)/
```

To automate it, add a second `ExecStart=` line to the service. A `oneshot` service runs its `ExecStart` lines in order. You'll also need an SSH key for root on this server that can log in to the backup host.

A cloud object store such as S3 or Backblaze B2, using `rclone`, works well too.

---

## Verify

| Check | Command | Expected |
|-------|---------|----------|
| Timer scheduled | `systemctl list-timers server-backup.timer` | Shows the next run |
| Last run OK | `systemctl status server-backup.service` | `status=0/SUCCESS` |
| Archives exist | `sudo ls -lh /var/backups/server` | Dated `.tar.gz` files |
| Archives private | `sudo ls -ld /var/backups/server` | `drwx------ root root` |
| Restore works | Step 6 | `diff` shows no differences |

## Stretch goals

1. Test retention: `sudo touch -d '10 days ago' /var/backups/server/old-files-test.tar.gz`, run the backup, and check that the file is deleted.
2. Add the list of installed packages to each backup: `dpkg --get-selections > /var/backups/server/packages.txt`.
3. Encrypt archives with `gpg --symmetric` before copying them off the server.
4. Make the script fail if the new archive is less than half the size of the previous one. A sudden drop in size often means something went wrong.

Previous: [02-nginx-https.md](02-nginx-https.md) · Next: [04-deploy-docker-app.md](04-deploy-docker-app.md)
