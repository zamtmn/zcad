# managerem

## Назначение

Модуль экспорта модели электрических устройств в Excel. Предоставляет команды для формирования табличных отчётов на основе данных чертежа.

## Что содержит

### Экспорт в Excel
- `uzvmodeltoxlsxfps.pas` — экспорт модели (fpspreadsheet)
- `uzvmodeltoxlsx.pas` — экспорт модели (альтернативная реализация)
- `uzvdevtoxlsx.pas` — экспорт устройств
- `uzvzcadxlsxfps.pas` — обёртка над fpspreadsheet
- `uzvzcadxlsxole.pas` — работа через OLE (Windows)
- `uzvxlsxtocad.pas` — импорт данных из Excel

### Управление и команды
- `uzvmanemcom.pas` — команды менеджера
- `uzvmanemdialogcom.pas` — диалоговые команды
- `uzvelectricalexcelcom.pas` — электротехнические команды Excel

### Схемы и параметры
- `uzvmanemschemalevelone.pas` — схема первого уровня
- `uzvmanemgetgem.pas` — получение геометрии
- `uzvmanemparams.pas` — параметры менеджера
- `uzvmanemshieldsgroupparams.pas` — параметры групп щитов

## Взаимодействие с другими модулями

**Использует:**
- `fpspreadsheet` — библиотека работы с Excel
- `uzcdrawings` — менеджер чертежей
- `uzeentdevice` — устройства
- `uzcentcable` — кабели
- `uzclog` — логирование

**Используется:**
- Командами CAD для формирования отчётов

## Важно знать

### Возможности
- Экспорт по шаблону с подстановкой данных
- Поддержка формул и форматирования
- Кроссплатформенная работа через fpspreadsheet
- Windows-only: работа через OLE Automation

### Специальные команды в ячейках
- `zdevsettings` — параметры устройств
- `zsetformulatocell` — установка формулы
- `zsetvaluetocell` — установка значения
- `zcalculate` — принудительная калькуляция
