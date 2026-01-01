# Production Dockerfile for NestJS Backend
# Optimized for production deployment without bind mounts

FROM node:20-alpine

# Install system dependencies
RUN apk add --no-cache \
    netcat-openbsd \
    postgresql-client \
    curl \
    bash \
    python3 \
    make \
    g++

WORKDIR /app

# Copy package files
COPY package*.json ./

# Clean npm cache and install dependencies with fallback
RUN npm cache clean --force && \
    (npm install --legacy-peer-deps --production=false || \
     npm install --force --production=false || \
     npm install --no-optional --legacy-peer-deps --production=false)

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Create directories for uploads and logs
RUN mkdir -p /app/uploads /app/logs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3001/api/v1/health || exit 1

# Use entrypoint script (handles migrations and startup)
ENTRYPOINT ["docker-entrypoint.sh"]
