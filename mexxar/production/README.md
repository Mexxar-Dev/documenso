# Mexxar Production Setup

Production deployment using Docker with cloud services (AWS S3/DigitalOcean Spaces, Cloud Database, SMTP).

## Architecture

- **Application**: Documenso Docker image
- **Database**: Cloud PostgreSQL (AWS RDS, DigitalOcean, etc.)
- **Storage**: S3-compatible (AWS S3, DigitalOcean Spaces)
- **Email**: SMTP service (SendGrid, Mailgun, AWS SES, etc.)
- **Certificate**: Self-signed (generated locally)

## Prerequisites

### Cloud Services Required

1. **PostgreSQL Database**
   - AWS RDS, DigitalOcean Managed Database, or similar
   - PostgreSQL 15 or higher recommended

2. **S3-Compatible Storage**
   - AWS S3 bucket, or
   - DigitalOcean Spaces

3. **SMTP Email Service**
   - SendGrid, Mailgun, AWS SES, or any SMTP provider

## Setup Instructions

### 1. Configure Environment

```bash
cd mexxar/production

# Copy example environment file
cp .env.example .env

# Edit with your cloud service credentials
nano .env
```

**Required Configuration:**

- **Auth & Encryption**: Generate secure random strings
  ```bash
  openssl rand -hex 32  # Run 3 times for the 3 secrets
  ```

- **Database**: Your cloud PostgreSQL connection string
  ```
  NEXT_PRIVATE_DATABASE_URL="postgresql://user:password@host:5432/database"
  ```

- **Storage**: S3 or Spaces credentials
  ```
  # For AWS S3
  NEXT_PRIVATE_UPLOAD_ENDPOINT="https://s3.amazonaws.com"
  NEXT_PRIVATE_UPLOAD_BUCKET="your-bucket-name"
  
  # For DigitalOcean Spaces
  NEXT_PRIVATE_UPLOAD_ENDPOINT="https://nyc3.digitaloceanspaces.com"
  NEXT_PRIVATE_UPLOAD_BUCKET="your-space-name"
  ```

- **SMTP**: Your email service credentials
  ```
  NEXT_PRIVATE_SMTP_HOST="smtp.sendgrid.net"
  NEXT_PRIVATE_SMTP_USERNAME="apikey"
  NEXT_PRIVATE_SMTP_PASSWORD="your-api-key"
  ```

### 2. Generate Certificate

```bash
./setup-cert.sh
```

This will:
- Prompt for certificate details (country, organization, domain)
- Generate a self-signed certificate
- Automatically update `.env` with the password

### 3. Start Production Service

```bash
./start.sh
```

This will:
- Validate `.env` exists
- Check for certificate
- Pull latest Docker image
- Start the service
- Verify health

### 4. Access Application

- **App**: http://localhost:3000 (or your configured port)
- **Health Check**: http://localhost:3000/api/health

## Management Commands

```bash
cd mexxar/production

# Start service
./start.sh

# Stop service
./stop.sh

# View logs
./logs.sh

# Regenerate certificate
./setup-cert.sh
```

## Docker Compose Commands

```bash
cd mexxar/production

# Start service
docker compose up -d

# View logs
docker compose logs -f app

# Stop service
docker compose down

# Restart
docker compose restart app

# Pull latest image
docker compose pull app
```

## Reverse Proxy Setup

For production, use a reverse proxy (Nginx, Caddy, Traefik) for:
- SSL/TLS termination
- Domain routing
- Load balancing (if needed)

### Example Nginx Configuration

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /path/to/ssl/cert.pem;
    ssl_certificate_key /path/to/ssl/key.pem;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Database Migrations

Migrations run automatically on container startup. To run manually:

```bash
docker compose exec app npx prisma migrate deploy
```

## Monitoring

### Health Check

```bash
curl http://localhost:3000/api/health
```

### View Logs

```bash
# Real-time logs
./logs.sh

# Last 100 lines
docker compose logs --tail 100 app

# Logs since 1 hour ago
docker compose logs --since 1h app
```

## Backup Strategy

### Database
Use your cloud provider's backup features:
- AWS RDS: Automated backups
- DigitalOcean: Daily backups

### Storage (S3/Spaces)
- Enable versioning on your bucket
- Configure lifecycle policies
- Regular snapshots

### Certificate
Backup `certs/cert.p12` file securely

## Troubleshooting

### Service Won't Start

1. Check environment variables:
   ```bash
   docker compose config
   ```

2. View detailed logs:
   ```bash
   docker compose logs app
   ```

3. Verify cloud services are accessible:
   ```bash
   # Test database connection
   psql "postgresql://user:password@host:5432/database"
   
   # Test S3/Spaces access
   aws s3 ls s3://your-bucket-name
   ```

### Certificate Issues

If document signing fails:

1. Verify certificate exists:
   ```bash
   ls -la certs/cert.p12
   ```

2. Check permissions:
   ```bash
   chmod 644 certs/cert.p12
   ```

3. Regenerate certificate:
   ```bash
   ./setup-cert.sh
   docker compose restart app
   ```

### Database Connection Issues

1. Verify connection string format
2. Check firewall rules allow connection from your server
3. Ensure database user has proper permissions

### Storage Issues

1. Verify bucket exists and is accessible
2. Check IAM permissions for access keys
3. Ensure bucket region matches configuration

## Security Checklist

- [ ] Use strong random secrets (32+ characters)
- [ ] Enable SSL/TLS with reverse proxy
- [ ] Restrict database access to your server IP
- [ ] Use IAM roles with minimal permissions for S3
- [ ] Enable bucket encryption
- [ ] Regular security updates: `docker compose pull && docker compose up -d`
- [ ] Monitor logs for suspicious activity
- [ ] Backup certificate securely
- [ ] Use environment-specific SMTP credentials

## Scaling

For high availability:

1. **Multiple Instances**: Run multiple containers behind a load balancer
2. **Database**: Use read replicas for better performance
3. **Storage**: S3/Spaces scales automatically
4. **Background Jobs**: Consider using Inngest for distributed job processing

## Updates

```bash
cd mexxar/production

# Pull latest image
docker compose pull app

# Restart with new image
docker compose up -d

# Verify health
curl http://localhost:3000/api/health
```

## Support

For issues specific to:
- **Documenso**: https://github.com/documenso/documenso
- **Cloud Services**: Refer to your provider's documentation
- **This Setup**: Check logs and troubleshooting section above
