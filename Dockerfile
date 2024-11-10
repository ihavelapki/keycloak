ARG ALPINE_VERSION
ARG KEYCLOAK_VERSION
FROM alpine:${ALPINE_VERSION}

MAINTAINER ihavelapki

ENV TZ=Europe/Moscow

RUN apk update && apk upgrade && apk add --no-cache curl openjdk17 bash && adduser -D kek

ENV KEYCLOAK_VERSION ${KEYCLOAK_VERSION}
RUN echo "${ALPINE_VERSION} ${KEYCLOAK_VERSION}" && curl -L https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz -o /tmp/keycloak.tar.gz && \
    tar -xzf /tmp/keycloak.tar.gz -C /opt && \
    rm /tmp/keycloak.tar.gz && \
    mv /opt/keycloak-${KEYCLOAK_VERSION} /opt/keycloak && \
    chown -R kek:kek /opt/keycloak

USER kek
WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

EXPOSE 8080 8443
