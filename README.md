
# Напоминалка СберСпасибо
### Напоминание первого числа каждого месяца о необходимости выбора категорий в СберСпасибо

После установки демон будет каждое первое число месяца в 09:00 Мск  (UTC+3) слать напоминание "Не забудь зайти в СберСпасибы и выбрать категории для кэшбэка" в нужные Telegram-чаты.

1. Установить зависимости
`sudo yum install -y bash curl jq`

2. Где что должно лежать
`/opt/sberbot/sberbot.sh` (0755)
`/etc/systemd/system/sberbot.timer`
`/etc/systemd/system/sberbot.service`

3. Настройка
В файле `sberbot.sh` в `BOT_TOKEN` нужно указать токен бота, от которого будут отправляться сообщения; в `CHAT_IDS` нужно указать нужные `chat_id` - кому отправлять.

5. Запуск
`sudo systemctl daemon-reload`
`sudo systemctl enable --now sberbot.timer`

6. Проверка
- cтатус таймера:
`sudo systemctl list-timers sberbot.timer`
- ручной тест
`sudo systemctl start sberbot.service`

Если все работает - в Telegram должно прийти сообщение.
