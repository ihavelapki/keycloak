#!/bin/bash
echo "-------------------------- START SCRIPT ---------------------------------------"
# Функция для вывода справки по использованию скрипта
usage() {
  echo "Usage: $0 [ -f <logfile> ] --env-file <path_to_env_file>"
  exit 1
}

# Инициализация переменных
LOG_FILE=""
ENV_FILE=""

# Обработка опций командной строки
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -f)
      LOG_FILE="$2"
      shift 2
      ;;
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# Проверка наличия аргументов
if [ -z "$ENV_FILE" ]; then
  usage
fi

# Загрузка переменных из указанного .env файла
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo ".env file not found at $ENV_FILE!"
  exit 1
fi

# Проверка наличия переменных окружения
required_vars=("KC_HOST" "MASTERUSER" "PASSWORD" "REALM_NAME" "NEW_USER" "NEW_CLIENT" "USER_PASSWORD" "FRONT_PORT")

# Флаг для отслеживания отсутствующих переменных
missing_vars=false

# Проверка наличия всех обязательных переменных
for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Required environment variable $var is not set"
    missing_vars=true
  fi
done

# Если есть отсутствующие переменные, завершить выполнение скрипта
if [ "$missing_vars" = true ]; then
  exit 1
fi

# Вывод значений переменных окружения
for var in "${required_vars[@]}"; do
  echo "Value of $var: ${!var}"
done

# Проверка наличия аргументов
if [ -z "$LOG_FILE" ]; then
  LOG_FILE=keycloak_setup_${REALM_NAME}_`date +%Y%m%d`.log
  echo "$LOG_FILE seted as log file name"
fi

echo "-------------------------- START KEYCLOAK SETUP ---------------------------------------"



# 0. Делаем файл с логом, чтобы потом сохранилось.
echo "0. Create logfile START"
sudo touch $LOG_FILE
sudo chmod 666 $LOG_FILE
echo "0. Created logfile ${LOG_FILE}"
echo "--------------------------------------------------------------------------------------------" >> $LOG_FILE
echo "Current date `date +%Y%m%d`" 
echo "Current time `date +%H:%M:%S`"
echo "Current date `date +%Y%m%d`" >> $LOG_FILE
echo "Current time `date +%H:%M:%S`" >> $LOG_FILE

