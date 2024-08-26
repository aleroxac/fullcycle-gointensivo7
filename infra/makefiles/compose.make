.PHONY: up
up: ## Put the compose containers up
	@docker-compose -f infra/docker/docker-compose.yaml up -d

.PHONY: down
down: ## Put the compose containers down
	@docker-compose -f infra/docker/docker-compose.yaml down
	@pkill air
