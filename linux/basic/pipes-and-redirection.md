# Pipes, Redirection, and Text Processing

## Standard streams

Every command has three streams:

| Stream | Number | Default |
|--------|--------|---------|
| stdin  | 0 | Keyboard |
| stdout | 1 | Terminal (normal output) |
| stderr | 2 | Terminal (error messages) |

## Redirection

```bash
ls > files.txt            # stdout to a file (overwrites)
ls >> files.txt           # Append instead of overwrite
ls /nope 2> errors.txt    # stderr to a file
cmd > out.txt 2>&1        # stdout and stderr to the same file
cmd &> out.txt            # Same, Bash shorthand
cmd 2>/dev/null           # Throw errors away
sort < names.txt          # Read stdin from a file
```

`/dev/null` is a "black hole" — anything written there disappears.

### Here-documents

```bash
cat > config.ini <<EOF
[server]
port=8080
EOF
```

## Pipes `|`

A pipe sends one command's output into the next command's input:

```bash
ls -l /etc | less
cat /etc/passwd | wc -l
ps aux | grep nginx
history | grep ssh
```

## Text processing tools

```bash
sort names.txt               # Sort lines
sort -n numbers.txt          # Numeric sort
sort -r                      # Reverse
uniq                         # Remove adjacent duplicates (sort first)
uniq -c                      # Count duplicates
cut -d: -f1 /etc/passwd      # Field 1, colon-delimited → usernames
tr 'a-z' 'A-Z'               # Translate characters (to uppercase)
tee out.txt                  # Write to a file AND pass through to stdout
```

### `awk` — work with columns

```bash
awk '{print $1}' access.log              # First column
awk -F: '{print $1, $7}' /etc/passwd     # Username and shell
df -h | awk 'NR>1 {print $5, $6}'        # Usage % and mount point, skip header
```

### `sed` — find and replace

```bash
sed 's/foo/bar/' file.txt        # Replace first "foo" on each line (prints result)
sed 's/foo/bar/g' file.txt       # Replace all
sed -i 's/8080/9090/g' app.conf  # Edit the file in place
sed -n '10,20p' file.txt         # Print lines 10–20
sed '/^#/d' file.txt             # Delete comment lines
```

## Real-world pipelines

```bash
# Top 10 IP addresses in a web server log
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# Top 5 biggest items in the current directory
du -sh * | sort -rh | head -5

# All login shells in use and how many users each
cut -d: -f7 /etc/passwd | sort | uniq -c

# Save output and still see it
sudo apt update 2>&1 | tee update.log
```

## Command chaining

```bash
cmd1 ; cmd2       # Run cmd2 after cmd1, regardless of result
cmd1 && cmd2      # Run cmd2 only if cmd1 succeeded
cmd1 || cmd2      # Run cmd2 only if cmd1 failed
mkdir build && cd build
ping -c1 google.com || echo "No network"
```

Previous: [find-grep.md](find-grep.md) · Next: [processes.md](processes.md)
