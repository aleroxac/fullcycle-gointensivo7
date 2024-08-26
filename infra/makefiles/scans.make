.PHONY: hadolint
hadolint: setup-build-workspace ## Run hadolint
	@cp ../scans/hadolint.yaml .build/
	@docker run --rm \
		-v ${PWD}/.build:/scan -w /scan \
		-w /scan \
		hadolint/hadolint:2.12.0-alpine \
			hadolint -c hadolint.yaml Dockerfile

.PHONY: kics
kics: ## Run kics
	@[ ! -d .reports ] && mkdir .reports
	@[ ! -f .reports/kics.html ] && touch .reports/kics.html
	@docker run --rm \
		-v ${PWD}:/scan \
		-w /scan \
		-it checkmarx/kics:v2.1.2-alpine scan \
			--config .scan/kics.yaml

.PHONY: trivy-files
trivy-files: # Run trivy-fs scan
	@[ ! -d ~/.cache/trivy ] && mkdir ~/.cache/trivy || true
	@docker run \
		-v ${PWD}:/scan \
		-v ~/.cache/trivy:/tmp/trivy \
		aquasec/trivy:0.54.1 fs \
			--cache-dir=/tmp/trivy \
			--vuln-type='os,library' \
			--format=table  \
			--security-checks='vuln,config,secret,license' \
			--severity='UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL' \
			--ignore-unfixed=true \
			--exit-code=1 /scan

.PHONY: trivy-image
trivy-image: # Run trivy-image scan
	@[ ! -d ~/.cache/trivy ] && mkdir ~/.cache/trivy || true
	@docker run \
		-v /run/containerd/containerd.sock:/run/containerd/containerd.sock \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v ~/.cache/trivy:/tmp/trivy \
		aquasec/trivy:0.54.1 image \
			--cache-dir=/tmp/trivy \
			--format='table' \
			--severity='UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL' \
			--ignore-unfixed=true \
			--exit-code=1 \
			aleroxac/fullcycle-gointensivo7-gobook:latest

.PHONY:can-trivy
trivy: trivy-files trivy-image ## Run trivy-fs and trivy-image scans

.PHONY: run-sonar
run-sonar: # Run sonarqube
	@if docker ps | grep sonar > /dev/null; then \
		echo "Sonarqube already running"; \
	else \
		docker rm -f sonar 2> /dev/null > /dev/null; \
		docker run -d --name sonar -p 9000:9000 sonarqube:community && sleep 15s; \
		until curl -s localhost:9000/api/system/health -u admin:admin | jq -e '.|select(.health=="GREEN")' > /dev/null; do \
			echo "Waiting for sonar..."; \
			sleep 30s; \
		done; \
		[ -f /tmp/sonar.json ] && rm -fv /tmp/sonar.json || true; \
		python .scans/setup-sonarqube.py | jq | tee /tmp/sonar.json; \
	fi

.PHONY: scan-sonar
scan-sonar: run-sonar test # Run sonar-scanner
	@docker run --rm \
		--network=host \
		-e SONAR_SCANNER_OPTS=" \
			-Dsonar.host.url=http://localhost:9000 \
			-Dsonar.login=$(shell jq -r '.token' /tmp/sonar.json) \
			-Dsonar.scm.revision=$(shell git --no-pager log --max-count=1 --oneline --format='%H') \
			-Dsonar.sources=/usr/src/. \
			-Dsonar.tests=/usr/src/. \
			-Dsonar.test.inclusions=/usr/src/**/*_test.go \
			-Dsonar.exclusions=/usr/src/**/*_test.go \
			-Dsonar.go.coverage.reportPaths=/usr/src/coverage.out \
			-Dsonar.go.tests.reportPath=/usr/src/coverage.json \
			-Dproject.settings=.scans/sonar-project.properties" \
		-v ${PWD}:/usr/src \
		sonarsource/sonar-scanner-cli:11.0

.PHONY: scan
scan: hadolint kics trivy sonar ## Run all scans: hadoling, kics, trivy-files, trivy-image, sonar
