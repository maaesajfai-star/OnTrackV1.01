#!/bin/bash

# UEMS Diagnostics Script
# This script collects diagnostic information about the UEMS environment

PROJECT_DIR="/home/mahmoud/AI/Projects/claude-Version1"
cd "$PROJECT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UEMS Diagnostics${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Docker version
echo -e "${BLUE}==> Docker Version${NC}"
docker --version
docker compose version
echo ""

# Container status
echo -e "${BLUE}==> Container Status${NC}"
docker compose ps
echo ""

# Container health
echo -e "${BLUE}==> Container Health${NC}"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"
echo ""

# Network status
echo -e "${BLUE}==> Network Status${NC}"
docker network inspect uems-network --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}' 2>/dev/null || echo "Network not found"
echo ""

# Volume status
echo -e "${BLUE}==> Volume Status${NC}"
docker volume ls | grep uems
echo ""

# Backend logs (last 30 lines)
echo -e "${BLUE}==> Backend Logs (last 30 lines)${NC}"
docker compose logs backend --tail 30
echo ""

# Postgres logs (last 20 lines)
echo -e "${BLUE}==> PostgreSQL Logs (last 20 lines)${NC}"
docker compose logs postgres --tail 20
echo ""

# Port check
echo -e "${BLUE}==> Port Status${NC}"
echo "Checking if ports are listening..."
for port in 80 3000 3001 5432 6379; do
    if lsof -i :$port > /dev/null 2>&1; then
        echo -e "  Port $port: ${GREEN}LISTENING${NC}"
    else
        echo -e "  Port $port: ${RED}NOT LISTENING${NC}"
    fi
done
echo ""

# Endpoint tests
echo -e "${BLUE}==> Endpoint Tests${NC}"

# Health endpoint
if curl -f http://localhost:3001/api/v1/health > /dev/null 2>&1; then
    echo -e "  Backend Health: ${GREEN}OK${NC}"
    curl -s http://localhost:3001/api/v1/health | head -3
else
    echo -e "  Backend Health: ${RED}FAILED${NC}"
fi
echo ""

# Swagger docs
if curl -f http://localhost:3001/api/docs > /dev/null 2>&1; then
    echo -e "  Swagger Docs: ${GREEN}OK${NC}"
else
    echo -e "  Swagger Docs: ${RED}FAILED${NC}"
fi
echo ""

# Database connection
echo -e "${BLUE}==> Database Connection${NC}"
if docker compose exec -T postgres pg_isready -U uems_user -d uems_db > /dev/null 2>&1; then
    echo -e "  PostgreSQL: ${GREEN}READY${NC}"
    docker compose exec -T postgres psql -U uems_user -d uems_db -c "SELECT version();" 2>&1 | head -3
else
    echo -e "  PostgreSQL: ${RED}NOT READY${NC}"
fi
echo ""

# Database tables
echo -e "${BLUE}==> Database Tables${NC}"
docker compose exec -T postgres psql -U uems_user -d uems_db -c "\dt" 2>&1 | head -20 || echo "Could not list tables"
echo ""

# Migration status
echo -e "${BLUE}==> Migration Status${NC}"
docker compose exec -T backend npm run typeorm -- migration:show 2>&1 | tail -20 || echo "Could not check migrations"
echo ""

# Environment variables (sanitized)
echo -e "${BLUE}==> Environment Variables (Backend Container)${NC}"
docker compose exec -T backend env | grep -E "NODE_ENV|POSTGRES_HOST|POSTGRES_PORT|POSTGRES_DB|POSTGRES_USER|REDIS_HOST|BACKEND_PORT" | sort
echo ""

# Disk usage
echo -e "${BLUE}==> Docker Disk Usage${NC}"
docker system df
echo ""

# Resource usage
echo -e "${BLUE}==> Container Resource Usage${NC}"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""

echo -e "${GREEN}Diagnostics complete!${NC}"
echo ""
echo "To save this output to a file, run:"
echo "  ./diagnose-uems.sh > diagnostics-$(date +%Y%m%d-%H%M%S).txt"
echo ""
