# UEMS Quick Start Guide

## Restart the System

```bash
cd /home/mahmoud/AI/Projects/claude-Version1
./restart-uems.sh
```

## Check Status

```bash
cd /home/mahmoud/AI/Projects/claude-Version1
docker compose ps
```

## View Logs

```bash
# All services
docker compose logs -f

# Backend only
docker compose logs -f backend

# PostgreSQL only
docker compose logs -f postgres
```

## Run Diagnostics

```bash
cd /home/mahmoud/AI/Projects/claude-Version1
./diagnose-uems.sh
```

## Access Points

| Service | URL |
|---------|-----|
| Main Site | http://localhost |
| Backend API | http://localhost:3001/api/v1 |
| API Docs | http://localhost:3001/api/docs |
| Frontend | http://localhost:3000 |

## Admin Login

- Username: `Admin`
- Password: `AdminAdmin@123`

## Common Commands

```bash
# Stop all
docker compose down

# Start all
docker compose up -d

# Rebuild backend
docker compose up -d --build backend

# View backend logs
docker compose logs -f backend

# Access database
docker compose exec postgres psql -U uems_user -d uems_db

# Run migrations
docker compose exec backend npm run migration:run

# Check migration status
docker compose exec backend npm run typeorm -- migration:show
```

## Troubleshooting

1. **Backend won't start**: Check logs with `docker compose logs backend`
2. **Database connection error**: Verify PostgreSQL is running with `docker compose ps postgres`
3. **Port already in use**: Find and kill the process using the port
4. **Complete reset needed**: Run `docker compose down -v && docker compose up --build -d`

## Files Overview

| File | Purpose |
|------|---------|
| `restart-uems.sh` | Automated restart and verification |
| `diagnose-uems.sh` | Collect diagnostic information |
| `FIX-SUMMARY.md` | Complete documentation of the fix |
| `TROUBLESHOOTING.md` | Detailed troubleshooting guide |
| `docker-compose.yml` | Container orchestration |
| `.env` | Environment configuration |

## Key Changes Made

1. Disabled TypeORM `synchronize` mode
2. Enhanced docker-entrypoint.sh with retry logic
3. Fixed migration file permissions
4. Added comprehensive scripts and documentation

For detailed information, see `FIX-SUMMARY.md` and `TROUBLESHOOTING.md`.
