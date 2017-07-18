<h1 align="center">
    <img src="http://s09.radikal.ru/i182/1610/5f/e56ed82e77f8t.jpg" height="25%" width="25%"/>
    <br/>
    SourceBans Material Admin
    <br/>
    Old Plugins for SourceMod
</h1>

### [![GitHub license](https://img.shields.io/badge/license-GPLv3-blue.svg?style=flat-square)](https://github.com/SB-MaterialAdmin/OldServer/blob/master/LICENSE) [![GitHub forks](https://img.shields.io/github/forks/SB-MaterialAdmin/OldServer.svg?style=flat-square)](https://github.com/SB-MaterialAdmin/OldServer/network) [![GitHub stars](https://img.shields.io/github/stars/SB-MaterialAdmin/OldServer.svg?style=flat-square)](https://github.com/SB-MaterialAdmin/OldServer/stargazers) [![GitHub issues](https://img.shields.io/github/issues/SB-MaterialAdmin/OldServer.svg?style=flat-square)](https://github.com/SB-MaterialAdmin/OldServer/issues) [![Travis Build](https://travis-ci.org/SB-MaterialAdmin/OldServer.svg?branch=master)](https://travis-ci.org/SB-MaterialAdmin/OldServer)

### Ссылки
- [Скачать этот плагин](https://github.com/SB-MaterialAdmin/OldServer/archive/master.zip)
- [Ищете новый?](https://github.com/SB-MaterialAdmin/NewServer)
- [Веб-панель](https://github.com/SB-MaterialAdmin/Web)
- [FAQ](https://github.com/SB-MaterialAdmin/Web/wiki/FAQ)

### Описание
Старая вариация плагинов SourceBans.

### Установка
- Если установлен плагин Material Admin:
  - Удалить плагины Material Admin, если используются.
  - Изменить название секции в _/addons/sourcemod/configs/databases.cfg_ с **materialadmin** на **sourcebans**.
- Если не установлен плагин Material Admin:
  - Создать секцию в _/addons/sourcemod/configs/databases.cfg_ с данными от БД, и с именем **sourcebans**.
- Настроить конфиги:
  - _/addons/sourcemod/configs/sourcebans/sourcebans.cfg_
  - _/addons/sourcemod/configs/sourcebans/sourcecomms.cfg_

### О плагинах
| Наименование плагина | Что делает? |
|:--------------------:|-------------|
|**sbpp\_main.sp**     |Сам плагин для выдачи банов. Так же занимается скачиванием Администраторов / групп / оверрайдов в кеш, выдачей Административных прав.|
|**sbpp\_comms**       |Плагин для выдачи мутов. Требует для работы **BaseComms**.|
|**sbpp\_admcfg**      |Плагин для выдачи Административных прав из кеша.|
|**sbpp\_checker**     |Проверяет наличие банов при заходе игроков, оповещает Администраторов.|
|**sbpp\_sleuth**      |Выдаёт баны мульти-аккаунтам. Детектит по IP.|

### Команды
| Команда | Аргументы | Требуемый админ флаг | Что делает? |
|--------:|:---------:|:--------------------:|-------------|
|**sm\_ban**|<#userid\|name> <minutes\|0> [reason]|**ADMFLAG\_BAN**|Бан по SteamID|
|**sm\_banip**|<ip\|#userid\|name> \<time\> [reason]|**ADMFLAG\_BAN**|Бан по IP|
|**sm\_addban**|\<time\> \<steamid\> [reason]|**ADMFLAG\_RCON**|Добавление бана по SteamID|
|**sm\_unban**|<steamid\|ip> [reason]|**ADMFLAG\_UNBAN**|Разбан игрока по IP / SteamID|
|-|-|-|-|
|**sm\_gag**|<#userid\|name> [time] [reason]|**ADMFLAG\_CHAT**|Отключение текстового чата|
|**sm\_mute**|<#userid\|name> [time] [reason]|**ADMFLAG\_CHAT**|Отключение голосового чата|
|**sm\_silence**|<#userid\|name> [time] [reason]|**ADMFLAG\_CHAT**|Отключение всего чата|
|**sm\_ungag**|<#userid\|name> [reason]|**ADMFLAG\_CHAT**|Включение текстового чата|
|**sm\_unmute**|<#userid\|name> [reason]|**ADMFLAG\_CHAT**|Включение голосового чата|
|**sm\_unsilence**|<#userid\|name> [reason]|**ADMFLAG\_CHAT**|Включение всего чата|
|-|-|-|-|
|**sb\_reload**|-|**ADMFLAG\_RCON**|Перезагрузка конфигурации SourceBans.|

### Сортировка в меню Администратора
```
// SourceBans
"PlayerCommands"
{
    "item"  "sm_ban"                // Забанить игрока
}

// SourceComms
"sourcecomm_cmds"
{
    "item"  "sourcecomm_gag"        // Блокировка текстового чата
    "item"  "sourcecomm_mute"       // Блокировка голосового чата
    "item"  "sourcecomm_silence"    // Блокировка всего чата

    "item"  "sourcecomm_ungag"      // Разблокировка текстового чата
    "item"  "sourcecomm_unmute"     // Разлокировка голосового чата
    "item"  "sourcecomm_unsilence"  // Блокировка текстового чата

    "item"  "sourcecomm_list"       // Просмотр игроков на сервере с блокировками и причинами
}
```

### Для скриптеров
|include-файл|Тип|Название|Аргументы|Описание|Что возвращает?|
|:----------:|:-:|--------|---------|--------|:-------------:|
|**sourcebans**|**forward**|**SourceBans\_OnBanPlayer**|int iClient, int iTarget, int iTime, char szReason[]|Событие, вызывается при выдаче бана игроку. **iClient** - Администратор, выдающий бан; **iTarget** - игрок, который получает бан; **iTime** - время бана, в минутах (0 - перманент); **szReason** - причина.|void|
|**sourcebans**|**native**|**SBBanPlayer** / **SourceBans\_BanPlayer**|int iClient, int iTarget, int iTime, char[] szReason|Выдача бана игроку. **Обратите внимание**: Функция **SBBanPlayer()** помечена как Deprecated. По возможности, используйте **SourceBans\_BanPlayer()**.|void|
|**sourcebans**|**native**|**SBGetAdminExpire** / **SourceBans\_GetAdminExpire**|AdminId iAID|Возвращает время истечения админки игрока. Вернёт -1, если не найдено; 0 - перманент; любое другое число - timestamp. **Обратите внимание**: Функция **SBGetAdminExpire()** помечена как Deprecated. По возможности, используйте **SourceBans\_GetAdminExpire()**.|int|

Функции SourceComms скоро будут добавлены...