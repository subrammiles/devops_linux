# `ls` — List Directory Contents

The `ls` command lists the files and directories in a location. With no arguments it lists the current working directory. It's usually the first command you run after opening a terminal or moving to a new folder.

## Syntax

```bash
ls [options] [file_or_directory...]
```

## Basic examples

```bash
ls                 # List the current directory
ls /etc            # List a specific directory
ls ~/Documents     # List a directory inside your home folder
ls file1.txt dir1  # List specific files/directories
```

## Common options

| Option | Meaning |
|--------|---------|
| `-l`   | Long format: permissions, owner, size, date |
| `-a`   | Show all files, including hidden ones (names starting with `.`) |
| `-A`   | Like `-a` but hides `.` and `..` |
| `-h`   | Human-readable sizes (`4.0K`, `12M`), used with `-l` |
| `-t`   | Sort by modification time, newest first |
| `-r`   | Reverse the sort order |
| `-S`   | Sort by file size, largest first |
| `-R`   | List subdirectories recursively |
| `-d`   | List the directory itself, not its contents |
| `-1`   | One entry per line |
| `-i`   | Show inode numbers |
| `--color=auto` | Colour output by file type |

Options can be combined: `ls -lah` is the same as `ls -l -a -h`.

## Reading the long format (`ls -l`)

```text
$ ls -l
-rw-r--r-- 1 alice devs  1200 Nov 25 10:14 notes.txt
drwxr-xr-x 2 alice devs  4096 Nov 24 18:02 scripts
lrwxrwxrwx 1 alice devs    11 Nov 20 09:00 latest -> notes.txt
```

| Field | Example | Meaning |
|-------|---------|---------|
| File type | `-` / `d` / `l` | `-` regular file, `d` directory, `l` symbolic link |
| Permissions | `rw-r--r--` | Owner / group / others (see [permissions.md](permissions.md)) |
| Link count | `1` | Number of hard links |
| Owner | `alice` | User who owns the file |
| Group | `devs` | Group that owns the file |
| Size | `1200` | Size in bytes (use `-h` for K/M/G) |
| Modified | `Nov 25 10:14` | Last modification time |
| Name | `notes.txt` | File name (`->` shows a link's target) |

## Useful combinations

```bash
ls -lah            # Everything, long format, readable sizes
ls -lt             # Newest files first
ls -ltr            # Oldest first (newest at the bottom — handy for logs)
ls -lS             # Largest files first
ls -ld /var/log    # Info about the directory itself
ls *.txt           # Only files ending in .txt (shell wildcard)
ls -d */           # Only directories
ls -R project/     # Everything under project/, recursively
```

## Hidden files

Files whose names start with a dot (`.bashrc`, `.git`, `.ssh`) are hidden. Use `ls -a` to see them:

```text
$ ls -a ~
.  ..  .bashrc  .profile  .ssh  Documents  Downloads
```

`.` is the current directory and `..` is the parent directory.

## Practice

1. List your home directory with hidden files: `ls -a ~`
2. Find the five most recently changed files in `/etc`: `ls -lt /etc | head -6`
3. Show the size of `/var/log` itself, not its contents: `ls -ldh /var/log`
4. List only directories in `/`: `ls -d /*/`

## Related

- `tree` — shows a directory as a tree (`sudo apt install tree`)
- `stat file` — detailed info about one file
- `find` — search for files (see [find-grep.md](find-grep.md))

Next: [navigation.md](navigation.md)
