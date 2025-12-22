{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
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
Менеджер выгрузки устройств в Excel с поддержкой шаблонов и специальных команд
Excel export manager for devices with template and special command support
}
{$mode objfpc}{$H+}

unit uzvmcexcelmanager;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  StrUtils,
  uzcLog,
  uzcinterface,
  uzvmcstruct,      // Структура TVElectrDevStruct / TVElectrDevStruct structure
  uzvzcadxlsxfps,   // Работа с XLSX через fpspreadsheet / XLSX operations via fpspreadsheet
  uzbstrproc,
  gvector,
  fpsTypes,
  fpSpreadsheet,
  fpsUtils,
  uzbPaths;

type
  {**
   * Тип специальной команды в ячейке
   * Special command type in cell
   *}
  TExcelCellCommandType = (
    ecctDevSettings,        // zdevsettings - получение параметров устройства / get device parameters
    ecctSetFormulaToCell,   // zsetformulatocell - установка формулы в ячейку / set formula to cell
    ecctSetValueToCell,     // zsetvaluetocell - установка значения в ячейку / set value to cell
    ecctCalculate           // zcalculate - принудительная калькуляция / forced calculation
  );

  {**
   * Менеджер экспорта в Excel с поддержкой шаблонов
   * Excel export manager with template support
   *
   * Основные возможности / Main features:
   * 1. Копирование шаблона Excel из хранилища шаблонов / Copy Excel template from template storage
   * 2. Переименование согласно названия проекта / Rename according to project name
   * 3. Обработка специальных ключей на уровне листов / Process special keys at worksheet level
   * 4. Обработка специальных команд в ячейках / Process special commands in cells
   *}
  TExcelExportManager = class
  private
    FTemplatePath: string;           // Путь к шаблону / Template path
    FOutputPath: string;             // Путь к выходному файлу / Output file path
    FProjectName: string;            // Имя проекта / Project name
    FDeviceList: TListVElectrDevStruct;  // Список устройств / Device list
    FWorkbook: TsWorkbook;           // Рабочая книга / Workbook
    FCurrentSheet: string;           // Текущий лист / Current sheet
    FVerboseMode: Boolean;           // Режим подробного вывода / Verbose output mode

    {** Получить значение ключа из текста ячейки / Get key value from cell text **}
    function GetKeyValue(const ACellText, AKeyName: string): string;

    {** Определить тип команды в ячейке / Determine command type in cell **}
    function GetCellCommandType(const ACellText: string): TExcelCellCommandType;

    {** Проверить содержит ли ячейка специальную команду / Check if cell contains special command **}
    function HasSpecialCommand(const ACellText: string): Boolean;

    {** Выполнить команду zdevsettings / Execute zdevsettings command **}
    function ExecuteDevSettingsCommand(const ADevice: TVElectrDevStruct;
      const ACellText, ASheetName: string; ARow: Cardinal; var ACol: Cardinal): Boolean;

    {** Выполнить команду zsetformulatocell / Execute zsetformulatocell command **}
    function ExecuteSetFormulaToCellCommand(const ACellText, ASheetName: string;
      ARow: Cardinal; var ACol: Cardinal): Boolean;

    {** Выполнить команду zsetvaluetocell / Execute zsetvaluetocell command **}
    function ExecuteSetValueToCellCommand(const ACellText, ASheetName: string;
      ARow: Cardinal; var ACol: Cardinal): Boolean;

    {** Выполнить команду zcalculate / Execute zcalculate command **}
    function ExecuteCalculateCommand: Boolean;

    {** Выполнить специальную команду в ячейке / Execute special command in cell **}
    function ExecuteSpecialCellCommand(const ADevice: PTVElectrDevStruct;
      const ACellText, ASheetName: string; ARow: Cardinal; var ACol: Cardinal): Boolean;

    {** Обработать специальные листы настроек / Process special settings sheets **}
    procedure ProcessSettingsSheets;

    {** Обработать команду <workbook>SET / Process <workbook>SET command **}
    procedure ProcessWorkbookSettings;

    {** Обработать команду <zalldev>SET / Process <zalldev>SET command **}
    procedure ProcessAllDevicesSettings;

    {** Получить значение поля устройства по имени / Get device field value by name **}
    function GetDeviceFieldValue(const ADevice: TVElectrDevStruct;
      const AFieldName: string): string;

  protected
    {** Логирование сообщения / Log message **}
    procedure LogMessage(const AMessage: string; AVerboseOnly: Boolean = False);

  public
    {** Конструктор / Constructor **}
    constructor Create;

    {** Деструктор / Destructor **}
    destructor Destroy; override;

    {**
     * Установить путь к шаблону Excel
     * Set Excel template path
     * @param ATemplatePath Полный путь к файлу шаблона / Full path to template file
     *}
    procedure SetTemplatePath(const ATemplatePath: string);

    {**
     * Установить путь к выходному файлу
     * Set output file path
     * @param AOutputPath Полный путь к выходному файлу / Full path to output file
     *}
    procedure SetOutputPath(const AOutputPath: string);

    {**
     * Установить имя проекта (используется для переименования)
     * Set project name (used for renaming)
     * @param AProjectName Имя проекта / Project name
     *}
    procedure SetProjectName(const AProjectName: string);

    {**
     * Установить список устройств для экспорта
     * Set device list for export
     * @param ADeviceList Список устройств / Device list
     *}
    procedure SetDeviceList(const ADeviceList: TListVElectrDevStruct);

    {**
     * Включить/выключить режим подробного вывода
     * Enable/disable verbose output mode
     * @param AVerbose True для включения / True to enable
     *}
    procedure SetVerboseMode(const AVerbose: Boolean);

    {**
     * Выполнить экспорт устройств в Excel
     * Perform device export to Excel
     *
     * Алгоритм работы / Algorithm:
     * 1. Копирование шаблона / Copy template
     * 2. Обработка настроек <workbook>SET / Process <workbook>SET settings
     * 3. Обработка <zalldev>SET для всех устройств / Process <zalldev>SET for all devices
     * 4. Заполнение данных устройств / Fill device data
     * 5. Сохранение файла / Save file
     *
     * @return True если успешно / True if successful
     *}
    function Execute: Boolean;

    {**
     * Экспортировать список устройств (упрощенный метод)
     * Export device list (simplified method)
     * @param ADeviceList Список устройств / Device list
     * @param ATemplatePath Путь к шаблону / Template path
     * @param AOutputPath Путь к выходному файлу / Output file path
     * @param AProjectName Имя проекта / Project name
     * @return True если успешно / True if successful
     *}
    function ExportDevices(const ADeviceList: TListVElectrDevStruct;
      const ATemplatePath, AOutputPath, AProjectName: string): Boolean;
  end;

