# UEMS Docker Deployment Guide

This guide provides comprehensive instructions for deploying the Unified Enterprise Management System (UEMS) using Docker and Docker Compose.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Architecture Overview](#architecture-overview)
- [Configuration](#configuration)
- [Development Deployment](#development-deployment)
- [Production Deployment](#production-deployment)
- [Docker Optimization Features](#docker-optimization-features)
- [Useful Commands](#useful-commands)
- [Troubleshooting](#troubleshooting)
- [Performance Tuning](#performance-tuning)

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM available for Docker
- 10GB free disk space

## Quick Start

### Development Environment

```bash
# 1. Clone the repository
git clone <repository-url>
cd claude-Version1

# 2. Copy and configure environment variables
cp .env.example .env
# Edit .env with your preferred editor and set secure passwords

# 3. Start all services
docker-compose up -d

# 4. View logs
docker-compose logs -f

# 5. Access the application
# Frontend: http://localhost
# Backend API: http://localhost/api/v1
# NextCloud: http://localhost/nextcloud
```

### Production Environment

```bash
# 1. Configure production environment
cp .env.example .env.production
# Edit .env.production with production values

# 2. Build and start production services
docker-compose -f docker-compose.prod.yml up -d --build

# 3. Monitor deployment
docker-compose -f docker-compose.prod.yml logs -f
```

## Architecture Overview

The UEMS Docker setup consists of the following services:

### Core Services

1. **Backend (NestJS)** - Port 3001
   - RESTful API server
   - TypeORM for database access
   - JWT authentication
   - Redis caching

2. **Frontend (Next.js)** - Port 3000
   - Server-side rendered React application
   - Standalone output for optimal performance
   - Optimized production builds

3. **PostgreSQL** - Port 5432
   - Primary database for UEMS
   - Version 16 with Alpine Linux
   - Automatic initialization scripts

4. **Redis** - Port 6379
   - Caching layer
   - Session storage
   - Performance optimization

5. **NextCloud** - Integrated DMS
   - Document management
   - Separate PostgreSQL database
   - Apache web server

6. **Nginx** - Ports 80, 443
   - Reverse proxy
   - SSL termination
   - Load balancing
   - Static file serving

## Configuration

### Environment Variables

Key environment variables (see `.env.example` for complete list):

```bash
# Database
POSTGRES_USER=uems_user
POSTGRES_PASSWORD=<secure_password>
POSTGRES_DB=uems_db

# Redis
REDIS_PASSWORD=<secure_password>

# JWT Secrets (generate with: openssl rand -base64 64)
JWT_SECRET=<64_char_secret>
JWT_REFRESH_SECRET=<64_char_secret>

# NextCloud
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=<secure_password>
```

### Security Best Practices

1. **Never use default passwords in production**
2. **Generate strong JWT secrets:**
   ```bash
   openssl rand -base64 64
   ```
3. **Use environment-specific .env files**
4. **Never commit .env files to version control**

## Development Deployment

### Features

- Hot-reload for backend and frontend
- Volume mounts for live code updates
- Debug logging enabled
- Development-friendly healthchecks

### Start Development Environment

```bash
# Start all services
docker-compose up -d

# Start specific service
docker-compose up -d backend

# Rebuild after dependency changes
docker-compose up -d --build backend

# View logs
docker-compose logs -f backend frontend
```

### Development Workflow

1. **Make code changes** - Changes are automatically reflected
2. **Install new dependencies** - Rebuild the service:
   ```bash
   docker-compose up -d --build backend
   ```
3. **Database migrations:**
   ```bash
   docker-compose exec backend npm run migration:run
   ```

## Production Deployment

### Build Optimization

The production Dockerfiles implement:

- **Multi-stage builds** - Smaller final images
- **Layer caching** - Faster rebuilds
- **Production dependencies only** - Reduced attack surface
- **Non-root users** - Enhanced security
- **Health checks** - Automated monitoring

### Deployment Steps

```bash
# 1. Set up production environment
cp .env.example .env.production
# Edit with production values

# 2. Build production images
docker-compose -f docker-compose.prod.yml build --no-cache

# 3. Start production stack
docker-compose -f docker-compose.prod.yml up -d

# 4. Verify all services are healthy
docker-compose -f docker-compose.prod.yml ps

# 5. Check logs
docker-compose -f docker-compose.prod.yml logs --tail=100
```

### SSL/TLS Configuration

For production HTTPS:

1. **Place SSL certificates:**
   ```bash
   mkdir -p nginx/ssl
   cp your-cert.crt nginx/ssl/
   cp your-key.key nginx/ssl/
   ```

2. **Or use Let's Encrypt with Certbot:**
   ```bash
   # Initial certificate generation
   docker-compose -f docker-compose.prod.yml run --rm certbot \
     certonly --webroot -w /var/www/certbot \
     -d yourdomain.com -d www.yourdomain.com

   # Certificates auto-renew via certbot service
   ```

## Docker Optimization Features

### 1. Dependency Installation at Build Time

All npm dependencies are installed during the Docker build process, not at runtime:

```dockerfile
# Dependencies stage
FROM base AS dependencies
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline --no-audit
```

### 2. Build Caching

Optimized layer ordering for maximum cache utilization:

```dockerfile
# Copy package files first (changes less frequently)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code later (changes more frequently)
COPY . .
```

### 3. Volume Management

Named volumes prevent node_modules conflicts:

```yaml
volumes:
  - ./backend:/app:cached
  - backend-node-modules:/app/node_modules  # Prevents host conflicts
```

### 4. Health Checks

All services include proper health checks:

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:3001/api/v1/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### 5. Resource Limits (Production)

CPU and memory limits prevent resource exhaustion:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 1G
    reservations:
      cpus: '1'
      memory: 512M
```

## Useful Commands

### General Management

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart a service
docker-compose restart backend

# View logs
docker-compose logs -f [service_name]

# Execute command in container
docker-compose exec backend sh
docker-compose exec backend npm run migration:run

# Check service status
docker-compose ps
```

### Database Management

```bash
# Backup database
docker-compose exec postgres pg_dump -U uems_user uems_db > backup.sql

# Restore database
docker-compose exec -T postgres psql -U uems_user uems_db < backup.sql

# Access PostgreSQL CLI
docker-compose exec postgres psql -U uems_user -d uems_db
```

### Redis Management

```bash
# Access Redis CLI
docker-compose exec redis redis-cli

# With password (production)
docker-compose exec redis redis-cli -a your_redis_password

# Clear cache
docker-compose exec redis redis-cli FLUSHALL
```

### Cleanup

```bash
# Remove all containers and volumes
docker-compose down -v

# Remove unused images
docker image prune -a

# Full cleanup (use with caution)
docker system prune -a --volumes
```

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker-compose logs [service_name]

# Check service status
docker-compose ps

# Restart service
docker-compose restart [service_name]
```

### Database Connection Issues

```bash
# Verify PostgreSQL is running
docker-compose ps postgres

# Check PostgreSQL logs
docker-compose logs postgres

# Test connection
docker-compose exec backend sh
> nc -zv postgres 5432
```

### Volume Permission Issues

```bash
# Fix permissions for uploads
sudo chown -R $(id -u):$(id -g) uploads logs

# Or inside container
docker-compose exec backend chown -R nestjs:nodejs /app/uploads
```

### Node Modules Conflicts

```bash
# Rebuild with fresh volumes
docker-compose down -v
docker-compose up -d --build
```

## Performance Tuning

### PostgreSQL Optimization

Edit `.env` for production:

```bash
POSTGRES_MAX_CONNECTIONS=200
POSTGRES_SHARED_BUFFERS=512MB
POSTGRES_EFFECTIVE_CACHE_SIZE=2GB
POSTGRES_WORK_MEM=16MB
POSTGRES_MAINTENANCE_WORK_MEM=128MB
```

### Redis Optimization

Production Redis configuration includes:

- Memory limit: 512MB
- LRU eviction policy
- AOF persistence for durability
- Automatic saves at intervals

### Next.js Optimization

The production build uses:

- Standalone output (minimal files)
- SWC minification
- Automatic static optimization
- Image optimization

### Nginx Optimization

Features enabled:

- Gzip compression
- Connection keep-alive
- Static file caching
- Request buffering

## Monitoring

### Health Check Endpoints

- Backend: `http://localhost:3001/api/v1/health`
- Frontend: `http://localhost:3000`
- Nginx: `http://localhost/health`

### Log Management

Logs are automatically rotated:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "50m"
    max-file: "5"
```

View logs:

```bash
# All services
docker-compose logs -f

# Specific service with tail
docker-compose logs -f --tail=100 backend

# Save logs to file
docker-compose logs > uems-logs.txt
```

## Support

For issues and questions:

1. Check this documentation
2. Review logs: `docker-compose logs`
3. Check Docker status: `docker-compose ps`
4. Verify environment variables in `.env`

## License

MIT License - See LICENSE file for details
