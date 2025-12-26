# UEMS Docker Quick Start Guide

## Prerequisites Check

```bash
# Verify Docker installation
docker --version  # Should be 20.10+
docker compose version  # Should be 2.0+

# Verify available resources
docker system info | grep -E "CPUs|Total Memory"
```

## Development Setup (5 Minutes)

### Step 1: Configure Environment

```bash
# Navigate to project directory
cd /home/mahmoud/AI/Projects/claude-Version1

# Copy environment file
cp .env.example .env

# Edit environment file with secure passwords
nano .env  # or use your preferred editor
```

**Required Changes in .env:**
- `POSTGRES_PASSWORD` - Change from default
- `REDIS_PASSWORD` - Set a secure password
- `NEXTCLOUD_ADMIN_PASSWORD` - Change from default
- `JWT_SECRET` - Generate using: `openssl rand -base64 64`
- `JWT_REFRESH_SECRET` - Generate using: `openssl rand -base64 64`

### Step 2: Start Services

```bash
# Using Makefile (recommended)
make setup  # Builds and starts all services

# Or using docker-compose directly
docker compose build
docker compose up -d
```

### Step 3: Verify Deployment

```bash
# Check service status
make status
# or
docker compose ps

# View logs
make logs
# or
docker compose logs -f

# Check health
make health
```

### Step 4: Access Applications

- **Frontend:** http://localhost
- **Backend API:** http://localhost/api/v1
- **API Documentation:** http://localhost/api/v1/docs
- **NextCloud:** http://localhost/nextcloud
- **PostgreSQL:** localhost:5432
- **Redis:** localhost:6379

### Step 5: Initial Database Setup

```bash
# Run migrations
make migrate
# or
docker compose exec backend npm run migration:run

# (Optional) Seed database
make seed
# or
docker compose exec backend npm run seed
```

## Production Deployment

### Step 1: Production Environment

```bash
# Create production environment file
cp .env.example .env.production

# Edit with production values
nano .env.production
```

**Critical Production Settings:**
```bash
NODE_ENV=production
DOMAIN_NAME=yourdomain.com
POSTGRES_PASSWORD=<strong_password>
REDIS_PASSWORD=<strong_password>
JWT_SECRET=<64_char_secret>
JWT_REFRESH_SECRET=<64_char_secret>
NEXTCLOUD_TRUSTED_DOMAINS=yourdomain.com
```

### Step 2: SSL Certificate Setup

**Option A: Let's Encrypt (Recommended)**

```bash
# Edit domain in command
make ssl-init
# Enter your domain when prompted
```

**Option B: Custom Certificate**

```bash
# Place your certificates
mkdir -p nginx/ssl
cp /path/to/your-cert.crt nginx/ssl/
cp /path/to/your-key.key nginx/ssl/
```

### Step 3: Build and Deploy

```bash
# Build production images
make prod-build

# Start production services
make prod-up

# Verify deployment
docker compose -f docker-compose.prod.yml ps
```

### Step 4: Post-Deployment

```bash
# Check logs
make prod-logs

# Run migrations
docker compose -f docker-compose.prod.yml exec backend npm run migration:run

# Monitor resources
make monitor
```

## Common Operations

### Development Workflow

```bash
# Start services
make up

# View logs
make logs-backend
make logs-frontend

# Restart after code changes
make restart-backend
make restart-frontend

# Run tests
make test

# Access container shell
make shell-backend
make shell-frontend
```

### Database Operations

```bash
# Create backup
make backup

# Restore from backup
make restore

# Access PostgreSQL
make shell-postgres

# Run migrations
make migrate

# Generate migration
make migrate-generate
```

### Cache Management

```bash
# Clear Redis cache
make redis-flush

# View Redis info
make redis-info

# Access Redis CLI
make shell-redis
```

### Cleanup

```bash
# Stop all services
make down

# Remove volumes (WARNING: deletes data)
make clean-volumes

# Full cleanup (WARNING: removes everything)
make clean
```

## Troubleshooting

### Services Not Starting

```bash
# Check logs for errors
make logs

# Check specific service
make logs-backend
make logs-postgres

# Restart specific service
make restart-backend
```

### Port Conflicts

