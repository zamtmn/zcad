# Excel Export Module / Модуль экспорта в Excel

## Описание / Description

Этот модуль предоставляет функциональность для экспорта данных устройств в файлы Excel с поддержкой шаблонов и специальных команд.

This module provides functionality for exporting device data to Excel files with template and special command support.

## Файлы / Files

### uzvmcdevtoexcel.pas
Базовые классы для простого экспорта устройств в Excel.

Base classes for simple device export to Excel.

**Основные компоненты / Main components:**
- `TDeviceExcelExporterBase` - Базовый класс экспортера / Base exporter class
- `TStandardDeviceExporter` - Стандартный экспортер / Standard exporter
- `TExportDevicesToExcelCommand` - Команда экспорта / Export command

**Использование / Usage:**
```pascal
var
  exporter: TStandardDeviceExporter;
  deviceList: TListVElectrDevStruct;
begin
  exporter := TStandardDeviceExporter.Create;
  try
    exporter.ExportToFile(deviceList, 'output.xlsx');
  finally
    exporter.Free;
  end;
end;
```

### uzvmcexcelmanager.pas
Менеджер экспорта с расширенными возможностями (на основе uzvmodeltoxlsxfps.pas).

Export manager with advanced features (based on uzvmodeltoxlsxfps.pas).

**Основные возможности / Main features:**

1. **Копирование шаблона** / **Template copying**
   - Автоматическое копирование Excel шаблона из хранилища
   - Automatic Excel template copying from storage

2. **Переименование по проекту** / **Project-based renaming**
   - Переименование согласно названия проекта
   - Renaming according to project name

3. **Специальные ключи на уровне листов** / **Special sheet-level keys**
   - `<workbook>SET` - настройки всей книги / workbook settings
   - `<zalldev>SET` - настройки для всех устройств / all devices settings
   - `<zallcab>SET` - настройки для всех кабелей / all cables settings
   - `<zHD>SET` - настройки для головных устройств / head devices settings

4. **Команды внутри ячеек** / **Cell commands**
   - `zdevsettings` - получение параметров устройств / get device parameters
   - `zsetformulatocell` - установка формулы в ячейку / set formula to cell
   - `zsetvaluetocell` - установка значения в ячейку / set value to cell
   - `zcalculate` - принудительная калькуляция / forced calculation

**Использование / Usage:**
```pascal
var
  manager: TExcelExportManager;
  deviceList: TListVElectrDevStruct;
begin
  manager := TExcelExportManager.Create;
  try
    manager.SetVerboseMode(True);
    manager.ExportDevices(deviceList, 'template.xlsx', 'output.xlsx', 'MyProject');
  finally
    manager.Free;
  end;
end;
```

## Команды в ячейках / Cell Commands

### zdevsettings
Получение и назначение параметров устройств в ячейки.

Get and assign device parameters to cells.

**Ключи / Keys:**
- `name=[<field_name>]` - имя параметра устройства / device parameter name
- `type=[<type>]` - тип значения (string, float, integer, boolean) / value type
- `calc=[before|after|both]` - момент калькуляции / calculation moment

**Пример / Example:**
```
<zdevsettings name=[fullname] type=[string] calc=[after]>
```

**Доступные поля устройства / Available device fields:**
- `zcadid` - ID устройства / device ID
- `fullname` - полное имя / full name
- `basename` - базовое имя / base name
- `realname` - реальное имя / real name
- `tracename` - имя трассы / trace name
- `headdev` - головное устройство / head device
- `feedernum` - номер фидера / feeder number
- `canbehead` - может быть головным (0/1) / can be head
- `devtype` - тип устройства / device type
- `opmode` - режим работы / operation mode
- `power` - мощность / power
- `voltage` - напряжение / voltage
- `cosfi` - коэффициент мощности / power factor
- `phase` - фаза / phase
- `pathHD` - путь ГУ / HD path
- `fullpathHD` - полный путь ГУ / full HD path
- `Sort1`, `Sort2`, `Sort3` - поля сортировки / sorting fields
- `Sort2name`, `Sort3name` - именные поля сортировки / sorting name fields

### zsetformulatocell
Присваивание ячейке определенной формулы.

Assign formula to cell.

**Ключи / Keys:**
- `toSheet=[<sheet>]` - лист назначения / destination sheet
- `fromSheet=[<sheet>]` - лист источника / source sheet
- `toCell=[<address>]` - адрес ячейки назначения / destination cell address
- `fromCell=[<address>]` - адрес ячейки источника / source cell address
- `formula=[<formula>]` - формула / formula
- `calc=[before|after|both]` - момент калькуляции / calculation moment

**Пример / Example:**
```
<zsetformulatocell toSheet=[Results] toCell=[A1] formula=[SUM(fromSheet!fromCell:fromCell)]>
```

