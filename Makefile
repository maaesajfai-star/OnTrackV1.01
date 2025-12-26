.PHONY: help build up down restart logs clean test migrate backup restore prod-build prod-up prod-down

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "$(BLUE)UEMS Docker Management Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  make [target]"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

# Development Commands
build: ## Build all Docker images for development
	@echo "$(GREEN)Building development images...$(NC)"
	docker-compose build --parallel

build-nocache: ## Build all Docker images without cache
	@echo "$(GREEN)Building development images without cache...$(NC)"
	docker-compose build --no-cache --parallel

up: ## Start all services in development mode
	@echo "$(GREEN)Starting development services...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)Services started!$(NC)"
	@echo "Frontend: http://localhost"
	@echo "Backend API: http://localhost/api/v1"
	@echo "NextCloud: http://localhost/nextcloud"

down: ## Stop all services
	@echo "$(RED)Stopping all services...$(NC)"
	docker-compose down

restart: ## Restart all services
	@echo "$(GREEN)Restarting all services...$(NC)"
	docker-compose restart

restart-backend: ## Restart only backend service
	@echo "$(GREEN)Restarting backend service...$(NC)"
	docker-compose restart backend

restart-frontend: ## Restart only frontend service
	@echo "$(GREEN)Restarting frontend service...$(NC)"
	docker-compose restart frontend

# Logs Commands
logs: ## Tail logs for all services
	docker-compose logs -f

logs-backend: ## Tail logs for backend service
	docker-compose logs -f backend

logs-frontend: ## Tail logs for frontend service
	docker-compose logs -f frontend

logs-postgres: ## Tail logs for PostgreSQL service
	docker-compose logs -f postgres

logs-redis: ## Tail logs for Redis service
	docker-compose logs -f redis

logs-nginx: ## Tail logs for Nginx service
	docker-compose logs -f nginx

# Database Commands
migrate: ## Run database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	docker-compose exec backend npm run migration:run

migrate-generate: ## Generate new migration
	@echo "$(GREEN)Generating new migration...$(NC)"
	@read -p "Enter migration name: " name; \
	docker-compose exec backend npm run migration:generate -- -n $$name

migrate-revert: ## Revert last migration
	@echo "$(RED)Reverting last migration...$(NC)"
	docker-compose exec backend npm run migration:revert

seed: ## Run database seeders
	@echo "$(GREEN)Running database seeders...$(NC)"
	docker-compose exec backend npm run seed

# Backup and Restore
backup: ## Backup PostgreSQL database
	@echo "$(GREEN)Backing up database...$(NC)"
	@mkdir -p backups
	docker-compose exec -T postgres pg_dump -U uems_user uems_db > backups/uems_backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup completed!$(NC)"

restore: ## Restore PostgreSQL database from backup
	@echo "$(RED)This will restore the database from backup!$(NC)"
	@read -p "Enter backup file path: " backup_file; \
	docker-compose exec -T postgres psql -U uems_user uems_db < $$backup_file
	@echo "$(GREEN)Restore completed!$(NC)"

# Cleanup Commands
clean: ## Remove all containers, volumes, and images
	@echo "$(RED)Removing all containers, volumes, and images...$(NC)"
	docker-compose down -v --rmi all
	@echo "$(GREEN)Cleanup completed!$(NC)"

clean-volumes: ## Remove only volumes
	@echo "$(RED)Removing volumes...$(NC)"
	docker-compose down -v
	@echo "$(GREEN)Volumes removed!$(NC)"

prune: ## Prune unused Docker resources
	@echo "$(RED)Pruning unused Docker resources...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)Prune completed!$(NC)"

# Testing Commands
test: ## Run backend tests
	@echo "$(GREEN)Running backend tests...$(NC)"
	docker-compose exec backend npm run test

test-e2e: ## Run backend E2E tests
	@echo "$(GREEN)Running backend E2E tests...$(NC)"
	docker-compose exec backend npm run test:e2e

