# Package Management

Linux installs software from *repositories* using a package manager.

| Distribution family | Tool | Package format |
|---------------------|------|----------------|
| Debian, Ubuntu      | `apt` | `.deb` |
| RHEL, Fedora, Rocky, Amazon Linux | `dnf` (older: `yum`) | `.rpm` |
| Alpine (common in Docker) | `apk` | `.apk` |
| Arch               | `pacman` | `.pkg.tar.zst` |

## apt (Ubuntu / Debian)

```bash
sudo apt update                 # Refresh the list of available packages (do this first)
sudo apt upgrade                # Upgrade installed packages
sudo apt install nginx          # Install
sudo apt install -y git curl    # Install several, auto-answer yes
sudo apt remove nginx           # Remove (keep config files)
sudo apt purge nginx            # Remove including config files
sudo apt autoremove             # Remove unused dependencies
apt search redis                # Search
apt show nginx                  # Details about a package
apt list --installed            # What's installed
sudo dpkg -i package.deb        # Install a downloaded .deb file
```

## dnf (RHEL / Fedora / Rocky)

```bash
sudo dnf check-update
sudo dnf upgrade
sudo dnf install nginx
sudo dnf remove nginx
dnf search redis
dnf info nginx
dnf list installed
```

## apk (Alpine)

```bash
apk update
apk add curl
apk del curl
```

## Snap

```bash
sudo snap install code --classic
snap list
sudo snap remove code
```

## Example: install MySQL on Ubuntu

See [../../ubuntu/generalinstall.md](../../ubuntu/generalinstall.md).

```bash
sudo apt update
sudo apt install -y mysql-server
sudo systemctl status mysql
sudo mysql_secure_installation
```

Previous: [processes.md](processes.md) · Next: [networking.md](networking.md)
