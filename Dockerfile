
ARG ALPINE_VERSION=3.23.6
ARG KC_VERSION=26.7.5

# -----------------------------------------------------------------------------
# Builder
# -----------------------------------------------------------------------------
FROM alpine:${ALPINE_VERSION} AS builder

ARG KC_VERSION

RUN apk add --no-cache \
      ca-certificates \
      curl \
      openjdk21-jre-headless \
      tzdata \
    && addgroup -g 40404 kek \
    && adduser -D -H -u 40404 -G kek kek

RUN curl \
      --fail \
      --location \
      --silent \
      --show-error \
      "https://github.com/keycloak/keycloak/releases/download/${KC_VERSION}/keycloak-${KC_VERSION}.tar.gz" \
      --output /tmp/keycloak.tar.gz \
    && tar -xzf /tmp/keycloak.tar.gz -C /opt \
    && mv "/opt/keycloak-${KC_VERSION}" /opt/keycloak \
    && rm -f /tmp/keycloak.tar.gz \
    && chown -R kek:kek /opt/keycloak

# COPY --chown=kek:kek themes/ /opt/keycloak/themes/

USER kek
WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build \
      --db=postgres \
      --health-enabled=true \
      --metrics-enabled=true \
      --http-relative-path=/auth

# -----------------------------------------------------------------------------
# Runtime
# -----------------------------------------------------------------------------
FROM alpine:${ALPINE_VERSION}

ARG KC_VERSION
ARG BUILD_REVISION
ARG BUILD_URL
ARG BUILD_TITLE

LABEL org.opencontainers.image.vendor="ihavelapki" \
      org.opencontainers.image.version="${KC_VERSION}" \
      org.opencontainers.image.revision="${BUILD_REVISION}" \
      org.opencontainers.image.url="${BUILD_URL}" \
      org.opencontainers.image.title="${BUILD_TITLE}"

ENV TZ=Europe/Moscow

RUN apk add --no-cache \
      ca-certificates \
      openjdk21-jre-headless \
      tzdata \
    && addgroup -g 40404 kek \
    && adduser -D -H -u 40404 -G kek kek \
    && mkdir -p /opt/keycloak/data/tmp \
    && chown -R kek:kek /opt

COPY --from=builder --chown=kek:kek /opt/keycloak/ /opt/keycloak/

USER kek
WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

EXPOSE 8080 8443 9000
