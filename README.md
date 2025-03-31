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

- `KEYCLOAK_ADMIN`: admin user of the master realm
- `KEYCLOAK_ADMIN_PASSWORD`: 


### **How to run**
```sh
docker compose --env-file .env up -d
```