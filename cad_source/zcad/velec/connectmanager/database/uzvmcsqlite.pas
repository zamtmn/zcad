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
  uzvmcdbconsts;

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

end.
