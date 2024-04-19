FROM adoptopenjdk/openjdk11:jre-11.0.22_7-alpine

RUN apk add --no-cache bash curl

ENV KEYCLOAK_VERSION 24.0.3
RUN curl -L https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz -o keycloak.tar.gz && \
    tar -xzf keycloak.tar.gz -C /opt && \
    rm keycloak.tar.gz && \
    mv /opt/keycloak-${KEYCLOAK_VERSION} /opt/keycloak

WORKDIR /opt/keycloak

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "build"]


EXPOSE 8080 8443
