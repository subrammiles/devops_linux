# Project 4: Deploy a Containerised App behind Nginx

**Goal:** build a small Python web app with a Redis database, run both with Docker Compose, put Nginx in front as a reverse proxy with HTTPS, and make it all start on boot.

**Uses:** [docker-basics](../intermediate/docker-basics.md), [Project 2: Nginx](02-nginx-https.md), [networking](../basic/networking.md), [monitoring-and-troubleshooting](../intermediate/monitoring-and-troubleshooting.md)

**You need:** the server from Projects 1 and 2, with Docker installed as described in [docker-basics.md](../intermediate/docker-basics.md).

## How it fits together

```text
Internet ──► Nginx on the host (:80/:443, HTTPS)
                │  proxy_pass
                ▼
          127.0.0.1:8000 ──► [web container: gunicorn + Flask]
                                     │
                                     ▼
                              [redis container] ──► volume: redis-data
```

Only Nginx faces the internet. The app port is bound to `127.0.0.1`, so it can't be reached from outside directly.

---

## Step 1: Create the app

```bash
mkdir -p ~/apps/counter && cd ~/apps/counter
```

`app.py`:

```python
import os
import socket

import redis
from flask import Flask

app = Flask(__name__)
db = redis.Redis(host=os.environ.get("REDIS_HOST", "redis"), port=6379)


@app.route("/")
def index():
    hits = db.incr("hits")
    return f"Hello from container {socket.gethostname()}! Page views: {hits}\n"


@app.route("/health")
def health():
    db.ping()
    return "ok\n"
```

`requirements.txt`:

```text
flask==3.0.3
redis==5.0.8
gunicorn==23.0.0
```

## Step 2: Write the Dockerfile

`Dockerfile`:

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--access-logfile", "-", "app:app"]
```

`.dockerignore`:

```text
__pycache__
*.pyc
.env
.git
```

`PYTHONUNBUFFERED=1` makes Python print output immediately, so it shows up in `docker logs` straight away. Gunicorn is a production web server. Flask's built-in server is only meant for development.

## Step 3: Write the Compose file

`compose.yaml`:

```yaml
services:
  web:
    build: .
    image: counter:1.0
    environment:
      REDIS_HOST: redis
    ports:
      - "127.0.0.1:8000:8000"
    depends_on:
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
      interval: 30s
      timeout: 5s
      retries: 3

  redis:
    image: redis:7-alpine
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - redis-data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

volumes:
  redis-data:
```

> **Why `127.0.0.1:8000:8000` and not `8000:8000`?** Docker adds its own firewall rules that **bypass ufw**. With `"8000:8000"`, port 8000 is open to the whole internet even when `ufw status` doesn't list it. Binding to `127.0.0.1` keeps it local to the server, and Nginx is the only way in.

Redis has no `ports:` entry. The `web` container reaches it over Compose's private network by the name `redis`, and nothing outside can reach it.

## Step 4: Build and run

```bash
docker compose up -d --build
docker compose ps                    # Both should show "healthy" after a few seconds
docker compose logs -f web           # Ctrl+C to stop following
curl http://127.0.0.1:8000           # Page views: 1
curl http://127.0.0.1:8000           # Page views: 2
```

Check that the data survives a restart:

```bash
docker compose down                  # Removes containers, keeps the volume
docker compose up -d
curl http://127.0.0.1:8000           # Count continues from before
```

## Step 5: Put Nginx in front

Create `/etc/nginx/sites-available/app.example.com`. Use a subdomain whose DNS points to this server, or reuse your domain from Project 2.

```bash
sudo tee /etc/nginx/sites-available/app.example.com > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name app.example.com;

    access_log /var/log/nginx/app.access.log;
    error_log  /var/log/nginx/app.error.log;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/app.example.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
curl -H "Host: app.example.com" http://localhost
```

The `proxy_set_header` lines pass the visitor's real IP address and the original protocol to the app. Without them, the app sees every request as coming from `127.0.0.1`.

Add HTTPS the same way as in Project 2:

```bash
sudo certbot --nginx -d app.example.com
curl https://app.example.com
```

## Step 6: Prove the app port is private

From **another machine** (your laptop):

```bash
curl --max-time 5 http://SERVER_IP:8000     # Should time out or be refused
curl https://app.example.com                # Should work
```

On the server:

```bash
sudo ss -tlpn | grep 8000                   # Should show 127.0.0.1:8000, not 0.0.0.0:8000
```

## Step 7: Start on boot

Docker itself must start at boot. Containers with `restart: unless-stopped` then come back automatically.

```bash
sudo systemctl is-enabled docker            # enabled
sudo reboot
# after reconnecting:
docker compose -f ~/apps/counter/compose.yaml ps
curl https://app.example.com
```

## Step 8: Deploy a new version

Edit `app.py`, for example by changing the greeting. Then:

```bash
cd ~/apps/counter
sed -i 's/counter:1.0/counter:1.1/' compose.yaml    # New image tag
docker compose up -d --build
docker compose ps
curl https://app.example.com
```

To roll back, set the tag back to `1.0` and run `docker compose up -d`. The old image is still stored locally.

Remove old images now and then with `docker image prune`.

---

## Verify

| Check | Command | Expected |
|-------|---------|----------|
| Containers healthy | `docker compose ps` | `healthy` for both |
| App works through Nginx | `curl https://app.example.com` | Greeting with a rising count |
| App port is private | `curl SERVER_IP:8000` from your laptop | Fails |
| Data persists | `docker compose down && docker compose up -d` | Count continues |
| Survives a reboot | `sudo reboot`, then curl | Works |

## Troubleshooting

| Symptom | Check |
|---------|-------|
| `502 Bad Gateway` from Nginx | The app isn't running or the port is wrong: `docker compose ps`, `curl 127.0.0.1:8000`, `sudo tail /var/log/nginx/app.error.log` |
| `web` keeps restarting | `docker compose logs web` |
| Redis connection error | `REDIS_HOST` must match the service name `redis` |
| `unhealthy` status | `docker inspect --format '{{json .State.Health}}' counter-web-1` |
| Port 8000 reachable from the internet | The `ports:` entry is missing `127.0.0.1:` |

## Stretch goals

1. Add Redis's data directory to the [Project 3](03-automated-backups.md) backup. Find the volume path with `docker volume inspect counter_redis-data`.
2. Run three copies of the app: `docker compose up -d --scale web=3`. You'll first need to remove the fixed host port and add an `upstream` block in Nginx.
3. Push the image to a registry such as Docker Hub or GitHub Container Registry, and deploy on another server with `docker compose pull`.
4. Write a GitHub Actions workflow that builds the image on every push.
5. Add rate limiting in Nginx with `limit_req_zone`.

Previous: [03-automated-backups.md](03-automated-backups.md)
