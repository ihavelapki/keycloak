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
required_vars=("KC_HOST" "MASTERUSER" "PASSWORD" "REALM_NAME")

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
  LOG_FILE=keycloak_delete_${REALM_NAME}_`date +%Y%m%d`.log
  echo "$LOG_FILE seted as log file name"
fi

echo "-------------------------- START REALM DELETING ---------------------------------------"

# 0. Делаем файл с логом, чтобы потом сохранилось.
echo "0. Create logfile START"
sudo touch $LOG_FILE
sudo chmod 666 $LOG_FILE
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


# Удалить реалм
echo "2. Delete realm ${REALM_NAME} START"
DELETE_STATUS=$(curl -X DELETE "$KC_HOST/admin/realms/$REALM_NAME" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")
  
echo "2. Status (empty - it's ok): ${DELETE_STATUS}" >> $LOG_FILE
echo "2. Realm ${REALM_NAME} has been deleted." >> $LOG_FILE
echo "2. Status (empty - it's ok): ${DELETE_STATUS}"
echo "2. Realm ${REALM_NAME} has been deleted."

echo "-------------------------- SCRIPT FINISHED ---------------------------------------"