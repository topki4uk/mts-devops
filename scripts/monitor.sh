#!/bin/bash

if [ -z "$1" ]; then
    echo "Ошибка: Не указано имя сервиса."
    echo "Использование: $0 <имя_сервиса>"
    exit 1
fi

SERVICE_NAME="$1"

STATUS=$(systemctl is-active "$SERVICE_NAME")

if [ "$STATUS" != "active" ]; then
    echo "Сервис '$SERVICE_NAME' НЕ работает (текущий статус: $STATUS)."
    echo "--- Последние 10 строк лога ---"
    journalctl -u "$SERVICE_NAME" -n 10
else
    echo "Сервис '$SERVICE_NAME' работает."
fi

# Получаем временную метку формата "Мес День Час" для времени час назад
LAST_HOUR_DATE=$(date -d '1 hour ago' '+%b %e %H')
ERROR_COUNT=$(grep -i "error" /var/log/syslog | awk -v hour="$LAST_HOUR_DATE" '$0 ~ hour {count++} END {print count+0}')

echo "Количество ошибок в /var/log/syslog за последний час: $ERROR_COUNT"
