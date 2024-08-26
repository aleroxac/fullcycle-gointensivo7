# syntax=docker/dockerfile:1
FROM golang:1.23.0 AS base



# ---------- ARGS
ARG \
    APP_PORT \
    APP_HEALTHCHECK_PATH \
    VCS_REF \
    VCS_URL \
    BUILD_DATE \
    IMAGE_VERSION


# ---------- ENVS
ENV \
    APP_PORT=${APP_PORT} \
    APP_HEALTHCHECK_PATH=${APP_HEALTHCHECK_PATH}


# ---------- LABELS
LABEL \
  maintainer="aleroxac" \
  vendor="aleroxac" \
  org.label-schema.author-name="Augusto Cardoso dos Santos" \
  org.label-schema.author-username="aleroxac" \
  org.label-schema.author-title="Site Reliability Engineer" \
  org.label-schema.author-email="acardoso.ti@gmail.com" \
  org.label-schema.license="MIT" \
  org.label-schema.schema-version='1.0.0-rc.1' \
  org.label-schema.vcs-ref=${VCS_REF} \
  org.label-schema.vcs-url=${VCS_URL} \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="fullcycle-gointensivo7" \
  org.label-schema.base="scratch" \
  org.label-schema.version=${IMAGE_VERSION} \
  org.label-schema.description="Projeto desenvolvido duranto o evento Go Intensivo da FullCycle." \
  org.label-schema.usage="" \
  org.label-schema.url="https://hub.docker.com/r/aleroxac/fullcycle-gointensivo7" \
  org.label-schema.os-name="scratch" \
  org.label-schema.os-version="" \
  org.label-schema.docker.cmd="docker run -d -p ${APP_PORT} --name gobook aleroxac/fullcycle-gointensivo7:gobook-v${IMAGE_VERSION}" \
  org.label-schema.docker.cmd.devel="" \
  org.label-schema.docker.cmd.test="" \
  org.label-schema.docker.cmd.debug="" \
  org.label-schema.docker.cmd.help="" \
  org.label-schema.docker.params="" \
  org.label-schema.app.port=${APP_PORT} \
  org.label-schema.app.healthcheck.path=${APP_HEALTHCHECK_PATH} \
  org.label-schema.app.lang="go" \
  org.label-schema.app.lang.version="1.23.0"



# ---------- BUILD
FROM base AS build
WORKDIR /build
COPY . /build
RUN \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o server cmd/books/main.go && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o healthcheck docker/healthcheck.go



# ---------- COMPRESS
FROM alpine AS upx
RUN apk add --no-cache upx
COPY --from=build /build/server /build/healthcheck /upx/
RUN upx --best --lzma /upx/server -o /upx/server_compressed
RUN upx --best --lzma /upx/healthcheck -o /upx/healthcheck_compressed



# ---------- MAIN
FROM scratch AS main
WORKDIR /app
COPY --from=upx /upx/server_compressed /app/server
COPY --from=upx /upx/healthcheck_compressed /app/healthcheck
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENV \
    HEALTHCHECK_PORT=${APP_PORT} \
    HEALTHCHECK_PATH=${APP_HEALTHCHECK_PATH}

ENTRYPOINT [ "/app/server" ]
EXPOSE ${APP_PORT}
HEALTHCHECK \
    --start-period=2s \
    --interval=1s \
    --timeout=1s \
    --retries=3 \
    CMD [ "/app/healthcheck" ]
