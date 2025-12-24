# UEMS Installation Guide

This guide provides step-by-step instructions for installing and configuring UEMS.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quick Installation (Docker)](#quick-installation-docker)
3. [Manual Installation](#manual-installation)
4. [Configuration](#configuration)
5. [Database Setup](#database-setup)
6. [NextCloud Configuration](#nextcloud-configuration)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- **Operating System**: Linux (Ubuntu 20.04+), macOS 11+, or Windows 10+ with WSL2
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: 20GB minimum
- **CPU**: 2 cores minimum, 4 cores recommended

### Required Software
- **Docker**: 24.x or higher ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose**: 2.x or higher ([Install Docker Compose](https://docs.docker.com/compose/install/))
- **Git**: 2.x or higher

### Optional Software
- **Node.js**: 20.x (for local development)
- **PostgreSQL Client**: 16.x (for database management)

## Quick Installation (Docker)

### Step 1: Clone the Repository

```bash
git clone <repository-url> uems
cd uems
```

### Step 2: Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` file and update the following critical variables:

```env
# Change these in production!
POSTGRES_PASSWORD=your_secure_database_password
JWT_SECRET=your_super_secret_jwt_key_min_32_chars
JWT_REFRESH_SECRET=your_super_secret_refresh_jwt_key_min_32_chars
NEXTCLOUD_ADMIN_PASSWORD=your_nextcloud_admin_password
```

### Step 3: Start the Application

```bash
docker-compose up -d
```

This command will:
- Download all required Docker images
- Create and start all containers (backend, frontend, databases, NextCloud, Nginx)
- Initialize the databases
- Set up networking

### Step 4: Wait for Services to Start

```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

Wait until all services show as "healthy".

### Step 5: Run Database Migrations and Seeds

```bash
# Run migrations
docker-compose exec backend npm run migration:run

# Seed initial data
docker-compose exec backend npm run seed
```

### Step 6: Access the Application

- **Frontend**: http://localhost
- **API Docs**: http://localhost/api/docs
- **NextCloud**: http://localhost/nextcloud
- **Backend Health**: http://localhost/api/v1/health

### Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@uems.com | Admin@123456 |
| HR Manager | hr@uems.com | HR@123456 |
| Sales User | sales@uems.com | Sales@123456 |

**⚠️ Change these passwords immediately in production!**

## Manual Installation

### Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your database credentials

# Run migrations
npm run migration:run

# Seed database
npm run seed

# Start development server
npm run start:dev
```

Backend will be available at `http://localhost:3001`

### Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Configure environment
echo "NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1" > .env.local

# Start development server
npm run dev
```

Frontend will be available at `http://localhost:3000`

### PostgreSQL Setup

```bash
# Install PostgreSQL 16
sudo apt-get update
sudo apt-get install postgresql-16

# Create database and user
sudo -u postgres psql
CREATE DATABASE uems_db;
CREATE USER uems_user WITH ENCRYPTED PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE uems_db TO uems_user;
\q
```

### NextCloud Setup

See [NEXTCLOUD_INTEGRATION.md](NEXTCLOUD_INTEGRATION.md) for detailed NextCloud installation and configuration.

## Configuration

### Environment Variables

#### Backend (.env)

```env
# Application
NODE_ENV=development
BACKEND_PORT=3001

# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=uems_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=uems_db

# JWT
JWT_SECRET=your_jwt_secret
JWT_EXPIRATION=15m
JWT_REFRESH_SECRET=your_refresh_secret
JWT_REFRESH_EXPIRATION=7d

# NextCloud
NEXTCLOUD_URL=http://localhost:8080
NEXTCLOUD_ADMIN_USER=admin
NEXTCLOUD_ADMIN_PASSWORD=admin_password

# Security
BCRYPT_ROUNDS=12
CORS_ORIGIN=http://localhost:3000

# File Upload
MAX_FILE_SIZE=10485760
UPLOAD_DIR=./uploads
```

#### Frontend (.env.local)

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
NEXT_PUBLIC_NEXTCLOUD_URL=http://localhost:8080
```

### Nginx Configuration

For production deployments, configure SSL/TLS:

```nginx
# /etc/nginx/conf.d/uems.conf
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # ... rest of configuration
}
```

## Database Setup

### Creating Migrations

```bash
cd backend

# Generate a new migration
npm run typeorm migration:generate -- src/database/migrations/MigrationName

# Run migrations
npm run migration:run

# Revert last migration
npm run migration:revert
```

### Backup and Restore

#### Backup

```bash
# Using Docker
docker-compose exec postgres pg_dump -U uems_user uems_db > backup.sql

# Direct PostgreSQL
pg_dump -U uems_user -h localhost uems_db > backup.sql
```

#### Restore

```bash
# Using Docker
docker-compose exec -T postgres psql -U uems_user uems_db < backup.sql

# Direct PostgreSQL
psql -U uems_user -h localhost uems_db < backup.sql
```

## NextCloud Configuration

### Initial Setup

1. Access NextCloud at `http://localhost/nextcloud`
2. Login with admin credentials from `.env`
3. Complete the setup wizard
4. Enable required apps:
   - External storage support
   - WebDAV

### Trusted Domains

Add your domain to NextCloud's trusted domains:

```bash
docker-compose exec nextcloud php occ config:system:set trusted_domains 1 --value=your-domain.com
```

### SMTP Configuration

Configure email notifications in NextCloud:

```bash
docker-compose exec nextcloud php occ config:system:set mail_smtpmode --value=smtp
docker-compose exec nextcloud php occ config:system:set mail_smtphost --value=smtp.gmail.com
docker-compose exec nextcloud php occ config:system:set mail_smtpport --value=587
```

## Troubleshooting

### Common Issues

#### Containers Won't Start

```bash
# Check logs
docker-compose logs

# Restart specific service
docker-compose restart backend

# Clean restart
docker-compose down
docker-compose up -d
```

#### Database Connection Errors

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Test connection
docker-compose exec backend npx typeorm-ts-node-commonjs -d src/config/typeorm.config.ts
```

#### Port Already in Use

```bash
# Find process using port 80
sudo lsof -i :80

# Kill the process or change NGINX_PORT in .env
```

#### NextCloud Not Accessible

```bash
# Check NextCloud logs
docker-compose logs nextcloud

# Verify trusted domains
docker-compose exec nextcloud php occ config:system:get trusted_domains
```

### Performance Issues

#### Slow API Responses

1. Check database indexes
2. Review database query logs
3. Increase PostgreSQL memory settings
4. Enable Redis caching

#### High Memory Usage

```bash
# Check resource usage
docker stats

# Adjust resource limits in docker-compose.prod.yml
```

### Getting Help

1. Check logs: `docker-compose logs -f`
2. Review [FAQ](FAQ.md)
3. Search [GitHub Issues](issues-url)
4. Contact support: support@uems.com

## Post-Installation

### Security Checklist

- [ ] Change all default passwords
- [ ] Configure SSL/TLS certificates
- [ ] Set up firewall rules
- [ ] Enable automated backups
- [ ] Configure monitoring
- [ ] Review and restrict CORS origins
- [ ] Set up log rotation
- [ ] Configure rate limiting

### Next Steps

1. Read the [User Guide](USER_GUIDE.md)
2. Review [API Documentation](API_DOCUMENTATION.md)
3. Set up automated backups
4. Configure monitoring and alerts
5. Train your team

## Updating UEMS

```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker-compose build

# Restart services
docker-compose down
docker-compose up -d

# Run new migrations
docker-compose exec backend npm run migration:run
```

---

**Need help?** See [Troubleshooting](#troubleshooting) or contact support.
