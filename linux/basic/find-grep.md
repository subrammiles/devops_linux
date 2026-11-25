# Searching — `find`, `grep`, `locate`, `which`

## `find` — search for files by name, type, size, time

```bash
find . -name "*.log"              # By name, from current dir down
find /etc -iname "*.conf"         # Case-insensitive name
find . -type d -name node_modules # Only directories
find . -type f -size +100M        # Files bigger than 100 MB
find /var/log -mtime -1           # Modified in the last day
find . -mmin -30                  # Modified in the last 30 minutes
find . -empty                     # Empty files and directories
find . -maxdepth 1 -type f        # Don't descend into subdirectories
find / -name passwd 2>/dev/null   # Hide "Permission denied" errors
```

Acting on results:

```bash
find . -name "*.tmp" -delete                 # Delete matches (check without -delete first!)
find . -name "*.sh" -exec chmod +x {} \;     # Run a command on each match
find . -name "*.log" -exec ls -lh {} +       # Pass many matches to one command
```

## `grep` — search inside files

```bash
grep "error" app.log              # Lines containing "error"
grep -i "error" app.log           # Case-insensitive
grep -n "error" app.log           # Show line numbers
grep -v "DEBUG" app.log           # Lines NOT matching
grep -c "error" app.log           # Count matching lines
grep -r "TODO" src/               # Recursive through a directory
grep -rl "password" /etc 2>/dev/null   # Only list file names
grep -w "root" /etc/passwd        # Whole word only
grep -A 3 -B 2 "Exception" app.log     # 3 lines after, 2 before each match
grep -E "error|fail" app.log      # Extended regex: either word
```

### Basic regular expressions

| Pattern | Matches |
|---------|---------|
| `^text` | Lines starting with `text` |
| `text$` | Lines ending with `text` |
| `.`     | Any single character |
| `.*`    | Any characters |
| `[0-9]` | A digit |
| `[a-z]+`| One or more lowercase letters (with `-E`) |

```bash
grep "^#" /etc/ssh/sshd_config        # Comment lines
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"   # Config without comments/blank lines
```

## Finding commands

```bash
which python3       # Path of the command that would run
type ls             # Is it an alias, builtin, or file?
whereis nginx       # Binary, source and man page locations
```

## `locate` — fast name search using a database

```bash
sudo apt install plocate
sudo updatedb
locate sshd_config
```

## Practice

1. Find all `.conf` files directly in `/etc`: `find /etc -maxdepth 1 -name "*.conf"`
2. Find which users use bash: `grep "bash$" /etc/passwd`
3. Count lines with "error" in syslog: `grep -ci error /var/log/syslog`
4. Find files over 50 MB in your home: `find ~ -type f -size +50M`

Previous: [users-and-groups.md](users-and-groups.md) · Next: [pipes-and-redirection.md](pipes-and-redirection.md)
