# Исправленное техническое задание — Модуль выгрузки данных в MS Access

## Версия: 2.0 (с учетом уточнений veb86)

---

## 0. Краткое описание изменений от исходного ТЗ

### Принятые решения по пробелам:

1. **Пробел №1 (Маппинг свойств примитивов)**: Принято предложение полностью — использовать механизм переменных через `FindVariableInEnt()`, создать адаптер `TEntityPropertyAdapter`
2. **Пробел №2 (Порядок колонок)**: Принято предложение полностью — использовать имена колонок вместо номеров
3. **Пробел №3 (Стратегия обновления)**: **ИЗМЕНЕНО** — перед заполнением данных целевая таблица полностью очищается (DELETE). Не используем UPSERT
4. **Пробел №4 (Связь примитивов и TVElectrDevStruct)**: **ИЗМЕНЕНО** — используем только `uzvgetentity` возвращающий `PGDBObjEntity`. `TVElectrDevStruct` в новом модуле **НЕ ИСПОЛЬЗУЕТСЯ**
5. **Пробел №5 (Обработка NULL)**: **ИЗМЕНЕНО** — любая ошибка должна приводить к прекращению работы команды импорта с выводом в командную строку `zcUI` причин остановки. Данные имеют значение только тогда, когда они выгружены правильно
6. **Пробел №6 (Валидация типов)**: **ИЗМЕНЕНО** — валидацию типов должен решать пользователь. Если в столбце float, значит тип загружаемых данных должен быть float. Если нет — ошибка и вывод сообщения в командную строку
7. **Пробел №7 (Batch size)**: Принято предложение полностью
8. **Пробел №8 (Фильтрация примитивов)**: Принято предложение полностью
9. **Пробел №9 (Логирование)**: **ИЗМЕНЕНО** — использовать встроенный логгер `uzclog.pas`. Использовать только `LM_Info`
10. **Пробел №10 (Расширяемость парсера)**: Принято предложение полностью

### Ключевые отличия от исходного ТЗ:

- ✅ Используем **только** `PGDBObjEntity` из `uzvgetentity.pas`
- ✅ **НЕ используем** `TVElectrDevStruct`
- ✅ Перед экспортом **очищаем** целевую таблицу полностью
- ✅ Любая ошибка → **остановка** всего процесса с выводом причины
- ✅ Строгая валидация типов: несоответствие типа → **ошибка**
- ✅ Логирование только через `uzclog.pas` с уровнем `LM_Info`

---

## 1. Цель

Обеспечить перенос данных (device, superline, cable) из программы ZCAD в MS Access по управляющим таблицам `EXPORTn`, где каждая строка таблицы — инструкция по заполнению целевой таблицы Access.

**Требования:**
- Максимальная конфигурируемость без перекомпиляции (правила хранятся в таблицах Access)
- Использование только примитивов `PGDBObjEntity` из `uzvgetentity.pas`
- Строгая обработка ошибок — любая ошибка останавливает процесс
- Очистка целевых таблиц перед заполнением
- Гибкая OOP-архитектура с разделением по слоям

---

## 2. Общая логика работы (workflow)

1. **Запуск команды** «импортировать в Access» (команда экспорта)

2. **Выбор файла Access:**
   - Если в команде указан файл Access — используется он
   - Если не указан — открывается диалог выбора файла `.mdb` или `.accdb`

3. **Подключение к Access** и получение списка таблиц с именами `EXPORT1`, `EXPORT2`, ... `EXPORTN`
   - Выбирать по порядку номера 1..N
   - Сортировка по возрастанию номера

4. **Обработка экспортных таблиц последовательно:**
   - Сначала `EXPORT1`, потом `EXPORT2` и т.д.

5. **Для каждой `EXPORTn`:**

   a. **Чтение всех строк** таблицы `EXPORTn` (по порядку)

   b. **Парсинг инструкций** — формирование объекта `TExportInstructions`:
      - Имя целевой таблицы (`tTable`)
      - Тип данных источника (`typeData`: device/superline/cable)
      - Маппинг колонок (`setcolumn`)

   c. **Очистка целевой таблицы** — выполнить `DELETE * FROM <TargetTable>`

   d. **Получение данных из источника** — вызов `uzvGetEntity()` для получения примитивов типа `PGDBObjEntity`

   e. **Фильтрация примитивов** по `typeData` (device/superline/cable)

   f. **Маппинг данных** — для каждого примитива:
      - Извлечь свойства по именам из `setcolumn` через `FindVariableInEnt()`
      - Валидировать типы данных (string/integer/float)
      - При ошибке валидации → **остановка** с выводом ошибки

   g. **Вставка данных** в целевую таблицу Access:
      - Пакетная вставка (по умолчанию 50 строк за раз)
      - Параметризованные запросы (защита от SQL-инъекций)

   h. **Commit транзакции** для текущей `EXPORTn`

   i. **Логирование статистики** — количество вставленных строк

