# Модуль экспорта данных в MS Access (uzvaccess)

## Описание

Модуль `uzvaccess` предназначен для гибкого экспорта данных примитивов (устройства, суперлинии, кабели) из приложения ZCAD в базу данных MS Access.

Экспорт осуществляется на основе управляющих таблиц `EXPORT1`, `EXPORT2`, ..., `EXPORTN`, которые содержат инструкции по маппингу данных из примитивов в целевые таблицы Access.

## Архитектура

Модуль построен по принципу разделения ответственности на три основных слоя:

### 1. DATA LAYER (слой данных)
- `uzvaccess_types.pas` — определение типов данных
- `uzvaccess_config.pas` — конфигурация модуля
- `uzvaccess_entity_adapter.pas` — адаптер для получения свойств примитивов

### 2. LOGIC LAYER (слой бизнес-логики)
- `uzvaccess_parser.pas` — парсинг инструкций из EXPORT-таблиц
- `uzvaccess_validator.pas` — валидация и преобразование типов данных
- `uzvaccess_logger.pas` — логирование процесса экспорта

### 3. DATABASE LAYER (слой работы с БД)
- `uzvaccess_connection.pas` — управление подключением к Access
- `uzvaccess_executor.pas` — выполнение SQL-запросов и вставка данных

### 4. ORCHESTRATION LAYER (слой оркестрации)
- `uzvaccess_exporter.pas` — главный класс TAccessExporter
- `uzvaccess_command.pas` — команда для интеграции с ZCAD

## Формат управляющих таблиц EXPORT

Каждая таблица `EXPORTn` содержит инструкции для экспорта данных в целевую таблицу Access.

### Структура таблицы

Все колонки имеют строковый тип. Каждая строка — это инструкция.

| Col1       | Col2            | Col3    | Col4                 | Col5+ |
|------------|-----------------|---------|----------------------|-------|
| tTable     | TargetTableName |         |                      |       |
| typeData   | device          |         |                      |       |
| setcolumn  | DeviceName      | string  | NMO_BaseName         |       |
| setcolumn  | Power           | float   | VPOWER_Value         |       |
| setcolumn  | Voltage         | integer | VVOLTAGE_Value       |       |

### Поддерживаемые инструкции

#### tTable
Определяет имя целевой таблицы в Access.

- **Col1:** `tTable`
- **Col2:** Имя целевой таблицы

#### typeData
Определяет тип источника данных.

- **Col1:** `typeData`
- **Col2:** Тип данных: `device`, `superline`, `cable`

#### setcolumn
Определяет маппинг колонки.

- **Col1:** `setcolumn`
- **Col2:** Имя колонки в целевой таблице
- **Col3:** Тип данных: `string`, `integer`, `float`
- **Col4:** Имя свойства источника (например, `NMO_BaseName`)
- **Col5+:** Зарезервировано для расширений

#### keyColumn (опционально)
Определяет ключевые колонки для UPSERT.

- **Col1:** `keyColumn`
- **Col2+:** Имена ключевых колонок

#### const (опционально)
Задает константное значение.

- **Col1:** `const`
- **Col2:** Имя колонки
- **Col3:** Константное значение

## Использование

### Базовый пример

```pascal
uses
  uzvaccess_types, uzvaccess_config, uzvaccess_exporter;

var
  config: TExportConfig;
  exporter: TAccessExporter;
  result: TExportResult;
begin
  // Создание конфигурации
  config := TExportConfig.Create;
  try
    config.DatabasePath := 'C:\path\to\database.accdb';
    config.EntityMode := 0;  // Все примитивы
    config.LogFilePath := 'C:\path\to\export.log';

    // Создание экспортера
    exporter := TAccessExporter.Create(config);
    try
      // Выполнение экспорта
      result := exporter.Execute;
      try
        // Вывод статистики
        WriteLn(result.GetSummary);
      finally
        result.Free;
      end;
    finally
      exporter.Free;
    end;
  finally
    config.Free;
  end;
end;
```

### Использование через команду ZCAD

```
// В командной строке ZCAD
AccessExport
```

Команда откроет диалог выбора файла Access и выполнит экспорт.

## Конфигурационный файл

Модуль поддерживает загрузку настроек из INI-файла.

### Пример config.ini

```ini
[Connection]
DatabasePath=C:\Projects\MyProject\data.accdb
Driver=Microsoft Access Driver (*.mdb, *.accdb)

[Behavior]
DryRun=false
StrictValidation=true
AllowNullValues=true
ErrorMode=continue

[Performance]
BatchSize=50
RetryAttempts=3
RetryDelay=1000

[Logging]
LogLevel=info
LogFilePath=C:\Logs\access_export.log
LogToGUI=true

[DataSource]
EntityMode=0
EntityModeParam=
```

### Загрузка конфигурации

```pascal
config := TExportConfig.Create;
config.LoadFromFile('config.ini');
```

## Получение свойств примитивов

Модуль использует механизм переменных (variables) для получения свойств примитивов.

### Примеры имен свойств

- `NMO_BaseName` — базовое имя устройства
- `VPOWER_Value` — мощность
- `VVOLTAGE_Value` — напряжение
- `VSPECIFICATION_Name` — спецификация
- `ENTID_Type` — тип примитива

