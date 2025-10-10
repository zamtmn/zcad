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

unit uzvmcmanager;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils, Classes, Dialogs, SQLDB, gvector,
  uzcdrawing, uzcdrawings,
  uzcinterface,
  uzvmcsqlite, uzvmcdrawing, uzvmchierarchy, uzvmcaccess, uzvmcstruct;

type
  TConnectionManager = class
  private
    FDrawingPath: string;
    FSQLiteManager: TSQLiteConnectionManager;
    FDeviceCollector: TDeviceDataCollector;
    FHierarchyBuilder: THierarchyBuilder;
    FAccessExporter: TAccessDBExporter;

    procedure PopulateHierarchyFromDevices;
    procedure InsertDevicesToDatabase;
    procedure UpdateHierarchyPaths;
  public
    constructor Create(const ADrawingPath: string);
    destructor Destroy; override;

    procedure CreateTemporaryDatabase;
    procedure AddHierarchyColumns;
    procedure ExportToAccessDatabase(const AAccessDBPath: string);
    procedure CollectAndExportDevicesToAccess(const AAccessDBPath: string);

    function CheckFileExists(const AFilePath: string): Boolean;

    property SQLiteManager: TSQLiteConnectionManager read FSQLiteManager;
    property DeviceCollector: TDeviceDataCollector read FDeviceCollector;
    property HierarchyBuilder: THierarchyBuilder read FHierarchyBuilder;
  end;

implementation

constructor TConnectionManager.Create(const ADrawingPath: string);
begin
  inherited Create;
  //FDrawingPath := ADrawingPath;

  if AnsiPos(':\', FDrawingPath) = 0 then
  zcUI.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);

    //raise Exception.Create('Чертеж не сохранен. Выполните сохранение в ZCAD!');

  //FSQLiteManager := TSQLiteConnectionManager.Create(FDrawingPath);
  //FDeviceCollector := TDeviceDataCollector.Create;
  //FHierarchyBuilder := THierarchyBuilder.Create;
  FAccessExporter := nil;
end;

destructor TConnectionManager.Destroy;
begin
  if Assigned(FAccessExporter) then
    FAccessExporter.Free;
  FHierarchyBuilder.Free;
  FDeviceCollector.Free;
  FSQLiteManager.Free;
  inherited Destroy;
end;

procedure TConnectionManager.PopulateHierarchyFromDevices;
var
  devices: specialize TVector<TDeviceData>;
  i: integer;
begin
  devices := FDeviceCollector.getAllCollectDevices;

  for i := 0 to devices.Size - 1 do
  begin
    if devices[i].HDName <> '' then
      FHierarchyBuilder.AddDevice(devices[i].HDName, 'root', devices[i].CanBeHead);
  end;

  for i := 0 to devices.Size - 1 do
  begin
    if devices[i].HDName <> '' then
      FHierarchyBuilder.AddDevice(devices[i].DevName, devices[i].HDName, devices[i].CanBeHead);
  end;

  devices.Free;
end;

procedure TConnectionManager.InsertDevicesToDatabase;
var
  devices: specialize TVector<TDeviceData>;
  i, j: integer;
  query: TSQLQuery;
begin
  devices := FDeviceCollector.getAllCollectDevices;

  query := TSQLQuery.Create(nil);
  try
    query.Database := FSQLiteManager.Connection;
    query.Transaction := FSQLiteManager.Transaction;
    query.SQL.Text := 'INSERT INTO dev (zcadid, devname, hdname, hdgroup, icanhd) VALUES (:zcadid, :devname, :hdname, :hdgroup, :icanhd)';

    for i := 0 to devices.Size - 1 do
    begin
      for j := 0 to Length(devices[i].Connections) - 1 do
      begin
        query.Params.ParamByName('zcadid').AsInteger := i + 1;
        query.Params.ParamByName('devname').AsString := devices[i].DevName;
        query.Params.ParamByName('hdname').AsString := devices[i].Connections[j].HeadDeviceName;
        query.Params.ParamByName('hdgroup').AsString := devices[i].Connections[j].NGHeadDevice;
        query.Params.ParamByName('icanhd').AsInteger := devices[i].CanBeHead;
        query.ExecSQL;
      end;
    end;

    FSQLiteManager.Transaction.Commit;
    zcUI.TextMessage('Devices inserted to database', TMWOHistoryOut);
  finally
    query.Free;
    devices.Free;
  end;
end;

procedure TConnectionManager.UpdateHierarchyPaths;
var
  selectQuery, updateQuery: TSQLQuery;
  hdname, wayHD, fullWayHD: string;