6. **Возврат результата:**
   - Общая статистика по всем таблицам
   - Вывод в командную строку `zcUI`

7. **Обработка ошибок:**
   - При любой ошибке — **ROLLBACK** текущей транзакции
   - Вывод детального сообщения об ошибке в `zcUI`
   - **ОСТАНОВКА** всего процесса экспорта

---

## 3. Требования к функционалу

### 3.1 Обязательные функции модуля

1. **Подключение/отключение к базе Access**
   - Поддержка ODBC драйвера для `.mdb` и `.accdb`
   - Строка подключения: `Driver={Microsoft Access Driver (*.mdb, *.accdb)};Dbq=<path>`

2. **Поиск и перечисление экспортных таблиц**
   - Шаблон: `EXPORT\d+` (EXPORT1, EXPORT2, ... EXPORTN)
   - Сортировка по возрастанию номера

3. **Чтение управляющей таблицы `EXPORTn`**
   - Все столбцы — строкового типа
   - Чтение построчно в порядке следования

4. **Парсинг инструкций** (см. §4)

5. **Получение списка примитивов через `uzvgetentity.pas`**
   - Использовать функцию `uzvGetEntity(mode, param)`
   - Поддержка всех 3 режимов: 0 (все), 1 (выделенные), 2 (по ENTID_Type)

6. **Извлечение свойств примитивов**
   - Использовать `FindVariableInEnt()` для получения значений переменных
   - Поддержка произвольных имен свойств (например: `NMO_BaseName`, `VSPECIFICATION_Name`)

7. **Очистка целевой таблицы** перед заполнением
   - `DELETE * FROM <TargetTable>`

8. **Формирование данных для целевой таблицы и запись в Access**
   - Параметризованные запросы (prepared statements)
   - Пакетная вставка (batch insert)

9. **Commit после каждой `EXPORTn`**
   - Использовать транзакции Access
   - Commit при успехе, Rollback при ошибке

10. **Логирование через `uzclog.pas`**
    - Использовать только уровень `LM_Info`
    - Формат: `[MODULE] Message`

11. **Строгая валидация типов**
    - При несоответствии типа данных → **ошибка + остановка**
    - Например: если колонка `float`, а значение не преобразуется в float → ошибка

12. **Обработка ошибок**
    - Любая ошибка → вывод в `zcUI` + остановка процесса
    - Не использовать режимы "продолжить при ошибке"

### 3.2 Нефункциональные требования

1. **Язык и стиль кода:**
   - FreePascal/Delphi в стиле проекта ZCAD
   - Соответствие стандартам кодирования из `CLAUDE.md`
   - Комментарии на русском языке
   - Модули не более 300-500 строк
   - Функции не более 30 строк

2. **Архитектура:**
   - Разделение на слои: Data, Logic, Database (см. §5)
   - Каждый класс — одна ответственность
   - Интерфейсы для расширяемости

3. **Размещение файлов:**
   - Новый модуль в `cad_source/zcad/velec/uzvaccess/`
   - Подпапки: `core/`, `data/`, `logic/`, `database/`, `command/`

4. **Документация:**
   - Комментарии в стиле проекта
   - Блок служебной информации в начале каждого файла
   - README.md с примерами использования
   - Примеры конфигурации таблиц EXPORT

5. **Производительность:**
   - Пакетная вставка (по умолчанию 50 строк)
   - Использование подготовленных запросов

6. **Транзакции:**
   - Commit по каждой EXPORT-таблице
   - Rollback при ошибке

7. **Безопасность:**
   - Параметризованные запросы (защита от SQL-инъекций)
   - Валидация всех входных данных

8. **Совместимость:**
   - Не ломать существующий код
   - Не использовать `TVElectrDevStruct` из `uzvmcaccess.pas`

---

## 4. Формат управляющей таблицы (EXPORTn)

### 4.1 Общие правила

- Все поля в таблице — **строкового типа**
- Каждая строка — инструкция
- Порядок строк важен
- Первая колонка (`Col1`) — тип инструкции

### 4.2 Пример минимального содержимого EXPORTn

| Col1      | Col2                 | Col3    | Col4                     | Col5 |
|-----------|----------------------|---------|--------------------------|------|
| tTable    | MyDevicesTable       |         |                          |      |
| typeData  | device               |         |                          |      |
| setcolumn | DeviceName           | string  | NMO_BaseName             |      |
| setcolumn | DevicePower          | float   | POWER                    |      |
| setcolumn | DeviceVoltage        | integer | VOLTAGE                  |      |
| setcolumn | Specification        | string  | VSPECIFICATION_Name      |      |

