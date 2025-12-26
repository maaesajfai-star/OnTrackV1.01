# Multi-stage Dockerfile for Next.js Frontend
# Optimized for both development and production with standalone output

# ==========================================
# Base Stage - Common setup
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

# Copy package files
COPY package.json package-lock.json ./

# Install ALL dependencies (dev deps needed for build)
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

# Disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED=1

# Expose port
EXPOSE 3000

# Health check for development
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Development command
CMD ["npm", "run", "dev"]

# ==========================================
# Builder Stage - Build the application
# ==========================================
FROM base AS builder

WORKDIR /app

# Copy dependencies
COPY --from=dependencies /app/node_modules ./node_modules

# Copy package files
COPY package.json package-lock.json ./

# Copy source code
COPY . .

# Disable telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application with standalone output
# The standalone output includes only necessary files for production
RUN npm run build

# ==========================================
# Production Stage
# ==========================================
FROM base AS production

WORKDIR /app

# Set production environment
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy public assets
COPY --from=builder /app/public ./public

# Copy standalone output and static files
# Next.js standalone output automatically includes only production dependencies
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Start the application using the standalone server
CMD ["node", "server.js"]
