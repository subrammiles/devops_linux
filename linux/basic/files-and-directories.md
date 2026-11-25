# Working with Files and Directories

`mkdir`, `touch`, `cp`, `mv`, `rm`, `rmdir`, `ln`

## `mkdir` — create directories

```bash
mkdir notes                  # Create one directory
mkdir dir1 dir2 dir3         # Create several
mkdir -p project/src/utils   # Create parent directories as needed
mkdir -v logs                # Verbose: print what was created
```

## `touch` — create empty files / update timestamps

```bash
touch todo.txt               # Create an empty file (or update its time if it exists)
touch a.txt b.txt c.txt      # Create several
```

## `cp` — copy

```bash
cp source.txt copy.txt           # Copy a file
cp file.txt backup/              # Copy into a directory
cp -r project/ project-backup/   # Copy a directory recursively
cp -i a.txt b.txt                # Ask before overwriting
cp -v *.conf /tmp/               # Verbose
cp -a src/ dest/                 # Archive: keep permissions, times, links
```

## `mv` — move or rename

```bash
mv old.txt new.txt           # Rename
mv file.txt ~/Documents/     # Move into a directory
mv *.log logs/               # Move many files
mv -i a.txt b.txt            # Ask before overwriting
mv -n a.txt b.txt            # Never overwrite
```

## `rm` — remove files

> ⚠️ There is no recycle bin. `rm` deletes permanently. Double-check paths, especially with wildcards.

```bash
rm file.txt                  # Delete a file
rm -i *.tmp                  # Ask before each deletion (good habit)
rm -r old-project/           # Delete a directory and everything inside
rm -rf build/                # Force, no prompts — be very careful
```

Before running `rm` with a wildcard, run `ls` with the same pattern to see what will match:

```bash
ls *.log     # check first
rm *.log     # then delete
```

## `rmdir` — remove empty directories

```bash
rmdir empty-dir              # Fails if the directory isn't empty (a safe default)
```

## `ln` — links

```bash
ln -s /var/log/syslog syslog-link   # Symbolic (soft) link — a shortcut
ln original.txt hardlink.txt        # Hard link — another name for the same data
ls -l syslog-link                   # Shows: syslog-link -> /var/log/syslog
```

- **Symbolic link**: points to a path. Breaks if the target is moved or deleted. Can cross filesystems and point to directories.
- **Hard link**: points to the same data on disk. The data stays until every hard link is removed.

## Wildcards (globbing)

| Pattern | Matches |
|---------|---------|
| `*`     | Any characters: `*.txt` → all `.txt` files |
| `?`     | Exactly one character: `file?.txt` → `file1.txt`, `fileA.txt` |
| `[abc]` | One of the listed characters: `file[12].txt` |
| `[0-9]` | A range: `log[0-9].txt` |
| `{a,b}` | Brace expansion: `cp file.{txt,bak}` → `cp file.txt file.bak` |

## Practice

```bash
mkdir -p ~/lab/{docs,scripts,backup}
cd ~/lab
touch docs/a.txt docs/b.txt
cp docs/*.txt backup/
mv docs/a.txt docs/readme.txt
ls -R
rm -r ~/lab          # clean up when done
```

Previous: [navigation.md](navigation.md) · Next: [viewing-files.md](viewing-files.md)
