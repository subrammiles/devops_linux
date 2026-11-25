# Processes and Services

## Viewing processes

```bash
ps                  # Processes in your current terminal
ps aux              # All processes, all users
ps -ef              # Same idea, different format
ps aux | grep nginx # Find a specific process
pgrep -a nginx      # PIDs and command lines matching "nginx"
pstree              # Process tree
top                 # Live view (q to quit)
htop                # Nicer live view (sudo apt install htop)
```

Key `ps aux` columns: `USER`, `PID` (process ID), `%CPU`, `%MEM`, `STAT` (state), `COMMAND`.

In `top`: `P` sort by CPU, `M` sort by memory, `k` kill a process, `q` quit.

## Stopping processes

```bash
kill 1234           # Ask process 1234 to stop (SIGTERM, signal 15)
kill -9 1234        # Force kill (SIGKILL) — last resort, no cleanup
pkill nginx         # Kill by name
killall node        # Kill all processes with this name
```

Common signals: `SIGTERM` (15, polite stop), `SIGKILL` (9, forced), `SIGHUP` (1, often "reload config"), `SIGINT` (2, what Ctrl+C sends).

## Foreground and background jobs

```bash
sleep 300 &         # Start in background
jobs                # List background jobs
fg %1               # Bring job 1 to the foreground
# Ctrl+Z            # Pause the foreground job
bg %1               # Resume it in the background
nohup ./long-task.sh > task.log 2>&1 &   # Keep running after you log out
```

## Services with `systemctl` (systemd)

Most modern distributions (Ubuntu, Debian, RHEL, Fedora) manage services with systemd.

```bash
systemctl status nginx          # Is it running? Recent log lines
sudo systemctl start nginx      # Start now
sudo systemctl stop nginx       # Stop now
sudo systemctl restart nginx    # Stop + start
sudo systemctl reload nginx     # Reload config without stopping (if supported)
sudo systemctl enable nginx     # Start automatically at boot
sudo systemctl disable nginx    # Don't start at boot
sudo systemctl enable --now nginx   # Enable and start in one step
systemctl list-units --type=service --state=running
systemctl --failed              # Services that failed
```

## Logs with `journalctl`

```bash
journalctl -u nginx             # Logs for one service
journalctl -u nginx -f          # Follow live
journalctl -u nginx --since "1 hour ago"
journalctl -p err -b            # Errors since last boot
journalctl --disk-usage
```

Traditional log files also live in `/var/log` (`syslog`, `auth.log`, `nginx/`...).

## System resources

```bash
uptime              # How long running + load average
free -h             # Memory usage
df -h               # Disk space per filesystem
du -sh /var/log     # Size of a directory
lscpu               # CPU info
nproc               # Number of CPUs
```

## Scheduling with cron

```bash
crontab -e          # Edit your scheduled jobs
crontab -l          # List them
```

Format: `minute hour day-of-month month day-of-week command`

```text
*/5 * * * *  /home/alice/check.sh          # Every 5 minutes
0 2 * * *    /home/alice/backup.sh         # Every day at 02:00
0 9 * * 1    /home/alice/report.sh         # Mondays at 09:00
```

Use [crontab.guru](https://crontab.guru) to check expressions.

Previous: [pipes-and-redirection.md](pipes-and-redirection.md) · Next: [package-management.md](package-management.md)
