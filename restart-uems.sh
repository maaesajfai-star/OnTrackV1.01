#!/bin/bash

# UEMS Complete Restart and Verification Script
# This script will restart all UEMS containers and verify they are working correctly

set -e

PROJECT_DIR="/home/mahmoud/AI/Projects/claude-Version1"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UEMS Complete Restart Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Step 1: Stop all containers
print_status "Stopping all containers..."
docker compose down
print_success "All containers stopped"
echo ""

# Step 2: Ask if user wants to clean volumes
read -p "Do you want to remove all volumes for a fresh start? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    print_status "Removing all volumes..."
    docker volume rm uems-postgres-data 2>/dev/null && print_success "Removed postgres data" || print_warning "postgres data volume not found"
    docker volume rm uems-backend-node-modules 2>/dev/null && print_success "Removed backend node_modules" || print_warning "backend node_modules volume not found"
    docker volume rm uems-frontend-node-modules 2>/dev/null && print_success "Removed frontend node_modules" || print_warning "frontend node_modules volume not found"
    docker volume rm uems-frontend-next 2>/dev/null && print_success "Removed frontend .next" || print_warning "frontend .next volume not found"
    echo ""
fi

# Step 3: Rebuild and start containers
print_status "Rebuilding and starting containers..."
docker compose up --build -d
print_success "Containers started"
echo ""

# Step 4: Wait for services
print_status "Waiting for services to initialize..."
sleep 10

# Step 5: Monitor postgres
print_status "Waiting for PostgreSQL to be ready..."
POSTGRES_READY=0
for i in {1..30}; do
    if docker compose exec -T postgres pg_isready -U uems_user -d uems_db > /dev/null 2>&1; then
        POSTGRES_READY=1
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

if [ $POSTGRES_READY -eq 1 ]; then
    print_success "PostgreSQL is ready"
else
    print_error "PostgreSQL failed to start"
    print_status "PostgreSQL logs:"
    docker compose logs postgres | tail -20
    exit 1
fi
echo ""

# Step 6: Wait for backend
print_status "Waiting for backend to be ready (this may take 60-90 seconds)..."
BACKEND_READY=0
for i in {1..45}; do
    if curl -f http://localhost:3001/api/v1/health > /dev/null 2>&1; then
        BACKEND_READY=1
        break
    fi
    echo -n "."
    sleep 2
done
echo ""

if [ $BACKEND_READY -eq 1 ]; then
    print_success "Backend is ready and healthy"
else
    print_error "Backend failed to start"
    print_status "Backend logs:"
    docker compose logs backend | tail -30
    exit 1
fi
echo ""

# Step 7: Check all container status
print_status "Container Status:"
docker compose ps
echo ""

# Step 8: Test endpoints
print_status "Testing endpoints..."

# Test health endpoint
if curl -f http://localhost:3001/api/v1/health > /dev/null 2>&1; then
    print_success "Health endpoint: OK"
else
    print_error "Health endpoint: FAILED"
fi

# Test Swagger docs
if curl -f http://localhost:3001/api/docs > /dev/null 2>&1; then
    print_success "Swagger docs: OK"
else
    print_warning "Swagger docs: Not accessible"
fi

echo ""

# Step 9: Show admin credentials
print_status "Admin Credentials:"
echo -e "  Username: ${GREEN}Admin${NC}"
echo -e "  Password: ${GREEN}AdminAdmin@123${NC}"
echo -e "  Email: ${GREEN}admin@uems.local${NC}"
echo ""

# Step 10: Test admin login
print_status "Testing admin login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"Admin","password":"AdminAdmin@123"}' 2>&1)

if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    print_success "Admin login: OK"
    echo ""
else
    print_warning "Admin login: Could not verify (nginx may not be ready yet)"
    echo "Response: $LOGIN_RESPONSE"
    echo ""
fi

# Step 11: Show useful commands
print_status "Useful Commands:"
echo "  View all logs:       docker compose logs -f"
echo "  View backend logs:   docker compose logs -f backend"
echo "  View postgres logs:  docker compose logs -f postgres"
echo "  Stop all:            docker compose down"
echo "  Restart backend:     docker compose restart backend"
echo "  Run migrations:      docker compose exec backend npm run migration:run"
echo "  Access database:     docker compose exec postgres psql -U uems_user -d uems_db"
echo ""

# Step 12: Show URLs
print_status "Application URLs:"
echo -e "  Backend API:     ${GREEN}http://localhost:3001/api/v1${NC}"
echo -e "  API Docs:        ${GREEN}http://localhost:3001/api/docs${NC}"
echo -e "  Frontend:        ${GREEN}http://localhost:3000${NC}"
echo -e "  Nginx Proxy:     ${GREEN}http://localhost${NC}"
echo ""

print_success "UEMS restart complete!"
echo ""
