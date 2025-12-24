# UEMS Deployment Guide

Production deployment guide for UEMS.

## Table of Contents
1. [Production Requirements](#production-requirements)
2. [Server Setup](#server-setup)
3. [Docker Deployment](#docker-deployment)
4. [Kubernetes Deployment](#kubernetes-deployment)
5. [SSL/TLS Configuration](#ssltls-configuration)
6. [Monitoring](#monitoring)
7. [Backup Strategy](#backup-strategy)
8. [Scaling](#scaling)

## Production Requirements

### Minimum Server Specifications

**Small Deployment (< 100 users)**
- CPU: 4 cores
- RAM: 8GB
- Storage: 100GB SSD
- Network: 100 Mbps

**Medium Deployment (100-500 users)**
- CPU: 8 cores
- RAM: 16GB
- Storage: 500GB SSD
- Network: 1 Gbps

**Large Deployment (> 500 users)**
- CPU: 16+ cores
- RAM: 32GB+
- Storage: 1TB+ SSD
- Network: 10 Gbps

### Software Requirements

- Docker 24.x+
- Docker Compose 2.x+ OR Kubernetes 1.27+
- Ubuntu 22.04 LTS / RHEL 8+ / Debian 12+
- SSL Certificate (Let's Encrypt or commercial)

## Server Setup

### 1. Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### 3. Install Docker Compose

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 4. Configure Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Docker Deployment

### 1. Clone Repository

```bash
git clone <repository-url> /opt/uems
cd /opt/uems
```

### 2. Configure Production Environment

```bash
cp .env.example .env.production
```

Edit `.env.production`:

```env
NODE_ENV=production

# Database - Use strong passwords!
POSTGRES_PASSWORD=<generate-strong-password>
NEXTCLOUD_DB_PASSWORD=<generate-strong-password>

# JWT Secrets - Use cryptographically secure random strings
JWT_SECRET=<generate-64-char-random-string>
JWT_REFRESH_SECRET=<generate-64-char-random-string>

# NextCloud
NEXTCLOUD_ADMIN_PASSWORD=<generate-strong-password>

# Domain
PRODUCTION_DOMAIN=yourdomain.com

# Security
BCRYPT_ROUNDS=12
CORS_ORIGIN=https://yourdomain.com
```

### 3. Deploy with Docker Compose

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

### 4. Initialize Database

```bash
docker-compose -f docker-compose.prod.yml exec backend npm run migration:run
docker-compose -f docker-compose.prod.yml exec backend npm run seed
```

### 5. Verify Deployment

```bash
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

## SSL/TLS Configuration

### Option 1: Let's Encrypt (Recommended)

Install Certbot:

```bash
sudo apt install certbot python3-certbot-nginx
```

Obtain certificate:

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Auto-renewal (cron):

```bash
sudo crontab -e
# Add: 0 3 * * * certbot renew --quiet
```

### Option 2: Custom Certificate

Place certificates:

```bash
mkdir -p nginx/ssl
cp your-cert.pem nginx/ssl/cert.pem
cp your-key.pem nginx/ssl/key.pem
```

Update `nginx/nginx.prod.conf`:

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # ... rest of configuration
}
```

## Monitoring

### Health Checks

```bash
# Application health
curl http://localhost/api/v1/health

# Container health
docker-compose ps
```

### Logging

Configure log rotation:

```bash
cat > /etc/logrotate.d/docker-container << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size 10M
    missingok
    delaycompress
    copytruncate
}
EOF
```

### Monitoring Tools

**Option 1: Prometheus + Grafana**

Add to docker-compose.prod.yml:

```yaml
prometheus:
  image: prom/prometheus
  volumes:
    - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
  ports:
    - "9090:9090"

grafana:
  image: grafana/grafana
  ports:
    - "3001:3000"
  environment:
    - GF_SECURITY_ADMIN_PASSWORD=admin
```

**Option 2: Cloud Monitoring**
- AWS CloudWatch
- Google Cloud Monitoring
- Azure Monitor
- Datadog

## Backup Strategy

### Database Backup

**Automated Daily Backup:**

```bash
# Create backup script
cat > /opt/uems/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/uems/backups

mkdir -p $BACKUP_DIR

# Backup UEMS database
docker-compose exec -T postgres pg_dump -U uems_user uems_db > $BACKUP_DIR/uems_db_$DATE.sql

# Backup NextCloud database
docker-compose exec -T nextcloud-db pg_dump -U nextcloud nextcloud > $BACKUP_DIR/nextcloud_db_$DATE.sql

# Backup NextCloud data
tar -czf $BACKUP_DIR/nextcloud_data_$DATE.tar.gz /var/lib/docker/volumes/uems-nextcloud-data

# Keep only last 30 days
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $DATE"
EOF

chmod +x /opt/uems/backup.sh
```

**Schedule with Cron:**

```bash
sudo crontab -e
# Add: 0 2 * * * /opt/uems/backup.sh >> /var/log/uems-backup.log 2>&1
```

### Restore from Backup

```bash
# Stop services
docker-compose down

# Restore database
docker-compose up -d postgres
cat backup_file.sql | docker-compose exec -T postgres psql -U uems_user uems_db

# Restore files
tar -xzf nextcloud_data_backup.tar.gz -C /

# Restart all services
docker-compose up -d
```

## Scaling

### Horizontal Scaling

Update docker-compose.prod.yml:

```yaml
backend:
  deploy:
    replicas: 3
    resources:
      limits:
        cpus: '1'
        memory: 1G
```

### Load Balancing

Use Nginx upstream for backend replicas:

```nginx
upstream backend {
    least_conn;
    server backend-1:3001;
    server backend-2:3001;
    server backend-3:3001;
}
```

### Database Optimization

**Connection Pooling:**

```env
DB_POOL_MIN=10
DB_POOL_MAX=50
```

**PostgreSQL Tuning:**

```sql
-- Increase shared buffers
ALTER SYSTEM SET shared_buffers = '2GB';

-- Increase work memory
ALTER SYSTEM SET work_mem = '32MB';

-- Enable query caching
ALTER SYSTEM SET effective_cache_size = '6GB';
```

### Caching Layer

Add Redis for session/data caching:

```yaml
redis:
  image: redis:7-alpine
  command: redis-server --requirepass yourpassword
  volumes:
    - redis-data:/data
```

## Performance Optimization

### CDN Integration

Use CloudFlare, AWS CloudFront, or similar for:
- Static asset delivery
- DDoS protection
- Edge caching

### Database Indexing

```sql
-- Add indexes for frequently queried fields
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_deals_stage ON deals(stage);
CREATE INDEX idx_candidates_stage ON candidates(stage);
```

### Compression

Nginx gzip is enabled by default. Verify:

```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript;
```

## Security Hardening

### 1. Update Secrets

Change all default passwords and generate new JWT secrets.

### 2. Enable HTTPS Only

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}
```

### 3. Configure CORS

```env
CORS_ORIGIN=https://yourdomain.com,https://www.yourdomain.com
```

### 4. Rate Limiting

```env
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100
```

### 5. Security Headers

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

## Troubleshooting

### High CPU Usage

```bash
docker stats
# Identify problematic container
docker-compose logs <container-name>
```

### High Memory Usage

```bash
# Check container memory
docker stats --no-stream

# Restart container if needed
docker-compose restart <container-name>
```

### Database Connection Issues

```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Test connection
docker-compose exec backend npm run typeorm -- query "SELECT 1"
```

## Maintenance

### Zero-Downtime Updates

```bash
# Pull latest code
git pull origin main

# Build new images
docker-compose -f docker-compose.prod.yml build

# Rolling update
docker-compose -f docker-compose.prod.yml up -d --no-deps --build backend
```

### Database Migrations

```bash
# Backup before migration
./backup.sh

# Run migrations
docker-compose exec backend npm run migration:run

# Verify
docker-compose exec backend npm run migration:show
```

## Support

For production deployment support, contact: support@uems.com
