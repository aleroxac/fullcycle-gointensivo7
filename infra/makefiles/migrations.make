.PHONY: migration_init
migration_init: ## Initialize migrations
	@migrate create -ext=sql -dir=sql/migrations -seq init

.PHONY: migration_up
migration_up: ## Migrations up
	@migrate -path=sql/migrations -database "postgres://root:$(DATABASE_PASSWORD)@localhost:5432/$(DATABASE_DB_NAME)?sslmode=disable" -verbose up
	@docker exec -it -e POSTGRES_PASSWORD=root postgresql pqsl -d $(DATABASE_DB_NAME) -c "\dt"

.PHONY: migration_down
migration_down: ## Migrations down
	@migrate -path=sql/migrations -database "postgres://root:$(DATABASE_PASSWORD)@localhost:5432/$(DATABASE_DB_NAME)?sslmode=disable" -verbose down --all
	@docker exec -it -e POSTGRES_PASSWORD=root postgresql psql -d ${DATABASE_DB_NAME} -c "\dt"

.PHONY: migration_clean
migration_clean: migration_down migration_up ## Run migration down and up to cleanup all data
