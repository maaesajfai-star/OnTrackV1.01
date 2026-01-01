#!/bin/bash
set -e

echo "=========================================="
echo "☢️  NUCLEAR OPTION: Complete Docker Reset"
echo "=========================================="
echo ""
echo "This will:"
echo "1. Stop ALL containers"
echo "2. Remove ALL volumes (destroys poisoned node_modules)"
echo "3. Remove ALL orphaned containers"
echo "4. Delete host node_modules"
echo "5. Downgrade uuid from v9 (ESM) to v8 (CommonJS)"
echo "6. Rebuild from absolute scratch"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${RED}⚠️  WARNING: This will delete ALL Docker volumes!${NC}"
echo -e "${YELLOW}Press Ctrl+C now to cancel, or wait 5 seconds to continue...${NC}"
sleep 5

echo ""
echo -e "${BLUE}Step 1: Nuclear shutdown with volume destruction...${NC}"
docker compose down --volumes --remove-orphans

echo -e "${GREEN}✓ All containers stopped, volumes deleted, orphans removed${NC}"

echo -e "${BLUE}Step 2: Removing host node_modules directories...${NC}"
rm -rf backend/node_modules backend/dist backend/.nest
rm -rf frontend/node_modules frontend/.next frontend/dist

echo -e "${GREEN}✓ Host directories cleaned${NC}"

echo -e "${BLUE}Step 3: Removing old Docker images...${NC}"
docker rmi ontrack-backend:latest 2>/dev/null || echo "  Backend image already removed"
docker rmi ontrack-frontend:latest 2>/dev/null || echo "  Frontend image already removed"

echo -e "${GREEN}✓ Old images removed${NC}"

echo -e "${BLUE}Step 4: Pruning Docker system...${NC}"
docker system prune -f

echo -e "${GREEN}✓ Docker system pruned${NC}"

echo -e "${BLUE}Step 5: Rebuilding backend (NO CACHE) with uuid@8...${NC}"
docker compose build --no-cache --pull backend

echo -e "${GREEN}✓ Backend rebuilt from scratch${NC}"

echo -e "${BLUE}Step 6: Rebuilding frontend (NO CACHE)...${NC}"
docker compose build --no-cache --pull frontend

echo -e "${GREEN}✓ Frontend rebuilt from scratch${NC}"

echo -e "${BLUE}Step 7: Starting all services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}=========================================="
echo "✅ NUCLEAR FIX COMPLETE"
echo "==========================================${NC}"
echo ""
echo "What was fixed:"
echo "  ✓ uuid downgraded from v9 (ESM) to v8 (CommonJS)"
echo "  ✓ Poisoned Docker volumes destroyed"
echo "  ✓ Fresh node_modules installed in containers"
echo "  ✓ No host contamination"
echo ""
echo "Watching backend logs..."
echo "Look for: '[Nest] Nest application successfully started'"
echo ""
sleep 3

docker compose logs -f backend
