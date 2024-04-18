FROM openjdk:11-jdk-alpine

# Установка зависимостей
RUN apk add --no-cache bash curl

# Установка Keycloak
ENV KEYCLOAK_VERSION 23.0.3
RUN curl -L https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-${KEYCLOAK_VERSION}.tar.gz -o keycloak.tar.gz && \
    tar -xzf keycloak.tar.gz -C /opt && \
    rm keycloak.tar.gz && \
    mv /opt/keycloak-${KEYCLOAK_VERSION} /opt/keycloak

# Конфигурация рабочей директории и точки входа
WORKDIR /opt/keycloak
ENTRYPOINT ["/opt/keycloak/bin/standalone.sh", "-b", "0.0.0.0"]

# Открытие портов
EXPOSE 8080 8443