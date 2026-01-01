#!/bin/bash
set -e

echo "=========================================="
echo "🔧 COMPLETE FIX - OnTrack Deployment"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Pull latest code from GitHub"
echo "2. Ensure line endings are correct"
echo "3. Destroy all volumes and containers"
echo "4. Clean host directories"
echo "5. Rebuild from scratch with uuid@8"
echo "6. Start all services"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Step 1: Pulling latest code...${NC}"
git pull origin main

echo -e "${BLUE}Step 2: Fixing line endings...${NC}"
dos2unix backend/docker-entrypoint.sh 2>/dev/null || sed -i 's/\r$//' backend/docker-entrypoint.sh
chmod +x backend/docker-entrypoint.sh

echo -e "${GREEN}✓ Line endings fixed${NC}"

echo -e "${BLUE}Step 3: Stopping and removing everything...${NC}"
docker compose down --volumes --remove-orphans

echo -e "${GREEN}✓ Containers and volumes removed${NC}"

echo -e "${BLUE}Step 4: Cleaning host directories...${NC}"
rm -rf backend/node_modules backend/dist backend/.nest
rm -rf frontend/node_modules frontend/.next frontend/dist

echo -e "${GREEN}✓ Host directories cleaned${NC}"

echo -e "${BLUE}Step 5: Removing old images...${NC}"
docker rmi ontrack-backend:latest 2>/dev/null || true
docker rmi ontrack-frontend:latest 2>/dev/null || true

echo -e "${GREEN}✓ Old images removed${NC}"

echo -e "${BLUE}Step 6: Building backend (NO CACHE)...${NC}"
docker compose build --no-cache --pull backend

echo -e "${GREEN}✓ Backend built successfully${NC}"

echo -e "${BLUE}Step 7: Building frontend (NO CACHE)...${NC}"
docker compose build --no-cache --pull frontend

echo -e "${GREEN}✓ Frontend built successfully${NC}"

echo -e "${BLUE}Step 8: Starting all services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}=========================================="
echo "✅ DEPLOYMENT COMPLETE"
echo "==========================================${NC}"
echo ""
echo "Services started:"
echo "  🗄️  PostgreSQL: postgres:5432"
echo "  🗄️  NextCloud DB: nextcloud-db:5432"
echo "  💾 Redis: redis:6379"
echo "  ☁️  NextCloud: http://localhost/nextcloud"
echo "  🔧 Backend API: http://localhost:3001"
echo "  🌐 Frontend: http://localhost:3000"
echo "  🔀 Nginx: http://localhost:80"
echo ""
echo "Checking backend startup..."
sleep 5
docker compose logs backend --tail=50
echo ""
echo -e "${YELLOW}Watching backend logs (Ctrl+C to exit)...${NC}"
docker compose logs -f backend
