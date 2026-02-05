# Mexxar Documenso Setup

Custom deployment configurations for Documenso, isolated from upstream repository.

## Directory Structure

```
mexxar/
├── develop/          # Development environment
│   ├── docker-compose.yml
│   ├── .env
│   ├── setup-cert.sh
│   └── certs/
└── production/       # Production environment (coming soon)
```

## Environments

### Development (`mexxar/develop/`)

Docker-based setup using production image with local services.

**Quick Start:**
```bash
cd mexxar/develop
./start.sh    # One command to start everything
```

See [develop/README.md](develop/README.md) for details.

### Production (`mexxar/production/`)

Production deployment with cloud services (S3/Spaces, Cloud Database, SMTP).

**Quick Start:**
```bash
cd mexxar/production
cp .env.example .env      # Configure cloud services
nano .env                 # Edit with your credentials
./setup-cert.sh           # Generate certificate
./start.sh                # Start production service
```

See [production/README.md](production/README.md) for details.

## Why Separate Directory?

- **Merge-friendly**: Upstream changes won't conflict with Mexxar configs
- **Isolated**: Custom settings don't affect original Documenso setup
- **Clean**: Easy to identify Mexxar-specific modifications
- **Flexible**: Can maintain multiple deployment configurations

## Upstream Merging

This structure allows you to:
1. Pull upstream changes: `git pull upstream main`
2. Merge without conflicts (Mexxar configs are separate)
3. Keep custom configurations intact
