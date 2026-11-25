# Bash Scripts: Permissions and How to Run Them

This folder has small, commented example scripts. Read each one, run it, then change it and run it again. That's the fastest way to learn.

## The scripts

| Script | What it teaches | Try it |
|--------|-----------------|--------|
| [01-hello.sh](01-hello.sh) | Shebang, `echo`, running commands inside text | `./01-hello.sh` |
| [02-variables.sh](02-variables.sh) | Variables, quoting, arithmetic | `./02-variables.sh` |
| [03-arguments.sh](03-arguments.sh) | `$1`, `$#`, `"$@"`, default values | `./03-arguments.sh a b "c d"` |
| [04-user-input.sh](04-user-input.sh) | `read`, hidden input, input validation | `./04-user-input.sh` |
| [05-if-else.sh](05-if-else.sh) | `if`/`elif`/`else`, file tests, exit codes | `./05-if-else.sh /etc/passwd` |
| [06-loops.sh](06-loops.sh) | `for`, `while`, `break`, reading a file line by line | `./06-loops.sh` |
| [07-functions.sh](07-functions.sh) | Functions, `local`, returning values | `./07-functions.sh` |
| [08-case-menu.sh](08-case-menu.sh) | `case` and an interactive menu | `./08-case-menu.sh` |
| [09-system-info.sh](09-system-info.sh) | A practical system report | `./09-system-info.sh` |
| [10-disk-alert.sh](10-disk-alert.sh) | Checking disk use, exit codes for automation | `./10-disk-alert.sh 50` |
| [11-backup-folder.sh](11-backup-folder.sh) | Dated backups that keep only the newest copies | `./11-backup-folder.sh ~/Documents` |
| [12-service-check.sh](12-service-check.sh) | Service and website health checks with coloured output | `./12-service-check.sh ssh cron` |

Before running any of them, go into this folder:

```bash
cd linux/scripts
```

---

## Three ways to run a script

### 1. Pass it to bash (no permission needed)

```bash
bash 01-hello.sh
```

Bash reads the file and runs it. The file doesn't need execute permission.

### 2. Make it executable and run it directly

```bash
chmod +x 01-hello.sh       # Do this once
./01-hello.sh
```

`./` means "in the current directory". Without it, Linux only looks for commands in the directories listed in `$PATH`, and you get `command not found`.

### 3. Install it so it runs from anywhere

```bash
mkdir -p ~/bin
cp 09-system-info.sh ~/bin/sysinfo     # The command name doesn't need .sh
chmod +x ~/bin/sysinfo
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
sysinfo                                # Works from any directory
```

To make a script available to every user on the system, use `/usr/local/bin` instead: `sudo cp 09-system-info.sh /usr/local/bin/sysinfo`.

---

## Giving permissions

### Check the current permissions

```bash
ls -l 01-hello.sh
```

```text
-rw-rw-r-- 1 alice alice 412 Nov 25 10:00 01-hello.sh     ← no x: not executable
-rwxrwxr-x 1 alice alice 412 Nov 25 10:00 01-hello.sh     ← x: executable
```

The `x` (execute) bit is what lets you run `./script.sh`. See [../basic/permissions.md](../basic/permissions.md) for the full explanation.

### Common ways to set it

```bash
chmod +x script.sh          # Everyone can execute (the usual choice)
chmod u+x script.sh         # Only you (the owner) can execute
chmod 755 script.sh         # rwxr-xr-x: you can edit; everyone can read and run
chmod 700 script.sh         # rwx------: only you can read, edit or run (use for scripts containing secrets)
chmod +x *.sh               # All scripts in this folder at once
```

To remove execute permission: `chmod -x script.sh`

### Scripts that need root

Some commands need administrator rights. Run the **whole script** with `sudo`:

```bash
sudo ./10-disk-alert.sh
```

Or use `sudo` only on the lines that need it, inside the script. That's usually better: the rest of the script runs as a normal user.

A script can check whether it's running as root:

```bash
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root: sudo $0" >&2
    exit 1
fi
```