implementation

const
  // Константы специальных команд / Special command constants
  CMD_START_SYMBOL = '<';
  CMD_FINISH_SYMBOL = '</';
  CMD_LAST_SYMBOL = '>';

  // Команды в ячейках / Cell commands
  CMD_DEV_SETTINGS = 'zdevsettings';
  CMD_SET_FORMULA = 'zsetformulatocell';
  CMD_SET_VALUE = 'zsetvaluetocell';
  CMD_CALCULATE = 'zcalculate';

  // Команды настроек / Settings commands
  CMD_WORKBOOK_SET = '<workbook>SET';
  CMD_ALLDEV_SET = '<zalldev>SET';
  CMD_HD_SET = '<zHD>SET';

  // Ключи для команд / Command keys
  KEY_NAME = 'name';
  KEY_TYPE = 'type';
  KEY_CALC = 'calc';
  KEY_TO_SHEET = 'toSheet';
  KEY_FROM_SHEET = 'fromSheet';
  KEY_TO_CELL = 'toCell';
  KEY_FROM_CELL = 'fromCell';
  KEY_FORMULA = 'formula';
  KEY_VALUE = 'value';

{ TExcelExportManager }

constructor TExcelExportManager.Create;
begin
  inherited Create;
  FTemplatePath := '';
  FOutputPath := '';
  FProjectName := '';
  FDeviceList := TListVElectrDevStruct.Create;
  FWorkbook := nil;
  FCurrentSheet := '';
  FVerboseMode := False;
end;

destructor TExcelExportManager.Destroy;
begin
  if FWorkbook <> nil then
    FWorkbook.Free;
  FDeviceList.Free;
  inherited Destroy;
end;

