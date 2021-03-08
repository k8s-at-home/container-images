FROM golang:1.15-alpine AS build

WORKDIR /workspace
ENV GO111MODULE=on

RUN apk add --no-cache git bash curl g++

# Fetch binary early because to allow more caching
COPY scripts scripts
COPY testdata testdata
RUN ./scripts/fetch-test-binaries.sh

COPY src src

# Build
RUN cd src; go mod download

RUN cd src; CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

#Test
ARG TEST_ZONE_NAME
RUN  \
     if [ -n "$TEST_ZONE_NAME" ]; then \
       cd src; \
       CCGO_ENABLED=0 TEST_ZONE_NAME="$TEST_ZONE_NAME" go test -v .; \
     fi

FROM alpine

RUN apk update \
        && apk upgrade \
        && apk add --no-cache \
        ca-certificates bash curl \
        && update-ca-certificates 2>/dev/null || true

COPY --from=build /workspace/src/webhook /usr/local/bin/webhook

ENTRYPOINT ["webhook"]
