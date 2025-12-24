# UEMS Quick Start Guide

Get UEMS running in under 5 minutes!

## Prerequisites

- Docker 24.x+ and Docker Compose 2.x+
- 4GB RAM minimum
- 20GB disk space

## Step 1: Clone & Configure

```bash
# Clone the repository
git clone <repository-url> uems
cd uems

# Copy environment file
cp .env.example .env

# IMPORTANT: Edit .env and change these values:
# - POSTGRES_PASSWORD
# - JWT_SECRET
# - JWT_REFRESH_SECRET
# - NEXTCLOUD_ADMIN_PASSWORD
```

## Step 2: Start Services

```bash
# Start all services
docker-compose up -d

# Wait for services to be healthy (30-60 seconds)
docker-compose ps
```

## Step 3: Initialize Database

```bash
# Run migrations
docker-compose exec backend npm run migration:run

# Seed initial data
docker-compose exec backend npm run seed
```

## Step 4: Access UEMS

Open your browser and navigate to:

- **Frontend**: http://localhost
- **API Docs**: http://localhost/api/docs
- **NextCloud**: http://localhost/nextcloud

## Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@uems.com | Admin@123456 |
| HR Manager | hr@uems.com | HR@123456 |
| Sales User | sales@uems.com | Sales@123456 |

## Quick Tour

### 1. CRM Module
- Create contacts and organizations
- Manage deals in Kanban pipeline
- Log activities (calls, emails, meetings)

### 2. HRM Module
- Add employees
- Create job postings
- Track candidates through ATS pipeline
- Upload and parse CVs

### 3. Document Management
- Access NextCloud integration
- Auto-provisioned folders
- Single sign-on

## Common Commands

```bash
# View logs
docker-compose logs -f

# Restart a service
docker-compose restart backend

# Stop all services
docker-compose down

# Update and restart
git pull
docker-compose up -d --build
```

## Troubleshooting

### Services won't start
```bash
docker-compose down
docker-compose up -d
docker-compose logs -f
```

### Database connection issues
```bash
docker-compose restart postgres
docker-compose exec backend npm run migration:run
```

### Port already in use
```bash
# Change ports in .env:
NGINX_PORT=8080
FRONTEND_PORT=3001
BACKEND_PORT=3002
```

## Next Steps

1. **Read Full Documentation**: See [README.md](README.md)
2. **Configure for Production**: See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
3. **Explore API**: Visit http://localhost/api/docs
4. **Customize**: Update branding, add features

## Support

- Documentation: `/docs` folder
- Issues: GitHub Issues
- Email: support@uems.com

---

**Ready to go!** Start exploring UEMS.