# 1. Получаем токен
echo "1. Get token START"
ADMIN_TOKEN=$(curl -X POST \
"$KC_HOST/realms/master/protocol/openid-connect/token" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d "username=$MASTERUSER&password=$PASSWORD&grant_type=password&client_id=admin-cli" \
| grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

echo "1. Admin token: ${ADMIN_TOKEN}" >> $LOG_FILE
echo "1. Admin token: ${ADMIN_TOKEN}"


# 2. Создаем новый реалм
echo "2. Create new realm ${REALM_NAME} START"
CREATE_NEW_REALM_STATUS=$(curl -X POST "$KC_HOST/admin/realms" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{
    "realm": "'"$REALM_NAME"'",
    "enabled": true
  }')

echo "2. Status (empty - it's ok): ${CREATE_NEW_REALM_STATUS}" >> $LOG_FILE
echo "2. Status (empty - it's ok): ${CREATE_NEW_REALM_STATUS}"
echo "2. Created new realm ${REALM_NAME}" >> $LOG_FILE
echo "2. Created new realm ${REALM_NAME}"


# 3. Задеём опцию, чтобы не нужен был https
echo "3. Set noSSL option START"
SET_NOSSL_RESP=$(curl -X PUT "$KC_HOST/admin/realms/$REALM_NAME" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{
    "sslRequired": "none"
  }')
  
echo "3. Status (empty - it's ok): ${SET_NOSSL_RESP}" >> $LOG_FILE
echo "3. Status (empty - it's ok): ${SET_NOSSL_RESP}"
echo "3. Setted noSSL option" >> $LOG_FILE
echo "3. Setted noSSL option"


# 4. Создаем нового юзера
echo "4. Create new user ${NEW_USER} in realm ${REALM_NAME} START"
CREATE_NEW_USER_STATUS=$(curl -X POST "$KC_HOST/admin/realms/$REALM_NAME/users" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{
    "username": "'"$NEW_USER"'",
    "enabled": true
  }')

echo "4. Status (empty - it's ok): ${CREATE_NEW_USER_STATUS}" >> $LOG_FILE
echo "4. Status (empty - it's ok): ${CREATE_NEW_USER_STATUS}"
echo "4. Created new user ${NEW_USER} in realm ${REALM_NAME}" >> $LOG_FILE
echo "4. Created new user ${NEW_USER} in realm ${REALM_NAME}"


# 5. Плучаем id нового юзера
echo "5. Get id of the new user ${NEW_USER} in realm ${REALM_NAME} START"
NEW_USER_ID=$(curl -s -X GET "$KC_HOST/admin/realms/$REALM_NAME/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  | grep -o '"id":"[^"]*' | cut -d'"' -f4)
  
echo "5. ID of the new user ${NEW_USER} in realm ${REALM_NAME}: ${NEW_USER_ID}" >> $LOG_FILE
echo "5. ID of the new user ${NEW_USER} in realm ${REALM_NAME}: ${NEW_USER_ID}"


# 6. Создаем нового клиента
echo "6. Create new client ${NEW_CLIENT} in realm ${REALM_NAME} START"
CREATE_NEW_CLIENT_STATUS=$(curl -s -X POST "$KC_HOST/admin/realms/$REALM_NAME/clients" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "clientId": "'"$NEW_CLIENT"'",
    "protocol": "openid-connect",
    "enabled": true,
    "publicClient": false,
    "attributes": {"access_type": "confidential"}
  }')

echo "6. Status (empty - it's ok): ${CREATE_NEW_CLIENT_STATUS}" >> $LOG_FILE
echo "6. Status (empty - it's ok): ${CREATE_NEW_CLIENT_STATUS}"
echo "6. Created new client ${NEW_CLIENT} in realm ${REALM_NAME}" >> $LOG_FILE
echo "6. Created new client ${NEW_CLIENT} in realm ${REALM_NAME}"


# 7. Получаем id нового клиента
echo "7. Get id of the new client ${NEW_CLIENT} in realm ${REALM_NAME}" 
NEW_CLIENT_ID=$(curl -s -X GET "$KC_HOST/admin/realms/$REALM_NAME/clients?clientId=$NEW_CLIENT" \
-H "Authorization: Bearer $ADMIN_TOKEN" \
-H 'Content-Type: application/json'  \
| grep -o '"id":"[^"]*' | cut -d'"' -f4)

echo "7. ID of the new client ${NEW_CLIENT} in realm ${REALM_NAME}: ${NEW_CLIENT_ID}" >> $LOG_FILE
echo "7. ID of the new client ${NEW_CLIENT} in realm ${REALM_NAME}: ${NEW_CLIENT_ID}"


# 8.
echo "8. Set redirectUris for the new client ${NEW_CLIENT}. START"
NEW_REDIRECT_URIS="http://"`hostname -f`":${FRONT_PORT}/*"
echo $NEW_REDIRECT_URIS
echo '{"redirectUris": ["'"$NEW_REDIRECT_URIS"'"]}'
STATUS_OF_SETREDIRECT=$(curl -X PUT "$KC_HOST/admin/realms/$REALM_NAME/clients/$NEW_CLIENT_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "redirectUris": ["'"$NEW_REDIRECT_URIS"'"]
  }')

echo "8. Status (empty - it's ok): $STATUS_OF_SETREDIRECT" >> $LOG_FILE
echo "8. Status (empty - it's ok): $STATUS_OF_SETREDIRECT"
echo "8. Setted redirectUris $NEW_REDIRECT_URIS for the new client ${NEW_CLIENT}." >> $LOG_FILE
echo "8. Setted redirectUris $NEW_REDIRECT_URIS for the new client ${NEW_CLIENT}."


# 9. Получаем секрет
echo "9. Get new client ${NEW_CLIENT} secret START"
CREDENTIALS_SECRET=$(curl -s -X GET "$KC_HOST/admin/realms/$REALM_NAME/clients/$NEW_CLIENT_ID/client-secret" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  | grep -o '"value":"[^"]*' | cut -d'"' -f4)

echo "9. New client ${NEW_CLIENT} secret: ${CREDENTIALS_SECRET}" >> $LOG_FILE
echo "9. New client ${NEW_CLIENT} secret: ${CREDENTIALS_SECRET}"


# 10. Смотрим чо есть ваще:
echo "10. View roles:"
ROLE_USERS=$(curl -s -X GET "KC_HOST/admin/realms/$REALM_NAME/roles/view-roles" \
	-H "Authorization: Bearer $ADMIN_TOKEN" \
	-H "Content-Type: application/json" \
	)

echo "10. View Roles ${ROLE_USERS}" >> $LOG_FILE
echo "10. View Roles ${ROLE_USERS}"


# 11. Получить ID клиента Realm-Management
echo "11. Get realm-management client id START"
RM_CLIENT_ID=$(curl -s -X GET "$KC_HOST/admin/realms/$REALM_NAME/clients?clientId=realm-management" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  | grep -o '"id":"[^"]*' | cut -d'"' -f4)

echo "11. Realm-Management client ID: ${RM_CLIENT_ID}" >> $LOG_FILE
echo "11. Realm-Management client ID: ${RM_CLIENT_ID}"


# 12. Импортировать роли реалма
echo "12. Get realm-management roles START"
REALM_ROLES=$(curl -s -X GET "$KC_HOST/admin/realms/$REALM_NAME/clients/${RM_CLIENT_ID}/roles" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json")
  
echo "12. Realm-Management roles: ${REALM_ROLES}" >> $LOG_FILE
echo "12. Realm-Management roles: ${REALM_ROLES}"


# 13. Получить id для каждой роли (сейчас работает некорректно, так как вытягивает не те id)
echo "13. Set roles ids"
VIEW_CLIENTS_ROLE_ID=$(echo "$REALM_ROLES" | grep -oP '"id":"\K[0-9a-f-]+(?=","name":"view-clients")')
VIEW_USERS_ROLE_ID=$(echo "$REALM_ROLES" | grep -oP '"id":"\K[0-9a-f-]+(?=","name":"view-users")')
MANAGE_CLIENTS_ROLE_ID=$(echo "$REALM_ROLES" | grep -oP '"id":"\K[0-9a-f-]+(?=","name":"manage-clients")')
MANAGE_USERS_ROLE_ID=$(echo "$REALM_ROLES" | grep -oP '"id":"\K[0-9a-f-]+(?=","name":"manage-users")')

echo "13. view-clients Role ID: ${VIEW_CLIENTS_ROLE_ID}" >> $LOG_FILE
echo "13. view-users Role ID: ${VIEW_USERS_ROLE_ID}" >> $LOG_FILE
echo "13. manage-clients Role ID: ${MANAGE_CLIENTS_ROLE_ID}" >> $LOG_FILE
echo "13. manage-users Role ID: ${MANAGE_USERS_ROLE_ID}" >> $LOG_FILE
echo "13. view-clients Role ID: ${VIEW_CLIENTS_ROLE_ID}"
echo "13. view-users Role ID: ${VIEW_USERS_ROLE_ID}"
echo "13. manage-clients Role ID: ${MANAGE_CLIENTS_ROLE_ID}"
echo "13. manage-users Role ID: ${MANAGE_USERS_ROLE_ID}"


# 13. Подготовить список ролей для назначения
echo "14. Create roles ids list START"
ROLES_LIST="{ \"id\": \"${VIEW_CLIENTS_ROLE_ID}\", \"name\": \"view-clients\"},{\"id\": \"${VIEW_USERS_ROLE_ID}\", \"name\": \"view-users\"},{\"id\": \"${MANAGE_CLIENTS_ROLE_ID}\", \"name\": \"manage-clients\"},{\"id\": \"${MANAGE_USERS_ROLE_ID}\", \"name\": \"manage-users\"}"

echo "14. Roles list: ${ROLES_LIST}" >> $LOG_FILE
echo "14. Roles list: ${ROLES_LIST}"


# 14. Назначить роли пользователю
echo "15. Set roles to client ${NEW_CLIENT} START"
ASSIGN_ROLES_RESULT=$(curl -s -X POST "$KC_HOST/admin/realms/$REALM_NAME/users/${NEW_USER_ID}/role-mappings/clients/${RM_CLIENT_ID}" \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  -d ["$ROLES_LIST"])

echo "15. Status (empty - it's ok): ${ASSIGN_ROLES_RESULT}"
echo "15. Roles has been setted" >> $LOG_FILE
echo "15. Roles has been setted"


# 15. Назначить пароль пользователю
echo "16. Set password for ${NEW_USER} in realm ${REALM_NAME} START"
SET_PASSWORD_STATUS=$(curl -s -X PUT "$KC_HOST/admin/realms/$REALM_NAME/users/$NEW_USER_ID/reset-password" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "password",
    "value": "'"$USER_PASSWORD"'",
    "temporary": false
  }')
  
echo "16. Status (empty - it's ok): ${SET_PASSWORD_STATUS}"
echo "16. Setted password for ${NEW_USER} in realm ${REALM_NAME}" >> $LOG_FILE
echo "16. Setted password for ${NEW_USER} in realm ${REALM_NAME}"


# 17. Установить флаг "Exclude Issuer From Authentication Response"
echo "17. Set \"Exclude Issuer From Authentication Response\" option to ${NEW_CLIENT} START"
RESP_SET_OPTION=$(curl -X PUT "$KC_HOST/admin/realms/$REALM_NAME/clients/$NEW_CLIENT_ID" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": {
      "exclude.issuer.from.auth.response": true
    }
  }')
echo "17. Status (empty - it's ok): ${RESP_SET_OPTION}"
echo "17. Setted \"Exclude Issuer From Authentication Response\" option to ${NEW_CLIENT}" >> $LOG_FILE
echo "17. Setted \"Exclude Issuer From Authentication Response\" option to ${NEW_CLIENT}"
echo "-------------------------- END SCRIPT ---------------------------------------"
