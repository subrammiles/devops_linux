# Docker Basics

Docker runs applications in **containers**: isolated processes that bring their own files and libraries but share the host's Linux kernel. They start in seconds and behave the same on a laptop and a server.

| Term | Meaning |
|------|---------|
| **Image** | A read-only template: the app plus everything it needs (`nginx:1.27`) |
| **Container** | A running (or stopped) instance of an image |
| **Dockerfile** | Instructions for building an image |
| **Registry** | Where images are stored and shared (Docker Hub, GHCR, ECR) |
| **Volume** | Storage that survives when a container is removed |

## Install on Ubuntu

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"     # Run docker without sudo; log out and back in afterwards
docker run hello-world              # Test
```

> Members of the `docker` group effectively have root access to the host. Only add trusted users.

## Running containers

```bash
docker run -d --name web -p 8080:80 nginx:1.27
#           │    │         │         └── image:tag
#           │    │         └── host port 8080 → container port 80
#           │    └── container name
#           └── detached (run in the background)

curl http://localhost:8080
```

```bash
docker ps                       # Running containers
docker ps -a                    # Including stopped ones
docker logs web                 # Container output
docker logs -f --tail 50 web    # Follow
docker exec -it web bash        # Open a shell inside (use sh for small images)
docker stop web                 # Stop
docker start web                # Start again
docker rm web                   # Remove (must be stopped, or use rm -f)
docker run --rm -it ubuntu:24.04 bash   # Throwaway container, removed on exit
```

Useful `docker run` options:

| Option | Meaning |
|--------|---------|
| `-d` | Run in the background |
| `-it` | Interactive terminal |
| `--rm` | Remove the container when it exits |
| `-p host:container` | Publish a port |
| `-e KEY=value` | Set an environment variable |
| `--env-file .env` | Load variables from a file |
| `-v host_path:container_path` | Mount a host directory |
| `-v volname:container_path` | Mount a named volume |
| `--restart unless-stopped` | Restart after crashes and reboots |
| `--name` | Give the container a name |

## Images

```bash
docker images                   # Local images
docker pull redis:7             # Download
docker rmi redis:7              # Remove
docker image prune              # Remove unused images
```

Use a specific tag such as `nginx:1.27` in real deployments. `latest` changes over time, so the same command can give different results later.

## Volumes: keeping data

A container's own files are lost when it's removed. Use a volume for data you want to keep:

```bash
docker volume create pgdata
docker run -d --name db \
  -e POSTGRES_PASSWORD=change-me \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:16

docker volume ls
docker volume inspect pgdata
```

Bind mount a host directory, which is handy during development:

```bash
docker run -d -p 8080:80 -v "$PWD/site":/usr/share/nginx/html:ro nginx:1.27
```

`:ro` makes the mount read-only inside the container.

## Writing a Dockerfile

Example for a small Python app with `app.py` and `requirements.txt`:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Copy and install dependencies first so Docker can cache this layer
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Don't run as root
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
```

Add a `.dockerignore` so unneeded files stay out of the image:

```text
.git
__pycache__
.env
*.log
```

Build and run:

```bash
docker build -t myapp:1.0 .
docker run -d -p 8000:8000 --name myapp myapp:1.0
```

Main instructions:

| Instruction | Purpose |
|-------------|---------|
| `FROM` | Base image |
| `WORKDIR` | Working directory for the following instructions |
| `COPY` | Copy files from the build context into the image |
| `RUN` | Run a command at build time |
| `ENV` | Set an environment variable |
| `EXPOSE` | Document the port the app listens on |
| `USER` | User to run as |
| `CMD` | Default command when the container starts |
| `ENTRYPOINT` | Fixed command; `CMD` then supplies its default arguments |

## Docker Compose: several containers together

`compose.yaml`:

```yaml
services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgres://postgres:change-me@db:5432/postgres
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: change-me
    volumes:
      - pgdata:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  pgdata:
```

Services reach each other by service name: the `web` container connects to the host `db`.

```bash
docker compose up -d            # Build if needed, create and start everything
docker compose ps
docker compose logs -f web
docker compose exec db psql -U postgres
docker compose down             # Stop and remove containers (volumes are kept)
docker compose down -v          # Also delete volumes, which deletes the data
```

## Cleaning up

```bash
docker system df                # Space used by images, containers, volumes
docker container prune          # Remove stopped containers
docker image prune -a           # Remove all images not used by a container
docker system prune             # Stopped containers, unused networks, dangling images
```

`docker volume prune` deletes volumes not attached to a container, including database data. Check `docker volume ls` first.

## Troubleshooting

```bash
docker logs <name>                  # Why did it exit?
docker ps -a                        # Exit code in the STATUS column
docker inspect <name>               # Full configuration: mounts, network, environment
docker stats                        # Live CPU and memory per container
docker run --rm -it --entrypoint sh myapp:1.0   # Start a shell in an image that keeps crashing
```

## Practice

1. Run `nginx:1.27` on port 8080 and open `http://localhost:8080`.
2. Make a `site/index.html` and serve it with a bind mount.
3. Write the Dockerfile above for a one-line `app.py` that prints "hello", then build and run it.
4. Start the Compose example and connect to the database with `docker compose exec db psql -U postgres`.
5. Clean up with `docker compose down -v` and `docker system prune`.

Previous: [monitoring-and-troubleshooting.md](monitoring-and-troubleshooting.md)
