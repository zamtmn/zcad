# Логирование загрузчика DWG

Диагностика загрузчика DWG использует отдельный модуль `DWG` в ZCAD
`programlog`. Модуль регистрируется в `dwg/uzedwglog.pas` без включения по
умолчанию, поэтому обычный импорт DWG не пишет диагностический шум в лог.
Таймеры загрузчика вынесены в отдельный модуль `DWGTIMER`, который также
выключен по умолчанию.

## Как включить лог

Модуль включается обычными ключами `programlog`:

```text
zcad ... logfile <path> lem DWG
```

Таймеры включаются отдельно:

```text
zcad ... logfile <path> lem DWGTIMER
```

Если ранее были включены все модули через `leam`, а сообщения DWG нужно
отключить, используйте обычное отключение модуля:

```text
zcad ... ldm DWG
```

Для отключения только таймеров:

```text
zcad ... ldm DWGTIMER
```

Все новые сообщения загрузчика DWG должны идти через хелперы из
`dwg/uzedwglog.pas`:

- `DWGLogInfoFormatStr`
- `DWGLogWarningFormatStr`
- `DWGLogErrorFormatStr`

Сообщения таймеров должны идти через `dwg/uzedwgtimerlog.pas`:

- `DWGTimerLogTiming`

Не добавляйте новую диагностику загрузчика DWG через `zDebugLn`, `DebugLn` или
проверки переменных окружения.

## Диагностические константы

У загрузчика есть два дополнительных диагностических режима для разработчика.
Оба задаются compile-time константами и оба выключены по умолчанию для
релизного кода.

### Side files и raw trace

В `dwg/uzedwgsidefiles.pas` задано:

```pascal
DWG_DIAG_MODE = dmOff;
```

Допустимые временные значения:

- `dmOff`: не писать side files и raw-object trace.
- `dmSummary`: записать краткие диагностические side files.
- `dmFull`: записать краткие и полные диагностические side files.
- `dmTrace`: записать полную диагностику и raw-object trace через модуль
  `DWG` в `programlog`.

В коммитах для релиза нужно оставлять `dmOff`.

### Точечный trace по handle

В `dwg/uzedwgtargetedlog.pas` задано:

```pascal
DWG_TARGET_HANDLE_LIST = '';
```

Для расследования конкретных handle можно временно задать список и
пересобрать проект:

```pascal
DWG_TARGET_HANDLE_LIST = 'A325E,A08,9FC';
```

Парсер принимает десятичные handle из JSON `dwgread` и hex handle с префиксами
`0x`/`$` или без них. Пустая строка означает, что точечное логирование
неактивно.

## Поведение по умолчанию

По умолчанию должно оставаться так:

- модуль `DWG` в `programlog` выключен, пока его не включили в командной
  строке;
- модуль `DWGTIMER` в `programlog` выключен, пока его не включили в командной
  строке;
- `DWG_DIAG_MODE = dmOff`;
- `DWG_TARGET_HANDLE_LIST = ''`;
- загрузчик DWG не читает переменные окружения `ZCAD_DWG_*`.
