.PHONY: help
help: ## Show this menu
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: clean
clean: ## Clean all temp files
	@rm -rf .build coverage.*
	@docker image rm aleroxac/fullcycle-gointensivo7-gobook:v$(IMAGE_VERSION)
	@docker image rm aleroxac/fullcycle-gointensivo7-gobook:latest