procedure TExcelExportManager.LogMessage(const AMessage: string; AVerboseOnly: Boolean);
begin
  if (not AVerboseOnly) or FVerboseMode then
    zcUI.TextMessage(AMessage, TMWOHistoryOut);
end;

procedure TExcelExportManager.SetTemplatePath(const ATemplatePath: string);
begin
  FTemplatePath := ATemplatePath;
end;

procedure TExcelExportManager.SetOutputPath(const AOutputPath: string);
begin
  FOutputPath := AOutputPath;
end;

procedure TExcelExportManager.SetProjectName(const AProjectName: string);
begin
  FProjectName := AProjectName;
end;

procedure TExcelExportManager.SetDeviceList(const ADeviceList: TListVElectrDevStruct);
var
  i: Integer;
begin
  FDeviceList.Clear;
  for i := 0 to ADeviceList.Size - 1 do
    FDeviceList.PushBack(ADeviceList[i]);
end;

procedure TExcelExportManager.SetVerboseMode(const AVerbose: Boolean);
begin
  FVerboseMode := AVerbose;
end;

function TExcelExportManager.GetKeyValue(const ACellText, AKeyName: string): string;
var
  startPos, endPos: Integer;
  startMarker: string;
begin
  Result := '';

  if (ACellText = '') or (AKeyName = '') then
    Exit;

  startMarker := AKeyName + '=[';
  startPos := Pos(startMarker, ACellText);

  if startPos = 0 then
    Exit;

  // Смещаем позицию на длину стартового маркера / Offset position by start marker length
  startPos := startPos + Length(startMarker);

  // Ищем закрывающую скобку / Find closing bracket
  endPos := PosEx(']', ACellText, startPos);

  if endPos = 0 then
    Exit;

  // Извлекаем подстроку / Extract substring
  Result := Copy(ACellText, startPos, endPos - startPos);
end;

function TExcelExportManager.GetCellCommandType(const ACellText: string): TExcelCellCommandType;
begin
  if ContainsText(ACellText, CMD_START_SYMBOL + CMD_DEV_SETTINGS) then
    Result := ecctDevSettings
  else if ContainsText(ACellText, CMD_START_SYMBOL + CMD_SET_FORMULA) then
    Result := ecctSetFormulaToCell
  else if ContainsText(ACellText, CMD_START_SYMBOL + CMD_SET_VALUE) then
    Result := ecctSetValueToCell
  else if ContainsText(ACellText, CMD_START_SYMBOL + CMD_CALCULATE) then
    Result := ecctCalculate
  else
    Result := ecctDevSettings; // По умолчанию / Default
end;

function TExcelExportManager.HasSpecialCommand(const ACellText: string): Boolean;
begin
  Result := (Pos(CMD_START_SYMBOL, ACellText) > 0) and
            (ContainsText(ACellText, CMD_DEV_SETTINGS) or
             ContainsText(ACellText, CMD_SET_FORMULA) or
             ContainsText(ACellText, CMD_SET_VALUE) or
             ContainsText(ACellText, CMD_CALCULATE));
end;

function TExcelExportManager.GetDeviceFieldValue(const ADevice: TVElectrDevStruct;
  const AFieldName: string): string;
begin
  Result := '';

  // Сопоставление имен полей со значениями / Map field names to values
  if AFieldName = 'zcadid' then
    Result := IntToStr(ADevice.zcadid)
  else if AFieldName = 'fullname' then
    Result := ADevice.fullname
  else if AFieldName = 'basename' then
    Result := ADevice.basename
  else if AFieldName = 'realname' then
    Result := ADevice.realname
  else if AFieldName = 'tracename' then
    Result := ADevice.tracename
  else if AFieldName = 'headdev' then
    Result := ADevice.headdev
  else if AFieldName = 'feedernum' then
    Result := IntToStr(ADevice.feedernum)
  else if AFieldName = 'canbehead' then
    Result := IntToStr(ADevice.canbehead)
  else if AFieldName = 'devtype' then
    Result := ADevice.devtype
  else if AFieldName = 'opmode' then
    Result := ADevice.opmode
  else if AFieldName = 'power' then
    Result := FloatToStr(ADevice.power)
  else if AFieldName = 'voltage' then
    Result := IntToStr(ADevice.voltage)
  else if AFieldName = 'cosfi' then
    Result := FloatToStr(ADevice.cosfi)
  else if AFieldName = 'phase' then
    Result := ADevice.phase
  else if AFieldName = 'pathHD' then
    Result := ADevice.pathHD
  else if AFieldName = 'fullpathHD' then
    Result := ADevice.fullpathHD
  else if AFieldName = 'Sort1' then
    Result := IntToStr(ADevice.Sort1)
  else if AFieldName = 'Sort2' then
    Result := IntToStr(ADevice.Sort2)
  else if AFieldName = 'Sort2name' then
    Result := ADevice.Sort2name
  else if AFieldName = 'Sort3' then
    Result := IntToStr(ADevice.Sort3)
  else if AFieldName = 'Sort3name' then
    Result := ADevice.Sort3name;
