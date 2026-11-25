# Project 2: Host a Website with Nginx and HTTPS

**Goal:** serve your own static website with Nginx, give it a proper configuration, and secure it with a free HTTPS certificate that renews itself.

**Uses:** [package-management](../basic/package-management.md), [files-and-directories](../basic/files-and-directories.md), [permissions](../basic/permissions.md), [processes](../basic/processes.md), [networking](../basic/networking.md)

**You need:**
- The server from [Project 1](01-harden-a-server.md).
- For real HTTPS: a domain name with a DNS **A record** pointing to the server's public IP. Check it with `dig +short yourdomain.com`.
- No domain? Follow every step except Step 6 and use **Step 6b** (a self-signed certificate) instead.

The examples use `example.com`. Replace it with your domain everywhere.

---

## Step 1: Install Nginx and open the firewall

```bash
sudo apt update
sudo apt install -y nginx
sudo ufw allow 'Nginx Full'          # Ports 80 and 443
systemctl status nginx
curl -I http://localhost             # HTTP/1.1 200 OK
```

Open `http://SERVER_IP` in a browser. You should see "Welcome to nginx!".

## Step 2: Create the website files

```bash
sudo mkdir -p /var/www/example.com/html
sudo chown -R "$USER":"$USER" /var/www/example.com/html

cat > /var/www/example.com/html/index.html <<'EOF'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>My Linux Server</title></head>
<body>
  <h1>It works!</h1>
  <p>Served by Nginx on my own server.</p>
</body>
</html>
EOF
```

Nginx runs as the user `www-data` and only needs to **read** these files. Check the permissions:

```bash
ls -ld /var/www/example.com/html
ls -l /var/www/example.com/html
```

Directories should be `755` and files `644`.

## Step 3: Write a server block

Nginx keeps site configs in `/etc/nginx/sites-available/` and turns them on with a link in `/etc/nginx/sites-enabled/`.

```bash
sudo tee /etc/nginx/sites-available/example.com > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;

    root /var/www/example.com/html;
    index index.html;

    access_log /var/log/nginx/example.com.access.log;
    error_log  /var/log/nginx/example.com.error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF
```

Enable it, disable the default site, test the configuration and reload:

```bash
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t                        # Always test before reloading
sudo systemctl reload nginx
```

Test it. The `Host` header lets you test before DNS is set up:

```bash
curl -H "Host: example.com" http://localhost
```

> `nginx -t` then `systemctl reload nginx` is the habit to build. A reload with a broken config is refused, so the site stays up. A **restart** with a broken config takes the site down.

## Step 4: Watch the logs

In a second terminal:

```bash
sudo tail -f /var/log/nginx/example.com.access.log
```

Reload the page in your browser and watch requests appear. Try a missing page (`/nope`) and look for the `404` status.

## Step 5: Add security headers and compression

Add these lines inside the `server { ... }` block, above `location /`:

```nginx
    server_tokens off;                           # Hide the Nginx version
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
```

```bash
sudo nginx -t && sudo systemctl reload nginx
curl -I -H "Host: example.com" http://localhost
```

## Step 6: HTTPS with Let's Encrypt (needs a domain)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
```

Certbot asks for an email address (for expiry warnings), gets a certificate, adds HTTPS to your server block, and offers to redirect HTTP to HTTPS. Choose to redirect.

Check the result:

```bash
curl -I https://example.com          # HTTP/2 200
curl -I http://example.com           # 301 redirect to https://
sudo cat /etc/nginx/sites-available/example.com   # See what certbot added
```

Certificates last 90 days. Certbot installs a timer that renews them automatically:

```bash
systemctl list-timers | grep certbot
sudo certbot renew --dry-run         # Test renewal without changing anything
sudo certbot certificates            # Expiry dates
```

## Step 6b: Self-signed certificate (no domain)

Browsers will show a warning because no trusted authority signed this certificate, but the traffic is still encrypted. This is fine for practice.

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/selfsigned.key \
  -out /etc/ssl/certs/selfsigned.crt \
  -subj "/CN=SERVER_IP"
```

Add a second server block to `/etc/nginx/sites-available/example.com`:

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name _;

    ssl_certificate     /etc/ssl/certs/selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/selfsigned.key;

    root /var/www/example.com/html;
    index index.html;
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
curl -k -I https://localhost         # -k accepts the self-signed certificate
```

---

## Verify

| Check | Command | Expected |
|-------|---------|----------|
| Config valid | `sudo nginx -t` | `syntax is ok`, `test is successful` |
| HTTP redirects | `curl -I http://example.com` | `301` to `https://` |
| HTTPS works | `curl -I https://example.com` | `200` |
| Renewal works | `sudo certbot renew --dry-run` | `Congratulations, all simulated renewals succeeded` |
| Listening | `sudo ss -tlpn \| grep nginx` | Ports 80 and 443 |

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Browser can't connect | `sudo ufw status`, the cloud firewall, `sudo ss -tlpn` |
| `403 Forbidden` | File permissions; `index.html` exists; `sudo tail /var/log/nginx/example.com.error.log` |
| `404` for every page | The `root` path in the server block |
| Still see "Welcome to nginx" | Default site still enabled, or `server_name` doesn't match |
| Certbot fails | `dig +short example.com` must return this server's IP, and port 80 must be reachable from the internet |

## Stretch goals

1. Host a second site on the same server with a second server block and `server_name`.
2. Add a custom 404 page with `error_page 404 /404.html;`.
3. Find your top visitors: `awk '{print $1}' /var/log/nginx/example.com.access.log | sort | uniq -c | sort -rn | head`
4. Test your HTTPS setup at [ssllabs.com/ssltest](https://www.ssllabs.com/ssltest/).

Previous: [01-harden-a-server.md](01-harden-a-server.md) · Next: [03-automated-backups.md](03-automated-backups.md)
