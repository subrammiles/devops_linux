# Networking Basics

## Your network configuration

```bash
ip a                    # IP addresses of all interfaces (short for ip addr)
ip r                    # Routing table / default gateway
hostname                # Machine name
hostname -I             # This machine's IP addresses
cat /etc/resolv.conf    # DNS servers
cat /etc/hosts          # Local name → IP overrides
```

## Testing connectivity

```bash
ping -c 4 8.8.8.8          # Can I reach an IP? (-c = count)
ping -c 4 google.com       # Does DNS work too?
traceroute google.com      # Path packets take (sudo apt install traceroute)
nslookup example.com       # DNS lookup
dig example.com            # Detailed DNS lookup (sudo apt install dnsutils)
dig +short example.com A
```

## Ports and connections

```bash
ss -tulpn               # Listening TCP/UDP ports and which process owns them
sudo ss -tulpn | grep :80
nc -zv localhost 22     # Is port 22 open? (netcat)
```

Common ports: 22 SSH, 80 HTTP, 443 HTTPS, 3306 MySQL, 5432 PostgreSQL, 6379 Redis, 8080 alternative HTTP.

## HTTP from the command line

```bash
curl https://example.com                 # Fetch a page
curl -I https://example.com              # Headers only
curl -s -o /dev/null -w "%{http_code}\n" https://example.com   # Just the status code
curl -X POST -H "Content-Type: application/json" -d '{"a":1}' http://localhost:8080/api
wget https://example.com/file.tar.gz     # Download a file
```

## SSH — remote login

```bash
ssh user@server-ip                   # Connect
ssh -p 2222 user@server-ip           # Non-default port
ssh -i ~/.ssh/mykey.pem user@host    # Use a specific key
```

### Key-based login

```bash
ssh-keygen -t ed25519 -C "my laptop"      # Create a key pair in ~/.ssh/
ssh-copy-id user@server-ip                # Install your public key on the server
ssh user@server-ip                        # Now logs in without a password
```

`~/.ssh/config` saves typing:

```text
Host web1
    HostName 203.0.113.10
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
```

Then just `ssh web1`.

### Copying files

```bash
scp file.txt user@host:/tmp/              # Local → remote
scp user@host:/var/log/app.log .          # Remote → local
scp -r site/ user@host:/var/www/          # Directory
rsync -avz site/ user@host:/var/www/site/ # Efficient sync (only changed files)
```

## Firewall (Ubuntu `ufw`)

```bash
sudo ufw status
sudo ufw allow 22/tcp        # Allow SSH first, or you may lock yourself out
sudo ufw allow 80,443/tcp
sudo ufw enable
sudo ufw deny 3306
```

Previous: [package-management.md](package-management.md) · Next: [shell-scripting.md](shell-scripting.md)