### 4.3 Обязательные управляющие параметры

#### `tTable` — имя целевой таблицы

- **Col1:** `tTable`
- **Col2:** Имя целевой таблицы в Access для заполнения
- **Обязателен:** Да
- **Количество:** 1 раз (первая встреченная строка с `tTable` определяет имя)

**Пример:**
```
tTable | MyDevicesTable
```

#### `typeData` — тип данных источника

- **Col1:** `typeData`
- **Col2:** Тип примитивов: `device`, `superline`, или `cable`
- **Обязателен:** Да
- **Количество:** 1 раз

**Описание:** Указывает, из какого набора примитивов брать данные. Примитивы фильтруются по `GetObjType()`:
- `device` → `GDBDeviceID`
- `superline` → `GDBSuperLineID`
- `cable` → `GDBCableID`

**Пример:**
```
typeData | device
```

#### `setcolumn` — определение маппинга колонок

- **Col1:** `setcolumn`
- **Col2:** **Имя колонки** в целевой таблице Access
- **Col3:** Тип данных: `string`, `integer`, или `float`
- **Col4:** Имя свойства (переменной) примитива-источника
- **Col5 и далее:** Зарезервировано для будущих расширений

**Обязателен:** Да (минимум 1, обычно несколько)

**Валидация типов:**
- Значение из примитива должно преобразовываться в указанный тип
- При ошибке преобразования → **остановка** с выводом ошибки

**Пример:**
```
setcolumn | DeviceName    | string  | NMO_BaseName
setcolumn | Power         | float   | POWER
setcolumn | Voltage       | integer | VOLTAGE
```

### 4.4 Поведение при заполнении целевой таблицы

1. **Очистка таблицы:** Перед вставкой данных выполняется `DELETE * FROM <TargetTable>`
2. **Вставка:** Только INSERT (без UPDATE/UPSERT)
3. **Порядок:** Вставка в порядке обработки примитивов

### 4.5 Будущие расширения (рекомендуется предусмотреть точки расширения)

- `const` — задать постоянное значение для колонки
- `expr` — вычисляемое выражение (например `concat(NMO_BaseName,'_',ID)`)
- `format` — форматирование даты/числа
- `filter` — фильтрация примитивов по условию

**Механизм расширения:** Паттерн Strategy + Registry для регистрации обработчиков новых инструкций

---

## 5. OOP-архитектура модуля

### 5.1 Общая структура (слои)

```
┌─────────────────────────────────────────────────────────────┐
│                      COMMAND LAYER                          │
│  uzvaccess_command.pas - команда экспорта ZCAD              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                      │
│  uzvaccess_exporter.pas - TAccessExporter (главный класс)   │
└─────────────────────────────────────────────────────────────┘
                            ↓
        ┌──────────────────┼──────────────────┐
        ↓                  ↓                  ↓
┌──────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   DATA       │  │     LOGIC        │  │    DATABASE      │
│   LAYER      │  │     LAYER        │  │    LAYER         │
└──────────────┘  └──────────────────┘  └──────────────────┘

DATA LAYER (работа с примитивами):
  - uzvaccess_entity_adapter.pas   - TEntityPropertyAdapter
  - uzvaccess_source_provider.pas  - IDataSourceProvider (interface)

LOGIC LAYER (парсинг и обработка):
  - uzvaccess_parser.pas           - TExportTableParser
  - uzvaccess_instructions.pas     - TExportInstruction (типы)
  - uzvaccess_validator.pas        - TTypeValidator
  - uzvaccess_mapper.pas           - TDataMapper

DATABASE LAYER (работа с Access):
  - uzvaccess_connection.pas       - TAccessConnection
  - uzvaccess_executor.pas         - TExportExecutor
  - uzvaccess_transaction.pas      - TTransactionManager

UTILITY LAYER:
  - uzvaccess_config.pas           - TExportConfig
  - uzvaccess_types.pas            - общие типы и константы
```

### 5.2 Ключевые классы и интерфейсы

#### 5.2.1 Главный класс — TAccessExporter

```pascal
type
  TAccessExporter = class
  private
    FConfig: TExportConfig;
    FConnection: TAccessConnection;
    FSourceProvider: IDataSourceProvider;
    FParser: TExportTableParser;
    FExecutor: TExportExecutor;
  public
    constructor Create(AConfig: TExportConfig);
    destructor Destroy; override;

    // Главный метод выполнения экспорта
    // Возвращает результат или выбрасывает исключение при ошибке
    function Execute(const AAccessFile: string = ''): TExportResult;

    // Вспомогательные методы
    function ValidateConfiguration: Boolean;
    function GetExportTables: TStringArray;
  end;
```

