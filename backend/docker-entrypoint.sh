#!/bin/sh
set -e

echo "🚀 Starting UEMS Backend..."

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL..."
until nc -z postgres 5432; do
  echo "  PostgreSQL is unavailable - sleeping"
  sleep 2
done
echo "✓ PostgreSQL is ready!"

# Wait a bit more to ensure PostgreSQL is fully initialized
sleep 5

# Run migrations (ignore errors if already applied)
echo "📦 Running database migrations..."
npm run migration:run || echo "⚠️  Migrations failed or already applied"

# Run database seeding (creates admin if needed)
echo "👤 Creating admin user..."
npm run seed || echo "⚠️  Seed failed or admin already exists"

# Start the application in development mode (no build required)
echo "🎯 Starting NestJS application in watch mode..."
echo "   (TypeScript will compile on-the-fly)"
exec npm run start:dev