end;

function TExcelExportManager.ExecuteDevSettingsCommand(
  const ADevice: TVElectrDevStruct; const ACellText, ASheetName: string;
  ARow: Cardinal; var ACol: Cardinal): Boolean;
var
  fieldName, calcVal, fieldValue: string;
begin
  Result := False;

  try
    // Получаем имя поля / Get field name
    fieldName := GetKeyValue(ACellText, KEY_NAME);
    if fieldName = '' then
      Exit;

    // Получаем значение calc для определения момента калькуляции / Get calc value
    calcVal := GetKeyValue(ACellText, KEY_CALC);

    // Калькуляция до обработки / Calculate before processing
    if (calcVal = 'before') or (calcVal = 'both') then
      uzvzcadxlsxfps.nowCalcFormulas;

    // Получаем значение поля устройства / Get device field value
    fieldValue := GetDeviceFieldValue(ADevice, fieldName);

    // Записываем значение в ячейку / Write value to cell
    Inc(ACol);
    uzvzcadxlsxfps.setCellValue(ASheetName, ARow, ACol, fieldValue);

    // Копируем формат из предыдущей строки / Copy format from previous row
    if ARow > 0 then
      uzvzcadxlsxfps.myCopyCellFormat(ASheetName, ARow - 1, ACol, ASheetName, ARow, ACol);

    Inc(ACol);

    // Калькуляция после обработки / Calculate after processing
    if (calcVal = 'after') or (calcVal = 'both') then
      uzvzcadxlsxfps.nowCalcFormulas;

    Result := True;
  except
    on E: Exception do
      LogMessage('ОШИБКА в ExecuteDevSettingsCommand: ' + E.Message);
  end;
end;

function TExcelExportManager.ExecuteSetFormulaToCellCommand(
  const ACellText, ASheetName: string; ARow: Cardinal; var ACol: Cardinal): Boolean;
var
  toSheet, fromSheet, toCell, fromCell, formula, calcVal: string;
begin
  Result := False;

  try
    // Получаем значение формулы / Get formula value
    formula := GetKeyValue(ACellText, KEY_FORMULA);
    if formula = '' then
      Exit;

    // Получаем параметры / Get parameters
    calcVal := GetKeyValue(ACellText, KEY_CALC);
    toSheet := GetKeyValue(ACellText, KEY_TO_SHEET);
    if toSheet = '' then
      toSheet := ASheetName;

    fromSheet := GetKeyValue(ACellText, KEY_FROM_SHEET);
    if fromSheet = '' then
      fromSheet := ASheetName;

    toCell := GetKeyValue(ACellText, KEY_TO_CELL);
    if toCell = '' then
      toCell := uzvzcadxlsxfps.getAddress(ASheetName, ARow, ACol);

    fromCell := GetKeyValue(ACellText, KEY_FROM_CELL);
    if fromCell = '' then
      fromCell := uzvzcadxlsxfps.getAddress(ASheetName, ARow, ACol);

    // Калькуляция до обработки / Calculate before processing
    if (calcVal = 'before') or (calcVal = 'both') then
      uzvzcadxlsxfps.nowCalcFormulas;

    // Заменяем ключи в формуле / Replace keys in formula
    formula := StringReplace(formula, KEY_TO_SHEET, toSheet, [rfReplaceAll, rfIgnoreCase]);
    formula := StringReplace(formula, KEY_FROM_SHEET, fromSheet, [rfReplaceAll, rfIgnoreCase]);
    formula := StringReplace(formula, KEY_TO_CELL, toCell, [rfReplaceAll, rfIgnoreCase]);
    formula := StringReplace(formula, KEY_FROM_CELL, fromCell, [rfReplaceAll, rfIgnoreCase]);

    // Устанавливаем формулу / Set formula
    uzvzcadxlsxfps.setCellAddressFormula(toSheet, toCell, formula);

    Inc(ACol);

    // Калькуляция после обработки / Calculate after processing
    if (calcVal = 'after') or (calcVal = 'both') then
      uzvzcadxlsxfps.nowCalcFormulas;

    Result := True;
  except
    on E: Exception do
      LogMessage('ОШИБКА в ExecuteSetFormulaToCellCommand: ' + E.Message);
  end;
