#!/bin/bash
# Quick test script to verify backend starts without errors

echo "Testing OnTrack Backend Startup..."
echo "======================================"
echo

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ ERROR: .env file not found!"
    echo "Please create .env file with required variables"
    exit 1
fi

echo "✅ .env file exists"

# Check if JWT_SECRET is set
if grep -q "JWT_SECRET=" .env && ! grep -q "JWT_SECRET=$" .env; then
    echo "✅ JWT_SECRET is configured"
else
    echo "❌ ERROR: JWT_SECRET not configured in .env"
    exit 1
fi

# Check if backend dependencies are installed
if [ -d "backend/node_modules" ]; then
    echo "✅ Backend dependencies installed"
else
    echo "❌ ERROR: Backend dependencies not installed"
    echo "Run: cd backend && npm install"
    exit 1
fi

# Check if backend builds
echo "📦 Testing backend build..."
cd backend
if npm run build > /dev/null 2>&1; then
    echo "✅ Backend builds successfully"
else
    echo "❌ ERROR: Backend build failed"
    echo "Run: cd backend && npm run build"
    exit 1
fi

echo
echo "======================================"
echo "✅ All checks passed!"
echo
echo "To start the application:"
echo "  docker compose up -d"
echo
echo "To view logs:"
echo "  docker compose logs -f backend"
