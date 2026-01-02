# Production Dockerfile for Next.js Frontend
# Using Debian-based image for better Next.js SWC compatibility

FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files
COPY package*.json ./

# Clean npm cache and install dependencies
RUN npm cache clean --force && \
    npm install --legacy-peer-deps

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
