#!/usr/bin/env bash
echo APP_PORT="$(find ${PWD} -type f -name ".env.example" -exec grep "HTTP_PORT" {} + | cut -d"=" -f2)"
echo APP_HEALTHCHECK_PATH="/api/v1/health/liveness"
echo VCS_REF="$(git rev-parse HEAD)"
echo VCS_URL="https://github.com/aleroxac/dockerfiles/commit/$(git rev-parse HEAD)"
echo BUILD_DATE="$(TZ="America/Sao_Paulo" date +'%Y-%m-%dT%H:%M:%SZ')"
echo IMAGE_VERSION="$(git --no-pager tag -l | sort -nr | head -n1 | grep "^v" || echo v1.0.0 | tr -d "v")"
