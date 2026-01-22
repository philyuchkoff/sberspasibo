
# Напоминалка СберСпасибо
### Напоминание первого числа каждого месяца о необходимости выбора категорий в СберСпасибо

После установки демон будет каждое первое число месяца в 09:00 Мск  (UTC+3) слать напоминание "Не забудь зайти в СберСпасибы и выбрать категории для кэшбэка" в нужные Telegram-чаты.

### Установить зависимости
`sudo yum install -y bash curl jq`

### Где что должно лежать
- `/opt/sberbot/sberbot.sh` (0755)
- `/etc/systemd/system/sberbot.timer`
- `/etc/systemd/system/sberbot.service`

### Настройка
В файле `sberbot.sh` в `BOT_TOKEN` нужно указать токен бота, от которого будут отправляться сообщения; в `CHAT_IDS` нужно указать нужные `chat_id` - кому отправлять.

### Запуск
`sudo systemctl daemon-reload`

`sudo systemctl enable --now sberbot.timer`

### Проверка
- cтатус таймера:
`sudo systemctl list-timers sberbot.timer`
- ручной тест
`sudo systemctl start sberbot.service`

Если все работает - в Telegram должно прийти сообщение.

### How to

`BOT_TOKEN`  можно получить у @BotFather

##### Как узнать необходимые `chat_id`
1. Выполните запрос: `curl -s https://api.telegram.org/bot<TOKEN>/getUpdates`
2. Контакт, чей `chat_id` вы хотите узнать, должен или **нажать кнопку Start** или просто **отправить любое сообщение** вашему боту.
3. Повторите команду из пункта 1.
4. Придет ответ, в нем `chat_id` этого контакта:
```"message": {
  "message_id": 123,
  "from": {
    "id": 481234567,          ← это и есть chat_id контакта
    "is_bot": false,
    "first_name": "Иван",
    ...
  },
  "chat": {
    "id": 481234567,          ← то же число
    "type": "private",
    ...
  }
}
```

5.  Повторите операцию для каждого нужного контакта.
6. Если апдейты уже были, а новые не приходят, вызовите `getUpdates` с параметром `offset`, чтобы сбросить очередь:  
`curl -s https://api.telegram.org/bot<TOKEN>/getUpdates?offset=-1`

[Что такое .timer в systemd](about_timer.md)