### zsetvaluetocell
Присваивание ячейке определенного значения.

Assign value to cell.

**Ключи / Keys:**
- `toSheet=[<sheet>]` - лист назначения / destination sheet
- `fromSheet=[<sheet>]` - лист источника / source sheet
- `toCell=[<address>]` - адрес ячейки назначения / destination cell address
- `fromCell=[<address>]` - адрес ячейки источника / source cell address
- `value=[<value>]` - значение / value
- `calc=[before|after|both]` - момент калькуляции / calculation moment

**Пример / Example:**
```
<zsetvaluetocell toSheet=[Summary] toCell=[A1] value=[Total Devices]>
```

### zcalculate
Принудительная калькуляция всей книги.

Force calculation of entire workbook.

**Пример / Example:**
```
<zcalculate>
```

## Архитектура / Architecture

Модуль следует ООП принципам и паттернам проектирования:

The module follows OOP principles and design patterns:

1. **Шаблонный метод (Template Method)**
   - `TDeviceExcelExporterBase` определяет скелет алгоритма
   - Наследники реализуют специфические шаги

2. **Фасад (Facade)**
   - `TExcelExportManager` предоставляет упрощенный интерфейс
   - Скрывает сложность работы с fpspreadsheet и uzvzcadxlsxfps

3. **Команда (Command)**
   - `TExportDevicesToExcelCommand` инкапсулирует операцию экспорта
   - Позволяет параметризовать операции

4. **Стратегия (Strategy)**
   - Различные экспортеры (Standard, Custom) взаимозаменяемы
   - Можно легко добавить новые типы экспортеров

## Расширение функциональности / Extending Functionality

### Создание пользовательского экспортера / Creating Custom Exporter

```pascal
type
  TMyCustomExporter = class(TDeviceExcelExporterBase)
  protected
    procedure CreateHeaders; override;
    procedure ExportDevice(const ADevice: TVElectrDevStruct); override;
  public
    constructor Create; override;
  end;

implementation

constructor TMyCustomExporter.Create;
begin
  inherited Create;
  // Ваша инициализация / Your initialization
end;

procedure TMyCustomExporter.CreateHeaders;
begin
  // Создание заголовков / Create headers
  FWorksheet.WriteText(FCurrentRow, 0, 'My Custom Header 1');
  FWorksheet.WriteText(FCurrentRow, 1, 'My Custom Header 2');
  Inc(FCurrentRow);
end;

procedure TMyCustomExporter.ExportDevice(const ADevice: TVElectrDevStruct);
begin
  // Экспорт устройства / Export device
  FWorksheet.WriteText(FCurrentRow, 0, ADevice.fullname);
  FWorksheet.WriteNumber(FCurrentRow, 1, ADevice.power);
end;
```

### Использование пользовательского экспортера / Using Custom Exporter

```pascal
var
  command: TExportDevicesToExcelCommand;
  customExporter: TMyCustomExporter;
begin
  command := TExportDevicesToExcelCommand.Create;
  customExporter := TMyCustomExporter.Create;
  try
    command.SetDeviceList(deviceList);
    command.SetFileName('output.xlsx');
    command.SetExporter(customExporter); // Передаем владение / Transfer ownership
    command.Execute;
  finally
    command.Free; // Освободит и customExporter / Will free customExporter too
  end;
end;
```

## Зависимости / Dependencies

- `uzvmcstruct` - Структура данных устройств / Device data structures
- `uzvzcadxlsxfps` - Обертка над fpspreadsheet / fpspreadsheet wrapper
- `fpspreadsheet` - Библиотека для работы с Excel / Excel library
- `uzcinterface` - Интерфейс для вывода сообщений / Message output interface

## Развитие модуля / Module Development

Текущая реализация является первым наброском. Планируется развитие:

Current implementation is a first draft. Planned development:

1. **Полная реализация ProcessSettingsSheets**
   - Обработка всех типов специальных листов
   - Processing of all special sheet types

2. **Логика заполнения устройств**
   - Итерация по списку устройств
   - Device list iteration
   - Вызов команд в ячейках
   - Cell command invocation

3. **Поддержка кабелей**
   - Добавление команд для работы с кабелями
   - Adding cable-related commands

4. **Расширенная калькуляция**
   - Оптимизация моментов пересчета формул
   - Formula recalculation optimization

5. **Обработка ошибок**
   - Более детальная обработка исключений
   - More detailed exception handling
   - Валидация входных данных
   - Input data validation

## Лицензия / License

Этот файл является частью ZCAD.

This file is part of ZCAD.

См. файл COPYING.txt для деталей о копирайте.

See the file COPYING.txt for details about the copyright.
