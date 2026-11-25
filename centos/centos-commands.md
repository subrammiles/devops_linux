# CentOS / RHEL / Rocky / AlmaLinux Commands

Commands specific to the Red Hat family. General Linux commands (`ls`, `cd`, `grep`...) are in [../linux/basic/](../linux/basic/). For Ubuntu equivalents, see [../ubuntu/ubuntu-commands.md](../ubuntu/ubuntu-commands.md) or the [side-by-side comparison](../linux/ubuntu-vs-centos.md).

## Which distribution should I use?

| Distribution | Status |
|--------------|--------|
| CentOS Linux 7 | **End of life** since 30 June 2024. No security updates. Migrate away |
| CentOS Linux 8 | **End of life** since 31 December 2021 |
| CentOS Stream 9 / 10 | Active. A "preview" of the next RHEL minor release |
| Rocky Linux, AlmaLinux | Active, free, rebuilt from RHEL. The usual replacement for old CentOS |
| RHEL (Red Hat Enterprise Linux) | Commercial with support; free for individual developers |
| Fedora | Fast-moving, upstream of RHEL; good desktop |

The commands below work on **all** current versions (8, 9, 10). Where CentOS 7 differs, it's noted.

## Which version am I running?

```bash
cat /etc/redhat-release     # e.g. Rocky Linux release 9.5 (Blue Onyx)
cat /etc/os-release
hostnamectl
uname -r
```

---

## Updating the system

The package manager is **`dnf`**. On CentOS 7 it was `yum`. On 8 and later, `yum` still works as an alias for `dnf`, so old instructions mostly work unchanged.

```bash
sudo dnf check-update           # What can be updated (no need to "refresh" first like apt update)
sudo dnf upgrade -y             # Install all updates
sudo dnf upgrade --security -y  # Security updates only (where advisory data exists, e.g. RHEL/Rocky/Alma)
sudo dnf autoremove -y          # Remove unneeded dependencies
sudo dnf clean all              # Clear cached metadata and packages
sudo dnf makecache              # Re-download repository metadata
```

`dnf update` is the same as `dnf upgrade`.

### Is a reboot needed?

```bash
sudo dnf install -y dnf-utils       # Provides needs-restarting
sudo needs-restarting -r            # Says whether a reboot is required
```

### Automatic updates

```bash
sudo dnf install -y dnf-automatic
sudo sed -i 's/^apply_updates = .*/apply_updates = yes/' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer
```

### Undo an update

`dnf` records every transaction and can roll back:

```bash
dnf history                     # List transactions with ID numbers
dnf history info 15             # What transaction 15 changed
sudo dnf history undo 15        # Reverse it
```

---

## Installing and removing software

```bash
sudo dnf install nginx                  # Install
sudo dnf install -y git curl vim        # Several at once, no prompt
sudo dnf reinstall nginx
sudo dnf remove nginx                   # Remove (config files changed by you are saved as .rpmsave)
sudo dnf downgrade nginx                # Go back one version
```

### Groups: install a whole set of tools

```bash
dnf group list
sudo dnf group install "Development Tools"     # gcc, make, git...
```

### Finding packages

```bash
dnf search redis                # Search
dnf info nginx                  # Details
dnf list installed              # Everything installed
dnf list installed | grep php
dnf list --available nginx      # Available versions
dnf repoquery --requires nginx  # Dependencies
```

### Which package provides a file or command?

This is very useful when a command is missing:

```bash
dnf provides semanage           # → policycoreutils-python-utils
dnf provides '*/bin/dig'        # → bind-utils
```

### Inspect installed packages with rpm

```bash
rpm -qa                         # All installed packages
rpm -qa | grep nginx
rpm -qi nginx                   # Info about an installed package
rpm -ql nginx                   # Files it installed
rpm -qf /usr/sbin/nginx         # Which package owns this file
rpm -qc nginx                   # Its config files
rpm -V nginx                    # Verify: list files changed since install
```

### Stop a package from being upgraded

```bash
sudo dnf install -y python3-dnf-plugin-versionlock
sudo dnf versionlock add docker-ce
dnf versionlock list
sudo dnf versionlock delete docker-ce
```

---

## Downloading files and packages

### Download files from the internet

`wget` isn't always installed on minimal images: `sudo dnf install -y wget`. `curl` usually is.

