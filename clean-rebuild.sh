#!/bin/bash
# Complete cleanup and rebuild script for OnTrack
# This ensures no cached data or volumes contaminate the build

set -e

echo "========================================="
echo "  OnTrack - Complete Clean Rebuild"
echo "========================================="
echo ""

# Stop all containers
echo "🛑 Stopping all containers..."
docker compose down || true

# Remove all OnTrack-related volumes
echo "🗑️  Removing all OnTrack volumes..."
docker volume rm ontrack-postgres-data 2>/dev/null || true
docker volume rm ontrack-redis-data 2>/dev/null || true
docker volume rm ontrack-nextcloud-db-data 2>/dev/null || true
docker volume rm ontrack-nextcloud-data 2>/dev/null || true
docker volume rm ontrack-nextcloud-apps 2>/dev/null || true
docker volume rm ontrack-nextcloud-config 2>/dev/null || true
docker volume rm ontrack-backend-uploads 2>/dev/null || true
docker volume rm ontrack-backend-logs 2>/dev/null || true

# Remove all OnTrack images
echo "🗑️  Removing all OnTrack images..."
docker rmi claude-version1-backend 2>/dev/null || true
docker rmi claude-version1-frontend 2>/dev/null || true

# Prune system
echo "🧹 Pruning Docker system..."
docker system prune -af

# Remove any host-side artifacts that could contaminate build
echo "🧹 Cleaning local artifacts..."
rm -rf backend/dist backend/node_modules/.cache 2>/dev/null || true
rm -rf frontend/.next frontend/node_modules/.cache 2>/dev/null || true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "🔨 Starting fresh build..."
echo ""

# Rebuild from scratch
docker compose build --no-cache --progress=plain

echo ""
echo "✅ Build complete!"
echo ""
echo "🚀 Starting services..."
echo ""

# Start services
docker compose up -d

echo ""
echo "✅ Services started!"
echo ""
echo "📊 Checking status..."
docker compose ps
echo ""
echo "📋 View logs with: docker compose logs -f"
echo ""
