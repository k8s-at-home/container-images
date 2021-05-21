# hadolint ignore=DL3007
FROM google/dart:latest

WORKDIR /app

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  git clone https://github.com/mitsumaui/leaf2mqtt.git . \
  && pub get \
  && pub get --offline 

ENTRYPOINT ["/usr/bin/dart", "src/leaf2mqtt.dart"]
