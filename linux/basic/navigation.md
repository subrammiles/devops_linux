# Navigating the Filesystem — `pwd`, `cd`

## The Linux directory tree

Linux has a single tree that starts at `/` (the *root*). There are no drive letters like `C:`.

| Directory | What lives there |
|-----------|------------------|
| `/`       | Root of the whole filesystem |
| `/home`   | Users' home directories (`/home/alice`) |
| `/root`   | Home directory of the `root` user |
| `/etc`    | System configuration files |
| `/var`    | Variable data: logs (`/var/log`), caches, spools |
| `/tmp`    | Temporary files (often cleared on reboot) |
| `/usr`    | Installed programs and libraries (`/usr/bin`, `/usr/lib`) |
| `/bin`, `/sbin` | Essential commands (often links into `/usr`) |
| `/opt`    | Optional / third-party software |
| `/dev`    | Device files (disks, terminals) |
| `/proc`, `/sys` | Virtual files exposing kernel and process info |
| `/mnt`, `/media` | Mount points for extra disks and USB drives |

## `pwd` — print working directory

```bash
$ pwd
/home/alice/Documents
```

## `cd` — change directory

```bash
cd /var/log        # Absolute path (starts with /)
cd Documents       # Relative path (from where you are now)
cd ..              # Up one level
cd ../..           # Up two levels
cd ~               # Your home directory
cd                 # Same as cd ~
cd -               # Back to the previous directory
cd ~/projects/app  # ~ expands to your home directory
```

## Absolute vs relative paths

- **Absolute** paths start at `/`: `/home/alice/notes.txt`. They work from anywhere.
- **Relative** paths start from the current directory: `notes.txt`, `./notes.txt`, `../shared/file`.

Special names:

| Symbol | Meaning |
|--------|---------|
| `.`    | Current directory |
| `..`   | Parent directory |
| `~`    | Your home directory |
| `~bob` | Bob's home directory |
| `-`    | Previous directory (with `cd`) |

## Tips

- Press **Tab** to auto-complete file and directory names. Press it twice to see all options.
- Paths with spaces need quotes: `cd "My Files"` or escaping: `cd My\ Files`.
- Names are case-sensitive: `Documents` and `documents` are different.

## Practice

1. `cd /var/log && pwd`
2. `cd ..` then `pwd` — you should be in `/var`.
3. `cd -` to jump back to `/var/log`.
4. `cd` with no arguments, then `pwd` to confirm you're home.

Previous: [ls.md](ls.md) · Next: [files-and-directories.md](files-and-directories.md)