test-cov: ## Run backend tests with coverage
	@echo "$(GREEN)Running backend tests with coverage...$(NC)"
	docker-compose exec backend npm run test:cov

# Shell Access
shell-backend: ## Access backend container shell
	docker-compose exec backend sh

shell-frontend: ## Access frontend container shell
	docker-compose exec frontend sh

shell-postgres: ## Access PostgreSQL shell
	docker-compose exec postgres psql -U uems_user -d uems_db

shell-redis: ## Access Redis CLI
	docker-compose exec redis redis-cli

# Production Commands
prod-build: ## Build production images
	@echo "$(GREEN)Building production images...$(NC)"
	docker-compose -f docker-compose.prod.yml build --no-cache --parallel

prod-up: ## Start production services
	@echo "$(GREEN)Starting production services...$(NC)"
	docker-compose -f docker-compose.prod.yml up -d
	@echo "$(GREEN)Production services started!$(NC)"

prod-down: ## Stop production services
	@echo "$(RED)Stopping production services...$(NC)"
	docker-compose -f docker-compose.prod.yml down

prod-logs: ## View production logs
	docker-compose -f docker-compose.prod.yml logs -f

prod-restart: ## Restart production services
	@echo "$(GREEN)Restarting production services...$(NC)"
	docker-compose -f docker-compose.prod.yml restart

# Status and Health
status: ## Show status of all services
	@echo "$(BLUE)Service Status:$(NC)"
	docker-compose ps

health: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@for service in backend frontend postgres redis nginx; do \
		status=$$(docker-compose ps -q $$service | xargs docker inspect -f '{{.State.Health.Status}}' 2>/dev/null || echo "no healthcheck"); \
		echo "$$service: $$status"; \
	done

# Installation and Setup
setup: ## Initial setup - create .env and start services
	@echo "$(GREEN)Setting up UEMS...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN).env file created. Please edit it with your configuration.$(NC)"; \
	else \
		echo "$(BLUE).env file already exists.$(NC)"; \
	fi
	@echo "$(GREEN)Building and starting services...$(NC)"
	make build
	make up
	@echo "$(GREEN)Setup completed!$(NC)"

# Update Commands
update-backend: ## Rebuild and restart backend
	@echo "$(GREEN)Updating backend...$(NC)"
	docker-compose up -d --build --force-recreate backend

update-frontend: ## Rebuild and restart frontend
	@echo "$(GREEN)Updating frontend...$(NC)"
	docker-compose up -d --build --force-recreate frontend

update-all: ## Rebuild and restart all services
	@echo "$(GREEN)Updating all services...$(NC)"
	docker-compose up -d --build --force-recreate

# Redis Commands
redis-flush: ## Flush Redis cache
	@echo "$(RED)Flushing Redis cache...$(NC)"
	docker-compose exec redis redis-cli FLUSHALL
	@echo "$(GREEN)Redis cache flushed!$(NC)"

redis-info: ## Show Redis information
	docker-compose exec redis redis-cli INFO

# SSL/Certbot Commands
ssl-init: ## Initialize Let's Encrypt SSL certificate
	@echo "$(GREEN)Initializing SSL certificate...$(NC)"
	@read -p "Enter domain name: " domain; \
	docker-compose -f docker-compose.prod.yml run --rm certbot \
		certonly --webroot -w /var/www/certbot \
		-d $$domain --email admin@$$domain --agree-tos --no-eff-email

ssl-renew: ## Renew Let's Encrypt SSL certificate
	@echo "$(GREEN)Renewing SSL certificate...$(NC)"
	docker-compose -f docker-compose.prod.yml run --rm certbot renew

# Monitoring
monitor: ## Monitor resource usage
	@echo "$(BLUE)Monitoring Docker resource usage...$(NC)"
	docker stats

# Quick Commands
dev: up ## Alias for 'up' - start development environment
stop: down ## Alias for 'down' - stop all services
rebuild: build-nocache up ## Rebuild without cache and start
