# Monitoring and Troubleshooting a Server

When something is wrong, check things in a fixed order instead of guessing. This page gives a checklist and the tools for each step.

## The first 60 seconds

Run these on any slow or broken server:

```bash
uptime                  # Load average and how long since the last reboot
dmesg -T | tail -20     # Recent kernel messages: disk errors, out-of-memory kills
free -h                 # Memory and swap
df -h                   # Disk space
top                     # What's using CPU and memory right now
systemctl --failed      # Services that have failed
journalctl -p err -b --no-pager | tail -30   # Recent errors since boot
```

## CPU and load

```bash
uptime
# 10:42:01 up 12 days,  load average: 3.10, 2.05, 1.20
#                                     1 min  5 min  15 min
nproc                   # Number of CPUs
```

Compare the load average with the number of CPUs. On a 4-CPU machine, a load of 4 means fully busy, and 8 means work is queuing. A rising 1-minute figure means the load is getting worse.

```bash
top                     # Press P to sort by CPU, 1 to show each CPU
htop                    # Easier to read (sudo apt install htop)
ps aux --sort=-%cpu | head -10
mpstat -P ALL 1         # Per-CPU use every second (sudo apt install sysstat)
```

In `top`, the `wa` value is time spent waiting for disk. A high `wa` means the disk is the problem, not the CPU.

## Memory

```bash
free -h
```

Look at the **available** column, not **free**. Linux uses spare RAM as disk cache, so "free" is always low on a healthy machine.

```bash
ps aux --sort=-%mem | head -10      # Biggest memory users
vmstat 1 5                          # si/so columns above 0 mean the system is swapping
```

When memory runs out, the kernel's OOM (out-of-memory) killer ends a process:

```bash
dmesg -T | grep -i -E 'killed process|out of memory'
journalctl -k | grep -i oom
```

## Disk I/O

```bash
iostat -xz 1            # Per-disk use; %util near 100 means the disk is saturated (sysstat package)
sudo iotop -o           # Which processes are reading/writing (sudo apt install iotop)
```

For disk *space* problems, see [disks-and-storage.md](disks-and-storage.md).

## Network

```bash
ss -s                       # Connection summary
ss -tan state established | wc -l   # Number of established TCP connections
sudo ss -tulpn              # What's listening, and which process
ip -s link                  # Packet and error counts per interface
sudo iftop                  # Live bandwidth per connection (sudo apt install iftop)
```

Checking a service from the outside in:

```bash
systemctl status nginx              # 1. Is the process running?
sudo ss -tlpn | grep :80            # 2. Is it listening on the expected port and address?
curl -v http://localhost            # 3. Does it answer locally?
sudo ufw status                     # 4. Is the firewall allowing the port?
curl -v http://SERVER_IP            # 5. Does it answer from another machine?
dig +short example.com              # 6. Does DNS point to the right IP?
```

A service listening on `127.0.0.1:80` only accepts local connections. It needs `0.0.0.0:80` (or the server's IP) to be reachable from outside.

## Logs

```bash
journalctl -u nginx --since "30 min ago"
journalctl -f                           # Everything, live
sudo tail -f /var/log/nginx/error.log
sudo grep -i "error" /var/log/syslog | tail
sudo tail -f /var/log/auth.log          # Logins, sudo use, SSH attempts
last -n 10                              # Recent logins
```

## Looking inside a process

```bash
pidof nginx                         # PID by name
ls -l /proc/<PID>/cwd               # Its working directory
cat /proc/<PID>/environ | tr '\0' '\n'   # Its environment variables (needs permission)
sudo lsof -p <PID>                  # Files and sockets it has open
sudo lsof -i :8080                  # Which process uses port 8080
sudo strace -p <PID> -f -e trace=network,file   # System calls it makes (sudo apt install strace)
```

`strace` is useful when a program fails with no clear error. It often shows the missing file or the refused connection.

## Collecting history with `sar`

`sar` (in the `sysstat` package) records CPU, memory and disk use over time, so you can see what happened during an incident after it's over:

```bash
sudo apt install sysstat
sudo systemctl enable --now sysstat
sar -u          # CPU history for today
sar -r          # Memory history
sar -u -f /var/log/sysstat/sa25    # A specific day (the 25th)
```

## Troubleshooting checklist

1. **What changed?** Recent deploys, package updates (`/var/log/apt/history.log`), config edits.
2. **Is it running?** `systemctl status`, `ps`.
3. **What do the logs say?** `journalctl -u`, `/var/log`.
4. **Resources?** CPU, memory, disk space, disk I/O.
5. **Network?** Listening, firewall, DNS, reachability.
6. **Reproduce it** with `curl` or by running the command by hand as the service user.
7. **Write down** what you found and how you fixed it.

## Practice

1. Run the "first 60 seconds" commands and write down what's normal for your machine.
2. Generate CPU load with `yes > /dev/null &`, watch it in `top`, then stop it with `kill %1`.
3. Find which process is listening on port 22: `sudo ss -tlpn | grep :22`.
4. Check whether the OOM killer has ever run: `journalctl -k | grep -i oom`.

Previous: [systemd-services.md](systemd-services.md) · Next: [docker-basics.md](docker-basics.md)
