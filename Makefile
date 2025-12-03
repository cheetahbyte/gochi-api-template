
APP_NAME=flagly-backend
BUILD_DIR=bin
MAIN_FILE=cmd/api/main.go

GREEN=\033[0;32m
NC=\033[0m # No Color

.PHONY: all build run test clean docker-build docker-run help

all: build

help: ## Show this help message
	@echo "Usage: make [target]"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${GREEN}%-15s${NC} %s\n", $$1, $$2}'

run: ## Run the application locally (without Docker)
	@echo "${GREEN}Running application...${NC}"
	go run $(MAIN_FILE)

build: ## Build the binary
	@echo "${GREEN}Building binary...${NC}"
	go build -o $(BUILD_DIR)/api $(MAIN_FILE)

test: ## Run unit tests
	@echo "${GREEN}Running tests...${NC}"
	go test -v ./...

clean: ## Remove build artifacts
	@echo "${GREEN}Cleaning up...${NC}"
	rm -rf $(BUILD_DIR)

docker-build: ## Build the Docker image
	@echo "${GREEN}Building Docker image...${NC}"
	docker build -t $(APP_NAME) .

docker-run: ## Run the Docker container
	@echo "${GREEN}Running Docker container...${NC}"
	docker run -p 8080:8080 --env-file .env $(APP_NAME)

deps: ## Download dependencies
	@echo "${GREEN}Downloading dependencies...${NC}"
	go mod download
	go mod tidy
