# File Permissions and Ownership

`chmod`, `chown`, `chgrp`, `umask`, `sudo`

## Reading permissions

```text
$ ls -l deploy.sh
-rwxr-x--- 1 alice devs 512 Nov 25 10:00 deploy.sh
│└┬┘└┬┘└┬┘
│ │  │  └── others: ---  (no access)
│ │  └───── group:  r-x  (read, execute)
│ └──────── owner:  rwx  (read, write, execute)
└────────── type:   -    (regular file)
```

| Letter | On a file | On a directory |
|--------|-----------|----------------|
| `r` read    | View contents | List names inside (`ls`) |
| `w` write   | Modify contents | Create/delete/rename files inside |
| `x` execute | Run as a program | Enter it (`cd`) and access files inside |

## `chmod` — change permissions

### Symbolic mode

```bash
chmod +x script.sh        # Add execute for everyone
chmod u+x script.sh       # Add execute for the owner (u)
chmod g-w file.txt        # Remove write from the group (g)
chmod o-rwx secret.txt    # Remove everything from others (o)
chmod a+r public.txt      # Add read for all (a)
chmod u=rw,go=r file.txt  # Set exactly
```

### Numeric (octal) mode

Each permission has a value: `r=4`, `w=2`, `x=1`. Add them for each of owner, group, others.

| Number | Permissions |
|--------|-------------|
| 7 | `rwx` |
| 6 | `rw-` |
| 5 | `r-x` |
| 4 | `r--` |
| 0 | `---` |

```bash
chmod 755 script.sh   # rwxr-xr-x  — typical for scripts and directories
chmod 644 file.txt    # rw-r--r--  — typical for normal files
chmod 600 ~/.ssh/id_ed25519   # rw-------  — private keys (SSH requires this)
chmod 700 ~/private   # rwx------  — private directory
chmod -R 755 site/    # Recursive
```

## `chown` / `chgrp` — change owner and group

```bash
sudo chown bob file.txt          # Change owner
sudo chown bob:devs file.txt     # Change owner and group
sudo chown -R www-data:www-data /var/www/site   # Recursive
sudo chgrp devs file.txt         # Change group only
```

## `sudo` — run as administrator

Regular users can't change system files. `sudo` runs one command as `root`:

```bash
sudo apt update
sudo nano /etc/hosts
sudo -i            # Open a root shell (use sparingly; type exit to leave)
```

Avoid `chmod 777` — it lets anyone modify the file. It's rarely the right fix.

## `umask` — default permissions

`umask` decides the permissions new files get:

```bash
umask          # usually 0022 → new files 644, new directories 755
```

## Practice

```bash
echo 'echo "it works"' > hi.sh
./hi.sh               # Permission denied
chmod u+x hi.sh
./hi.sh               # it works
ls -l hi.sh
chmod 600 hi.sh && ls -l hi.sh
```

Previous: [viewing-files.md](viewing-files.md) · Next: [users-and-groups.md](users-and-groups.md)
