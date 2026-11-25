# Ubuntu / Debian Commands

Commands specific to Ubuntu and Debian. General Linux commands (`ls`, `cd`, `grep`...) are in [../linux/basic/](../linux/basic/). For the CentOS / RHEL equivalents, see [../centos/centos-commands.md](../centos/centos-commands.md) or the [side-by-side comparison](../linux/ubuntu-vs-centos.md).

## Which version am I running?

```bash
lsb_release -a              # Distributor, release and codename
cat /etc/os-release         # Works on almost any Linux
hostnamectl                 # OS, kernel and hostname together
uname -r                    # Kernel version
```

Ubuntu versions are numbered year.month. **LTS** (Long Term Support) releases come out in April of even years (22.04, 24.04, 26.04) and get 5 years of updates. Use an LTS release on servers.

---

## Updating the system

```bash
sudo apt update                 # 1. Refresh the package list (doesn't install anything)
apt list --upgradable           # 2. See what can be upgraded
sudo apt upgrade -y             # 3. Install upgrades
sudo apt full-upgrade -y        # Also allows removing/replacing packages when needed (e.g. kernel changes)
sudo apt autoremove -y          # Remove packages that are no longer needed
sudo apt clean                  # Clear downloaded package files from /var/cache/apt/archives
```

The usual one-liner:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

### Is a reboot needed?

```bash
ls /var/run/reboot-required 2>/dev/null && cat /var/run/reboot-required.pkgs
```

If the file exists, a kernel or core library was updated. Reboot when convenient: `sudo reboot`.

### Upgrade to the next Ubuntu release

```bash
sudo apt update && sudo apt full-upgrade -y
sudo do-release-upgrade         # Back up first; this upgrades e.g. 22.04 → 24.04
```

### Automatic security updates

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## Installing and removing software

```bash
sudo apt install nginx                  # Install
sudo apt install -y git curl htop       # Several at once, no prompt
sudo apt install nginx=1.24.0-2ubuntu7  # A specific version
sudo apt reinstall nginx                # Reinstall (repairs deleted files)
sudo apt remove nginx                   # Remove, keep config files in /etc
sudo apt purge nginx                    # Remove including config files
```

### Finding packages

```bash
apt search redis                # Search names and descriptions
apt show nginx                  # Version, size, dependencies, description
apt-cache policy nginx          # Installed version vs available versions, and which repo
apt list --installed            # Everything installed
apt list --installed | grep php
dpkg -l | grep nginx            # Installed packages, older style
```

### Which package owns a file?

```bash
dpkg -S /usr/sbin/nginx         # Installed file → package name
dpkg -L nginx                   # All files a package installed
```

For a command that isn't installed yet, Ubuntu usually suggests the package when you type it:

```text
$ htop
Command 'htop' not found, but can be installed with:
sudo apt install htop
```

### Stop a package from being upgraded

```bash
sudo apt-mark hold docker-ce     # Pin the current version
apt-mark showhold                # List held packages
sudo apt-mark unhold docker-ce
```

---

## Downloading files and packages

### Download files from the internet

```bash
wget https://example.com/file.tar.gz              # Save with the original name
wget -O app.tar.gz https://example.com/file.tar.gz   # Choose the name
wget -c https://example.com/big.iso               # Resume an interrupted download
curl -LO https://example.com/file.tar.gz          # curl: -L follow redirects, -O keep the name
curl -fsSL https://example.com/install.sh -o install.sh   # Download a script, then READ it before running
```

> Avoid `curl ... | sudo bash`. Download the script, read it, then run it.

Verify a download when the site publishes a checksum:

```bash
sha256sum file.tar.gz           # Compare with the value on the website
```

### Download a package without installing it

```bash
apt download nginx                          # Saves nginx_*.deb in the current directory
sudo apt install --download-only nginx      # Downloads it and its dependencies to /var/cache/apt/archives/
```

### Install a downloaded .deb file

```bash
sudo apt install ./google-chrome-stable_current_amd64.deb   # Resolves dependencies (note the ./)
sudo dpkg -i package.deb                                    # Lower-level; then fix dependencies:
sudo apt -f install
```

### Snap packages

```bash
snap find vlc
sudo snap install vlc
sudo snap install code --classic     # --classic for tools that need full system access
snap list
sudo snap refresh                    # Update all snaps
sudo snap remove vlc
```

---

## Adding software repositories

