# Ubuntu vs CentOS / RHEL: Side-by-Side Commands

Most Linux commands are identical on every distribution. The differences are in package management, firewall, security modules, service names and log locations.

Full guides: [Ubuntu](../ubuntu/ubuntu-commands.md) · [CentOS / RHEL / Rocky / Alma](../centos/centos-commands.md)

## Package management

| Task | Ubuntu / Debian | CentOS / RHEL / Rocky / Alma |
|------|-----------------|------------------------------|
| Package manager | `apt` (`.deb`) | `dnf` (`.rpm`); `yum` on CentOS 7 |
| Refresh package list | `sudo apt update` | `sudo dnf makecache` (usually automatic) |
| List available updates | `apt list --upgradable` | `dnf check-update` |
| Upgrade everything | `sudo apt upgrade` | `sudo dnf upgrade` |
| Install | `sudo apt install nginx` | `sudo dnf install nginx` |
| Remove | `sudo apt remove nginx` | `sudo dnf remove nginx` |
| Remove with config | `sudo apt purge nginx` | `sudo dnf remove nginx` (edited configs saved as `.rpmsave`) |
| Remove unused deps | `sudo apt autoremove` | `sudo dnf autoremove` |
| Search | `apt search redis` | `dnf search redis` |
| Package info | `apt show nginx` | `dnf info nginx` |
| List installed | `apt list --installed` | `dnf list installed` / `rpm -qa` |
| Files in a package | `dpkg -L nginx` | `rpm -ql nginx` |
| Which package owns a file | `dpkg -S /usr/sbin/nginx` | `rpm -qf /usr/sbin/nginx` |
| Which package provides a command (not installed) | Suggested automatically when you type it | `dnf provides '*/bin/dig'` |
| Install a local file | `sudo apt install ./pkg.deb` | `sudo dnf install ./pkg.rpm` |
| Download without installing | `apt download nginx` | `dnf download nginx` |
| Hold a version | `sudo apt-mark hold pkg` | `sudo dnf versionlock add pkg` |
| Undo an install/update | Not built in | `sudo dnf history undo <id>` |
| Clean cache | `sudo apt clean` | `sudo dnf clean all` |
| Extra repositories | PPAs: `add-apt-repository` | EPEL: `dnf install epel-release` |
| Repo config | `/etc/apt/sources.list.d/` | `/etc/yum.repos.d/` |
| Reboot needed? | `ls /var/run/reboot-required` | `needs-restarting -r` |
| Auto updates | `unattended-upgrades` | `dnf-automatic` |

## Services

The `systemctl` commands are identical on both. The differences:

| | Ubuntu / Debian | CentOS / RHEL |
|---|-----------------|---------------|
| After installing a service | Usually **started and enabled automatically** | **Not started**: run `sudo systemctl enable --now <svc>` |
| SSH service | `ssh` | `sshd` |
| Apache package / service | `apache2` | `httpd` |
| Apache config | `/etc/apache2/` | `/etc/httpd/` |
| Apache user | `www-data` | `apache` |
| Nginx user | `www-data` | `nginx` |
| Cron service | `cron` | `crond` |
| MySQL service | `mysql` | `mysqld` (or `mariadb`) |

```bash
# Same on both:
sudo systemctl start|stop|restart|reload|status <service>
sudo systemctl enable --now <service>
journalctl -u <service> -f
```

## Firewall

| Task | Ubuntu: `ufw` | CentOS / RHEL: `firewalld` |
|------|---------------|----------------------------|
| Default state | Installed but **inactive** | Usually **active** |
| Status | `sudo ufw status` | `sudo firewall-cmd --list-all` |
| Allow HTTP | `sudo ufw allow 80/tcp` | `sudo firewall-cmd --permanent --add-service=http` |
| Allow a port | `sudo ufw allow 8080/tcp` | `sudo firewall-cmd --permanent --add-port=8080/tcp` |
| Apply changes | Immediate | `sudo firewall-cmd --reload` |
| Enable | `sudo ufw enable` | `sudo systemctl enable --now firewalld` |

## Security module

| | Ubuntu | CentOS / RHEL |
|---|--------|---------------|
| Module | AppArmor | SELinux (enforcing by default) |
| Status | `sudo aa-status` | `getenforce`, `sestatus` |
| See denials | `journalctl -k \| grep DENIED` | `sudo ausearch -m avc -ts recent` |
| Typical fix | Rarely needed for common services | `restorecon`, `setsebool`, `semanage` |

## Users

| | Ubuntu | CentOS / RHEL |
|---|--------|---------------|
| Admin group | `sudo` | `wheel` |
| Add user | `sudo adduser alice` (interactive) | `sudo useradd -m alice && sudo passwd alice` |
| Grant sudo | `sudo usermod -aG sudo alice` | `sudo usermod -aG wheel alice` |

## Networking

| | Ubuntu Server | CentOS / RHEL |
|---|---------------|---------------|
| Config tool | Netplan (`/etc/netplan/*.yaml`) | NetworkManager (`nmcli`, `nmtui`) |
| Apply changes | `sudo netplan apply` | `sudo nmcli connection up <name>` |
| DNS status | `resolvectl status` | `nmcli dev show`, `/etc/resolv.conf` |
| Time sync | `systemd-timesyncd` (`timedatectl`) | `chronyd` (`chronyc sources`) |

## Log files

| Contents | Ubuntu / Debian | CentOS / RHEL |
|----------|-----------------|---------------|
| General system log | `/var/log/syslog` | `/var/log/messages` |
| Logins, sudo, SSH | `/var/log/auth.log` | `/var/log/secure` |
| Package history | `/var/log/apt/history.log` | `/var/log/dnf.log`, `dnf history` |
| Security denials | `journalctl -k` (AppArmor) | `/var/log/audit/audit.log` (SELinux) |
| Cron | in `syslog` | `/var/log/cron` |
| Everything (systemd) | `journalctl` | `journalctl` |

## Version information

| | Ubuntu | CentOS / RHEL |
|---|--------|---------------|
| Release file | `lsb_release -a` | `cat /etc/redhat-release` |
| Both | `cat /etc/os-release`, `hostnamectl` | |

## Writing scripts that work on both

Detect the distribution in a script:

```bash
#!/usr/bin/env bash
. /etc/os-release

case "$ID" in
    ubuntu|debian)
        sudo apt update && sudo apt install -y nginx
        sudo ufw allow 'Nginx Full' || true
        ;;
    centos|rhel|rocky|almalinux|fedora)
        sudo dnf install -y nginx
        sudo systemctl enable --now nginx
        sudo firewall-cmd --permanent --add-service=http --add-service=https
        sudo firewall-cmd --reload
        ;;
    *)
        echo "Unsupported distribution: $ID" >&2
        exit 1
        ;;
esac
```

`ID_LIKE` in `/etc/os-release` helps with less common distributions. For example, Linux Mint has `ID_LIKE="ubuntu debian"`.

## Practice without a server

Try both families with Docker on your own machine:

```bash
docker run --rm -it ubuntu:24.04 bash
docker run --rm -it rockylinux:9 bash
```

Inside, try `cat /etc/os-release`, a package search, and installing a package. Note that `systemctl` doesn't work inside a plain container, because there's no systemd running.
