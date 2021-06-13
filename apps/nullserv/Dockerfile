FROM golang:alpine AS build-env

ARG TARGETPLATFORM

ENV CGO_ENABLED=0

WORKDIR /apps

# hadolint ignore=DL4006
RUN \
  export GOOS \
  && /bin/ash \
  && apk --no-cache --no-progress add ca-certificates=20191127-r5 git=2.30.2-r0 libcap=2.46-r0 \
  && update-ca-certificates \
  && GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) \
  && export GOARCH \
  && GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export GOARM \
  && GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) \
  && git clone https://github.com/bmrzycki/nullserv.git . \
  && ./mkbuildinfo.sh \
  && go build -a -ldflags '-w -extldflags "-static"' -o nullserv ./*.go

FROM scratch
COPY --from=build-env /apps/nullserv /

ENTRYPOINT ["/nullserv"]
