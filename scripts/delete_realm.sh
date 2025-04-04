#!/bin/bash
echo "-------------------------- START REALM DELETING ---------------------------------------"| tee $LOG_FILE
echo "Current date `date +%Y%m%d`" 
echo "Current time `date +%H:%M:%S`"

# Удалить реалм
echo "2. Delete realm ${REALM_NAME} START"
DELETE_STATUS=$(curl -X DELETE "$KC_HOST/admin/realms/$REALM_NAME" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json")
  
echo "2. Status (empty - it's ok): ${DELETE_STATUS}" >> $LOG_FILE
echo "2. Realm ${REALM_NAME} has been deleted." >> $LOG_FILE

echo "-------------------------- SCRIPT FINISHED ---------------------------------------" tee $LOG_FILE