```bash
# Check what's using ports
sudo lsof -i :80
sudo lsof -i :3000
sudo lsof -i :3001
sudo lsof -i :5432

# Change ports in .env
NGINX_PORT=8080
FRONTEND_PORT=3001
BACKEND_PORT=3002
POSTGRES_PORT=5433
```

### Database Connection Issues

```bash
# Verify PostgreSQL is running
docker compose ps postgres

# Check PostgreSQL logs
make logs-postgres

# Test connection from backend
docker compose exec backend sh
> nc -zv postgres 5432
```

### Build Failures

```bash
# Clear Docker cache and rebuild
make build-nocache

# Or manually
docker compose build --no-cache
docker compose up -d
```

### Permission Issues

```bash
# Fix upload directory permissions
sudo chown -R $(id -u):$(id -g) uploads logs

# Or inside container
docker compose exec backend chown -R nestjs:nodejs /app/uploads
```

## Performance Optimization

### For Development

```bash
# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Use volume mount caching (already configured)
# Backend and frontend use :cached and :delegated flags
```

### For Production

**PostgreSQL Tuning** (already in docker-compose.prod.yml):
- Max connections: 200
- Shared buffers: 512MB
- Effective cache: 2GB

**Redis Tuning** (already configured):
- Max memory: 512MB
- Eviction: LRU
- Persistence: AOF

**Nginx** (already optimized):
- Gzip compression
- Keep-alive connections
- Static file caching

## Monitoring

### Health Checks

```bash
# Check all services
make health

# Individual endpoints
curl http://localhost/api/v1/health
curl http://localhost/health  # Nginx
```

### Resource Usage

```bash
# Real-time monitoring
make monitor

# Or
docker stats

# Specific service
docker stats uems-backend uems-frontend
```

### Logs

```bash
# All services
make logs

# Specific service with tail
docker compose logs -f --tail=100 backend

# Save logs to file
docker compose logs > uems-logs.txt
```

## Backup Strategy

### Automated Backup

```bash
# Daily backup (add to cron)
0 2 * * * cd /home/mahmoud/AI/Projects/claude-Version1 && make backup

# Weekly full backup
0 3 * * 0 cd /home/mahmoud/AI/Projects/claude-Version1 && make backup
```

### Manual Backup

```bash
# Database
make backup

# Files and uploads
tar -czf uploads_backup_$(date +%Y%m%d).tar.gz uploads/

# NextCloud data
docker run --rm -v uems-nextcloud-data-prod:/data -v $(pwd):/backup \
  alpine tar -czf /backup/nextcloud_backup_$(date +%Y%m%d).tar.gz -C /data .
```

## Useful Makefile Commands

```bash
make help           # Show all available commands
make setup          # Initial setup
make up             # Start development
make down           # Stop services
make logs           # View logs
make migrate        # Run migrations
make backup         # Backup database
make test           # Run tests
make prod-up        # Start production
make clean          # Remove everything
```

## Security Checklist

Before production deployment:

- [ ] Changed all default passwords
- [ ] Generated secure JWT secrets (64+ characters)
- [ ] Configured SSL/TLS certificates
- [ ] Set CORS_ORIGIN to your domain
- [ ] Enabled rate limiting
- [ ] Configured firewall rules
- [ ] Set up automated backups
- [ ] Configured log rotation
- [ ] Reviewed environment variables
- [ ] Tested disaster recovery

## Support and Documentation

- **Full Documentation:** See `DOCKER_README.md`
- **Optimization Details:** See `DOCKER_OPTIMIZATION_SUMMARY.md`
- **Environment Variables:** See `.env.example`

## Next Steps

1. ✅ Complete development setup
2. ✅ Run tests: `make test`
3. ✅ Test all features
4. ⬜ Configure production environment
5. ⬜ Set up SSL certificates
6. ⬜ Deploy to production
7. ⬜ Configure monitoring
8. ⬜ Set up automated backups

---

**Quick Command Reference:**

```bash
# Development
make setup          # First time setup
make up             # Start
make down           # Stop
make logs           # View logs

# Production
make prod-build     # Build
make prod-up        # Deploy
make prod-logs      # Monitor

# Maintenance
make backup         # Backup
make migrate        # Update DB
make clean          # Reset
```

For detailed information, see `DOCKER_README.md`.
