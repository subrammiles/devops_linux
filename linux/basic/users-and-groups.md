# Users and Groups

## Who am I?

```bash
whoami        # Your username
id            # Your user ID (uid), group ID (gid), and groups
groups        # Groups you belong to
who           # Who is logged in
w             # Who is logged in and what they're running
```

## Where accounts are stored

| File | Contents |
|------|----------|
| `/etc/passwd` | User accounts (name, uid, home directory, shell) |
| `/etc/shadow` | Password hashes (root-only) |
| `/etc/group`  | Groups and their members |

```text
$ grep alice /etc/passwd
alice:x:1001:1001:Alice:/home/alice:/bin/bash
 name │  uid  gid  comment   home      shell
```

## Managing users (requires `sudo`)

```bash
sudo adduser bob                 # Interactive: creates user, home dir, password (Debian/Ubuntu)
sudo useradd -m -s /bin/bash bob # Lower-level: -m create home, -s set shell
sudo passwd bob                  # Set or change bob's password
passwd                           # Change your own password
sudo usermod -aG docker bob      # Add bob to the docker group (-a = append, keep other groups)
sudo usermod -aG sudo bob        # Give bob sudo rights (Ubuntu)
sudo deluser bob                 # Delete user (Ubuntu)
sudo userdel -r bob              # Delete user and home directory
```

> Always use `-aG` together. `usermod -G docker bob` without `-a` *replaces* bob's groups.

Group changes apply at the next login. Log out and back in, or run `newgrp docker`.

## Managing groups

```bash
sudo groupadd devs               # Create group
sudo gpasswd -d bob devs         # Remove bob from devs
sudo groupdel devs               # Delete group
getent group devs                # Show group members
```

## Switching users

```bash
su - bob          # Become bob (needs bob's password)
sudo -u bob whoami   # Run one command as bob
sudo su -         # Become root
exit              # Go back
```

## Practice

1. Run `id` and note your groups.
2. `sudo adduser testuser`, then `grep testuser /etc/passwd`.
3. `sudo groupadd lab && sudo usermod -aG lab testuser && getent group lab`
4. Clean up: `sudo deluser --remove-home testuser && sudo groupdel lab`

Previous: [permissions.md](permissions.md) · Next: [find-grep.md](find-grep.md)
