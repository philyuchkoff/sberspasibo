## Что такое .timer в systemd

-   Это юнит-таймер (аналог cron-строки), который по расписанию активирует **другой** юнит (обычно `.service`).
-   Живёт отдельно от сервиса: можно включать/выключать/перезапускать таймер, не трогая сервис и наоборот.
-   Все таймеры CentOS 7/8/9 обрабатывает `systemd-timer-generator`, а запускает их `systemd` сам, никаких крон-демонов не надо.

### Сразу: почему использую таймер, а не cron
Если коротко: таймер надежнее, понимает часовые пояса, TZ-переходы, пропущенные события (например, в нужное время машина была недоступна, например, перезагружалась), логируется единообразно и не требует отдельного cron-демона.

### Посмотрим на наш `/etc/systemd/system/sberbot.timer`:

````
[Unit]
Description=Monthly reminder to pick SberSpasibo cashback categories
Requires=sberbot.service          # гарантирует, что сервис существует
# After= и Wants= тут не нужны — таймер сам вызывает сервис

[Timer]
OnCalendar=*-*-01 09:00:00        # 1-е число любого месяца в 09:00:00
TimeZone=Europe/Moscow            # явно указываем часовой пояс
Persistent=true                   # если вдруг машина была выключена,
                                  # и мы проспали событие — запустить сразу
                                  # при следующем включении (только один раз).

# Дополнительные полезные ключи:
# Unit=другой.service             # если нужно запустить не sberbot.service
# AccuracySec=1h                  # точность ±1 ч (по умолчанию 1 мин) - таймер будет запускаться в пределах этой погрешности, что полезно при большом количестве таймеров (размазывает нагрузку)
# RandomizedDelaySec=5min         # добавить 0…5 мин к моменту старта
# OnBootSec=5min                  # запустить ещё и через 5 мин после загрузки
# OnUnitActiveSec=1d              # повторять каждый день (для периодики)

[Install]
WantedBy=timers.target            # автостарт при загрузке системы
````

### Как systemd понимает `OnCalendar`
Формат: `Дата Часы` или `DayOfWeek YYYY-MM-DD HH:MM:SS`.  
Можно комбинировать и писать в одну строку:
| Пример OnCalendar      | Когда                             |
| ---------------------- | --------------------------------- |
| `*-*-01 09:00:00`      | 1-е число любого месяца в 09:00   |
| `Mon *-*-01..07 09:00` | Первый понедельник месяца в 09:00 |
| `Mon..Fri 09:00`       | Каждый будний день в 09:00        |
| `daily`                | Синоним `*-*-* 00:00:00`          |
| `hourly`               | Каждый час в :00                  |
| `Wed *-*-* 14:00:00`   | Каждую среду в 14:00              |

`TimeZone=` берётся из `/usr/share/zoneinfo/…`; если строки нет, используется локаль системы (`/etc/localtime`).
### Про `Persistent=true` 
Если машина была выключена в момент `09:00 1-го числа` (в моем случае), при следующем включении systemd увидит просроченное событие и сразу запустит сервис **один раз**.  
Если выключение длилось несколько долго и пропущено **несколько** запусков, systemd запустит **только последний** пропущенный запуск, а не отыграет всё пропущенное подряд.  
Если вам это не нужно, то уберите строку или поставьте `false`.

### Жизненный цикл таймера
    
1.  `systemctl daemon-reload` — перечитать файлы.
2.  `systemctl enable sberbot.timer` — создаст симлинк в `timers.target.wants`.
3.  `systemctl start sberbot.timer` — таймер активен, появляется в `systemctl list-timers`.
4.  Каждый раз при наступлении события systemd делает `systemctl start sberbot.service`.
5.  Статус таймера можно смотреть: 
`systemctl status sberbot.timer`
`systemctl list-timers sberbot.timer`
6. Таймер можно отключить:
`systemctl stop sberbot.timer`
`systemctl disable sberbot.timer`

### Как изменить расписание без пересоздания файлов
    
-   Отредактируйте `sberbot.timer`.
-   `systemctl daemon-reload`
-   `systemctl restart sberbot.timer` - systemd пересчитает ближайшее срабатывание (`NEXT` в `list-timers`).

### Как проверить, когда сработает в следующий раз
```
$ systemctl list-timers sberbot.timer
NEXT                                 LEFT LAST PASSED UNIT          ACTIVATES
Sun 2026-02-01 09:00:00 MSK 1 week 2 days -         - sberbot.timer sberbot.service

1 timers listed.
Pass --all to see loaded but inactive timers, too.
```

### Где хранит systemd журнал срабатываний
Любой запуск сервиса попадает в общий журнал и его можно посмотреть `journalctl -u sberbot.service`

Факт timer elapsed можно увидеть так: `journalctl -u sberbot.timer`

### Команды
| Действие                                  | Команда                                 |
| ----------------------------------------- | --------------------------------------- |
| Показать все активные таймеры             | `systemctl list-timers`                 |
| Показать только наш                       | `systemctl list-timers sberbot.timer`   |
| Вручную запустить сервис (тест)           | `systemctl start sberbot.service`       |
| Перезапустить таймер после редактирования | `systemctl restart sberbot.timer`       |
| Отключить напоминания                     | `systemctl disable --now sberbot.timer` |
