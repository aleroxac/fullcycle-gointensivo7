.PHONY: setup-build-workspace
setup-build-workspace: ## Setup the build workspace
	@[ -d .build ] && rm -rf .build
	@mkdir .build
	@cp -r cmd/ docker/ internal/ go.mod go.sum .build/

.PHONY: build
build: setup-build-workspace ## Build the container image
	@docker build \
		-t aleroxac/fullcycle-gointensivo7-gobook:v$(IMAGE_VERSION) \
		-t aleroxac/fullcycle-gointensivo7-gobook:latest \
		--cache-from aleroxac/fullcycle-gointensivo7-gobook:latest \
		--build-arg APP_PORT=$(APP_PORT) \
		--build-arg APP_HEALTHCHECK_PATH=$(APP_HEALTHCHECK_PATH) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-f .build/Dockerfile .build/

.PHONY: push
push: ## Push the container image to image registry
	@docker push aleroxac/fullcycle-gointensivo7-gobook:v$(IMAGE_VERSION)
	@docker push aleroxac/fullcycle-gointensivo7-gobook:latest
