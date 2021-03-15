ARG VERSION

FROM alpine:${VERSION}

RUN \
    apk add --no-cache \
        tini \
        ca-certificates

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["echo", "'No can haz support yet. Chek bak l8r!'", "exit", "1337" ]
