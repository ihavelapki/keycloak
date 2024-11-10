ARG ALPINE_VERSION

FROM alpine:${ALPINE_VERSION}


MAINTAINER ihavelapki

ENV TZ=Europe/Moscow
ARG KC_VERSION
ENV KC_VERSION=${KC_VERSION}
RUN printenv

RUN apk update && apk upgrade && apk add --no-cache curl openjdk17 bash && adduser -D kek
 
RUN curl -L https://github.com/keycloak/keycloak/releases/download/${KC_VERSION}/keycloak-${KC_VERSION}.tar.gz -o /tmp/keycloak.tar.gz && \
    tar -xzf /tmp/keycloak.tar.gz -C /opt && \
    rm /tmp/keycloak.tar.gz && \
    mv /opt/keycloak-${KC_VERSION} /opt/keycloak && \
    chown -R kek:kek /opt/keycloak

USER kek
WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

EXPOSE 8080 8443
