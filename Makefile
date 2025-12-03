ifneq (,$(wildcard .env))
    include .env
    export
endif

# Variables
APP_NAME=myapp
BUILD_DIR=bin
MAIN_FILE=cmd/api/main.go

DATABASE_URL?=postgres://user:password@host:port/dbname?sslmode=disable
MIGRATION_DIR=sql/schema

# Colors for terminal output
GREEN=\033[0;32m
NC=\033[0m # No Color

.PHONY: all build run test clean docker-build docker-run deps help sqlc migrate-up migrate-down migrate-create migrate-status

all: build

help: ## Show this help message
	@echo "Usage: make [target]"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-15s${NC} %s\n", $$1, $$2}'

# --- Application ---

run: ## Run the application locally (without Docker)
	@echo "${GREEN}Running application...${NC}"
	DATABASE_URL=$(DATABASE_URL) go run $(MAIN_FILE)

build: ## Build the binary
	@echo "${GREEN}Building binary...${NC}"
	go build -o $(BUILD_DIR)/api $(MAIN_FILE)

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

# --- Database Migrations (Goose) ---

migrate-up: ## Run all new database migrations
	@echo "${GREEN}Running migrations UP...${NC}"
	goose -dir $(MIGRATION_DIR) postgres "$(DATABASE_URL)" up

migrate-down: ## Rollback the last migration
	@echo "${GREEN}Rolling back migration...${NC}"
	goose -dir $(MIGRATION_DIR) postgres "$(DATABASE_URL)" down

migrate-status: ## Check the status of migrations
	@echo "${GREEN}Checking migration status...${NC}"
	goose -dir $(MIGRATION_DIR) postgres "$(DATABASE_URL)" status

migrate-create: ## Create a new migration file (Usage: make migrate-create name=add_users)
	@echo "${GREEN}Creating migration file...${NC}"
	@if [ -z "$(name)" ]; then echo "Error: name argument required (make migrate-create name=foo)"; exit 1; fi
	goose -dir $(MIGRATION_DIR) create $(name) sql