begin
  selectQuery := TSQLQuery.Create(nil);
  updateQuery := TSQLQuery.Create(nil);
  try
    selectQuery.Database := FSQLiteManager.Connection;
    selectQuery.Transaction := FSQLiteManager.Transaction;
    selectQuery.SQL.Text := 'SELECT DISTINCT hdname FROM dev WHERE hdname <> ''''';
    selectQuery.Open;

    updateQuery.Database := FSQLiteManager.Connection;
    updateQuery.Transaction := FSQLiteManager.Transaction;
    updateQuery.SQL.Text := 'UPDATE dev SET hdway = :hdway, hdfullway = :hdfullway WHERE hdname = :hdname';
    updateQuery.Prepare;

    while not selectQuery.EOF do
    begin
      hdname := selectQuery.FieldByName('hdname').AsString;
      wayHD := FHierarchyBuilder.GetDeviceWay(hdname);
      fullWayHD := FHierarchyBuilder.GetDeviceFullWay(hdname);

      updateQuery.Params.ParamByName('hdname').AsString := hdname;
      updateQuery.Params.ParamByName('hdway').AsString := wayHD;
      updateQuery.Params.ParamByName('hdfullway').AsString := fullWayHD;
      updateQuery.ExecSQL;

      selectQuery.Next;
    end;

    FSQLiteManager.Transaction.Commit;
    zcUI.TextMessage('Hierarchy paths updated', TMWOHistoryOut);
  finally
    selectQuery.Free;
    updateQuery.Free;
  end;
end;

procedure TConnectionManager.CreateTemporaryDatabase;
begin
  FSQLiteManager.CreateDatabase;
  FSQLiteManager.CreateDevTable;
  InsertDevicesToDatabase;
  zcUI.TextMessage('Temporary database created successfully', TMWOHistoryOut);
end;

procedure TConnectionManager.AddHierarchyColumns;
begin
  PopulateHierarchyFromDevices;
  FHierarchyBuilder.BuildFullHierarchy;
  FHierarchyBuilder.BuildOnlyHDHierarchy;

  FSQLiteManager.AddColumnIfNotExists('hdway', 'TEXT');
  FSQLiteManager.AddColumnIfNotExists('hdfullway', 'TEXT');

  UpdateHierarchyPaths;
  zcUI.TextMessage('Hierarchy columns added', TMWOHistoryOut);
end;

procedure TConnectionManager.ExportToAccessDatabase(const AAccessDBPath: string);
begin
  if not Assigned(FAccessExporter) then
    FAccessExporter := TAccessDBExporter.Create(AAccessDBPath);

  FAccessExporter.DatabasePath := AAccessDBPath;
  FAccessExporter.Connect;
  FAccessExporter.ClearTables;

  zcUI.TextMessage('Export to Access completed', TMWOHistoryOut);
end;

// Функция сбора всех устройств с чертежа и экспорта их в базу данных Access
// На входе: путь к файлу базы данных Access
// Функция выполняет следующие действия:
// 1. Собирает список всех устройств с чертежа в виде TListVElectrDevStruct
// 2. Подключается к базе данных Access
// 3. Очищает таблицы базы данных
// 4. Экспортирует каждое устройство из списка в базу данных
// 5. Фиксирует изменения в базе данных
procedure TConnectionManager.CollectAndExportDevicesToAccess(const AAccessDBPath: string);
var
  devicesList: TListVElectrDevStruct;
  i: integer;
begin
  // Сбор всех устройств с чертежа в виде списка структур
  devicesList := FDeviceCollector.GetAllDevicesAsStructList;

  try
    // Инициализация экспортера Access, если ещё не создан
    if not Assigned(FAccessExporter) then
      FAccessExporter := TAccessDBExporter.Create(AAccessDBPath);

    FAccessExporter.DatabasePath := AAccessDBPath;
    FAccessExporter.Connect;
    FAccessExporter.ClearTables;

    // Экспорт каждого устройства из списка в базу данных Access
    for i := 0 to devicesList.Size - 1 do
    begin
      FAccessExporter.ExportDevice(devicesList[i]);
    end;

    // Фиксация изменений в базе данных
    FAccessExporter.Commit;

    zcUI.TextMessage('Collected and exported ' + IntToStr(devicesList.Size) + ' devices to Access database', TMWOHistoryOut);
  finally
    // Освобождение списка устройств
    devicesList.Free;
  end;
end;

// Функция проверки существования файла по указанному пути
// На входе: полный путь до файла
// На выходе: значение булеан (True - файл существует, False - файл не существует)
function TConnectionManager.CheckFileExists(const AFilePath: string): Boolean;
begin
  Result := FileExists(AFilePath);
end;

end.
