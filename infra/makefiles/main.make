.PHONY: fmt
fmt: ## Format the code
	@go fmt ./...

.PHONY: vet
vet: ## Run static analysis
	@go vet ./...




.PHONY: docs
docs: ## Generate/update swagger docs
	@swag init -g cmd/server/main.go || true
	@swag fmt

.PHONY: generate
generate: ## Run sqls generate
	@sqlc generate

.PHONY: test
test: ## Run the tests
	@go test -v ./... -coverprofile=coverage.out
	@go tool cover \
		-html coverage.out -o coverage.html \
		-json coverage.out -o coverage.json



.PHONY: run
run: ## Run the app locally
	@go run cmd/books/main.go

.PHONY: run-with-docs
run-with-docs: docs ## Build docs and run the app locally
	@go run cmd/books/main.go

.PHONY: air
air: ## Run the app locally, with live-reaload by air
	@air

.PHONY: air-with-docs
air-with-docs: docs ## Build docs and run the app locally, with live-reaload by air
	@air
