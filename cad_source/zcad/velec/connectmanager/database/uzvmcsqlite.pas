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

unit uzvmcsqlite;
{$INCLUDE zengineconfig.inc}

interface
uses
   sysutils, Classes, Dialogs,
   SQLDB, SQLite3Conn, sqlite3dyn,
   uzcdrawing, uzcdrawings,
   uzcinterface,
   uzvmcdbconsts, uzvmcstruct;

type
  TSQLiteConnectionManager = class
  private
    FConnection: TSQLite3Connection;
    FTransaction: TSQLTransaction;
    FDatabasePath: string;
    function LoadSQLiteLibrary: Boolean;
    function IsDatabaseLocked: Boolean;
  public
    constructor Create(const ADrawingPath: string);
    destructor Destroy; override;

    procedure OpenConnection;
    procedure CloseConnection;
    procedure CreateDatabase;
    procedure CreateDevTable;
    procedure AddColumnIfNotExists(const AColumnName, AColumnType: string);

     function ExecuteQuery(const ASQL: string): TSQLQuery;
     procedure ExecuteNonQuery(const ASQL: string);

     // Database table management
     procedure CreateDeviceTable;
     procedure CreateConnectTable;
     procedure CreateDeviceInputTable;
     procedure ClearTables;

     // Export methods (ported from Access)
     procedure ExportDevice(const ADeviceInfo: TVElectrDevStruct);
     procedure ExportConnection(const ADeviceInfo: TVElectrDevStruct);
     procedure ExportDeviceVOLODQ(const ADeviceInfo: TVElectrDevStruct);
     procedure ExportDeviceInputVOLODQ(const ADeviceInfo: TVElectrDevStruct);
     procedure ExportConnectVOLODQ(const ADeviceInfo: TVElectrDevStruct; ihddevname: string);
     procedure Commit;

     property Connection: TSQLite3Connection read FConnection;
     property Transaction: TSQLTransaction read FTransaction;
     property DatabasePath: string read FDatabasePath;
  end;

implementation

constructor TSQLiteConnectionManager.Create(const ADrawingPath: string);
begin
  inherited Create;
  FDatabasePath := ADrawingPath + vcalctempdbfilename;

  if not LoadSQLiteLibrary then
    raise Exception.Create('SQLite3.dll not found!');

  FConnection := TSQLite3Connection.Create(nil);
  FConnection.DatabaseName := FDatabasePath;

  FTransaction := TSQLTransaction.Create(nil);
  FTransaction.Database := FConnection;
  FConnection.Transaction := FTransaction;
end;

destructor TSQLiteConnectionManager.Destroy;
begin
  if Assigned(FTransaction) then
    FTransaction.Free;
  if Assigned(FConnection) then
    FConnection.Free;
  inherited Destroy;
end;

function TSQLiteConnectionManager.LoadSQLiteLibrary: Boolean;
var
  LibPath: String;
begin
  LibPath := 'sqlite3.dll';

  if not FileExists(LibPath) then
  begin
    LibPath := ExtractFilePath(ParamStr(0)) + 'sqlite3.dll';
    zcUI.TextMessage('Найдена sqlite3.dll по пути: ' + LibPath, TMWOHistoryOut);
  end;

  if not FileExists(LibPath) then
    LibPath := 'C:\zcad\zcad\sqlite3.dll';

  sqlite3dyn.SQLiteDefaultLibrary := LibPath;
  Result := FileExists(LibPath);

  if not Result then
    zcUI.TextMessage('Не удалось найти sqlite3.dll по пути: ' + LibPath, TMWOHistoryOut);
end;

function TSQLiteConnectionManager.IsDatabaseLocked: Boolean;
var
  FileHandle: THandle;
begin
  Result := False;
  try
    FileHandle := FileOpen(FDatabasePath, fmOpenWrite or fmShareExclusive);
    if FileHandle <> THandle(-1) then
    begin
      FileClose(FileHandle);
      Result := False;
    end
    else
      Result := True;
  except
    Result := True;
  end;
end;

procedure TSQLiteConnectionManager.OpenConnection;
begin
  if not FConnection.Connected then
    FConnection.Open;
  if not FTransaction.Active then
    FTransaction.Active := True;
end;

procedure TSQLiteConnectionManager.CloseConnection;
begin
  if FTransaction.Active then
    FTransaction.Active := False;
  if FConnection.Connected then
    FConnection.Close;
end;

