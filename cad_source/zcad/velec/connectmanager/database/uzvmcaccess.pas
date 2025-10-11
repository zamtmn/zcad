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

unit uzvmcaccess;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils, Classes, Dialogs,
  SQLDB, odbcconn,
  uzcinterface, uzvmcstruct;

type
  TAccessDBExporter = class
  private
    FConnection: TODBCConnection;
    FQuery: TSQLQuery;
    FTransaction: TSQLTransaction;
    FDatabasePath: string;
  public
    constructor Create(const ADatabasePath: string);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    procedure ClearTables;
    procedure ExportDevice(const ADeviceInfo: TVElectrDevStruct);
    procedure ExportConnection(const ADeviceInfo: TVElectrDevStruct);
    procedure Commit;

    property DatabasePath: string read FDatabasePath write FDatabasePath;
  end;

implementation

constructor TAccessDBExporter.Create(const ADatabasePath: string);
begin
  inherited Create;
  FDatabasePath := ADatabasePath;

  FConnection := TODBCConnection.Create(nil);
  FQuery := TSQLQuery.Create(nil);
  FTransaction := TSQLTransaction.Create(nil);

  FConnection.Driver := 'Microsoft Access Driver (*.mdb, *.accdb)';
  FConnection.LoginPrompt := False;
end;

destructor TAccessDBExporter.Destroy;
begin
  Disconnect;
  FQuery.Free;
  FTransaction.Free;
  FConnection.Free;
  inherited Destroy;
end;

procedure TAccessDBExporter.Connect;
begin
  FConnection.Params.Clear;
  FConnection.Params.Add('Dbq=' + FDatabasePath);
  if FConnection.Connected then
    Exit;

  FConnection.Connected := True;

  FTransaction.DataBase := FConnection;
  FQuery.DataBase := FConnection;
  FQuery.Transaction := FTransaction;

  zcUI.TextMessage('Connected to Access database: ' + FDatabasePath, TMWOHistoryOut);
end;

procedure TAccessDBExporter.Disconnect;
begin
  if FConnection.Connected then
    FConnection.Connected := False;
end;

procedure TAccessDBExporter.ClearTables;
begin
  try
    FQuery.SQL.Text := 'DELETE * FROM Device';
    FQuery.ExecSQL;

    FQuery.SQL.Text := 'DELETE * FROM Connect';
    FQuery.ExecSQL;

    zcUI.TextMessage('Access tables cleared', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка очищения таблиц: ' + E.Message, TMWOHistoryOut);
  end;
end;

procedure TAccessDBExporter.ExportDevice(const ADeviceInfo: TVElectrDevStruct);
begin
  try
    //zcUI.TextMessage('pPrimID: ' + pPrimID+' - pPower: ' + pPower, TMWOHistoryOut);
    FQuery.SQL.Text := 'INSERT INTO Device (Prim_ID, Рower, Voltage, Phase, CosF, Type) VALUES (:pPrimID, :pPower, :pVoltage, :pPhase, :pCosF, :pType)';
    FQuery.Params.ParamByName('pPrimID').AsString := ADeviceInfo.fullname;
    FQuery.Params.ParamByName('pPower').AsFloat := ADeviceInfo.power;
    FQuery.Params.ParamByName('pVoltage').AsInteger := ADeviceInfo.voltage;
    FQuery.Params.ParamByName('pPhase').AsString := ADeviceInfo.phase;
    FQuery.Params.ParamByName('pCosF').AsFloat := ADeviceInfo.cosfi;
    FQuery.Params.ParamByName('pType').AsString := ADeviceInfo.devtype;
    FQuery.ExecSQL;
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка экспорта устройства: ' + E.Message, TMWOHistoryOut);
  end;
end;

procedure TAccessDBExporter.ExportConnection(const ADeviceInfo: TVElectrDevStruct);
begin
  try
    FQuery.SQL.Text := 'INSERT INTO Connect (Prim_ID, Sec_ID, Feeder) VALUES (:pPrimID, :pSecID, :pFeeder)';
    FQuery.Params.ParamByName('pPrimID').AsString := ADeviceInfo.fullname;
    FQuery.Params.ParamByName('pSecID').AsString := ADeviceInfo.headdev;
    FQuery.Params.ParamByName('pFeeder').AsInteger := ADeviceInfo.feedernum;
    FQuery.ExecSQL;
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка экспорта подключения: ' + E.Message, TMWOHistoryOut);
  end;
end;

procedure TAccessDBExporter.Commit;
begin
  FTransaction.Commit;
  zcUI.TextMessage('Access export committed successfully', TMWOHistoryOut);
end;

end.
