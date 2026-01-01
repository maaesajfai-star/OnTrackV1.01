#!/bin/bash
set -e

echo "=========================================="
echo "🔧 CRITICAL FIX: Binary Incompatibility"
echo "=========================================="
echo ""
echo "Root Cause: Host node_modules (compiled for your OS) are being"
echo "mounted into Linux container, causing binary incompatibility."
echo ""
echo "Solution: Remove ALL host node_modules and rebuild cleanly."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Step 1: Stopping all containers...${NC}"
docker compose down

echo -e "${YELLOW}Step 2: Removing ALL Docker volumes (including node_modules)...${NC}"
docker compose down -v

echo -e "${YELLOW}Step 3: Removing host node_modules directories...${NC}"
echo "  Removing backend/node_modules..."
rm -rf backend/node_modules

echo "  Removing frontend/node_modules..."
rm -rf frontend/node_modules

echo -e "${GREEN}✓ Host node_modules removed${NC}"

echo -e "${YELLOW}Step 4: Removing Docker images to force clean rebuild...${NC}"
docker rmi ontrack-backend:latest 2>/dev/null || echo "  Backend image not found (OK)"
docker rmi ontrack-frontend:latest 2>/dev/null || echo "  Frontend image not found (OK)"

echo -e "${YELLOW}Step 5: Building backend with NO CACHE...${NC}"
docker compose build --no-cache backend

echo -e "${YELLOW}Step 6: Building frontend with NO CACHE...${NC}"
docker compose build --no-cache frontend

echo -e "${YELLOW}Step 7: Starting all services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}=========================================="
echo "✓ Rebuild Complete!"
echo "==========================================${NC}"
echo ""
echo "Watching backend logs (Ctrl+C to exit)..."
echo "Look for: '[Nest] Nest application successfully started'"
echo ""
sleep 3

docker compose logs -f backend