**Ответственность:**
- Координация всего процесса экспорта
- Управление жизненным циклом компонентов
- Обработка ошибок верхнего уровня

#### 5.2.2 Интерфейс источника данных — IDataSourceProvider

```pascal
type
  IDataSourceProvider = interface
    ['{GUID-HERE}']

    // Получить список примитивов для экспорта
    // ATypeData: 'device', 'superline', или 'cable'
    function GetEntities(const ATypeData: string): TEntityVector;

    // Получить значение свойства примитива по имени
    // AEntity: PGDBObjEntity
    // APropName: имя переменной (например 'NMO_BaseName')
    // Возвращает Variant или Unassigned если не найдено
    function GetPropertyValue(AEntity: Pointer;
                             const APropName: string): Variant;

    // Проверить наличие свойства у примитива
    function HasProperty(AEntity: Pointer;
                        const APropName: string): Boolean;
  end;
```

**Реализация:**

```pascal
type
  TEntitySourceProvider = class(TInterfacedObject, IDataSourceProvider)
  private
    FEntityMode: Integer;      // режим uzvGetEntity (0, 1, 2)
    FEntityModeParam: string;  // параметр для режима 2
  public
    constructor Create(AMode: Integer; const AParam: string);

    function GetEntities(const ATypeData: string): TEntityVector;
    function GetPropertyValue(AEntity: Pointer;
                             const APropName: string): Variant;
    function HasProperty(AEntity: Pointer;
                        const APropName: string): Boolean;
  end;
```

**Реализация GetPropertyValue:**
- Использует `FindVariableInEnt()` для поиска переменной
- Получает значение через `pvd^.data.PTD.GetValueAsString()`
- При необходимости преобразует в нужный тип

#### 5.2.3 Парсер инструкций — TExportTableParser

```pascal
type
  TExportInstruction = class
  public
    InstructionType: string;  // 'tTable', 'typeData', 'setcolumn', etc.
    Parameters: TStringList;   // Col1, Col2, Col3, ...
  end;

  TColumnMapping = class
  public
    ColumnName: string;      // имя колонки в Access
    DataType: string;        // 'string', 'integer', 'float'
    SourceProperty: string;  // имя свойства в примитиве
  end;

  TExportInstructions = class
  private
    FTargetTable: string;
    FTypeData: string;
    FColumnMappings: TObjectList; // TObjectList<TColumnMapping>
  public
    constructor Create;
    destructor Destroy; override;

    property TargetTable: string read FTargetTable;
    property TypeData: string read FTypeData;
    property ColumnMappings: TObjectList read FColumnMappings;

    procedure SetTargetTable(const AValue: string);
    procedure SetTypeData(const AValue: string);
    procedure AddColumnMapping(AMapping: TColumnMapping);
  end;

  TExportTableParser = class
  private
    FInstructionHandlers: TDictionary; // <string, TInstructionHandler>
  public
    constructor Create;
    destructor Destroy; override;

    // Парсинг таблицы EXPORT
    // При ошибке парсинга выбрасывает исключение
    function Parse(const ATableName: string;
                  ADataset: TDataset): TExportInstructions;

    // Регистрация обработчиков (расширяемость)
    procedure RegisterHandler(const AInstruction: string;
                             AHandler: TInstructionHandler);
  end;
```

#### 5.2.4 Валидатор типов — TTypeValidator

```pascal
type
  TTypeValidator = class
  public
    // Валидация и преобразование типов
    // При ошибке преобразования выбрасывает исключение
    class function ValidateAndConvert(const AValue: Variant;
                                     const ATargetType: string): Variant;

    // Вспомогательные методы
    class function IsValidInteger(const AValue: Variant): Boolean;
    class function IsValidFloat(const AValue: Variant): Boolean;
  end;
```

**Поведение:**
- Строгая валидация — несоответствие типа → исключение
- Примеры:
  - `string` → всегда успех
  - `integer` → проверка через `TryStrToInt()`
  - `float` → проверка через `TryStrToFloat()`

#### 5.2.5 Исполнитель экспорта — TExportExecutor