### Execute permission and Git

Git saves the execute bit. After `chmod +x`, commit the change so it's kept when someone else clones the repository:

```bash
chmod +x linux/scripts/*.sh
git add linux/scripts/
git commit -m "Make scripts executable"
git ls-files -s linux/scripts/   # 100755 = executable, 100644 = not
```

On Windows, where `chmod` doesn't exist, use `git update-index --chmod=+x script.sh`.

---

## Anatomy of a script

```bash
#!/usr/bin/env bash          # 1. Shebang: which program runs this file
# Comment explaining the script
set -euo pipefail            # 2. Safety: stop on errors and undefined variables

name="${1:-World}"           # 3. Variables and arguments
echo "Hello, $name"          # 4. Commands
exit 0                       # 5. Exit code: 0 = success, anything else = failure
```

**The shebang** must be the very first line. `#!/usr/bin/env bash` finds bash wherever it's installed. `#!/bin/bash` also works on almost all Linux systems.

**`bash script.sh` vs `sh script.sh`:** on Ubuntu, `sh` is `dash`, a smaller shell that doesn't support bash features such as `[[ ]]`, arrays and `{1..5}`. Run these scripts with `bash` or `./`, not `sh`.

### Exit codes

Every command returns a number when it finishes. `0` means success.

```bash
./10-disk-alert.sh 90
echo $?                      # 0 = all OK, 1 = a disk is over 90%

./10-disk-alert.sh 90 && echo "Disks fine"
./10-disk-alert.sh 90 || echo "Disk problem!"
```

---

## Running scripts on a schedule

Run the disk check every hour and log the output:

```bash
crontab -e
```

Add this line, replacing the path with the real full path. cron doesn't know your current directory.

```text
0 * * * * /home/YOURUSER/devops_linux/linux/scripts/10-disk-alert.sh 85 >> /home/YOURUSER/disk-alert.log 2>&1
```

For more control, use a systemd timer instead. See [../intermediate/systemd-services.md](../intermediate/systemd-services.md).

---

## Debugging

```bash
bash -n script.sh            # Check syntax without running
bash -x script.sh            # Print each line before running it (shows variable values)
shellcheck script.sh         # Find common mistakes: sudo apt install shellcheck
```

You can also turn tracing on for just part of a script:

```bash
set -x     # start printing commands
...
set +x     # stop
```

## Common errors and fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Permission denied` | No execute bit | `chmod +x script.sh`, or run `bash script.sh` |
| `command not found` (for your script) | Ran `script.sh` instead of `./script.sh` | Add `./`, or install it in a `$PATH` directory |
| `/usr/bin/env: 'bash\r': No such file or directory` or `bad interpreter` | File has Windows line endings (CRLF) | `sed -i 's/\r$//' script.sh`, or `dos2unix script.sh` |
| `[[: not found` or `Syntax error: "(" unexpected` | Ran with `sh` (dash) instead of bash | `bash script.sh` or `./script.sh` |
| `name: command not found` on a line like `name = "x"` | Spaces around `=` | Write `name="x"` |
| Errors with file names that contain spaces | Variable not quoted | Use `"$file"`, not `$file` |
| `unbound variable` | `set -u` and a variable wasn't set | Set it, or give a default: `"${1:-default}"` |
| `Permission denied` on a file or folder inside the script | The script needs root for that action | `sudo ./script.sh`, or `sudo` on that line only |

## Exercises

1. Change `01-hello.sh` so it also prints your IP address (`hostname -I`).
2. Make `03-arguments.sh` print the arguments in reverse order.
3. Add a "5) Show top processes" option to `08-case-menu.sh` (`top -bn1 | head -15`).
4. Change `10-disk-alert.sh` so it also prints the 3 biggest directories in `/var` when a disk is over the threshold.
5. Write your own `13-user-report.sh` that lists every user with UID ≥ 1000 and their shell (hint: `awk -F: '$3 >= 1000' /etc/passwd`).
6. Install `09-system-info.sh` as `sysinfo` in `~/bin` and run it from your home directory.