```bash
wget https://example.com/file.tar.gz
wget -O app.tar.gz https://example.com/file.tar.gz
wget -c https://example.com/big.iso               # Resume
curl -LO https://example.com/file.tar.gz
curl -fsSL https://example.com/install.sh -o install.sh   # Download, then READ before running
sha256sum file.tar.gz                             # Check against the published checksum
```

### Download a package without installing it

```bash
sudo dnf install -y dnf-plugins-core              # Needed on 8/9; built in on dnf5 (Fedora 41+, RHEL 10)
dnf download nginx                                # Saves nginx-*.rpm in the current directory
dnf download --resolve nginx                      # Also download its dependencies
sudo dnf install --downloadonly --downloaddir=/tmp/pkgs nginx
```

Useful for installing on a server without internet access: download on one machine, copy the `.rpm` files over, and install them.

### Install a downloaded .rpm file

```bash
sudo dnf install ./package.rpm          # Resolves dependencies from repos (preferred)
sudo rpm -ivh package.rpm               # Lower-level; fails if dependencies are missing
sudo rpm -Uvh package.rpm               # Upgrade (or install)
```

---

## Repositories

```bash
dnf repolist                    # Enabled repositories
dnf repolist all                # Including disabled ones
ls /etc/yum.repos.d/            # Repository files (.repo)
```

### EPEL: Extra Packages for Enterprise Linux

Many common tools (`htop`, `certbot`, `fail2ban`, `ncdu`) are in EPEL, not the base repositories.

```bash
# CentOS Stream, Rocky, AlmaLinux:
sudo dnf install -y epel-release
# Many EPEL packages also need the CRB repository (called PowerTools on version 8):
sudo dnf config-manager --set-enabled crb

sudo dnf install -y htop
```