```pascal
type
  TExportTableResult = record
    TableName: string;
    RowsProcessed: Integer;
    RowsInserted: Integer;
    Success: Boolean;
    ErrorMessage: string;
  end;

  TExportExecutor = class
  private
    FConnection: TAccessConnection;
    FTransaction: TTransactionManager;
    FBatchSize: Integer;
  public
    constructor Create(AConnection: TAccessConnection;
                      ABatchSize: Integer = 50);
    destructor Destroy; override;

    // Выполнение экспорта для одной EXPORT-таблицы
    // При ошибке выбрасывает исключение (откат произойдет автоматически)
    function ExecuteExport(AInstructions: TExportInstructions;
                          ADataSource: IDataSourceProvider): TExportTableResult;
  private
    // Очистка целевой таблицы
    procedure ClearTargetTable(const ATableName: string);

    // Вставка данных пакетом
    procedure InsertBatch(const ATableName: string;
                         AColumnMappings: TObjectList;
                         AData: TDataRows);
  end;
```

#### 5.2.6 Конфигурация — TExportConfig

```pascal
type
  TExportConfig = class
  public
    // Подключение
    DatabasePath: string;
    ConnectionString: string;

    // Источник данных
    EntityMode: Integer;       // режим uzvGetEntity (0, 1, 2)
    EntityModeParam: string;   // параметр для режима 2

    // Производительность
    BatchSize: Integer;        // по умолчанию 50

    constructor Create;

    // Валидация конфигурации
    function Validate: Boolean;
  end;
```

---

## 6. Workflow выполнения (детально)

```
1. Команда UzvAccessExport вызывается
   │
   ├─ Парсинг параметров команды (путь к Access или пусто)
   │
   └─ Создание TAccessExporter
   ↓
2. TAccessExporter.Execute(AAccessFile)
   │
   ├─ Если AAccessFile пусто → показать диалог выбора файла
   │
   ├─ Загрузка конфигурации (TExportConfig)
   │
   ├─ Валидация конфигурации
   │  ├─ Проверка существования файла Access
   │  └─ Проверка валидности параметров
   │
   └─ Логирование: "Starting export to <file>"
   ↓
3. Подключение к Access
   │
   ├─ TAccessConnection.Connect()
   │  ├─ Формирование строки подключения ODBC
   │  ├─ Подключение к БД
   │  └─ При ошибке → исключение + вывод в zcUI
   │
   └─ Логирование: "Connected to Access database"
   ↓
4. Получение списка EXPORT-таблиц
   │
   ├─ Запрос метаданных БД
   │
   ├─ Фильтрация таблиц по шаблону EXPORT\d+
   │
   ├─ Сортировка по номеру (EXPORT1, EXPORT2, ...)
   │
   └─ Логирование: "Found N export tables"
   ↓
5. Для каждой EXPORT-таблицы (цикл):
   │
   ├─ 5.1. Логирование: "Processing table EXPORTn"
   │
   ├─ 5.2. Чтение строк таблицы EXPORTn
   │    └─ SELECT * FROM EXPORTn
   │
   ├─ 5.3. Парсинг инструкций
   │    │
   │    ├─ TExportTableParser.Parse()
   │    │
   │    ├─ Обработка каждой строки:
   │    │  ├─ Если Col1 = 'tTable' → сохранить имя целевой таблицы
   │    │  ├─ Если Col1 = 'typeData' → сохранить тип данных
   │    │  ├─ Если Col1 = 'setcolumn' → добавить маппинг колонки
   │    │  └─ Иначе → ошибка "Unknown instruction"
   │    │
   │    ├─ Валидация результата:
   │    │  ├─ Проверка наличия tTable → если нет, исключение
   │    │  ├─ Проверка наличия typeData → если нет, исключение
   │    │  └─ Проверка наличия хотя бы одного setcolumn → если нет, исключение
   │    │
   │    └─ Возврат TExportInstructions
   │
   ├─ 5.4. Логирование: "Target table: <name>, TypeData: <type>"
   │
   ├─ 5.5. Очистка целевой таблицы
   │    │
   │    ├─ TExportExecutor.ClearTargetTable()
   │    │
   │    ├─ DELETE * FROM <TargetTable>
   │    │
   │    └─ Логирование: "Cleared target table"
   │
   ├─ 5.6. Получение данных из источника
   │    │
   │    ├─ IDataSourceProvider.GetEntities(typeData)
   │    │  └─ Вызов uzvGetEntity(mode, param)
   │    │
   │    ├─ Фильтрация по типу (device/superline/cable)
   │    │  └─ Проверка GetObjType() каждого примитива
   │    │
   │    └─ Логирование: "Found M entities"
   │
   ├─ 5.7. Маппинг данных
   │    │
   │    ├─ Для каждого примитива (цикл):
   │    │  │
   │    │  ├─ Для каждого ColumnMapping:
   │    │  │  │
   │    │  │  ├─ Извлечь значение свойства
   │    │  │  │  └─ IDataSourceProvider.GetPropertyValue(entity, propName)
   │    │  │  │     └─ FindVariableInEnt() + GetValueAsString()
   │    │  │  │
   │    │  │  ├─ Валидировать тип
   │    │  │  │  └─ TTypeValidator.ValidateAndConvert(value, dataType)
   │    │  │  │     └─ При ошибке → исключение + вывод в zcUI
   │    │  │  │
   │    │  │  └─ Добавить в строку данных
   │    │  │
   │    │  └─ Добавить строку в пакет (batch)
   │    │
   │    └─ Логирование: "Mapped M rows"
   │
   ├─ 5.8. Выполнение экспорта
   │    │
   │    ├─ TExportExecutor.ExecuteExport()
   │    │
   │    ├─ Начало транзакции
   │    │
   │    ├─ Вставка данных пакетами:
   │    │  │
   │    │  ├─ Разбить данные на батчи (по BatchSize)
   │    │  │
   │    │  ├─ Для каждого батча:
   │    │  │  │
   │    │  │  ├─ Формирование INSERT запроса
   │    │  │  │  └─ INSERT INTO <Table> (col1, col2, ...) VALUES (?, ?, ...)
   │    │  │  │
   │    │  │  ├─ Установка параметров
   │    │  │  │
   │    │  │  ├─ Выполнение ExecSQL
   │    │  │  │
   │    │  │  └─ При ошибке → исключение
   │    │  │
   │    │  └─ Логирование: "Inserted X rows"
   │    │
   │    ├─ COMMIT транзакции
   │    │
   │    └─ Логирование: "Export completed for EXPORTn"
   │
   └─ При ошибке на любом этапе:
      │
      ├─ ROLLBACK транзакции
      │
      ├─ Вывод ошибки в zcUI.TextMessage()
      │
      ├─ Логирование ошибки (LM_Info)
      │
      └─ Выброс исключения (остановка всего процесса)
   ↓
6. Возврат общей статистики
   │
   ├─ TExportResult с данными по всем таблицам
   │
   ├─ Вывод итогов в zcUI
   │
   └─ Логирование: "Export finished successfully"
   ↓
7. Закрытие соединения
   │
   └─ TAccessConnection.Disconnect()
```

