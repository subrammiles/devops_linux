# Archives and Compression

`tar`, `gzip`, `zip`, `xz`

An **archive** bundles many files into one file. **Compression** makes a file smaller. On Linux, `tar` does the bundling and usually calls a compressor at the same time.

## `tar`

The flags read like a sentence:

| Flag | Meaning |
|------|---------|
| `c` | **C**reate an archive |
| `x` | E**x**tract an archive |
| `t` | List (**t**able of) contents |
| `f` | The next argument is the archive **f**ile name |
| `v` | **V**erbose: print file names |
| `z` | Compress with gzip (`.tar.gz` / `.tgz`) |
| `j` | Compress with bzip2 (`.tar.bz2`) |
| `J` | Compress with xz (`.tar.xz`) |
| `C dir` | Change to `dir` first (for extracting somewhere else) |

### Create

```bash
tar -czvf project.tar.gz project/          # gzip-compressed archive of a directory
tar -cJvf logs.tar.xz /var/log/myapp       # xz: smaller, slower
tar -czf backup-$(date +%F).tar.gz ~/docs  # Date in the file name
tar -czf site.tar.gz --exclude='node_modules' --exclude='*.log' site/
```

### List without extracting

```bash
tar -tzvf project.tar.gz
```

### Extract

```bash
tar -xzvf project.tar.gz                   # Into the current directory
tar -xzvf project.tar.gz -C /opt/          # Into /opt
tar -xzvf project.tar.gz project/README.md # Just one file
```

Modern GNU tar detects the compression when extracting, so `tar -xf file.tar.gz` also works.

> Always list (`-t`) an archive you downloaded before extracting it, to see where the files will go.

## gzip, bzip2, xz (single files)

These compress one file and replace it with the compressed version.

```bash
gzip app.log            # Creates app.log.gz and removes app.log
gzip -k app.log         # Keep the original
gunzip app.log.gz       # Decompress (or: gzip -d)
xz big.sql              # Better compression, slower
unxz big.sql.xz
```

Read compressed files without decompressing them:

```bash
zcat app.log.gz | less
zgrep "ERROR" app.log.gz
zless app.log.gz
```

Log rotation on servers produces files like `syslog.2.gz`, so `zgrep` is useful when searching old logs.

## zip / unzip

Use these when sharing with Windows users.

```bash
sudo apt install zip unzip
zip -r project.zip project/
unzip -l project.zip            # List contents
unzip project.zip -d /tmp/out   # Extract to a directory
```

## Comparing compressors

| Tool | Speed | Size | Typical use |
|------|-------|------|-------------|
| gzip | Fast | Good | Default for logs and backups |
| bzip2 | Slower | Better | Older software releases |
| xz | Slowest | Best | Software releases, long-term storage |
| zstd | Very fast | Very good | Newer systems (`tar --zstd`) |
| zip | Fast | Good | Sharing with Windows |

## Moving archives between machines

```bash
# Archive on the remote server and download it in one step, without a temporary file
ssh user@server 'tar -czf - /var/www/site' > site.tar.gz

# Copy a directory to a server through a pipe
tar -czf - mydir | ssh user@server 'tar -xzf - -C /tmp'
```

`-` as the file name means standard output or standard input.

## Practice

```bash
mkdir -p ~/lab/data && cd ~/lab
for i in {1..5}; do seq 1 10000 > data/file$i.txt; done
du -sh data
tar -czf data.tar.gz data && ls -lh data.tar.gz
tar -tzf data.tar.gz
mkdir out && tar -xzf data.tar.gz -C out && ls out/data
rm -r ~/lab
```

Previous: [environment-and-bashrc.md](environment-and-bashrc.md) · Next: [disks-and-storage.md](disks-and-storage.md)
