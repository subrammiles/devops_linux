# devops_linux

Notes and tutorials for learning Linux for DevOps. Work through them in order; each page ends with practice exercises and links to the previous and next pages.

## Linux basics — learning path

| # | Topic | Commands covered |
|---|-------|------------------|
| 1 | [Listing files](linux/basic/ls.md) | `ls` |
| 2 | [Navigating the filesystem](linux/basic/navigation.md) | `pwd`, `cd`, directory layout |
| 3 | [Files and directories](linux/basic/files-and-directories.md) | `mkdir`, `touch`, `cp`, `mv`, `rm`, `ln`, wildcards |
| 4 | [Viewing and editing files](linux/basic/viewing-files.md) | `cat`, `less`, `head`, `tail`, `nano`, `vim` |
| 5 | [Permissions and ownership](linux/basic/permissions.md) | `chmod`, `chown`, `sudo`, `umask` |
| 6 | [Users and groups](linux/basic/users-and-groups.md) | `id`, `adduser`, `usermod`, `su` |
| 7 | [Searching](linux/basic/find-grep.md) | `find`, `grep`, `which`, `locate` |
| 8 | [Pipes and redirection](linux/basic/pipes-and-redirection.md) | `>`, `\|`, `sort`, `uniq`, `cut`, `awk`, `sed` |
| 9 | [Processes and services](linux/basic/processes.md) | `ps`, `top`, `kill`, `systemctl`, `journalctl`, `cron` |
| 10 | [Package management](linux/basic/package-management.md) | `apt`, `dnf`, `apk`, `snap` |
| 11 | [Networking](linux/basic/networking.md) | `ip`, `ping`, `ss`, `curl`, `ssh`, `scp`, `ufw` |
| 12 | [Shell scripting](linux/basic/shell-scripting.md) | variables, conditions, loops, functions |

## Linux intermediate

Start these after finishing the basics.

| # | Topic | What it covers |
|---|-------|----------------|
| 1 | [Environment and `.bashrc`](linux/intermediate/environment-and-bashrc.md) | `export`, `PATH`, aliases, startup files, history shortcuts |
| 2 | [Archives and compression](linux/intermediate/archives-and-compression.md) | `tar`, `gzip`, `xz`, `zip`, `zgrep` |
| 3 | [Disks and storage](linux/intermediate/disks-and-storage.md) | `lsblk`, `df`, `du`, `mount`, `/etc/fstab`, swap, LVM |
| 4 | [Writing systemd services](linux/intermediate/systemd-services.md) | Unit files, overrides, hardening, timers |
| 5 | [Monitoring and troubleshooting](linux/intermediate/monitoring-and-troubleshooting.md) | Load, memory, I/O, network checks, `lsof`, `strace`, `sar` |
| 6 | [Docker basics](linux/intermediate/docker-basics.md) | Containers, images, volumes, Dockerfile, Compose |

## Example scripts

[linux/scripts/](linux/scripts/README.md) has 12 short, commented Bash scripts, from `hello world` to disk alerts, backups and service checks. Its README explains how to give a script execute permission (`chmod +x`), the different ways to run a script, and how to fix common errors.

## Projects

Hands-on builds that combine the commands above. Do them in order on one Ubuntu server; a throwaway cloud or local VM is ideal.

| # | Project | You will build |
|---|---------|----------------|
| 1 | [Secure a fresh server](linux/projects/01-harden-a-server.md) | Key-only SSH, no root login, `ufw`, fail2ban, automatic security updates |
| 2 | [Nginx with HTTPS](linux/projects/02-nginx-https.md) | A static site, server blocks, security headers, Let's Encrypt with auto-renewal |
| 3 | [Automated backups](linux/projects/03-automated-backups.md) | A backup script with retention, a systemd timer, failure alerts, a tested restore |
| 4 | [Deploy a Docker app](linux/projects/04-deploy-docker-app.md) | Flask + Redis with Compose, Nginx reverse proxy, HTTPS, start on boot, rollbacks |

## Distribution-specific commands

How to update, install, download, start services, and use the firewall on each distribution family.

- [Ubuntu / Debian commands](ubuntu/ubuntu-commands.md): `apt`, PPAs, `.deb` files, snap, `ufw`, AppArmor, Netplan
- [CentOS / RHEL / Rocky / Alma commands](centos/centos-commands.md): `dnf`/`yum`, `rpm`, EPEL, `firewalld`, SELinux, `nmcli`
- [Ubuntu vs CentOS side-by-side](linux/ubuntu-vs-centos.md): one table per topic, plus a script that works on both
- [Ubuntu: installing MySQL and command-line basics](ubuntu/generalinstall.md)

## Getting help on any command

```bash
man ls          # Full manual (q to quit, /word to search)
ls --help       # Short summary of options
tldr ls         # Practical examples (sudo apt install tldr)
```
