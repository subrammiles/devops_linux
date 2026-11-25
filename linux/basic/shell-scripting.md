# Bash Shell Scripting

A shell script is a text file of commands that Bash runs top to bottom.

## Your first script

```bash
#!/usr/bin/env bash
# hello.sh — prints a greeting
echo "Hello, $(whoami)! Today is $(date +%A)."
```

```bash
chmod +x hello.sh
./hello.sh
```

The first line (the *shebang*) tells Linux to run the file with Bash.

## Safer defaults

Put this near the top of real scripts:

```bash
set -euo pipefail
```

- `-e` stop if a command fails
- `-u` error on undefined variables
- `-o pipefail` a pipeline fails if any part fails

## Variables

```bash
name="world"            # No spaces around =
echo "Hello, $name"
echo "Hello, ${name}!"  # Braces when followed by other characters
today=$(date +%F)       # Command substitution
count=$((3 + 4))        # Arithmetic
readonly PI=3.14
export APP_ENV=prod     # Make available to child processes
```

Always quote variables: `"$file"` — otherwise names with spaces break.

## Arguments

```bash
#!/usr/bin/env bash
echo "Script: $0"
echo "First arg: $1"
echo "All args: $@"
echo "Number of args: $#"
```

`./args.sh one two` → `First arg: one`, `Number of args: 2`.

| Variable | Meaning |
|----------|---------|
| `$0` | Script name |
| `$1`…`$9` | Positional arguments |
| `$@` | All arguments (use `"$@"`) |
| `$#` | Number of arguments |
| `$?` | Exit code of the last command (0 = success) |
| `$$` | PID of the script |

## Reading input

```bash
read -p "Your name: " name
echo "Hi $name"
```

## Conditions

```bash
if [[ -f /etc/nginx/nginx.conf ]]; then
    echo "nginx config exists"
elif [[ -d /etc/apache2 ]]; then
    echo "apache found"
else
    echo "no web server config"
fi
```

| Test | True when |
|------|-----------|
| `-f file` | File exists |
| `-d dir`  | Directory exists |
| `-e path` | Anything exists at path |
| `-x file` | File is executable |
| `-z "$s"` | String is empty |
| `-n "$s"` | String is not empty |
| `"$a" == "$b"` | Strings equal |
| `$a -eq $b` | Numbers equal (`-ne`, `-lt`, `-le`, `-gt`, `-ge`) |

Checking if a command succeeded:

```bash
if ping -c1 -W1 8.8.8.8 &>/dev/null; then
    echo "online"
fi
```

## case

```bash
case "$1" in
    start)   echo "Starting..." ;;
    stop)    echo "Stopping..." ;;
    *)       echo "Usage: $0 {start|stop}"; exit 1 ;;
esac
```

## Loops

```bash
for i in 1 2 3; do echo "$i"; done

for f in *.log; do
    echo "Compressing $f"
    gzip "$f"
done

for i in {1..5}; do echo "Run $i"; done

count=0
while [[ $count -lt 3 ]]; do
    echo "count=$count"
    count=$((count + 1))
done

while read -r line; do
    echo "Line: $line"
done < file.txt
```

## Functions

```bash
log() {
    echo "[$(date +%T)] $*"
}

backup() {
    local src="$1"
    local dest="$2"
    cp -r "$src" "$dest" && log "Backed up $src"
}

backup /etc/nginx /tmp/nginx-backup
```

## Exit codes

```bash
exit 0      # success
exit 1      # failure
```

## Example: disk usage alert

```bash
#!/usr/bin/env bash
set -euo pipefail

THRESHOLD=${1:-80}   # default 80% if no argument given

df -h --output=pcent,target | tail -n +2 | while read -r usage mount; do
    pct=${usage%\%}
    if (( pct >= THRESHOLD )); then
        echo "WARNING: $mount is at $usage"
    fi
done
```

## Example: simple backup script

```bash
#!/usr/bin/env bash
set -euo pipefail

SRC="${1:?Usage: $0 <directory>}"
DEST="$HOME/backups"
STAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$DEST"
tar -czf "$DEST/$(basename "$SRC")-$STAMP.tar.gz" "$SRC"
echo "Saved to $DEST"

# Keep only the 7 newest backups
ls -1t "$DEST"/*.tar.gz | tail -n +8 | xargs -r rm --
```

## Debugging

```bash
bash -x script.sh      # Print each command as it runs
shellcheck script.sh   # Lint for common mistakes (sudo apt install shellcheck)
```

Previous: [networking.md](networking.md) · Next: [Intermediate — environment and .bashrc](../intermediate/environment-and-bashrc.md)