end;

function TExcelExportManager.ExecuteSetValueToCellCommand(
  const ACellText, ASheetName: string; ARow: Cardinal; var ACol: Cardinal): Boolean;
var
  toSheet, fromSheet, toCell, fromCell, value, calcVal: string;
begin
  Result := False;

  try
    // Получаем значение / Get value
    value := GetKeyValue(ACellText, KEY_VALUE);
    if value = '' then
      Exit;

    // Получаем параметры / Get parameters
    calcVal := GetKeyValue(ACellText, KEY_CALC);
    toSheet := GetKeyValue(ACellText, KEY_TO_SHEET);
    if toSheet = '' then
      toSheet := ASheetName;

    fromSheet := GetKeyValue(ACellText, KEY_FROM_SHEET);
    if fromSheet = '' then
      fromSheet := ASheetName;

    toCell := GetKeyValue(ACellText, KEY_TO_CELL);
    if toCell = '' then
      toCell := uzvzcadxlsxfps.getAddress(ASheetName, ARow, ACol);

    fromCell := GetKeyValue(ACellText, KEY_FROM_CELL);
    if fromCell = '' then
      fromCell := uzvzcadxlsxfps.getAddress(ASheetName, ARow, ACol);

    // Калькуляция до обработки / Calculate before processing
    if (calcVal = 'before') or (calcVal = 'both') then
      uzvzcadxlsxfps.nowCalcFormulas;

    // Заменяем ключи в значении / Replace keys in value
    value := StringReplace(value, KEY_TO_SHEET, toSheet, [rfReplaceAll, rfIgnoreCase]);
    value := StringReplace(value, KEY_FROM_SHEET, fromSheet, [rfReplaceAll, rfIgnoreCase]);
    value := StringReplace(value, KEY_TO_CELL, toCell, [rfReplaceAll, rfIgnoreCase]);
    value := StringReplace(value, KEY_FROM_CELL, fromCell, [rfReplaceAll, rfIgnoreCase]);

    // Устанавливаем значение / Set value
    uzvzcadxlsxfps.setCellAddressValue(toSheet, toCell, value);

    Inc(ACol);

    // Калькуляция после обработки / Calculate after processing
    if (calcVal = 'after') or (calcVal = 'both') then
      uzvzcadxlsxfps.nowCalcFormulas;

    Result := True;
  except
    on E: Exception do
      LogMessage('ОШИБКА в ExecuteSetValueToCellCommand: ' + E.Message);
  end;
end;

function TExcelExportManager.ExecuteCalculateCommand: Boolean;
begin
  Result := False;
  try
    uzvzcadxlsxfps.nowCalcFormulas;
    LogMessage('Принудительная калькуляция книги выполнена', True);
    Result := True;
  except
    on E: Exception do
      LogMessage('ОШИБКА в ExecuteCalculateCommand: ' + E.Message);
  end;
end;

function TExcelExportManager.ExecuteSpecialCellCommand(
  const ADevice: PTVElectrDevStruct; const ACellText, ASheetName: string;
  ARow: Cardinal; var ACol: Cardinal): Boolean;
var
  cmdType: TExcelCellCommandType;