On RHEL itself, install EPEL from the URL in the [EPEL documentation](https://docs.fedoraproject.org/en-US/epel/).

### Add a third-party repository (example: Docker)

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
```

Enable or disable a repository:

```bash
sudo dnf config-manager --set-disabled docker-ce-stable
sudo dnf install --enablerepo=epel htop      # Use a disabled repo just for this command
```

---

## Services

Same systemd commands as Ubuntu, with one important difference: **services are NOT started or enabled automatically after install.** You must do it yourself.

```bash
sudo dnf install -y nginx
systemctl status nginx              # inactive (dead): not started yet

sudo systemctl enable --now nginx   # Start now and at every boot
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx
sudo systemctl disable nginx
systemctl is-active nginx
systemctl is-enabled nginx
systemctl list-units --type=service --state=running
systemctl list-unit-files --type=service --state=enabled
journalctl -u nginx -f
```

On CentOS 6 and older (not systemd): `service nginx start` and `chkconfig nginx on`. You'll still see these in old guides.

### Service names on the Red Hat family

| Software | Package | Service name | Config |
|----------|---------|--------------|--------|
| SSH server | `openssh-server` | `sshd` | `/etc/ssh/sshd_config` |
| Apache | `httpd` | `httpd` | `/etc/httpd/` |
| Nginx | `nginx` | `nginx` | `/etc/nginx/` |
| MySQL | `mysql-server` | `mysqld` | `/etc/my.cnf`, `/etc/my.cnf.d/` |
| MariaDB | `mariadb-server` | `mariadb` | `/etc/my.cnf.d/` |
| PostgreSQL | `postgresql-server` | `postgresql` | `/var/lib/pgsql/data/` |
| Cron | `cronie` | `crond` | `/etc/crontab` |
| Firewall | `firewalld` | `firewalld` | `/etc/firewalld/` |

### Example: install and start Apache

```bash
sudo dnf install -y httpd
sudo systemctl enable --now httpd
sudo firewall-cmd --permanent --add-service=http --add-service=https
sudo firewall-cmd --reload
curl -I http://localhost
```

### Example: install MySQL / MariaDB

```bash
sudo dnf install -y mariadb-server
sudo systemctl enable --now mariadb
sudo mysql_secure_installation
```

PostgreSQL needs one extra step to create its data directory before the first start:

```bash
sudo dnf install -y postgresql-server
sudo postgresql-setup --initdb
sudo systemctl enable --now postgresql
```

---

## Firewall: firewalld

RHEL-family servers use **firewalld**. It's usually enabled by default, so new services are blocked until you open their ports.

```bash
sudo firewall-cmd --state                       # running?
sudo firewall-cmd --list-all                    # Current zone, allowed services and ports
sudo firewall-cmd --get-services                # Predefined service names

sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --remove-port=8080/tcp
sudo firewall-cmd --reload                      # Apply --permanent changes
```

> Without `--permanent`, a rule is active right away but is lost on reload or reboot. With `--permanent`, it's saved but only takes effect after `--reload`. The usual pattern is `--permanent`, then `--reload`.

Allow a port only from one network:

```bash
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0/24" port port="5432" protocol="tcp" accept'
sudo firewall-cmd --reload
```

---

## SELinux

SELinux is enabled by default and is the most common reason that "it works on Ubuntu but not on CentOS". A service may be running and the firewall open, yet access is still denied.

```bash
getenforce                      # Enforcing / Permissive / Disabled
sestatus                        # Detailed status
ls -Z /var/www/html             # SELinux labels on files
ps -eZ | grep nginx             # Labels on processes
```

### Find out what SELinux blocked

```bash
sudo ausearch -m avc -ts recent           # Recent denials
sudo journalctl -t setroubleshoot         # Human-readable explanations (if setroubleshoot is installed)
```

### Common fixes (better than turning SELinux off)

```bash
# Files copied/moved into the web root have the wrong label → reset labels
sudo restorecon -Rv /var/www/html

# Use a custom directory for web content
sudo dnf install -y policycoreutils-python-utils     # Provides semanage
sudo semanage fcontext -a -t httpd_sys_content_t "/srv/site(/.*)?"
sudo restorecon -Rv /srv/site

# Let Nginx/Apache connect to a backend app (reverse proxy) → fixes "502 Bad Gateway"
sudo setsebool -P httpd_can_network_connect 1

# Run a service on a non-standard port
sudo semanage port -a -t http_port_t -p tcp 8081
sudo semanage port -a -t ssh_port_t -p tcp 2222
```

### Temporarily switch to permissive (for testing only)

```bash
sudo setenforce 0               # Permissive: logs denials but doesn't block; resets at reboot
sudo setenforce 1               # Back to enforcing
```

If something works in permissive mode but not in enforcing mode, SELinux is the cause. Fix the policy instead of leaving it off. The permanent setting is in `/etc/selinux/config`.

---

## Users and sudo

On the Red Hat family, admins are members of the **`wheel`** group (not `sudo`).

```bash
sudo useradd -m alice                # -m creates the home directory
sudo passwd alice                    # useradd doesn't set a password
sudo usermod -aG wheel alice         # Give admin rights
sudo userdel -r alice                # Delete with home directory
```

There's no interactive `adduser` like Ubuntu's. On RHEL, `adduser` is just a link to `useradd`.

## Networking

The Red Hat family uses **NetworkManager**, controlled with `nmcli` (or the text menu `nmtui`).

```bash
ip a
nmcli device status                  # Interfaces and their state
nmcli connection show                # Saved connections
sudo nmtui                           # Simple text menu for editing connections
```

Static IP example (replace `eth0` with the connection name from `nmcli connection show`):

```bash
sudo nmcli connection modify eth0 \
  ipv4.method manual \
  ipv4.addresses 192.168.1.50/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "1.1.1.1 8.8.8.8"
sudo nmcli connection up eth0
```

## Hostname and time

```bash
sudo hostnamectl set-hostname web01
timedatectl
sudo timedatectl set-timezone Asia/Kolkata
chronyc sources                      # NTP time sync status (chronyd)
```

## Important log files

| File | Contents |
|------|----------|
| `/var/log/messages` | General system messages (Ubuntu: `syslog`) |
| `/var/log/secure` | Logins, sudo, SSH (Ubuntu: `auth.log`) |
| `/var/log/audit/audit.log` | SELinux denials and audit events |
| `/var/log/dnf.log` | Package manager activity |
| `/var/log/httpd/`, `/var/log/nginx/` | Web server logs |
| `/var/log/cron` | Cron job runs |

```bash
journalctl -b -p err
sudo tail -f /var/log/secure
```

## Migrating from CentOS 7 or 8

If you still have a CentOS 7 or 8 server, move it to Rocky Linux or AlmaLinux. Both projects provide migration tools that convert a running system in place:

- AlmaLinux: [ELevate](https://wiki.almalinux.org/elevate/) for major version upgrades (7 → 8 → 9)
- Rocky Linux: [migrate2rocky](https://docs.rockylinux.org/guides/migrate2rocky/) for CentOS 8 → Rocky 8

Take a full backup or snapshot first. For important servers, building a new server and moving the application across is often safer.
