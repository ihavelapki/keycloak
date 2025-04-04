#!/bin/bash

echo "-------------------------- START PARSING ARGS ---------------------------------------"
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

# Флаг для отслеживания отсутствующих переменных
missing_vars=false

# Проверка наличия всех обязательных переменных
for var in "${REQUIRED_VARS[@]}"; do
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
for var in "${REQUIRED_VARS[@]}"; do
  echo "Value of $var: ${!var}"
done

# Проверка наличия аргументов
if [ -z "$LOG_FILE" ]; then
  LOG_FILE=log_`date +%Y%m%d`.log
  echo "$LOG_FILE seted as log file name"
fi