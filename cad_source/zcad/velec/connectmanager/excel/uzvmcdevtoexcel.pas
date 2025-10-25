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
{$mode objfpc}{$H+}

unit uzvmcdevtoexcel;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcinterface,
  uzvmcstruct,  // Структура TVElectrDevStruct
  uzvzcadxlsxfps,  // Работа с XLSX через fpspreadsheet
  gvector,
  fpsTypes,
  fpSpreadsheet,
  Classes;

type
  {**
   * Базовый класс для экспорта устройств в Excel
   * Base class for exporting devices to Excel
   *}
  TDeviceExcelExporterBase = class
  protected
    FWorkbook: TsWorkbook;  // Рабочая книга Excel / Excel workbook
    FWorksheet: TsWorksheet;  // Активный лист / Active worksheet
    FCurrentRow: Cardinal;  // Текущая строка для записи / Current row for writing

    {** Создать заголовки таблицы / Create table headers **}
    procedure CreateHeaders; virtual; abstract;

    {** Экспортировать одно устройство / Export single device **}
    procedure ExportDevice(const ADevice: TVElectrDevStruct); virtual; abstract;

    {** Инициализировать книгу Excel / Initialize Excel workbook **}
    procedure InitializeWorkbook; virtual;

    {** Финализировать книгу Excel / Finalize Excel workbook **}
    procedure FinalizeWorkbook; virtual;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    {**
     * Экспортировать список устройств в файл Excel
     * Export device list to Excel file
     * @param ADeviceList Список устройств / Device list
     * @param AFileName Путь к файлу для сохранения / File path for saving
     * @return True если успешно / True if successful
     *}
    function ExportToFile(const ADeviceList: TListVElectrDevStruct;
                         const AFileName: string): Boolean; virtual;
  end;

  {**
   * Стандартный экспортер устройств в Excel
   * Standard device exporter to Excel
   *}
  TStandardDeviceExporter = class(TDeviceExcelExporterBase)
  protected
    procedure CreateHeaders; override;
    procedure ExportDevice(const ADevice: TVElectrDevStruct); override;
  public
    constructor Create; override;
  end;

  {**
   * Утилитный класс для выгрузки устройств в Excel
   * Utility class for exporting devices to Excel
   *}
  TExportDevicesToExcelCommand = class
  private
    FDeviceList: TListVElectrDevStruct;  // Список устройств / Device list
    FExporter: TDeviceExcelExporterBase;  // Экспортер / Exporter
    FFileName: string;  // Имя файла / File name

  public
    {** Конструктор команды / Command constructor **}
    constructor Create;

    {** Деструктор команды / Command destructor **}
    destructor Destroy; override;

    {**
     * Установить список устройств для экспорта
     * Set device list for export
     *}
    procedure SetDeviceList(const AList: TListVElectrDevStruct);

    {**
     * Установить имя файла для экспорта
     * Set file name for export
     *}
    procedure SetFileName(const AFileName: string);

    {**
     * Установить пользовательский экспортер
     * Set custom exporter
     *}
    procedure SetExporter(AExporter: TDeviceExcelExporterBase);

    {**
     * Выполнить команду экспорта
     * Execute export command
     *}
    function Execute: Boolean;
  end;

implementation

{ TDeviceExcelExporterBase }

constructor TDeviceExcelExporterBase.Create;
begin
  inherited Create;
  FWorkbook := nil;
  FWorksheet := nil;
  FCurrentRow := 0;
end;

destructor TDeviceExcelExporterBase.Destroy;
begin
  if FWorkbook <> nil then
    FWorkbook.Free;
  inherited Destroy;
end;

procedure TDeviceExcelExporterBase.InitializeWorkbook;
begin
  // Создаем новую рабочую книгу / Create new workbook
  FWorkbook := TsWorkbook.Create;
  FWorkbook.Options := FWorkbook.Options + [boReadFormulas];

  // Создаем первый лист / Create first worksheet
  FWorksheet := FWorkbook.AddWorksheet('Устройства');

  // Начинаем с первой строки / Start from first row
  FCurrentRow := 0;

  // Создаем заголовки / Create headers
  CreateHeaders;
end;

procedure TDeviceExcelExporterBase.FinalizeWorkbook;
begin
  // Автоматическая подгонка ширины столбцов (опционально)
  // Auto-fit column widths (optional)
  // Можно добавить дополнительную логику форматирования
  // Additional formatting logic can be added here
end;

function TDeviceExcelExporterBase.ExportToFile(
  const ADeviceList: TListVElectrDevStruct;
  const AFileName: string): Boolean;
var
  i: Integer;
