# Writing systemd Services and Timers

The basics page [processes.md](../basic/processes.md) showed how to start and stop existing services. This page shows how to run **your own** program as a service: it starts at boot, restarts if it crashes, and logs to the journal.

## Where unit files live

| Location | Purpose |
|----------|---------|
| `/etc/systemd/system/` | Your own units and overrides (use this one) |
| `/lib/systemd/system/` or `/usr/lib/systemd/system/` | Units installed by packages (don't edit these) |

```bash
systemctl cat nginx         # Show a unit file
systemctl list-unit-files --type=service
```

## Example: run a Python web app as a service

Assume the app is at `/opt/myapp/app.py` and should run as user `myapp`.

```bash
sudo useradd --system --no-create-home --shell /usr/sbin/nologin myapp
sudo chown -R myapp:myapp /opt/myapp
```

Create `/etc/systemd/system/myapp.service`:

```ini
[Unit]
Description=My Python web app
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=myapp
Group=myapp
WorkingDirectory=/opt/myapp
Environment=APP_ENV=production
EnvironmentFile=-/etc/myapp/env
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Load and start it:

```bash
sudo systemctl daemon-reload          # Required after creating or editing unit files
sudo systemctl enable --now myapp
systemctl status myapp
journalctl -u myapp -f                # Everything the app prints to stdout/stderr
```

## What the main settings mean

| Setting | Meaning |
|---------|---------|
| `After=` | Start after these units (ordering only) |
| `Wants=` / `Requires=` | Also start these units. `Requires` fails this unit if they fail |
| `Type=simple` | `ExecStart` is the main process and stays in the foreground |
| `Type=oneshot` | Runs once and exits (for scripts) |
| `Type=forking` | The program puts itself in the background (older daemons) |
| `User=` / `Group=` | Run as this account instead of root |
| `WorkingDirectory=` | Directory the process starts in |
| `Environment=` | Set one variable |
| `EnvironmentFile=` | Load `KEY=value` lines from a file. A leading `-` means "ignore if missing" |
| `ExecStart=` | The command. Use full paths |
| `ExecReload=` | Command for `systemctl reload` (for example `kill -HUP $MAINPID`) |
| `Restart=` | `no`, `on-failure`, or `always` |
| `RestartSec=` | Wait time before restarting |
| `WantedBy=multi-user.target` | Start at normal boot when enabled |

## Changing a packaged service safely

Don't edit files in `/lib/systemd/system`; package updates overwrite them. Use an override instead:

```bash
sudo systemctl edit nginx
```

This opens an editor for `/etc/systemd/system/nginx.service.d/override.conf`. Add only the lines you want to change:

```ini
[Service]
LimitNOFILE=65536
Restart=always
```

`systemctl edit` reloads systemd for you. Restart the service to apply the change.

## Basic hardening

These settings limit what a service can do if it's compromised:

```ini
[Service]
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/myapp
```

Check how exposed a service is:

```bash
systemd-analyze security myapp
```

## Timers: a modern alternative to cron

Timers run a service on a schedule, and their output goes to the journal.

`/etc/systemd/system/backup.service`:

```ini
[Unit]
Description=Nightly backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
```

`/etc/systemd/system/backup.timer`:

```ini
[Unit]
Description=Run backup every night

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
RandomizedDelaySec=10m

[Install]
WantedBy=timers.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer
systemctl list-timers                 # Next and last run times
sudo systemctl start backup.service   # Run it now to test
journalctl -u backup.service
```

`Persistent=true` runs a missed job at the next boot if the machine was off at the scheduled time.

`OnCalendar` examples:

| Expression | When |
|------------|------|
| `hourly` | Every hour |
| `daily` | Every day at midnight |
| `Mon *-*-* 09:00` | Mondays at 09:00 |
| `*:0/15` | Every 15 minutes |

Check an expression with `systemd-analyze calendar "Mon *-*-* 09:00"`.

## Troubleshooting

```bash
systemctl status myapp              # Exit code and last log lines
journalctl -u myapp -n 50 --no-pager
journalctl -u myapp -b              # Since last boot
systemd-analyze verify /etc/systemd/system/myapp.service   # Check the unit file for errors
sudo systemctl reset-failed myapp   # Clear the failed state after too many restarts
```

Common mistakes:

- Forgetting `sudo systemctl daemon-reload` after editing a unit file.
- Using a relative path in `ExecStart`.
- The service user can't read its files (check with `sudo -u myapp ls /opt/myapp`).
- The program puts itself in the background while the unit uses `Type=simple`.

## Practice

1. Write a script `/usr/local/bin/tick.sh` that runs `while true; do echo tick; sleep 5; done`, and make it executable.
2. Create `tick.service` for it, then enable and start it.
3. Watch it with `journalctl -u tick -f`.
4. Kill it with `sudo pkill -f tick.sh` and confirm `Restart=on-failure` brings it back. (`pkill` sends SIGTERM, which systemd treats as a clean exit, so use `Restart=always` if it doesn't come back.)
5. Clean up: `sudo systemctl disable --now tick && sudo rm /etc/systemd/system/tick.service && sudo systemctl daemon-reload`

Previous: [disks-and-storage.md](disks-and-storage.md) · Next: [monitoring-and-troubleshooting.md](monitoring-and-troubleshooting.md)
