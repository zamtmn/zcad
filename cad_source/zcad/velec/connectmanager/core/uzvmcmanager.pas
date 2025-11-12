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

    procedure InsertDevicesToDatabase;
  public
    constructor Create(const ADrawingPath: string);
    destructor Destroy; override;

    procedure CreateTemporaryDatabase;
     procedure ExportToAccessDatabase(const AAccessDBPath: string);
     function GetDevicesFromDrawing: TListVElectrDevStruct;
     procedure ExportDevicesListToAccess(devicesList: TListVElectrDevStruct; const AAccessDBPath: string);
     procedure ExportDevicesListToSQLite(devicesList: TListVElectrDevStruct);

    function CheckFileExists(const AFilePath: string): Boolean;

    property SQLiteManager: TSQLiteConnectionManager read FSQLiteManager;
    property DeviceCollector: TDeviceDataCollector read FDeviceCollector;
    property HierarchyBuilder: THierarchyBuilder read FHierarchyBuilder;
  end;

implementation

constructor TConnectionManager.Create(const ADrawingPath: string);
begin
  inherited Create;
  ////FDrawingPath := ADrawingPath;
  //
  ////if AnsiPos(':\', FDrawingPath) = 0 then
  ////zcUI.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);

    //raise Exception.Create('Чертеж не сохранен. Выполните сохранение в ZCAD!');

  //FSQLiteManager := TSQLiteConnectionManager.Create(FDrawingPath);
  //FDeviceCollector := TDeviceDataCollector.Create;
  FHierarchyBuilder := THierarchyBuilder.Create;
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

procedure TConnectionManager.CreateTemporaryDatabase;
begin
  FSQLiteManager.CreateDatabase;
  FSQLiteManager.CreateDevTable;
  InsertDevicesToDatabase;
  zcUI.TextMessage('Temporary database created successfully', TMWOHistoryOut);
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

// Функция экспорта подготовленного списка устройств в базу данных Access
// На входе:
//   devicesList - подготовленный список устройств с построенными иерархическими путями
//   AAccessDBPath - путь к файлу базы данных Access
// Функция выполняет следующие действия:
// 1. Инициализирует и подключается к базе данных Access
// 2. Очищает таблицы базы данных
// 3. Экспортирует каждое устройство из списка в базу данных
// 4. Фиксирует изменения в базе данных
procedure TConnectionManager.ExportDevicesListToAccess(devicesList: TListVElectrDevStruct; const AAccessDBPath: string);
var
  i: integer;
  fnhddev:string;
  function getfullnamebasename(ihd:string):string;
  const
    sep='.';
  var
    j:integer;
  begin
    result:='ERROR';
    for j := 0 to devicesList.Size - 1 do
    begin
      if devicesList[j].basename = ihd then
        begin
          result:= devicesList[j].basename + sep
                  + devicesList[j].headdev + sep
                  + inttostr(devicesList[j].feedernum) + sep
                  + inttostr(devicesList[j].numconnect) + sep
                  + inttostr(devicesList[j].numdevinfeeder);
          break;
        end;
    end;
  end;

