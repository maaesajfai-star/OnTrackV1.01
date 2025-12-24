# UEMS Command Reference Guide

Quick reference for all UEMS commands and operations.

## 📋 Table of Contents

1. [Docker Commands](#docker-commands)
2. [Database Commands](#database-commands)
3. [Development Commands](#development-commands)
4. [Testing Commands](#testing-commands)
5. [Deployment Commands](#deployment-commands)
6. [Maintenance Commands](#maintenance-commands)
7. [Troubleshooting Commands](#troubleshooting-commands)

---

## Docker Commands

### Start Services

```bash
# Development environment
docker-compose up -d

# Production environment
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# Start with build
docker-compose up -d --build

# Start specific service
docker-compose up -d backend
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ DESTROYS DATA)
docker-compose down -v

# Stop specific service
docker-compose stop backend
```

### View Status

```bash
# List running containers
docker-compose ps

# View container stats (CPU, Memory)
docker stats

# Check health status
docker-compose ps | grep healthy
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend

# Last 100 lines
docker-compose logs --tail=100 backend

# Since specific time
docker-compose logs --since 30m backend
```

### Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart backend

# Restart with rebuild
docker-compose up -d --build --force-recreate backend
```

### Execute Commands in Container

```bash
# Backend shell
docker-compose exec backend sh

# Frontend shell
docker-compose exec frontend sh

# PostgreSQL shell
docker-compose exec postgres psql -U uems_user uems_db

# Run npm command
docker-compose exec backend npm run <command>
```

---

## Database Commands

### Migrations

```bash
# Run migrations
docker-compose exec backend npm run migration:run

# Revert last migration
docker-compose exec backend npm run migration:revert

# Generate new migration
docker-compose exec backend npm run migration:generate -- src/database/migrations/MigrationName

# Show migrations status
docker-compose exec backend npm run typeorm migration:show
```

### Seed Data

```bash
# Run seed script
docker-compose exec backend npm run seed

# Seed with custom data (if implemented)
docker-compose exec backend npm run seed:custom
```

### Database Access

```bash
# Access PostgreSQL CLI
docker-compose exec postgres psql -U uems_user uems_db

# Run SQL query
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT * FROM users;"

# List databases
docker-compose exec postgres psql -U uems_user -c "\l"

# List tables
docker-compose exec postgres psql -U uems_user uems_db -c "\dt"

# Describe table
docker-compose exec postgres psql -U uems_user uems_db -c "\d users"
```

### Backup & Restore

```bash
# Backup database
docker-compose exec postgres pg_dump -U uems_user uems_db > backup_$(date +%Y%m%d).sql

# Restore database
cat backup.sql | docker-compose exec -T postgres psql -U uems_user uems_db

# Backup with Docker
docker-compose exec -T postgres pg_dump -U uems_user uems_db > backup.sql

# Backup all databases
docker-compose exec postgres pg_dumpall -U uems_user > backup_all.sql
```

---

## Development Commands

### Backend Development

```bash
# Start backend in dev mode (local)
cd backend
npm install
npm run start:dev

# Start in debug mode
npm run start:debug

# Format code
npm run format

# Lint code
npm run lint

# Build for production
npm run build

# Start production build
npm run start:prod
```

### Frontend Development

```bash
# Start frontend in dev mode (local)
cd frontend
npm install
npm run dev

# Build for production
npm run build

# Start production server
npm run start

# Type check
npm run type-check

# Lint
npm run lint
```

### Code Quality

```bash
# Backend linting
cd backend && npm run lint

# Frontend linting
cd frontend && npm run lint

# Format code (Prettier)
cd backend && npm run format
cd frontend && npm run format

# Type checking
cd backend && npx tsc --noEmit
cd frontend && npm run type-check
```

---

## Testing Commands

### Backend Tests

```bash
# Run all tests
docker-compose exec backend npm run test

# Run tests in watch mode
docker-compose exec backend npm run test:watch

# Run E2E tests
docker-compose exec backend npm run test:e2e

# Run tests with coverage
docker-compose exec backend npm run test:cov

# Run specific test file
docker-compose exec backend npm run test -- users.service.spec.ts
```

### Frontend Tests

```bash
# Run tests (when implemented)
docker-compose exec frontend npm run test

# Run tests in watch mode
docker-compose exec frontend npm run test:watch

# E2E tests with Playwright (when implemented)
docker-compose exec frontend npm run test:e2e
```

### Health Checks

```bash
# Check backend health
curl http://localhost/api/v1/health

# Check all services
curl http://localhost/health

# Check NextCloud status
curl http://localhost/nextcloud/status.php

# Check database connectivity
docker-compose exec backend npx typeorm query "SELECT 1"
```

---

## Deployment Commands

### Build for Production

```bash
# Build all images
docker-compose -f docker-compose.prod.yml build

# Build specific service
docker-compose -f docker-compose.prod.yml build backend

# Build with no cache
docker-compose -f docker-compose.prod.yml build --no-cache
```

### Deploy to Production

```bash
# Deploy with production compose
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d

# Deploy with zero downtime
docker-compose -f docker-compose.prod.yml up -d --no-deps --build backend
docker-compose -f docker-compose.prod.yml up -d --no-deps --build frontend

# Scale backend
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

### Update Production

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
docker-compose -f docker-compose.prod.yml exec backend npm run migration:run
```

---

## Maintenance Commands

### Clean Up

```bash
# Remove stopped containers
docker-compose rm -f

# Remove unused images
docker image prune -a

# Remove unused volumes (⚠️ DESTROYS DATA)
docker volume prune

# Remove all unused data
docker system prune -a --volumes

# Clean build cache
docker builder prune
```

### View Resource Usage

```bash
# Container stats
docker stats

# Disk usage
docker system df

# Volume sizes
docker volume ls -q | xargs docker volume inspect | grep -A 1 Mountpoint

# Image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

### Logs Management

```bash
# View log size
docker-compose logs backend 2>/dev/null | wc -l

# Clear logs (⚠️ Be careful)
truncate -s 0 $(docker inspect --format='{{.LogPath}}' uems-backend)

# View Docker daemon logs
journalctl -u docker.service

# Rotate logs manually
docker-compose restart
```

---

## Troubleshooting Commands

### Debug Container Issues

```bash
# Inspect container
docker-compose exec backend ps aux

# Check container logs
docker-compose logs --tail=100 backend

# View container config
docker inspect uems-backend

# Network troubleshooting
docker network ls
docker network inspect uems-network

# Volume troubleshooting
docker volume ls
docker volume inspect uems-postgres-data
```

### Database Troubleshooting

```bash
# Check database connections
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT count(*) FROM pg_stat_activity;"

# Check database size
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT pg_size_pretty(pg_database_size('uems_db'));"

# Terminate idle connections
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'idle';"

# Vacuum database
docker-compose exec postgres psql -U uems_user uems_db -c "VACUUM ANALYZE;"
```

### NextCloud Troubleshooting

```bash
# NextCloud OCC commands
docker-compose exec nextcloud php occ

# Check NextCloud status
docker-compose exec nextcloud php occ status

# List NextCloud users
docker-compose exec nextcloud php occ user:list

# Repair NextCloud
docker-compose exec nextcloud php occ maintenance:repair

# Update trusted domains
docker-compose exec nextcloud php occ config:system:set trusted_domains 1 --value=yourdomain.com
```

### Network Debugging

```bash
# Test connectivity between containers
docker-compose exec backend ping postgres

# Test external connectivity
docker-compose exec backend ping -c 3 google.com

# View network configuration
docker network inspect uems-network

# DNS resolution
docker-compose exec backend nslookup postgres
```

### Performance Debugging

```bash
# Check slow queries (PostgreSQL)
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT query, mean_exec_time FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;"

# Monitor real-time database activity
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT * FROM pg_stat_activity WHERE state = 'active';"

# Check table sizes
docker-compose exec postgres psql -U uems_user uems_db -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"
```

---

## Useful One-Liners

```bash
# Quick restart all services
docker-compose restart && docker-compose logs -f

# Check if all services are healthy
docker-compose ps | grep -c "Up (healthy)"

# View all environment variables
docker-compose exec backend env

# Quick database connection test
docker-compose exec backend npm run typeorm query "SELECT NOW()"

# Count API requests (from logs)
docker-compose logs backend | grep "GET\|POST\|PATCH\|DELETE" | wc -l

# Find large log files
docker ps -q | xargs -I {} docker inspect --format='{{.LogPath}} {{.Name}}' {} | xargs ls -lh

# Export all database tables
docker-compose exec postgres pg_dump -U uems_user uems_db --format=plain > full_backup.sql

# Quick health check all services
for service in frontend backend postgres nextcloud; do echo -n "$service: "; docker-compose ps $service | grep -q "Up" && echo "✓" || echo "✗"; done
```

---

## Emergency Commands

### Emergency Stop

```bash
# Force stop all containers
docker-compose kill

# Force remove all containers
docker-compose rm -f

# Nuclear option: remove everything
docker-compose down -v
docker system prune -a --volumes -f
```

### Emergency Restore

```bash
# Restore from backup
docker-compose down
docker volume rm uems-postgres-data
docker-compose up -d postgres
sleep 10
cat backup.sql | docker-compose exec -T postgres psql -U uems_user uems_db
docker-compose up -d
```

### Emergency Rollback

```bash
# Rollback to previous version
git log --oneline | head -5
git checkout <previous-commit-hash>
docker-compose down
docker-compose up -d --build
```

---

## Environment Variables Quick Reference

```bash
# View current configuration
docker-compose config

# Validate compose file
docker-compose config --quiet

# View specific service config
docker-compose config --services

# Print resolved environment
docker-compose exec backend printenv | grep -E "POSTGRES|JWT|NEXTCLOUD"
```

---

## Quick Command Aliases (Optional)

Add to your `.bashrc` or `.zshrc`:

```bash
# UEMS aliases
alias uems-up='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose up -d'
alias uems-down='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose down'
alias uems-logs='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose logs -f'
alias uems-ps='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose ps'
alias uems-restart='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose restart'
alias uems-migrate='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose exec backend npm run migration:run'
alias uems-seed='cd /home/mahmoud/AI/Projects/claude-Version1 && docker-compose exec backend npm run seed'
alias uems-health='curl -s http://localhost/api/v1/health | jq'
```

---

**For more details, see**:
- [Installation Guide](docs/INSTALLATION.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Troubleshooting Guide](docs/INSTALLATION.md#troubleshooting)