---

## 7. Обработка ошибок

### 7.1 Стратегия обработки

**Принцип:** Любая ошибка приводит к **немедленной остановке** всего процесса экспорта.

| Уровень | Ошибка | Действие |
|---------|--------|----------|
| Connection | Не удалось подключиться к Access | Вывод ошибки → **STOP** |
| Parsing | Неверная инструкция в EXPORT | Вывод ошибки → **STOP** |
| Validation | Отсутствует обязательная инструкция (tTable/typeData) | Вывод ошибки → **STOP** |
| Data Extraction | Свойство не найдено в примитиве | Вывод ошибки → **STOP** |
| Type Validation | Неверный тип данных (string → integer) | Вывод ошибки → **STOP** |
| Execution | SQL ошибка при вставке | Rollback → Вывод ошибки → **STOP** |

### 7.2 Формат вывода ошибок

**В командную строку (zcUI):**
```
Ошибка экспорта в Access: <детальное описание ошибки>
Таблица: EXPORTn
Строка: <номер строки при парсинге>
Причина: <текст ошибки>
```

**В лог (uzclog.pas):**
```pascal
programlog.LogOutFormatStr(
  'uzvaccess: ERROR - %s (Table: %s, Row: %d)',
  [ErrorMessage, TableName, RowNumber],
  LM_Info
);
```

### 7.3 Реализация обработки ошибок

```pascal
type
  EAccessExportError = class(Exception)
  private
    FTableName: string;
    FRowNumber: Integer;
  public
    constructor Create(const AMessage, ATableName: string; ARowNumber: Integer);
    property TableName: string read FTableName;
    property RowNumber: Integer read FRowNumber;
  end;

// Пример использования
procedure TExportTableParser.ParseRow(ARow: TDataset; ARowNum: Integer);
begin
  try
    // парсинг
  except
    on E: Exception do
      raise EAccessExportError.Create(
        'Ошибка парсинга: ' + E.Message,
        FCurrentTableName,
        ARowNum
      );
  end;
end;
```

---

## 8. Расширяемость архитектуры

### 8.1 Добавление новых инструкций

**Механизм:** Паттерн Strategy + Registry

```pascal
type
  TInstructionHandler = function(AParams: TStringList;
                                 AInstructions: TExportInstructions): Boolean;

// Регистрация нового обработчика
Parser.RegisterHandler('const', @HandleConstInstruction);

// Обработчик
function HandleConstInstruction(AParams: TStringList;
                               AInstructions: TExportInstructions): Boolean;
begin
  // Col1='const', Col2=ColumnName, Col3=Value
  // Добавление константного значения для колонки
  AInstructions.AddConstValue(AParams[1], AParams[2]);
  Result := True;
end;
```

