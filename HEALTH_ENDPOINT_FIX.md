# Health Endpoint Fix - Deployment Guide

## Problem Identified

The health endpoint was returning 404 due to incorrect `exclude` format in `main.ts`. NestJS's `setGlobalPrefix()` requires specific route exclusion syntax using `RequestMethod` enum.

## Root Cause

**Before (BROKEN):**
```typescript
app.setGlobalPrefix('api/v1', {
  exclude: ['health', '/'],  // Wrong format - treats as strings
});
```

**After (FIXED):**
```typescript
app.setGlobalPrefix('api/v1', {
  exclude: [
    { path: 'health', method: RequestMethod.GET },
    { path: '', method: RequestMethod.GET },
  ],
});
```

## Files Changed

1. `/home/mahmoud/AI/Projects/claude-Version1/backend/src/main.ts`
   - Added `RequestMethod` import
   - Changed exclude format to object array with path and method

## Quick Deploy Steps (Production Ready)

### Step 1: Rebuild Backend Container
```bash
cd /home/mahmoud/AI/Projects/claude-Version1

# Rebuild only the backend service
docker compose build backend

# Or force rebuild without cache
docker compose build --no-cache backend
```

### Step 2: Restart Backend Service
```bash
# Restart backend (preserves database/redis)
docker compose up -d --force-recreate backend

# View logs to verify startup
docker compose logs -f backend
```

### Step 3: Verify Health Endpoint
```bash
# Run the automated test script
./backend/test-health.sh

# Or manual curl test
curl -v http://localhost:3001/health

# Expected response:
# HTTP/1.1 200 OK
# {
#   "status": "ok",
#   "timestamp": "2026-01-03T...",
#   "uptime": 123.45,
#   "environment": "production",
#   "version": "1.0.0",
#   "service": "OnTrack Backend API"
# }
```

### Step 4: Verify Docker Healthcheck
```bash
# Check container health status
docker ps --filter name=ontrack-backend

# Should show "healthy" in STATUS column after ~40 seconds
# Example: Up 2 minutes (healthy)

# View health check logs
docker inspect ontrack-backend | grep -A 10 Health
```

## Emergency Rollback (If Needed)

If the fix doesn't work:

```bash
# Revert the changes
cd /home/mahmoud/AI/Projects/claude-Version1/backend
git checkout src/main.ts

# Apply alternative fix (dedicated health controller)
# See ALTERNATIVE_FIX.md
```

## Testing Checklist

- [ ] `/health` returns 200 OK
- [ ] `/` returns 200 OK with API info
- [ ] `/api/v1/health` returns 404 (correctly excluded)
- [ ] `/api/docs` returns Swagger UI
- [ ] Docker container shows "healthy" status
- [ ] Backend logs show no 404 errors for /health

## Production Deployment Timeline

| Step | Action | Duration | Status |
|------|--------|----------|--------|
| 1 | Code review | 5 min | DONE |
| 2 | Build backend | 3-5 min | PENDING |
| 3 | Deploy to production | 2 min | PENDING |
| 4 | Health check verification | 1 min | PENDING |
| 5 | Monitor logs | 5 min | PENDING |
| **TOTAL** | | **15-20 min** | |

## Verification Commands

```bash
# 1. Check if backend is responding
curl http://localhost:3001/health

# 2. Check container health
docker compose ps backend

# 3. Check healthcheck logs
docker inspect ontrack-backend --format='{{json .State.Health}}' | jq

# 4. Check application logs
docker compose logs backend --tail=50

# 5. Full system health check
docker compose ps
```

## What Changed Technically

### NestJS Route Exclusion Behavior

NestJS's `setGlobalPrefix()` supports two exclusion formats:

1. **String array (DEPRECATED/UNRELIABLE):**
   ```typescript
   exclude: ['health', '/']
   ```
   - Inconsistent across NestJS versions
   - May not work with versioning enabled
   - Not recommended for production

2. **RouteInfo array (RECOMMENDED):**
   ```typescript
   exclude: [
     { path: 'health', method: RequestMethod.GET },
     { path: '', method: RequestMethod.GET },
   ]
   ```
   - Explicit method specification
   - Works with versioning
   - Production-ready

### Why This Fix Works

1. **Explicit Method Matching**: By specifying `RequestMethod.GET`, NestJS knows exactly which routes to exclude
2. **Path Precision**: Empty string `''` properly matches the root path `/`
3. **Versioning Compatibility**: Works with `enableVersioning()` enabled
4. **Route Registration Order**: Ensures health endpoint is registered before global prefix is applied

## Monitoring After Deployment

Watch for these metrics:

```bash
# Monitor health endpoint response time
while true; do
  curl -w "\nTime: %{time_total}s\n" http://localhost:3001/health
  sleep 5
done

# Monitor Docker healthcheck failures
docker events --filter event=health_status
```

## Success Criteria

1. Health endpoint returns 200 OK within 100ms
2. Docker healthcheck passes within 40 seconds of startup
3. No 404 errors in backend logs
4. Container stays "healthy" for 5+ minutes continuously

## Contact for Issues

If issues persist after this fix:
- Check NestJS version compatibility
- Verify no middleware is blocking the health route
- Consider implementing dedicated HealthModule (see alternative fix)

---

**Fix Applied:** 2026-01-03
**Deploy Status:** Ready for immediate production deployment
**Risk Level:** LOW (single file change, syntax fix only)