begin
  Result := False;

  try
    // Инициализируем книгу / Initialize workbook
    InitializeWorkbook;

    // Экспортируем каждое устройство / Export each device
    for i := 0 to ADeviceList.Size - 1 do
    begin
      ExportDevice(ADeviceList[i]);
      Inc(FCurrentRow);
    end;

    // Финализируем книгу / Finalize workbook
    FinalizeWorkbook;

    // Сохраняем файл / Save file
    try
      FWorkbook.WriteToFile(AFileName, sfOOXML, True);
      Result := True;
      zcUI.TextMessage('Экспорт устройств в Excel завершен успешно: ' + AFileName, TMWOHistoryOut);
      zcUI.TextMessage('Всего экспортировано устройств: ' + IntToStr(ADeviceList.Size), TMWOHistoryOut);
    except
      on E: Exception do
      begin
        zcUI.TextMessage('ОШИБКА при сохранении файла: ' + E.Message, TMWOHistoryOut);
        Result := False;
      end;
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage('ОШИБКА при экспорте устройств: ' + E.Message, TMWOHistoryOut);
      Result := False;
    end;
  end;
end;

{ TStandardDeviceExporter }

constructor TStandardDeviceExporter.Create;
begin
  inherited Create;
end;

procedure TStandardDeviceExporter.CreateHeaders;
const
  // Заголовки столбцов / Column headers
  Headers: array[0..19] of string = (
    'ID устройства',           // Device ID
    'Полное имя',              // Full name
    'Базовое имя',             // Base name
    'Реальное имя',            // Real name
    'Имя трассы',              // Trace name
    'Головное устройство',     // Head device
    'Номер фидера',            // Feeder number
    'Может быть головным',     // Can be head
    'Тип устройства',          // Device type
    'Режим работы',            // Operation mode
    'Мощность',                // Power
    'Напряжение',              // Voltage
    'Cos φ',                   // Cos phi
    'Фаза',                    // Phase
    'Путь ГУ',                 // HD path
    'Полный путь ГУ',          // Full HD path
    'Сортировка 1',            // Sort 1
    'Сортировка 2',            // Sort 2
    'Сортировка 2 (имя)',      // Sort 2 name
    'Сортировка 3'             // Sort 3
  );
var
  Col: Cardinal;
begin
  // Записываем заголовки в первую строку / Write headers to first row
  for Col := 0 to High(Headers) do
  begin
    FWorksheet.WriteText(FCurrentRow, Col, Headers[Col]);
    // Делаем заголовки жирными (опционально)
    // Make headers bold (optional)
    FWorksheet.WriteFont(FCurrentRow, Col, 'Arial', 10, [fssBold], scBlack);
  end;

  Inc(FCurrentRow);
end;

procedure TStandardDeviceExporter.ExportDevice(const ADevice: TVElectrDevStruct);
var
  Col: Cardinal;
begin
  Col := 0;

  // Экспортируем все поля устройства / Export all device fields
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.zcadid); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.fullname); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.basename); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.realname); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.tracename); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.headdev); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.feedernum); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.canbehead); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.devtype); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.opmode); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.power); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.voltage); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.cosfi); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.phase); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.pathHD); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.fullpathHD); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.Sort1); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.Sort2); Inc(Col);
  FWorksheet.WriteText(FCurrentRow, Col, ADevice.Sort2name); Inc(Col);
  FWorksheet.WriteNumber(FCurrentRow, Col, ADevice.Sort3); Inc(Col);
end;

{ TExportDevicesToExcelCommand }

constructor TExportDevicesToExcelCommand.Create;
begin
  FDeviceList := TListVElectrDevStruct.Create;
  FExporter := TStandardDeviceExporter.Create;
  FFileName := '';
end;

destructor TExportDevicesToExcelCommand.Destroy;
begin
  FDeviceList.Free;
  if FExporter <> nil then
    FExporter.Free;
  inherited Destroy;
end;

procedure TExportDevicesToExcelCommand.SetDeviceList(const AList: TListVElectrDevStruct);
var
  i: Integer;
begin
  // Очищаем старый список / Clear old list
  FDeviceList.Clear;

  // Копируем новый список / Copy new list
  for i := 0 to AList.Size - 1 do
    FDeviceList.PushBack(AList[i]);
end;

procedure TExportDevicesToExcelCommand.SetFileName(const AFileName: string);
begin
  FFileName := AFileName;
end;

procedure TExportDevicesToExcelCommand.SetExporter(AExporter: TDeviceExcelExporterBase);
begin
  // Освобождаем старый экспортер / Free old exporter
  if FExporter <> nil then
    FExporter.Free;

  FExporter := AExporter;
end;

function TExportDevicesToExcelCommand.Execute: Boolean;
begin
  Result := False;

  // Проверяем наличие данных / Check for data
  if FDeviceList.Size = 0 then
  begin
    zcUI.TextMessage('ПРЕДУПРЕЖДЕНИЕ: Список устройств пуст', TMWOHistoryOut);
    Exit;
  end;

  // Проверяем имя файла / Check file name
  if FFileName = '' then
  begin
    zcUI.TextMessage('ОШИБКА: Не указано имя файла для экспорта', TMWOHistoryOut);
    Exit;
  end;

  // Выполняем экспорт / Perform export
  zcUI.TextMessage('Начало экспорта устройств в Excel...', TMWOHistoryOut);
  Result := FExporter.ExportToFile(FDeviceList, FFileName);
end;

end.