### 8.2 Добавление новых типов источников

**Возможность:** Реализация дополнительных `IDataSourceProvider`

```pascal
type
  TCustomSourceProvider = class(TInterfacedObject, IDataSourceProvider)
  public
    function GetEntities(const ATypeData: string): TEntityVector; override;
    function GetPropertyValue(...): Variant; override;
    function HasProperty(...): Boolean; override;
  end;
```

### 8.3 Добавление новых типов данных

**Возможность:** Расширение `TTypeValidator`

```pascal
class function TTypeValidator.ValidateAndConvert(
  const AValue: Variant;
  const ATargetType: string): Variant;
begin
  case LowerCase(ATargetType) of
    'string':  Result := VarToStr(AValue);
    'integer': Result := ConvertToInteger(AValue);
    'float':   Result := ConvertToFloat(AValue);
    'date':    Result := ConvertToDate(AValue);  // новый тип
    // ...
  end;
end;
```

---

## 9. Структура файлов в проекте

```
cad_source/zcad/velec/uzvaccess/
├── core/
│   ├── uzvaccess_exporter.pas          -- TAccessExporter (главный класс)
│   ├── uzvaccess_types.pas             -- общие типы, константы, исключения
│   └── uzvaccess_config.pas            -- TExportConfig
│
├── data/
│   ├── uzvaccess_source_provider.pas   -- IDataSourceProvider (интерфейс)
│   └── uzvaccess_entity_adapter.pas    -- TEntitySourceProvider (реализация)
│
├── logic/
│   ├── uzvaccess_parser.pas            -- TExportTableParser
│   ├── uzvaccess_instructions.pas      -- TExportInstructions, TColumnMapping
│   ├── uzvaccess_validator.pas         -- TTypeValidator
│   └── uzvaccess_mapper.pas            -- TDataMapper
│
├── database/
│   ├── uzvaccess_connection.pas        -- TAccessConnection
│   ├── uzvaccess_executor.pas          -- TExportExecutor
│   └── uzvaccess_transaction.pas       -- TTransactionManager
│
├── command/
│   └── uzvaccess_command.pas           -- команда ZCAD (UzvAccessExport_com)
│
├── examples/
│   ├── example_export.accdb            -- пример БД Access с таблицами EXPORT
│   └── README_EXAMPLES.md              -- описание примеров
│
└── README.md                            -- документация модуля
```

---

## 10. Документация

### 10.1 README.md для модуля

Должен содержать:
- Описание модуля и его назначения
- Примеры использования команды
- Формат таблиц EXPORT с примерами
- Типы данных и их маппинг
- Список доступных свойств примитивов (device/superline/cable)
- Обработка ошибок
- FAQ

### 10.2 Примеры конфигурации EXPORT-таблиц

**Пример 1: Простой экспорт устройств (devices)**

Таблица `EXPORT1` в Access:

| Col1      | Col2            | Col3    | Col4                |
|-----------|-----------------|---------|---------------------|
| tTable    | DevicesTable    |         |                     |
| typeData  | device          |         |                     |
| setcolumn | DeviceName      | string  | NMO_BaseName        |
| setcolumn | Power           | float   | POWER               |
| setcolumn | Voltage         | integer | VOLTAGE             |
| setcolumn | Specification   | string  | VSPECIFICATION_Name |

**Пример 2: Экспорт кабелей (cables)**

Таблица `EXPORT2` в Access:

| Col1      | Col2          | Col3    | Col4              |
|-----------|---------------|---------|-------------------|
| tTable    | CablesTable   |         |                   |
| typeData  | cable         |         |                   |
| setcolumn | CableName     | string  | NMO_BaseName      |
| setcolumn | Length        | float   | CABLE_LENGTH      |
| setcolumn | CrossSection  | float   | CABLE_SECTION     |

**Пример 3: Экспорт суперлиний (superlines)**

Таблица `EXPORT3` в Access:

| Col1      | Col2             | Col3    | Col4           |
|-----------|------------------|---------|----------------|
| tTable    | SuperLinesTable  |         |                |
| typeData  | superline        |         |                |
| setcolumn | LineName         | string  | NMO_BaseName   |
| setcolumn | LineID           | string  | ENTID_Type     |

### 10.3 Блок служебной информации в начале файлов

```pascal
{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Vladimir Bobrov)
}
{$mode delphi}

unit uzvaccess_<название>;

{$INCLUDE zengineconfig.inc}

{**
  Модуль: uzvaccess_<название>
  Назначение: <описание>

  Зависимости:
    - uzvgetentity.pas - получение примитивов
    - uzclog.pas - логирование
    - ...
**}

interface

// ...
```

