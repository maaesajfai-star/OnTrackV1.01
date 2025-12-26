# Multi-stage Dockerfile for NestJS Backend
# Optimized for both development and production environments

# ==========================================
# Base Stage - Common dependencies
# ==========================================
FROM node:20-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    libc6-compat \
    curl

WORKDIR /app

# ==========================================
# Dependencies Stage - Install all deps
# ==========================================
FROM base AS dependencies

# Copy package files for dependency installation
COPY package.json package-lock.json ./

# Install ALL dependencies (including dev dependencies for building)
RUN npm ci --prefer-offline --no-audit

# ==========================================
# Development Stage
# ==========================================
FROM base AS development

WORKDIR /app

# Copy dependencies from dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package files
COPY package.json package-lock.json ./

# Copy source code
COPY . .

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3001/api/v1/health || exit 1

# Default development command (can be overridden)
CMD ["npm", "run", "start:dev"]

# ==========================================
# Builder Stage - Build the application
# ==========================================
FROM base AS builder

WORKDIR /app

# Copy dependencies from dependencies stage
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package files and source
COPY package.json package-lock.json ./
COPY . .

# Build the application
RUN npm run build && \
    npm prune --production

# ==========================================
# Production Stage
# ==========================================
FROM base AS production

WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Copy production dependencies from builder
COPY --from=builder /app/node_modules ./node_modules

# Copy package files
COPY --from=builder /app/package.json ./package.json

# Copy built application
COPY --from=builder /app/dist ./dist

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001 && \
    mkdir -p /app/uploads /app/logs && \
    chown -R nestjs:nodejs /app

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE 3001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3001/api/v1/health || exit 1

# Start the application
CMD ["node", "dist/main"]