begin
  if not CheckFileExists(AAccessDBPath) then
    exit;

  // Инициализация экспортера Access, если ещё не создан
  if not Assigned(FAccessExporter) then
    FAccessExporter := TAccessDBExporter.Create(AAccessDBPath);

  FAccessExporter.DatabasePath := AAccessDBPath;
  FAccessExporter.Connect;
  FAccessExporter.ClearTables;

  // Экспорт каждого устройства из списка в базу данных Access
  for i := 0 to devicesList.Size - 1 do
  begin
    //if i>0 then begin
    //  if devicesList[i].fullname <> devicesList[i-1].fullname then
    //    FAccessExporter.ExportDeviceVOLODQ(devicesList[i]);
    //end
    //else
    FAccessExporter.ExportDeviceVOLODQ(devicesList[i]);
  end;
  for i := 0 to devicesList.Size - 1 do
  begin
    //FAccessExporter.ExportDeviceVOLODQ(devicesList[i]);
    fnhddev:=getfullnamebasename(devicesList[i].headdev);
    if fnhddev<>'ERROR'then
    FAccessExporter.ExportConnectVOLODQ(devicesList[i],getfullnamebasename(devicesList[i].headdev));

  end;

  for i := 0 to devicesList.Size - 1 do
  begin
    if i>0 then begin
      if devicesList[i].fullname <> devicesList[i-1].fullname then
        FAccessExporter.ExportDeviceInputVOLODQ(devicesList[i]);
        //FAccessExporter.ExportDevice(devicesList[i]);
    end
    else
      FAccessExporter.ExportDeviceInputVOLODQ(devicesList[i]);
  end;

   // Фиксация изменений в базе данных
   FAccessExporter.Commit;
 end;

 // Функция экспорта подготовленного списка устройств в базу данных SQLite
 // На входе:
 //   devicesList - подготовленный список устройств с построенными иерархическими путями
 // Функция выполняет следующие действия:
 // 1. Инициализирует и подключается к базе данных SQLite
 // 2. Создает необходимые таблицы
 // 3. Очищает таблицы базы данных
 // 4. Экспортирует каждое устройство из списка в базу данных
 // 5. Фиксирует изменения в базе данных
 procedure TConnectionManager.ExportDevicesListToSQLite(devicesList: TListVElectrDevStruct);
 var
   i: integer;
   fnhddev:string;
   function getfullnamebasename(ihd:string):string;
   const
     sep='.';
   var
     j:integer;
   begin
     result:='ERROR';
     for j := 0 to devicesList.Size - 1 do
     begin
       if devicesList[j].basename = ihd then
         begin
           result:= devicesList[j].basename + sep
                   + devicesList[j].headdev + sep
                   + inttostr(devicesList[j].feedernum) + sep
                   + inttostr(devicesList[j].numconnect) + sep
                   + inttostr(devicesList[j].numdevinfeeder);
           break;
         end;
     end;
   end;

 begin
   // Инициализация SQLite менеджера, если ещё не создан
   if not Assigned(FSQLiteManager) then
     FSQLiteManager := TSQLiteConnectionManager.Create(FDrawingPath);

   FSQLiteManager.OpenConnection;
   FSQLiteManager.CreateDeviceTable;
   FSQLiteManager.CreateConnectTable;
   FSQLiteManager.CreateDeviceInputTable;
   FSQLiteManager.ClearTables;

   // Экспорт каждого устройства из списка в базу данных SQLite
   for i := 0 to devicesList.Size - 1 do
   begin
     FSQLiteManager.ExportDeviceVOLODQ(devicesList[i]);
   end;

   for i := 0 to devicesList.Size - 1 do
   begin
     fnhddev:=getfullnamebasename(devicesList[i].headdev);
     if fnhddev<>'ERROR' then
       FSQLiteManager.ExportConnectVOLODQ(devicesList[i], getfullnamebasename(devicesList[i].headdev));
   end;

   for i := 0 to devicesList.Size - 1 do
   begin
     if i>0 then begin
       if devicesList[i].fullname <> devicesList[i-1].fullname then
         FSQLiteManager.ExportDeviceInputVOLODQ(devicesList[i]);
     end
     else
       FSQLiteManager.ExportDeviceInputVOLODQ(devicesList[i]);
   end;

   // Фиксация изменений в базе данных
   FSQLiteManager.Commit;
 end;

// Функция подготовки списка всех устройств с чертежа
// На выходе: список устройств TListVElectrDevStruct с построенными иерархическими путями
// Функция выполняет следующие действия:
// 1. Собирает список всех устройств с чертежа в виде TListVElectrDevStruct
// 2. Строит иерархические пути для каждого устройства (pathHD и fullpathHD)
// 3. Заполняет поля сортировки (Sort1, Sort2, Sort3)
// Примечание: сортировка и экспорт в базу данных выполняются вызывающей стороной
function TConnectionManager.GetDevicesFromDrawing: TListVElectrDevStruct;
const
  sep='.';
var
  i: integer;