---

## 11. Тестирование

### 11.1 Тестовая база Access

Создать `test_export.accdb` с таблицами:

**Управляющие таблицы:**
- `EXPORT1` — экспорт устройств
- `EXPORT2` — экспорт кабелей
- `EXPORT3` — экспорт суперлиний

**Целевые таблицы:**
- `DevicesTable` — с колонками DeviceName, Power, Voltage, Specification
- `CablesTable` — с колонками CableName, Length, CrossSection
- `SuperLinesTable` — с колонками LineName, LineID

### 11.2 Сценарии тестирования

1. **Успешный экспорт:**
   - Заполнить EXPORT1 корректными инструкциями
   - Создать несколько device-примитивов в чертеже
   - Запустить команду UzvAccessExport
   - Проверить наличие данных в DevicesTable

2. **Ошибка парсинга:**
   - Добавить в EXPORT1 строку с неизвестной инструкцией
   - Проверить вывод ошибки и остановку процесса

3. **Ошибка валидации типов:**
   - В EXPORT1 указать тип `integer` для свойства, содержащего текст
   - Проверить вывод ошибки валидации

4. **Пустой список примитивов:**
   - Очистить чертеж
   - Проверить корректную обработку (очистка таблицы + 0 вставок)

---

## 12. Преимущества итоговой архитектуры

1. **Разделение ответственности:**
   - Каждый класс решает одну задачу
   - Понятная структура кода

2. **Расширяемость:**
   - Легко добавлять новые инструкции через Registry
   - Возможность добавления новых источников данных
   - Расширение типов данных

3. **Строгость и надежность:**
   - Любая ошибка останавливает процесс
   - Пользователь всегда видит причину ошибки
   - Данные либо полностью корректны, либо не выгружены

4. **Гибкость:**
   - Конфигурация через таблицы Access без перекомпиляции
   - Поддержка произвольных свойств примитивов
   - Произвольное количество EXPORT-таблиц

5. **Производительность:**
   - Пакетные вставки
   - Транзакции для целостности данных

6. **Поддерживаемость:**
   - Понятная структура файлов
   - Документированный код
   - Примеры использования

7. **Соответствие стандартам ZCAD:**
   - Использование существующих модулей (`uzvgetentity`, `uzclog`)
   - Стиль кодирования из `CLAUDE.md`
   - Русскоязычные комментарии

---

## 13. Отличия от исходного ТЗ (итоговая сводка)

| Аспект | Исходное ТЗ | Исправленное ТЗ |
|--------|-------------|-----------------|
| Источник данных | `TVElectrDevStruct` или `PGDBObjEntity` | **Только** `PGDBObjEntity` из `uzvgetentity` |
| Стратегия обновления | INSERT/UPDATE (UPSERT) | **Очистка таблицы** + INSERT |
| Обработка ошибок | Продолжить/остановить (настраиваемо) | **Всегда остановка** при ошибке |
| Валидация типов | Мягкий/строгий режим (настраиваемо) | **Только строгий режим** |
| Логирование | Собственный `TExportLogger` + файл | **Только** `uzclog.pas` с `LM_Info` |
| Обработка NULL | Настраиваемо (skip/NULL/0) | **Ошибка** при отсутствии свойства |
| Колонки в EXPORT | Номер колонки (1..N) | **Имя колонки** |
| DryRun режим | Есть | Не требуется (можно добавить) |
| Retry механизм | Есть (подключение) | Не требуется |

---

## 14. Вопросы для финального уточнения (опционально)

1. **Список доступных свойств:**
   - Какие именно свойства (переменные) доступны у примитивов device/superline/cable?
   - Нужен полный список для документации

2. **GUI интеграция:**
   - Нужен ли прогресс-бар при экспорте?
   - Или достаточно сообщений в командную строку?

3. **Версии Access:**
   - Какие версии поддерживать (.mdb, .accdb)?
   - Есть ли ограничения на ODBC драйверы?

4. **Encoding:**
   - Какую кодировку использовать для строк (UTF-8, ANSI)?

---

## 15. Заключение

Данное исправленное техническое задание учитывает все уточнения от veb86 и предлагает:

- ✅ Гибкую OOP-архитектуру с разделением по слоям
- ✅ Использование только `PGDBObjEntity` из `uzvgetentity.pas`
- ✅ Строгую обработку ошибок с остановкой процесса
- ✅ Очистку целевых таблиц перед заполнением
- ✅ Строгую валидацию типов данных
- ✅ Логирование через `uzclog.pas`
- ✅ Расширяемость через паттерны Strategy и Registry
- ✅ Соответствие стандартам кодирования ZCAD

Модуль готов к реализации в соответствии с данным ТЗ.
