#!/usr/bin/env bash
# /opt/sberbot/sberbot.sh
set -euo pipefail

BOT_TOKEN="ВАШ_ТОКЕН_БОТА"
CHAT_IDS=(111111111 222222222)   # список ваших chat_id через пробел

TEXT="Не забудь зайти в СберСпасибы и выбрать категории для кэшбэка"

for CHAT_ID in "${CHAT_IDS[@]}"; do
  curl -s -X POST \
       https://api.telegram.org/bot${BOT_TOKEN}/sendMessage \
       -d chat_id="${CHAT_ID}" \
       -d text="${TEXT}" \
       -d parse_mode=HTML
done
