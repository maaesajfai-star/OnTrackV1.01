# Production Dockerfile for NestJS Backend
# Using Debian-based image for better compatibility

FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    postgresql-client \
    curl \
    bash \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Clean npm cache and install dependencies
RUN npm cache clean --force && \
    npm install --legacy-peer-deps --production=false

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
