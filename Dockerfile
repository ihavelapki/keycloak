ARG ALPINE_VERSION
ARG KC_VERSION

FROM alpine:${ALPINE_VERSION}


MAINTAINER ihavelapki

ENV TZ=Europe/Moscow

ENV KC_V=${KC_VERSION}
RUN printenv

RUN apk update && apk upgrade && apk add --no-cache curl openjdk17 bash && adduser -D kek
 
RUN curl -L https://github.com/keycloak/keycloak/releases/download/${KC_V}/keycloak-${KC_V}.tar.gz -o /tmp/keycloak.tar.gz && \
    tar -xzf /tmp/keycloak.tar.gz -C /opt && \
    rm /tmp/keycloak.tar.gz && \
    mv /opt/keycloak-${KC_V} /opt/keycloak && \
    chown -R kek:kek /opt/keycloak

USER kek
WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

EXPOSE 8080 8443
