#!/bin/bash
# Health Endpoint Test Script
# Tests all critical endpoints to ensure routing is correct

echo "========================================"
echo "OnTrack Backend Health Check Test"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="${BACKEND_URL:-http://localhost:3001}"
MAX_RETRIES=30
RETRY_DELAY=2

echo "Backend URL: $BACKEND_URL"
echo "Waiting for backend to be ready..."
echo ""

# Wait for backend to be ready
for i in $(seq 1 $MAX_RETRIES); do
    if curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL/health" | grep -q "200"; then
        echo -e "${GREEN}Backend is ready!${NC}"
        break
    fi
    echo "Attempt $i/$MAX_RETRIES - Backend not ready yet..."
    if [ $i -eq $MAX_RETRIES ]; then
        echo -e "${RED}Backend failed to start after $MAX_RETRIES attempts${NC}"
        exit 1
    fi
    sleep $RETRY_DELAY
done

echo ""
echo "========================================"
echo "Running Endpoint Tests"
echo "========================================"
echo ""

# Test 1: Health endpoint at /health
echo "Test 1: GET /health"
HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/health")
HEALTH_CODE=$(echo "$HEALTH_RESPONSE" | tail -n 1)
HEALTH_BODY=$(echo "$HEALTH_RESPONSE" | head -n -1)

if [ "$HEALTH_CODE" = "200" ]; then
    echo -e "${GREEN}PASS${NC} - Status: $HEALTH_CODE"
    echo "Response: $HEALTH_BODY"
else
    echo -e "${RED}FAIL${NC} - Status: $HEALTH_CODE"
    echo "Response: $HEALTH_BODY"
    exit 1
fi

echo ""

# Test 2: Root endpoint at /
echo "Test 2: GET /"
ROOT_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/")
ROOT_CODE=$(echo "$ROOT_RESPONSE" | tail -n 1)
ROOT_BODY=$(echo "$ROOT_RESPONSE" | head -n -1)

if [ "$ROOT_CODE" = "200" ]; then
    echo -e "${GREEN}PASS${NC} - Status: $ROOT_CODE"
    echo "Response: $ROOT_BODY"
else
    echo -e "${RED}FAIL${NC} - Status: $ROOT_CODE"
    echo "Response: $ROOT_BODY"
fi

echo ""

# Test 3: Verify health is NOT at /api/v1/health
echo "Test 3: GET /api/v1/health (should 404)"
API_HEALTH_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/api/v1/health")
API_HEALTH_CODE=$(echo "$API_HEALTH_RESPONSE" | tail -n 1)

if [ "$API_HEALTH_CODE" = "404" ]; then
    echo -e "${GREEN}PASS${NC} - Status: $API_HEALTH_CODE (correctly excluded from API prefix)"
else
    echo -e "${YELLOW}WARNING${NC} - Status: $API_HEALTH_CODE (health endpoint might be accessible at both paths)"
fi

echo ""

# Test 4: Swagger docs
echo "Test 4: GET /api/docs (Swagger)"
DOCS_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/api/docs")
DOCS_CODE=$(echo "$DOCS_RESPONSE" | tail -n 1)

if [ "$DOCS_CODE" = "200" ] || [ "$DOCS_CODE" = "301" ] || [ "$DOCS_CODE" = "302" ]; then
    echo -e "${GREEN}PASS${NC} - Status: $DOCS_CODE"
else
    echo -e "${YELLOW}WARNING${NC} - Status: $DOCS_CODE"
fi

echo ""
echo "========================================"
echo "Health Check Summary"
echo "========================================"
echo ""

# Extract health data
if [ "$HEALTH_CODE" = "200" ]; then
    echo -e "${GREEN}Health Endpoint: OPERATIONAL${NC}"
    echo "Endpoint: $BACKEND_URL/health"
    echo "Status Code: $HEALTH_CODE"

    # Parse JSON if jq is available
    if command -v jq &> /dev/null; then
        echo ""
        echo "Health Details:"
        echo "$HEALTH_BODY" | jq '.'
    else
        echo "Health Response: $HEALTH_BODY"
    fi

    echo ""
    echo -e "${GREEN}Docker healthcheck will PASS${NC}"
    exit 0
else
    echo -e "${RED}Health Endpoint: FAILED${NC}"
    echo "Expected: 200"
    echo "Got: $HEALTH_CODE"
    echo ""
    echo -e "${RED}Docker healthcheck will FAIL${NC}"
    exit 1
fi