begin
  // Сбор всех устройств с чертежа в виде списка структур
  Result := FDeviceCollector.GetAllDevicesAsStructList;

  // Построение иерархических путей для всех устройств
  FHierarchyBuilder.BuildHierarchyPaths(Result);
//
  //for i := 0 to Result.Size - 1 do
  //    zcUI.TextMessage('beforeSort= '
  //                                    + ' pathHD=' + Result[i].pathHD
  //                                    + ' Sort1=' + inttostr(Result[i].Sort1)
  //                                    + ' Sort2=' + inttostr(Result[i].Sort2)
  //                                    + ' Sort2name=' + Result[i].Sort2name
  //                                    + ' Sort3=' + inttostr(Result[i].Sort3)
  //                                    + ' Sort3name=' + Result[i].Sort3name
  //                                    + ' Power=' + floattostr(Result[i].Power)
  //                                    + ' basename=' + Result[i].basename
  //                                    + ' NEWname=' + Result[i].basename + sep
  //                                    + Result[i].headdev + sep
  //                                    + inttostr(Result[i].feedernum) + sep
  //                                    + inttostr(Result[i].numconnect) + sep
  //                                    , TMWOHistoryOut);


  // Затем заполнить поля сортировки
  FHierarchyBuilder.FillSortFields(Result);
  //for i := 0 to Result.Size - 1 do
  //    zcUI.TextMessage('beforeSort= '
  //                                + ' pathHD=' + Result[i].pathHD
  //                                + ' Sort1=' + inttostr(Result[i].Sort1)
  //                                + ' Sort2=' + inttostr(Result[i].Sort2)
  //                                + ' Sort2name=' + Result[i].Sort2name
  //                                + ' Sort3=' + inttostr(Result[i].Sort3)
  //                                + ' Sort3name=' + Result[i].Sort3name
  //                                + ' Power=' + floattostr(Result[i].Power)
  //                                + ' basename=' + Result[i].basename
  //                                + ' NEWname=' + Result[i].basename + sep
  //                                + Result[i].headdev + sep
  //                                + inttostr(Result[i].feedernum) + sep
  //                                + inttostr(Result[i].numconnect) + sep
  //                                , TMWOHistoryOut);
  //// Затем заполнить поля номер устройства в фидере
  //FHierarchyBuilder.SetNumDevinFeeder(Result);
  //  for i := 0 to Result.Size - 1 do
  //  zcUI.TextMessage('SetNumDevinFeeder= '
  //                              + ' pathHD=' + Result[i].pathHD
  //                              + ' Sort1=' + inttostr(Result[i].Sort1)
  //                              + ' Sort2name=' + Result[i].Sort2name
  //                              + ' Sort3=' + inttostr(Result[i].Sort3)
  //                              + ' Sort3name=' + Result[i].Sort3name
  //                              + ' Power=' + floattostr(Result[i].Power)
  //                              + ' basename=' + Result[i].basename
  //                              + ' NEWname=' + Result[i].basename + sep
  //                                    + Result[i].headdev + sep
  //                                    + inttostr(Result[i].feedernum) + sep
  //                                    + inttostr(Result[i].numconnect) + sep
  //                                    + inttostr(Result[i].numdevinfeeder), TMWOHistoryOut);
  //
  //for i := 0 to Result.Size - 1 do
  //    zcUI.TextMessage('FindOnlyHDHierarchy ' + Result[i].pathHD + ' - sort1= ' + inttostr(Result[i].Sort1) + ' - sort2= ' + inttostr(Result[i].Sort2)+ ' - sort2name= ' + Result[i].Sort2name + ' - sort3= ' + inttostr(Result[i].Sort3)+ ' - sort3name= ' + Result[i].Sort3name, TMWOHistoryOut);

  zcUI.TextMessage('Collected ' + IntToStr(Result.Size) + ' devices from drawing', TMWOHistoryOut);
end;

// Функция проверки существования файла по указанному пути
// На входе: полный путь до файла
// На выходе: значение булеан (True - файл существует, False - файл не существует)
function TConnectionManager.CheckFileExists(const AFilePath: string): Boolean;
begin
  Result := FileExists(AFilePath);
end;

end.
