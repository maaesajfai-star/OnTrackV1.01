#!/bin/bash
# Quick deployment script for health endpoint fix
# Execute this to deploy the fix to production

set -e  # Exit on any error

echo "========================================"
echo "Health Endpoint Fix - Deployment"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_DIR="/home/mahmoud/AI/Projects/claude-Version1"
cd "$PROJECT_DIR"

echo -e "${BLUE}Step 1: Building backend container...${NC}"
docker compose build backend
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}Step 2: Stopping old backend container...${NC}"
docker compose stop backend
echo -e "${GREEN}Backend stopped${NC}"
echo ""

echo -e "${BLUE}Step 3: Starting new backend container...${NC}"
docker compose up -d backend
echo -e "${GREEN}Backend started${NC}"
echo ""

echo -e "${BLUE}Step 4: Waiting for backend to be ready (max 60s)...${NC}"
MAX_WAIT=60
ELAPSED=0
while [ $ELAPSED -lt $MAX_WAIT ]; do
    if curl -s http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}Backend is responding!${NC}"
        break
    fi
    echo -n "."
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done
echo ""

if [ $ELAPSED -ge $MAX_WAIT ]; then
    echo -e "${RED}Backend did not start within ${MAX_WAIT}s${NC}"
    echo "Showing logs:"
    docker compose logs --tail=50 backend
    exit 1
fi

echo ""
echo -e "${BLUE}Step 5: Testing health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:3001/health)
HEALTH_CODE=$(echo "$HEALTH_RESPONSE" | tail -n 1)
HEALTH_BODY=$(echo "$HEALTH_RESPONSE" | head -n -1)

if [ "$HEALTH_CODE" = "200" ]; then
    echo -e "${GREEN}SUCCESS! Health endpoint is working!${NC}"
    echo "Response:"
    echo "$HEALTH_BODY" | python3 -m json.tool 2>/dev/null || echo "$HEALTH_BODY"
else
    echo -e "${RED}FAILED! Health endpoint returned: $HEALTH_CODE${NC}"
    echo "Response: $HEALTH_BODY"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 6: Checking Docker healthcheck status...${NC}"
sleep 10  # Wait a bit for healthcheck to run
HEALTH_STATUS=$(docker inspect ontrack-backend --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
echo "Container health status: $HEALTH_STATUS"

if [ "$HEALTH_STATUS" = "healthy" ]; then
    echo -e "${GREEN}Container healthcheck: PASSING${NC}"
elif [ "$HEALTH_STATUS" = "starting" ]; then
    echo -e "${YELLOW}Container healthcheck: STARTING (wait 30s more)${NC}"
else
    echo -e "${YELLOW}Container healthcheck: $HEALTH_STATUS${NC}"
fi

echo ""
echo "========================================"
echo -e "${GREEN}Deployment Complete!${NC}"
echo "========================================"
echo ""
echo "Summary:"
echo "  Health Endpoint: http://localhost:3001/health"
echo "  Status: $HEALTH_CODE"
echo "  Container: $HEALTH_STATUS"
echo ""
echo "Next steps:"
echo "  1. Monitor logs: docker compose logs -f backend"
echo "  2. Run full test: ./backend/test-health.sh"
echo "  3. Check all services: docker compose ps"
echo ""
echo -e "${GREEN}Ready for stakeholder presentation!${NC}"
