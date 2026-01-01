# UEMS Troubleshooting Guide

## TypeORM SyntaxError Fix (December 2025)

### Problem
Backend container fails with:
```
ERROR [TypeOrmModule] Unable to connect to the database. Retrying (4)...
SyntaxError: Invalid or unexpected token
```

### Root Cause
The error was caused by a combination of issues:
1. **Synchronize + Migrations Conflict**: TypeORM was configured with `synchronize: true` in development mode while also trying to run manual migrations, causing conflicts
2. **File Loading Issues**: TypeORM's ts-node loader was attempting to process files during both migration and synchronization phases
3. **Race Conditions**: The docker-entrypoint script had minimal error handling

### Solution Applied

#### 1. Fixed TypeORM Configuration
**File**: `backend/src/config/typeorm.config.ts`
- Disabled `synchronize` mode (set to `false`)
- Added `migrationsRun: false` to prevent automatic migration execution
- Improved logging configuration for better debugging

#### 2. Enhanced Docker Entrypoint
**File**: `backend/docker-entrypoint.sh`
- Added retry logic with maximum attempt counter
- Added `pg_isready` check before running migrations
- Improved error handling and logging
- Better separation of concerns

#### 3. Fixed File Permissions
- Changed migration file permissions from `600` to `644`

### How to Apply the Fix

1. **Stop all containers**:
   ```bash
   cd /home/mahmoud/AI/Projects/claude-Version1
   docker compose down
   ```

2. **Clean up volumes (OPTIONAL - only if you want fresh start)**:
   ```bash
   docker volume rm uems-postgres-data
   docker volume rm uems-backend-node-modules
   ```

3. **Rebuild and start**:
   ```bash
   docker compose up --build -d
   ```

4. **Monitor logs**:
   ```bash
   # Watch all services
   docker compose logs -f

   # Watch only backend
   docker compose logs -f backend

   # Watch only postgres
   docker compose logs -f postgres
   ```

### Verification Steps

1. **Check container status**:
   ```bash
   docker compose ps
   ```
   All services should show "Up" status and backend should be "healthy"

2. **Check backend health**:
   ```bash
   curl http://localhost:3001/api/v1/health
   ```
   Should return health status

3. **Check Swagger docs**:
   ```bash
   curl http://localhost:3001/api/docs
   ```

4. **Verify database connection**:
   ```bash
   docker compose exec backend npm run typeorm -- query "SELECT 1"
   ```

5. **Test admin login**:
   ```bash
   curl -X POST http://localhost/api/v1/auth/login \
     -H "Content-Type: application/json" \
     -d '{"username":"Admin","password":"AdminAdmin@123"}'
   ```

### Common Issues After Fix

#### Backend Still Not Starting
**Check**:
```bash
docker compose logs backend | tail -50
```

**Possible causes**:
- PostgreSQL not ready: Wait 30-60 seconds after starting
- Port 3001 already in use: `lsof -i :3001` and kill the process
- Volume permission issues: `docker compose down -v` and restart

#### Migration Errors
**Check migration status**:
```bash
docker compose exec backend npm run typeorm -- migration:show
```

**Revert last migration**:
```bash
docker compose exec backend npm run migration:revert
```

**Run migrations manually**:
```bash
docker compose exec backend npm run migration:run
```

#### Database Connection Refused
**Check PostgreSQL**:
```bash
docker compose exec postgres pg_isready -U uems_user -d uems_db
```

**Reset PostgreSQL**:
```bash
docker compose stop postgres
docker volume rm uems-postgres-data
docker compose up -d postgres
# Wait 30 seconds
docker compose up -d backend
```

### Admin Credentials

After successful startup:
- **Username**: `Admin`
- **Password**: `AdminAdmin@123`
- **Email**: `admin@uems.local`

### Development Mode Notes

- The backend runs in watch mode using `nest start --watch`
- TypeScript is compiled on-the-fly using ts-node
- Source code is mounted as a volume for hot-reload
- Migrations must be run manually via `npm run migration:run`
- Schema changes require creating migrations, not relying on synchronize

### Creating New Migrations

```bash
# Generate migration from entity changes
docker compose exec backend npm run migration:generate -- src/database/migrations/MigrationName

# Create empty migration
docker compose exec backend npm run migration:create -- src/database/migrations/MigrationName

# Run migrations
docker compose exec backend npm run migration:run

# Revert last migration
docker compose exec backend npm run migration:revert
```

### Quick Reset Script

```bash
#!/bin/bash
# File: reset-uems.sh

cd /home/mahmoud/AI/Projects/claude-Version1

echo "Stopping all containers..."
docker compose down

echo "Removing backend volume..."
docker volume rm uems-backend-node-modules 2>/dev/null || true

echo "Rebuilding and starting..."
docker compose up --build -d

echo "Waiting for services to be ready..."
sleep 30

echo "Checking status..."
docker compose ps

echo "Checking backend logs..."
docker compose logs backend | tail -20

echo "Testing health endpoint..."
curl -f http://localhost:3001/api/v1/health && echo " - OK" || echo " - FAILED"

echo "Done!"
```

### Contact

For issues, check:
1. Docker logs: `docker compose logs -f`
2. Backend logs: `docker compose exec backend ls -la logs/`
3. Database status: `docker compose exec postgres psql -U uems_user -d uems_db -c "SELECT version();"`
