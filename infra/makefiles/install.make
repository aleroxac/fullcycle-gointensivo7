.PHONY: install-migrate
install-migrate: ## Install migrate
	@if [ ! -f /usr/local/bin/migrate ]; then \
		wget -O /tmp/migrate.tar.gz https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz; \
		tar -C /tmp -xzvf /tmp/migrate.tar.gz; \
		sudo mv /tmp/migrate /usr/local/bin/migrate; \
	else \
		echo "Great, you already have [migrate] installed"; \
	fi

.PHONY: install-swag
install-swag: ## Install swag
	@if [ ! -f ~/.go/bin/swag ]; then \
		go install github.com/swaggo/swag/cmd/swag@latest
	else \
		echo "Great, you already have [swag] installed"; \
	fi

.PHONY: install-wire
install-wire: ## Install wire
	@if [ ! -f ~/.go/bin/wire ]; then \
		go install github.com/google/wire/cmd/wire@latest
	else \
		echo "Great, you already have [wire] installed"; \
	fi

.PHONY: install-sqlc
install-sqlc: ## Install sqlc
	@if [ ! -f ~/.go/bin/sqlc ]; then \
		go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest; \
	else \
		echo "Great, you already have [sqlc] installed"; \
	fi

.PHONY: install-cobra
install-cobra: ## Install cobra
	@if [ ! -f ~/.go/bin/sqlc ]; then \
		go install github.com/spf13/cobra-cli@latest
	else \
		echo "Great, you already have [cobra] installed"; \
	fi

.PHONY: install-air
install-air: ## Install air
	@if [ ! -f ~/.go/bin/air ]; then \
		go install github.com/cosmtrek/air@latest
	else \
		echo "Great, you already have [air] installed"; \
	fi

.PHONY: install-requirements
install: ## Install module requirements	
	@go mod tidy

.PHONY: install
install: install-migrate install-swag install-requirements ## Install all requirements