begin
  Result := False;

  if not HasSpecialCommand(ACellText) then
    Exit;

  cmdType := GetCellCommandType(ACellText);

  case cmdType of
    ecctDevSettings:
      if ADevice <> nil then
        Result := ExecuteDevSettingsCommand(ADevice^, ACellText, ASheetName, ARow, ACol);

    ecctSetFormulaToCell:
      Result := ExecuteSetFormulaToCellCommand(ACellText, ASheetName, ARow, ACol);

    ecctSetValueToCell:
      Result := ExecuteSetValueToCellCommand(ACellText, ASheetName, ARow, ACol);

    ecctCalculate:
      Result := ExecuteCalculateCommand;
  end;
end;

procedure TExcelExportManager.ProcessWorkbookSettings;
begin
  LogMessage('Обработка настроек <workbook>SET...', True);
  // Здесь будет обработка настроек книги / Workbook settings processing
  // Пока оставляем заглушку / Placeholder for now
end;

procedure TExcelExportManager.ProcessAllDevicesSettings;
begin
  LogMessage('Обработка настроек <zalldev>SET...', True);
  // Здесь будет обработка настроек всех устройств / All devices settings processing
  // Пока оставляем заглушку / Placeholder for now
end;

procedure TExcelExportManager.ProcessSettingsSheets;
begin
  // Обработка специальных листов настроек / Process special settings sheets
  ProcessWorkbookSettings;
  ProcessAllDevicesSettings;
end;

function TExcelExportManager.Execute: Boolean;
begin
  Result := False;

  try
    LogMessage('=== Начало экспорта устройств в Excel ===');

    // Проверка входных данных / Validate input data
    if FTemplatePath = '' then
    begin
      LogMessage('ОШИБКА: Не указан путь к шаблону');
      Exit;
    end;

    if not FileExists(FTemplatePath) then
    begin
      LogMessage('ОШИБКА: Файл шаблона не найден: ' + FTemplatePath);
      Exit;
    end;

    if FOutputPath = '' then
    begin
      LogMessage('ОШИБКА: Не указан путь к выходному файлу');
      Exit;
    end;

    if FDeviceList.Size = 0 then
    begin
      LogMessage('ПРЕДУПРЕЖДЕНИЕ: Список устройств пуст');
      // Продолжаем работу, возможно нужно просто скопировать шаблон
      // Continue, maybe just need to copy template
    end;

    // Шаг 1: Открытие шаблона / Step 1: Open template
    LogMessage('Шаг 1: Открытие шаблона Excel...');
    if not uzvzcadxlsxfps.openXLSXFile(FTemplatePath) then
    begin
      LogMessage('ОШИБКА: Не удалось открыть файл шаблона');
      Exit;
    end;

    // Шаг 2: Обработка специальных листов настроек / Step 2: Process settings sheets
    LogMessage('Шаг 2: Обработка специальных листов настроек...');
    ProcessSettingsSheets;

    // Шаг 3: Заполнение данных устройств / Step 3: Fill device data
    LogMessage('Шаг 3: Заполнение данных устройств (' + IntToStr(FDeviceList.Size) + ' устройств)...');
    // Здесь будет логика заполнения устройств / Device filling logic here
    // Пока оставляем заглушку / Placeholder for now

    // Шаг 4: Сохранение файла / Step 4: Save file
    LogMessage('Шаг 4: Сохранение файла...');
    if not uzvzcadxlsxfps.saveXLSXFile(FOutputPath) then
    begin
      LogMessage('ОШИБКА: Не удалось сохранить файл');
      Exit;
    end;

    // Шаг 5: Очистка ресурсов / Step 5: Cleanup
    LogMessage('Шаг 5: Очистка ресурсов...');
    uzvzcadxlsxfps.destroyWorkbook;

    LogMessage('=== Экспорт завершен успешно ===');
    LogMessage('Файл сохранен: ' + FOutputPath);
    Result := True;

  except
    on E: Exception do
    begin
      LogMessage('КРИТИЧЕСКАЯ ОШИБКА при экспорте: ' + E.Message);
      Result := False;
    end;
  end;
end;

function TExcelExportManager.ExportDevices(const ADeviceList: TListVElectrDevStruct;
  const ATemplatePath, AOutputPath, AProjectName: string): Boolean;
begin
  SetDeviceList(ADeviceList);
  SetTemplatePath(ATemplatePath);
  SetOutputPath(AOutputPath);
  SetProjectName(AProjectName);
  Result := Execute;
end;

end.
