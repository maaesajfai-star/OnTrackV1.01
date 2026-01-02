# Production Dockerfile for Next.js Frontend
# Optimized for production deployment without bind mounts

FROM node:20-alpine

# Install system dependencies
RUN apk add --no-cache \
    libc6-compat \
    curl \
    python3 \
    make \
    g++

WORKDIR /app

# Copy package files
COPY package*.json ./

# Clean npm cache and install dependencies with fallback
RUN npm cache clean --force && \
    (npm install --legacy-peer-deps || \
     npm install --force || \
     npm install --no-optional --legacy-peer-deps)

# Copy source code
COPY . .

# Disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN npm run build

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start the application
CMD ["npm", "start"]
