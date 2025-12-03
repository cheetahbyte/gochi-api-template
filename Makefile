# --- Load .env file if it exists ---
ifneq (,$(wildcard .env))
    include .env
    export
endif

# Variables
APP_NAME=myapp
BUILD_DIR=bin
MAIN_FILE=cmd/api/main.go
MIGRATE_FILE=cmd/migrate/main.go

# Output binary names
API_BINARY=$(BUILD_DIR)/api
MIGRATE_BINARY=$(BUILD_DIR)/migrate

DATABASE_URL?=postgres://postgres:password@localhost:5432/flagly?sslmode=disable
MIGRATION_DIR=sql/schema

# Colors
GREEN=\033[0;32m
NC=\033[0m # No Color

.PHONY: all build run test clean docker-build docker-run deps help sqlc migrate-up migrate-down migrate-create migrate-status run-migrate

all: build

help: ## Show this help message
	@echo "Usage: make [target]"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-15s${NC} %s\n", $$1, $$2}'

# --- Application ---

run: ## Run the API locally
	@echo "${GREEN}Running application...${NC}"
	go run $(MAIN_FILE)

build: ## Build BOTH binaries (API + Migrator)
	@echo "${GREEN}Building API binary...${NC}"
	go build -o $(API_BINARY) $(MAIN_FILE)
	@echo "${GREEN}Building Migrator binary...${NC}"
	go build -o $(MIGRATE_BINARY) $(MIGRATE_FILE)

run-migrate: build ## Run the compiled migration binary locally
	@echo "${GREEN}Running migration binary...${NC}"
	$(MIGRATE_BINARY)

test: ## Run unit tests
	@echo "${GREEN}Running tests...${NC}"
	go test -v ./...

clean: ## Remove build artifacts
	@echo "${GREEN}Cleaning up...${NC}"
	rm -rf $(BUILD_DIR)

deps: ## Download dependencies
	@echo "${GREEN}Downloading dependencies...${NC}"
	go mod download
	go mod tidy

# --- Docker ---

docker-build: ## Build the Docker image
	@echo "${GREEN}Building Docker image...${NC}"
	docker build -t $(APP_NAME) .

docker-run: ## Run the Docker container
	@echo "${GREEN}Running Docker container...${NC}"
	docker run -p 8080:8080 --env-file .env $(APP_NAME)

# --- Code Generation (SQLC) ---

sqlc: ## Generate Go code from SQL queries
	@echo "${GREEN}Generating SQLC code...${NC}"
	sqlc generate

# --- Database Migrations (Development Tools) ---
# These commands use the 'goose' CLI tool for quick local development

migrate-up: ## Run migrations UP (using goose CLI)
	@echo "${GREEN}Running migrations UP (CLI)...${NC}"
	goose -dir $(MIGRATION_DIR) postgres "$(DATABASE_URL)" up

migrate-down: ## Rollback migration (using goose CLI)
	@echo "${GREEN}Rolling back migration (CLI)...${NC}"
	goose -dir $(MIGRATION_DIR) postgres "$(DATABASE_URL)" down

migrate-status: ## Check status (using goose CLI)
	@echo "${GREEN}Checking migration status (CLI)...${NC}"
	goose -dir $(MIGRATION_DIR) postgres "$(DATABASE_URL)" status

migrate-create: ## Create a new migration file
	@echo "${GREEN}Creating migration file...${NC}"
	@if [ -z "$(name)" ]; then echo "Error: name argument required (make migrate-create name=foo)"; exit 1; fi
	goose -dir $(MIGRATION_DIR) create $(name) sql
