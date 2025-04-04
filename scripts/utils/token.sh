#!/bin/bash

# 1. Получаем токен
echo "Get master token for ${USERNAME}"
TOKEN=$(curl -X -k POST "$KC_URL/realms/master/protocol/openid-connect/token" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-d "username=${USERNAME}&password=${PASSWORD}&grant_type=password&client_id=admin-cli" \
| grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

echo "master token: ${TOKEN}"