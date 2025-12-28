# Goall Server Makefile
# Provides convenient commands for database management and development

# Load environment variables from .env file if it exists
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Default values (can be overridden by .env or environment)
POSTGRES_USER ?= goall
POSTGRES_PASSWORD ?= goall_secret
POSTGRES_DB ?= goall
POSTGRES_PORT ?= 5432
DATABASE_URL ?= postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable

# Migrations directory
MIGRATIONS_DIR = ./migrations

.PHONY: help db-up db-down db-reset db-shell db-logs \
        migrate-install migrate-up migrate-down migrate-force migrate-create migrate-version \
        setup

# Default target - show help
help:
	@echo "Goall Server - Available Commands"
	@echo ""
	@echo "Database Commands:"
	@echo "  make db-up          Start PostgreSQL container"
	@echo "  make db-down        Stop PostgreSQL container"
	@echo "  make db-reset       Reset database (destroy and recreate)"
	@echo "  make db-shell       Open psql shell in the database"
	@echo "  make db-logs        Show PostgreSQL container logs"
	@echo ""
	@echo "Migration Commands:"
	@echo "  make migrate-install   Install golang-migrate CLI"
	@echo "  make migrate-up        Run all pending migrations"
	@echo "  make migrate-down      Rollback the last migration"
	@echo "  make migrate-force V=N Force set migration version to N"
	@echo "  make migrate-create N=name  Create a new migration"
	@echo "  make migrate-version   Show current migration version"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup          Full setup: start DB and run migrations"
	@echo ""

# ============================================================================
# Database Commands
# ============================================================================

# Start the PostgreSQL container
db-up:
	@echo "Starting PostgreSQL container..."
	docker compose up -d postgres
	@echo "Waiting for PostgreSQL to be ready..."
	@until docker compose exec -T postgres pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB) > /dev/null 2>&1; do \
		sleep 1; \
	done
	@echo "PostgreSQL is ready!"

# Stop the PostgreSQL container
db-down:
	@echo "Stopping PostgreSQL container..."
	docker compose down

# Reset the database (destroy volume and recreate)
db-reset:
	@echo "Resetting database..."
	docker compose down -v
	$(MAKE) db-up
	@sleep 2
	$(MAKE) migrate-up

# Open a psql shell in the database
db-shell:
	docker compose exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

# Show PostgreSQL container logs
db-logs:
	docker compose logs -f postgres

# ============================================================================
# Migration Commands
# ============================================================================

# Install golang-migrate CLI
migrate-install:
	@echo "Installing golang-migrate..."
	go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
	@echo "golang-migrate installed! Make sure $(shell go env GOPATH)/bin is in your PATH"

# Run all pending migrations
migrate-up:
	@echo "Running migrations..."
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" up
	@echo "Migrations completed!"

# Rollback the last migration
migrate-down:
	@echo "Rolling back last migration..."
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" down 1

# Force set migration version (useful for fixing dirty state)
migrate-force:
ifndef V
	$(error V is required. Usage: make migrate-force V=1)
endif
	@echo "Forcing migration version to $(V)..."
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" force $(V)

# Create a new migration
migrate-create:
ifndef N
	$(error N is required. Usage: make migrate-create N=migration_name)
endif
	@echo "Creating migration: $(N)"
	migrate create -ext sql -dir $(MIGRATIONS_DIR) -seq $(N)

# Show current migration version
migrate-version:
	@migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" version

# ============================================================================
# Setup Commands
# ============================================================================

# Full setup: copy env, start database, run migrations
setup: db-up
	@sleep 2
	$(MAKE) migrate-up
	@echo ""
	@echo "Setup complete! Database is ready."
	@echo "Connection URL: $(DATABASE_URL)"
