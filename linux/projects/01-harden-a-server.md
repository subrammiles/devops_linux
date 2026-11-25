# Project 1: Secure a Fresh Server

**Goal:** take a new Ubuntu server and make it safe to leave on the internet: key-only SSH, no root login, a firewall, automatic blocking of password-guessing bots, and automatic security updates.

**Uses:** [users-and-groups](../basic/users-and-groups.md), [permissions](../basic/permissions.md), [networking](../basic/networking.md), [package-management](../basic/package-management.md), [processes](../basic/processes.md)

**You need:** an Ubuntu 22.04 or 24.04 server you can reach over SSH, such as a cheap cloud VM or a local VM. A VM is ideal because you can delete it and start again if something goes wrong.

> ⚠️ **Lockout risk.** Several steps change how SSH works. Keep your current SSH session open the whole time, and test every change from a **second** terminal before closing the first. If the new login fails, use the open session to undo the change.

---

## Step 1: Update the system

```bash
sudo apt update && sudo apt upgrade -y
sudo reboot          # If a kernel update was installed; reconnect afterwards
```

## Step 2: Create a regular admin user

Skip this if your cloud provider already gave you a non-root user such as `ubuntu`.

```bash
sudo adduser deploy
sudo usermod -aG sudo deploy
```

## Step 3: Set up SSH key login

**On your own computer** (not the server):

```bash
ssh-keygen -t ed25519 -C "my laptop"     # Press Enter for the default path; set a passphrase
ssh-copy-id deploy@SERVER_IP
```

Test in a **new terminal**:

```bash
ssh deploy@SERVER_IP          # Should log in without asking for the server password
sudo whoami                   # Should print: root
```

Don't continue until this works.

## Step 4: Turn off password and root login

Ubuntu reads extra SSH settings from `/etc/ssh/sshd_config.d/`. For each setting, sshd uses the **first** value it finds, and it reads those files in alphabetical order. Some cloud images ship `50-cloudimg-settings.conf` with `PasswordAuthentication yes`, so name your file with `00-` to make it win.

```bash
sudo tee /etc/ssh/sshd_config.d/00-hardening.conf > /dev/null <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
EOF

sudo sshd -t                     # Check syntax; no output means OK
sudo systemctl restart ssh
```

Confirm the settings in effect:

```bash
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|kbdinteractive'
```

Expected output:

```text
permitrootlogin no
passwordauthentication no
kbdinteractiveauthentication no
```

**Test from a new terminal** that `ssh deploy@SERVER_IP` still works. Then check that password login is refused:

```bash
ssh -o PubkeyAuthentication=no deploy@SERVER_IP
# deploy@SERVER_IP: Permission denied (publickey).
```

## Step 5: Turn on the firewall

Allow SSH **before** enabling the firewall, or you'll cut off your own connection.

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status verbose
```

Later projects open ports 80 and 443 for a web server.

Cloud providers often have their own firewall (AWS security groups, for example) in front of the VM. A port must be open in both.

## Step 6: Block password-guessing bots with fail2ban

fail2ban reads login failures from the logs and temporarily bans the IP addresses responsible.

```bash
sudo apt install -y fail2ban

sudo tee /etc/fail2ban/jail.local > /dev/null <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled = true
EOF

sudo systemctl enable --now fail2ban
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
```

Never edit `jail.conf` directly. Package updates overwrite it, so put your settings in `jail.local`.

Useful commands:

```bash
sudo fail2ban-client status sshd             # Currently banned IPs
sudo fail2ban-client set sshd unbanip 1.2.3.4   # Unban an IP (for example, your own)
```

## Step 7: Automatic security updates

```bash
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades     # Answer "Yes"
cat /etc/apt/apt.conf.d/20auto-upgrades
```

Expected output:

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

Do a test run that changes nothing:

```bash
sudo unattended-upgrade --dry-run --debug | tail
```

## Step 8: Check what's listening

```bash
sudo ss -tulpn
```

On a fresh server you should see only SSH on port 22, plus possibly `systemd-resolved` on `127.0.0.53` (local only). Stop and disable anything you don't recognise and don't need.

---

## Verify: final checklist

| Check | Command | Expected |
|-------|---------|----------|
| Key login works | `ssh deploy@SERVER_IP` | Logs in |
| Password login refused | `ssh -o PubkeyAuthentication=no deploy@SERVER_IP` | `Permission denied (publickey)` |
| Root login refused | `ssh root@SERVER_IP` | `Permission denied` |
| Firewall on | `sudo ufw status` | `Status: active`, only OpenSSH allowed |
| fail2ban running | `sudo fail2ban-client status sshd` | Shows the jail |
| Auto-updates on | `systemctl status unattended-upgrades` | `active` |

## Stretch goals

1. Add a `~/.ssh/config` entry on your laptop so `ssh myserver` works (see [networking.md](../basic/networking.md)).
2. Read `/var/log/auth.log` and count failed login attempts: `sudo grep -c "Failed\|Invalid" /var/log/auth.log`.
3. Turn steps 1–7 into one Bash script that you can run on every new server.
4. Look up Ansible and rewrite the script as a playbook.

Next: [02-nginx-https.md](02-nginx-https.md)