### PPA (Personal Package Archive)

```bash
sudo add-apt-repository ppa:deadsnakes/ppa     # Example: newer Python versions
sudo apt update
sudo apt install python3.13
sudo add-apt-repository --remove ppa:deadsnakes/ppa
```

### Third-party repository with a signing key (example: Docker)

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Repository lists live in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/`. Ubuntu 24.04 uses the newer `/etc/apt/sources.list.d/ubuntu.sources` format.

---

## Services

Ubuntu uses systemd. **Most services start automatically right after `apt install`.**

```bash
sudo apt install -y nginx
systemctl status nginx              # Already active (running)

sudo systemctl start nginx          # Start
sudo systemctl stop nginx           # Stop
sudo systemctl restart nginx        # Restart
sudo systemctl reload nginx         # Reload config without dropping connections
sudo systemctl enable nginx         # Start at boot
sudo systemctl disable nginx        # Don't start at boot
sudo systemctl enable --now nginx   # Enable and start now
systemctl is-active nginx           # active / inactive
systemctl is-enabled nginx          # enabled / disabled
systemctl list-units --type=service --state=running
journalctl -u nginx -f              # Live logs
```

The older `service` command still works: `sudo service nginx restart`.

### Service names on Ubuntu

| Software | Package | Service name | Config |
|----------|---------|--------------|--------|
| SSH server | `openssh-server` | `ssh` | `/etc/ssh/sshd_config` |
| Apache | `apache2` | `apache2` | `/etc/apache2/` |
| Nginx | `nginx` | `nginx` | `/etc/nginx/` |
| MySQL | `mysql-server` | `mysql` | `/etc/mysql/` |
| PostgreSQL | `postgresql` | `postgresql` | `/etc/postgresql/<ver>/main/` |
| Cron | `cron` | `cron` | `/etc/crontab` |
| Docker | `docker.io` or `docker-ce` | `docker` | `/etc/docker/` |

### Example: install and start Apache

```bash
sudo apt update
sudo apt install -y apache2
sudo systemctl enable --now apache2
sudo ufw allow 'Apache Full'
curl -I http://localhost
```

---

## Firewall: ufw

```bash
sudo ufw status verbose
sudo ufw allow OpenSSH              # Allow SSH BEFORE enabling, or you can lock yourself out
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow from 10.0.0.0/24 to any port 5432   # Only from a subnet
sudo ufw enable
sudo ufw app list                   # Profiles installed by packages (Nginx Full, Apache...)
sudo ufw status numbered
sudo ufw delete 3                   # Delete rule number 3
sudo ufw disable
```

## Security module: AppArmor

Ubuntu uses AppArmor to restrict what programs can access.

```bash
sudo aa-status                       # Loaded profiles and their modes
sudo journalctl -k | grep -i apparmor | grep DENIED   # Blocked actions
```

---

## Users and sudo

On Ubuntu, admins are members of the **`sudo`** group.

```bash
sudo adduser alice                   # Interactive: creates home, sets password
sudo usermod -aG sudo alice          # Give admin rights
sudo deluser --remove-home alice
```

## Networking

Ubuntu servers configure the network with **Netplan** (YAML files in `/etc/netplan/`). Desktops use NetworkManager.

```bash
ip a                                  # Addresses
ls /etc/netplan/
sudo netplan try                      # Apply with automatic rollback if you lose the connection
sudo netplan apply
resolvectl status                     # DNS servers
```

Static IP example (`/etc/netplan/01-static.yaml`, file permissions must be `600`):

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

## Hostname, time and locale

```bash
sudo hostnamectl set-hostname web01
timedatectl                              # Current time, timezone, NTP status
sudo timedatectl set-timezone Asia/Kolkata
timedatectl list-timezones | grep Asia
```

## Important log files

| File | Contents |
|------|----------|
| `/var/log/syslog` | General system messages |
| `/var/log/auth.log` | Logins, sudo, SSH |
| `/var/log/kern.log` | Kernel messages |
| `/var/log/apt/history.log` | What apt installed/removed and when |
| `/var/log/dpkg.log` | Package-level changes |
| `/var/log/nginx/`, `/var/log/apache2/` | Web server logs |

```bash
journalctl -b -p err                  # Errors since boot
grep " install " /var/log/dpkg.log    # Install history
```

See also: [generalinstall.md](generalinstall.md) for installing MySQL.