procedure TSQLiteConnectionManager.CreateDatabase;
begin
  if not IsDatabaseLocked then
  begin
    if FileExists(FDatabasePath) then
      DeleteFile(FDatabasePath);
  end
  else
    raise Exception.Create('База данных заблокирована!');

  OpenConnection;
  zcUI.TextMessage('Database created: ' + FDatabasePath, TMWOHistoryOut);
end;

procedure TSQLiteConnectionManager.CreateDevTable;
var
  Query: TSQLQuery;
begin
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := FConnection;
    Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS dev (' +
                      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                      'zcadid INTEGER, ' +
                      'devname TEXT NOT NULL, ' +
                      'hdname TEXT, ' +
                      'hdgroup TEXT, ' +
                      'icanhd INTEGER' +
                      ')';
    Query.ExecSQL;
    FTransaction.Commit;
    zcUI.TextMessage('Table "dev" created', TMWOHistoryOut);
  finally
    Query.Free;
  end;
end;

procedure TSQLiteConnectionManager.AddColumnIfNotExists(const AColumnName, AColumnType: string);
var
  ColExists: Boolean;
  Query: TSQLQuery;
begin
  ColExists := False;
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := FConnection;
    Query.SQL.Text := 'PRAGMA table_info(dev);';
    Query.Open;

    while not Query.EOF do
    begin
      if SameText(Query.FieldByName('name').AsString, AColumnName) then
      begin
        ColExists := True;
        Break;
      end;
      Query.Next;
    end;

    Query.Close;

    if not ColExists then
    begin
      Query.SQL.Text := Format('ALTER TABLE dev ADD COLUMN %s %s;', [AColumnName, AColumnType]);
      Query.ExecSQL;
      FTransaction.Commit;
    end;
  finally
    Query.Free;
  end;
end;

function TSQLiteConnectionManager.ExecuteQuery(const ASQL: string): TSQLQuery;
begin
  Result := TSQLQuery.Create(nil);
  Result.Database := FConnection;
  Result.Transaction := FTransaction;
  Result.SQL.Text := ASQL;
  Result.Open;
end;

procedure TSQLiteConnectionManager.ExecuteNonQuery(const ASQL: string);
var
   Query: TSQLQuery;
begin
   Query := TSQLQuery.Create(nil);
   try
     Query.Database := FConnection;
     Query.Transaction := FTransaction;
     Query.SQL.Text := ASQL;
     Query.ExecSQL;
     FTransaction.Commit;
   finally
     Query.Free;
   end;
end;

// Database table management
procedure TSQLiteConnectionManager.CreateDeviceTable;
var
   Query: TSQLQuery;
begin
   Query := TSQLQuery.Create(nil);
   try
     Query.Database := FConnection;
     Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS Device (' +
                       'Prim_ID TEXT, ' +
                       'Рower REAL, ' +
                       'Voltage INTEGER, ' +
                       'Phase TEXT, ' +
                       'CosF REAL, ' +
                       'Type TEXT, ' +
                       'pathHD TEXT, ' +
                       'fullpathHD TEXT, ' +
                       'S1 INTEGER, ' +
                       'S2 INTEGER, ' +
                       'S3 INTEGER)';
     Query.ExecSQL;
     FTransaction.Commit;
     zcUI.TextMessage('Table "Device" created', TMWOHistoryOut);
   finally
     Query.Free;
   end;
end;

procedure TSQLiteConnectionManager.CreateConnectTable;
var
   Query: TSQLQuery;
begin
   Query := TSQLQuery.Create(nil);
   try
     Query.Database := FConnection;
     Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS Connect (' +
                       'Prim_ID TEXT, ' +
                       'Sec_ID TEXT, ' +
                       'Feeder INTEGER)';
     Query.ExecSQL;
     FTransaction.Commit;
     zcUI.TextMessage('Table "Connect" created', TMWOHistoryOut);
   finally
     Query.Free;
   end;
end;

procedure TSQLiteConnectionManager.CreateDeviceInputTable;
var
   Query: TSQLQuery;
begin
   Query := TSQLQuery.Create(nil);
   try
     Query.Database := FConnection;
     Query.SQL.Text := 'CREATE TABLE IF NOT EXISTS DeviceInput (' +
                       'Input_ID TEXT, ' +
                       'Prim_ID TEXT, ' +
                       'Value REAL)';
     Query.ExecSQL;
     FTransaction.Commit;
     zcUI.TextMessage('Table "DeviceInput" created', TMWOHistoryOut);
   finally
     Query.Free;
   end;
end;

procedure TSQLiteConnectionManager.ClearTables;
begin
   try
     ExecuteNonQuery('DELETE FROM Device');
     ExecuteNonQuery('DELETE FROM Connect');
     ExecuteNonQuery('DELETE FROM DeviceInput');
     zcUI.TextMessage('SQLite tables cleared', TMWOHistoryOut);
   except
     on E: Exception do
       zcUI.TextMessage('Ошибка очищения таблиц: ' + E.Message, TMWOHistoryOut);
   end;
end;

// Export methods (ported from Access)
procedure TSQLiteConnectionManager.ExportDevice(const ADeviceInfo: TVElectrDevStruct);
var
   Query: TSQLQuery;
begin
   try
     Query := TSQLQuery.Create(nil);
     try
       Query.Database := FConnection;
       Query.Transaction := FTransaction;
       Query.SQL.Text := 'INSERT INTO Device (Prim_ID, Рower, Voltage, Phase, CosF, Type, pathHD, fullpathHD, S1, S2, S3) VALUES (:pPrimID, :pPower, :pVoltage, :pPhase, :pCosF, :pType, :ppathHD, :pfullpathHD, :pS1, :pS2, :pS3)';
       Query.Params.ParamByName('pPrimID').AsString := ADeviceInfo.fullname;
       Query.Params.ParamByName('pPower').AsFloat := ADeviceInfo.power;
       Query.Params.ParamByName('pVoltage').AsInteger := ADeviceInfo.voltage;
       Query.Params.ParamByName('pPhase').AsString := ADeviceInfo.phase;
       Query.Params.ParamByName('pCosF').AsFloat := ADeviceInfo.cosfi;
       Query.Params.ParamByName('pType').AsString := ADeviceInfo.devtype;
       Query.Params.ParamByName('ppathHD').AsString := ADeviceInfo.pathHD;
       Query.Params.ParamByName('pfullpathHD').AsString := ADeviceInfo.fullpathHD;
       Query.Params.ParamByName('pS1').AsInteger := ADeviceInfo.Sort1;
       Query.Params.ParamByName('pS2').AsInteger := ADeviceInfo.Sort2;
       Query.Params.ParamByName('pS3').AsInteger := ADeviceInfo.Sort3;
       Query.ExecSQL;
     finally
       Query.Free;
     end;
   except
     on E: Exception do
       zcUI.TextMessage('Ошибка экспорта устройства: ' + E.Message, TMWOHistoryOut);
   end;
end;

procedure TSQLiteConnectionManager.ExportDeviceVOLODQ(const ADeviceInfo: TVElectrDevStruct);
const
   sep='.';
var
   Query: TSQLQuery;
   devPrimID: string;
begin
   try
     devPrimID := ADeviceInfo.basename + sep
             + ADeviceInfo.headdev + sep
             + inttostr(ADeviceInfo.feedernum) + sep
             + inttostr(ADeviceInfo.numconnect) + sep
             + inttostr(ADeviceInfo.numdevinfeeder);

     Query := TSQLQuery.Create(nil);
     try
       Query.Database := FConnection;
       Query.Transaction := FTransaction;
       Query.SQL.Text := 'INSERT INTO Device (Prim_ID, Type) VALUES (:pPrimID, :pType)';
       Query.Params.ParamByName('pPrimID').AsString := devPrimID;
       Query.Params.ParamByName('pType').AsString := ADeviceInfo.devtype;
       Query.ExecSQL;
     finally
       Query.Free;
     end;
   except
     on E: Exception do
       zcUI.TextMessage('Ошибка ExportDeviceVOLODQ устройства: ADeviceInfo.fullname = '+ADeviceInfo.fullname + ' ; devPrimID='+devPrimID+ 'Сообщение ошибки' + E.Message, TMWOHistoryOut);
   end;
end;

procedure TSQLiteConnectionManager.ExportDeviceInputVOLODQ(const ADeviceInfo: TVElectrDevStruct);
const
   sep='.';
var
   Query: TSQLQuery;
   phase: integer;
   devPrimID: string;
begin
   try
     devPrimID := ADeviceInfo.basename + sep
         + ADeviceInfo.headdev + sep
         + inttostr(ADeviceInfo.feedernum) + sep
         + inttostr(ADeviceInfo.numconnect) + sep
         + inttostr(ADeviceInfo.numdevinfeeder);

     Query := TSQLQuery.Create(nil);
     try
       Query.Database := FConnection;
       Query.Transaction := FTransaction;
       Query.SQL.Text := 'INSERT INTO DeviceInput (Input_ID, Prim_ID, Value) VALUES (:pInputID, :pPrimID, :pValue)';
       Query.Prepare;

       Query.Params.ParamByName('pInputID').AsString := 'Cos';
       Query.Params.ParamByName('pPrimID').AsString := devPrimID;
       Query.Params.ParamByName('pValue').AsFloat := ADeviceInfo.cosfi;
       Query.ExecSQL;

       Query.Params.ParamByName('pInputID').AsString := 'F';
       Query.Params.ParamByName('pPrimID').AsString := devPrimID;
       if ADeviceInfo.phase = 'ABC' then
         phase := 0
       else if ADeviceInfo.phase = 'A' then
         phase := 1
       else if ADeviceInfo.phase = 'B' then
         phase := 2
       else if ADeviceInfo.phase = 'C' then
         phase := 3
       else
         phase := -1;

       Query.Params.ParamByName('pValue').AsFloat := phase;
       Query.ExecSQL;

       Query.Params.ParamByName('pInputID').AsString := 'Py';
       Query.Params.ParamByName('pPrimID').AsString := devPrimID;
       Query.Params.ParamByName('pValue').AsFloat := ADeviceInfo.power;
       Query.ExecSQL;

       Query.Params.ParamByName('pInputID').AsString := 'U';
       Query.Params.ParamByName('pPrimID').AsString := devPrimID;
       Query.Params.ParamByName('pValue').AsFloat := ADeviceInfo.voltage;
       Query.ExecSQL;
     finally
       Query.Free;
     end;
   except
     on E: Exception do
       zcUI.TextMessage('Ошибка ExportDeviceInputVOLODQ устройства: ADeviceInfo.fullname = '+ADeviceInfo.fullname + ' ; devPrimID='+devPrimID+ 'Сообщение ошибки' + E.Message, TMWOHistoryOut);
   end;
end;

procedure TSQLiteConnectionManager.ExportConnectVOLODQ(const ADeviceInfo: TVElectrDevStruct; ihddevname: string);
const
   sep='.';
var
   Query: TSQLQuery;
   devPrimID: string;
begin
   try
     devPrimID := ADeviceInfo.basename + sep
         + ADeviceInfo.headdev + sep
         + inttostr(ADeviceInfo.feedernum) + sep
         + inttostr(ADeviceInfo.numconnect) + sep
         + inttostr(ADeviceInfo.numdevinfeeder);

     Query := TSQLQuery.Create(nil);
     try
       Query.Database := FConnection;
       Query.Transaction := FTransaction;
       Query.SQL.Text := 'INSERT INTO Connect (Prim_ID, Sec_ID, Feeder) VALUES (:pPrimID, :pSecID, :pFeeder)';
       Query.Params.ParamByName('pPrimID').AsString := devPrimID;
       Query.Params.ParamByName('pSecID').AsString := ihddevname;
       Query.Params.ParamByName('pFeeder').AsInteger := ADeviceInfo.feedernum;
       Query.ExecSQL;
     finally
       Query.Free;
     end;
   except
     on E: Exception do
       zcUI.TextMessage('Ошибка ExportConnectVOLODQ устройства: ADeviceInfo.fullname = '+ADeviceInfo.fullname + ' ; devPrimID='+devPrimID+ 'Сообщение ошибки' + E.Message, TMWOHistoryOut);
   end;
end;

procedure TSQLiteConnectionManager.ExportConnection(const ADeviceInfo: TVElectrDevStruct);
var
   Query: TSQLQuery;
begin
   try
     Query := TSQLQuery.Create(nil);
     try
       Query.Database := FConnection;
       Query.Transaction := FTransaction;
       Query.SQL.Text := 'INSERT INTO Connect (Prim_ID, Sec_ID, Feeder) VALUES (:pPrimID, :pSecID, :pFeeder)';
       Query.Params.ParamByName('pPrimID').AsString := ADeviceInfo.fullname;
       Query.Params.ParamByName('pSecID').AsString := ADeviceInfo.headdev;
       Query.Params.ParamByName('pFeeder').AsInteger := ADeviceInfo.feedernum;
       Query.ExecSQL;
     finally
       Query.Free;
     end;
   except
     on E: Exception do
       zcUI.TextMessage('Ошибка экспорта подключения: ' + E.Message, TMWOHistoryOut);
   end;
end;

procedure TSQLiteConnectionManager.Commit;
begin
   FTransaction.Commit;
   zcUI.TextMessage('SQLite export committed successfully', TMWOHistoryOut);
end;

end.
