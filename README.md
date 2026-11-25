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

## Ubuntu

- [General installs (MySQL) and command-line basics](ubuntu/generalinstall.md)

## Getting help on any command

```bash
man ls          # Full manual (q to quit, /word to search)
ls --help       # Short summary of options
tldr ls         # Practical examples (sudo apt install tldr)
```
