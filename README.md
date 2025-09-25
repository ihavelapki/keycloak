# keycloak

## Table of contents
* [Scripts for configuring Keycloak](./scripts/)
    * [](./scripts/setup_realm.sh)
    * []()
* [Description](#)
    * [Docker compose parameters](#)
    * [How to run](#)
    * [Docker compose](./docker-compose.yml)
    


## **Description**

### **Docker compose parameters**

- `KC_DB_URL`: "jdbc:postgresql://keycloak_db:5432/kcdb"
- `KC_DB_USERNAME`: kcdbadm
- `KC_DB_PASSWORD` - 
- `KEYCLOAK_ADMIN`: admin user of the master realm. Default value is `${KC_MASTER_USER}`. Needed .env file with value of this param. For example `KC_MASTER_USER=masteruser`
- `KEYCLOAK_ADMIN_PASSWORD`: ${KC_MASTER_PASSWORD}
- `KC_LOG_LEVEL`: "ERROR"
- `KC_HTTP_RELATIVE_PATH`: "/auth"
- `KC_HTTPS_CERTIFICATE_FILE`: "/opt/rtl/ssl/tls.crt"
- `KC_HTTPS_CERTIFICATE_KEY_FILE`: "/opt/rtl/ssl/tls.key"
- `KC_PROXY_HEADERS`: "xforwarded"
- `KC_PROXY_PROTOCOL_ENABLED`: true
- `KC_HOSTNAME_STRICT`: false
- `KC_HEALTH_ENABLED`: true

### **How to run**
```sh
docker compose --env-file .env up -d
```