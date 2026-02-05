# Mexxar Development Setup

Docker-based development environment using the production Documenso image with local services.

## Features

- **Production Docker Image**: Uses official `documenso/documenso:latest`
- **Local Services**: PostgreSQL, MinIO (S3), Inbucket (SMTP)
- **Isolated**: Separate from upstream Documenso configs
- **Easy Setup**: One-command start with automatic certificate generation

## Quick Start

### 1. Start Everything (One Command)

```bash
cd mexxar/develop
./start.sh
```

This will:
- Check for certificate (generate if missing)
- Pull latest Documenso image
- Start all services

Services started:
- PostgreSQL (port 54320)
- Inbucket mailserver (port 9000, 2500)
- MinIO S3 storage (port 9001, 9002)
- Documenso app (port 3000)

### 2. Access Application

- **App**: http://localhost:3000
- **Mailserver**: http://localhost:9000 (view sent emails)
- **MinIO Console**: http://localhost:9001
  - Username: `documenso`
  - Password: `password`

## Management Scripts

```bash
cd mexxar/develop

# Start services
./start.sh

# Stop services
./stop.sh

# View app logs
./logs.sh

# Generate/regenerate certificate
./setup-cert.sh
```

## Docker Compose Commands

You can also use Docker Compose directly:

```bash
cd mexxar/develop

# Start services
docker compose up -d

# View logs
docker compose logs -f app

# Stop services
docker compose down

# Restart app only
docker compose restart app
```

## Configuration

Edit `mexxar/develop/.env` to customize:

- `NEXTAUTH_SECRET` - Auth secret (generate with `openssl rand -hex 32`)
- `NEXT_PRIVATE_ENCRYPTION_KEY` - Encryption key
- `NEXT_PUBLIC_WEBAPP_URL` - Application URL
- `NEXT_PRIVATE_SIGNING_PASSPHRASE` - Certificate password (set by setup-cert.sh)
- `NEXT_PUBLIC_DISABLE_SIGNUP` - Set to `1` to disable signups

## Database Access

Connect to PostgreSQL:

```bash
psql postgresql://documenso:password@localhost:54320/documenso
```

## Troubleshooting

### Certificate Issues

If you see certificate permission errors:

```bash
cd mexxar/develop
chmod 644 certs/cert.p12
docker compose restart app
```

### Reset Everything

```bash
npm run mexxar:dev:down
docker volume rm documenso-mexxar-dev_mexxar_dev_database documenso-mexxar-dev_mexxar_dev_minio
npm run mexxar:dev
```

### View All Logs

```bash
cd mexxar/develop
docker compose logs -f
```

## Architecture

```
mexxar/develop/
├── docker-compose.yml    # Service definitions
├── .env                  # Environment configuration
├── setup-cert.sh         # Certificate generation script
└── certs/                # Certificate storage (gitignored)
    └── cert.p12          # Generated certificate
```

## Notes

- This setup is isolated from the upstream Documenso repository
- All Mexxar-specific configs are in the `mexxar/` directory
- You can safely merge upstream changes without conflicts
- The production image is used, so no local build required
- Database migrations run automatically on startup