Адаптер автоматически определяет тип примитива и извлекает соответствующие свойства.

## Обработка ошибок

### Режимы работы при ошибках

- **continue** (по умолчанию) — продолжить обработку следующей таблицы
- **stop** — остановить при первой ошибке

### Повторные попытки

Модуль поддерживает автоматические повторные попытки подключения с экспоненциальной задержкой.

```ini
RetryAttempts=3
RetryDelay=1000  ; начальная задержка в мс
```

## Транзакции

Каждая EXPORT-таблица обрабатывается в отдельной транзакции:

1. Начало транзакции
2. Парсинг инструкций
3. Получение данных из примитивов
4. Вставка/обновление данных в Access
5. **COMMIT** при успехе или **ROLLBACK** при ошибке

## Логирование

Модуль ведет подробное логирование с несколькими уровнями:

- **DEBUG** — отладочная информация
- **INFO** — информационные сообщения
- **WARNING** — предупреждения
- **ERROR** — ошибки

Логи записываются:
- В файл (если указан `LogFilePath`)
- В GUI ZCAD (если `LogToGUI=true`)
- В programlog ZCAD

## Производительность

### Пакетная вставка

Данные вставляются пакетами для повышения производительности:

```ini
BatchSize=50  ; вставлять по 50 строк за раз
```

### Параметризованные запросы

Все SQL-запросы используют параметры для защиты от SQL-инъекций и повышения производительности.

## Расширяемость

### Добавление новых типов инструкций

Модуль поддерживает регистрацию пользовательских обработчиков инструкций:

```pascal
parser.RegisterInstructionHandler('myinstruction', @HandleMyInstruction);
```

### Добавление новых типов источников данных

Можно зарегистрировать обработчики для новых типов примитивов без изменения кода модуля.

## Примеры управляющих таблиц

### Пример 1: Простой экспорт устройств

Таблица `EXPORT1`:

| Col1      | Col2       | Col3    | Col4              | Col5 |
|-----------|------------|---------|-------------------|------|
| tTable    | Devices    |         |                   |      |
| typeData  | device     |         |                   |      |
| setcolumn | DeviceName | string  | NMO_BaseName      |      |
| setcolumn | Power      | float   | VPOWER_Value      |      |
| setcolumn | Voltage    | integer | VVOLTAGE_Value    |      |
| setcolumn | Phase      | string  | VPHASE_Value      |      |

### Пример 2: Экспорт с ключевыми колонками

Таблица `EXPORT2`:

| Col1      | Col2       | Col3    | Col4              | Col5 |
|-----------|------------|---------|-------------------|------|
| tTable    | Cables     |         |                   |      |
| typeData  | cable      |         |                   |      |
| keyColumn | CableName  |         |                   |      |
| setcolumn | CableName  | string  | NMO_BaseName      |      |
| setcolumn | Length     | float   | VLENGTH_Value     |      |
| setcolumn | CrossSection | float | VCROSSSECTION_Value |    |

При наличии `keyColumn` модуль будет обновлять существующие записи вместо вставки дубликатов.

### Пример 3: Экспорт с константами

Таблица `EXPORT3`:

| Col1      | Col2       | Col3    | Col4              | Col5 |
|-----------|------------|---------|-------------------|------|
| tTable    | Equipment  |         |                   |      |
| typeData  | device     |         |                   |      |
| setcolumn | Name       | string  | NMO_BaseName      |      |
| const     | Category   | Electrical |                 |      |
| const     | Status     | Active  |                   |      |

## Тестирование

### Режим Dry Run

Для проверки конфигурации без записи в базу данных используйте режим `DryRun`:

```ini
DryRun=true
```

В этом режиме модуль:
- Подключается к базе данных
- Парсит инструкции
- Получает данные из примитивов
- **НЕ выполняет** вставки/обновления
- Выводит подробную статистику

## Ограничения и известные проблемы

1. MS Access имеет ограничения на размер базы данных (2 ГБ для .mdb, 2 ГБ эффективно для .accdb)
2. Пакетная вставка в Access менее эффективна, чем в других БД
3. Максимальная длина строки в Access — 255 символов для текстовых полей
4. Имена колонок с пробелами должны быть заключены в квадратные скобки

## Структура файлов

```
cad_source/zcad/velec/uzvaccess/
├── README.md                          # Документация (этот файл)
├── uzvaccess_types.pas                # Типы данных
├── uzvaccess_config.pas               # Конфигурация
├── uzvaccess_logger.pas               # Логирование
├── uzvaccess_connection.pas           # Подключение к Access
├── uzvaccess_parser.pas               # Парсер инструкций
├── uzvaccess_entity_adapter.pas       # Адаптер примитивов
├── uzvaccess_validator.pas            # Валидация типов
├── uzvaccess_executor.pas             # Исполнитель экспорта
├── uzvaccess_exporter.pas             # Главный класс
└── uzvaccess_command.pas              # Команда ZCAD
```

## Авторы

@author Vladimir Bobrov

## Лицензия

См. файл COPYING.txt в корне проекта ZCAD.
