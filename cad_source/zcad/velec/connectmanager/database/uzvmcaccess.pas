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
    procedure ExportDeviceVOLODQ(const ADeviceInfo: TVElectrDevStruct);
    procedure ExportDeviceInputVOLODQ(const ADeviceInfo: TVElectrDevStruct);
    procedure ExportConnectVOLODQ(const ADeviceInfo: TVElectrDevStruct;ihddevname:string);
    procedure Commit;

    property DatabasePath: string read FDatabasePath write FDatabasePath;
  end;

implementation

  const
    sep='.';

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

    FQuery.SQL.Text := 'DELETE * FROM DeviceInput';
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
    FQuery.SQL.Text := 'INSERT INTO Device (Prim_ID, Рower, Voltage, Phase, CosF, Type, pathHD, fullpathHD,S1,S2,S3) VALUES (:pPrimID, :pPower, :pVoltage, :pPhase, :pCosF, :pType, :ppathHD, :pfullpathHD, :pS1, :pS2, :pS3)';
    FQuery.Params.ParamByName('pPrimID').AsString := ADeviceInfo.fullname;
    FQuery.Params.ParamByName('pPower').AsFloat := ADeviceInfo.power;
    FQuery.Params.ParamByName('pVoltage').AsInteger := ADeviceInfo.voltage;
    FQuery.Params.ParamByName('pPhase').AsString := ADeviceInfo.phase;
    FQuery.Params.ParamByName('pCosF').AsFloat := ADeviceInfo.cosfi;
    FQuery.Params.ParamByName('pType').AsString := ADeviceInfo.devtype;
    FQuery.Params.ParamByName('ppathHD').AsString := ADeviceInfo.pathHD;
    FQuery.Params.ParamByName('pfullpathHD').AsString := ADeviceInfo.fullpathHD;
    FQuery.Params.ParamByName('pS1').AsInteger := ADeviceInfo.Sort1;
    FQuery.Params.ParamByName('pS2').AsInteger := ADeviceInfo.Sort2;
    FQuery.Params.ParamByName('pS3').AsInteger := ADeviceInfo.Sort3;
    FQuery.ExecSQL;
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка экспорта устройства: ' + E.Message, TMWOHistoryOut);
  end;
end;
procedure TAccessDBExporter.ExportDeviceVOLODQ(const ADeviceInfo: TVElectrDevStruct);
var
    devPrimID:string;
begin
  try
    devPrimID:= ADeviceInfo.basename + sep
            + ADeviceInfo.headdev + sep
            + inttostr(ADeviceInfo.feedernum) + sep
            + inttostr(ADeviceInfo.numconnect) + sep
            + inttostr(ADeviceInfo.numdevinfeeder);

    FQuery.SQL.Text := 'INSERT INTO Device (Prim_ID, Type) VALUES (:pPrimID, :pType)';
    FQuery.Params.ParamByName('pPrimID').AsString := devPrimID;
    FQuery.Params.ParamByName('pType').AsString := ADeviceInfo.devtype;
    FQuery.ExecSQL;
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка ExportDeviceVOLODQ устройства: ADeviceInfo.fullname = '+ADeviceInfo.fullname + ' ; devPrimID='+devPrimID+ 'Сообщение ошибки' + E.Message, TMWOHistoryOut);
  end;
end;

procedure TAccessDBExporter.ExportDeviceInputVOLODQ(const ADeviceInfo: TVElectrDevStruct);
var
  phase:integer;
  devPrimID:string;

begin
  try
    devPrimID:= ADeviceInfo.basename + sep
        + ADeviceInfo.headdev + sep
        + inttostr(ADeviceInfo.feedernum) + sep
        + inttostr(ADeviceInfo.numconnect) + sep
        + inttostr(ADeviceInfo.numdevinfeeder);
    FQuery.SQL.Text := 'INSERT INTO DeviceInput ([Input_ID], [Prim_ID], [Value]) VALUES (:pInputID, :pPrimID, :pValue)';
    FQuery.Prepare;
    FQuery.Params.ParamByName('pInputID').AsString := 'Cos';
    FQuery.Params.ParamByName('pPrimID').AsString := devPrimID;
    FQuery.Params.ParamByName('pValue').AsFloat := 1;
    FQuery.ExecSQL;
    FQuery.Params.ParamByName('pInputID').AsString := 'F';
    FQuery.Params.ParamByName('pPrimID').AsString := devPrimID;
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

    //FQuery.Params.ParamByName('pValue').AsFloat := phase;
    FQuery.ExecSQL;
    FQuery.Params.ParamByName('pInputID').AsString := 'Py';
    FQuery.Params.ParamByName('pPrimID').AsString := devPrimID;
    FQuery.Params.ParamByName('pValue').AsFloat := ADeviceInfo.power;
    FQuery.ExecSQL;
    FQuery.Params.ParamByName('pInputID').AsString := 'U';
    FQuery.Params.ParamByName('pPrimID').AsString := devPrimID;
    FQuery.Params.ParamByName('pValue').AsFloat := ADeviceInfo.voltage;
    FQuery.ExecSQL;
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка ExportDeviceInputVOLODQ устройства: ADeviceInfo.fullname = '+ADeviceInfo.fullname + ' ; devPrimID='+devPrimID+ 'Сообщение ошибки' + E.Message, TMWOHistoryOut);
  end;
end;

procedure TAccessDBExporter.ExportConnectVOLODQ(const ADeviceInfo: TVElectrDevStruct;ihddevname:string);
var
    devPrimID:string;
begin
  try
    devPrimID:= ADeviceInfo.basename + sep
        + ADeviceInfo.headdev + sep
        + inttostr(ADeviceInfo.feedernum) + sep
        + inttostr(ADeviceInfo.numconnect) + sep
        + inttostr(ADeviceInfo.numdevinfeeder);
    FQuery.SQL.Text := 'INSERT INTO Connect (Prim_ID, Sec_ID, Feeder) VALUES (:pPrimID, :pSecID, :pFeeder)';
    FQuery.Params.ParamByName('pPrimID').AsString := ADeviceInfo.basename + sep
                                                    + ADeviceInfo.headdev + sep
                                                    + inttostr(ADeviceInfo.feedernum) + sep
                                                    + inttostr(ADeviceInfo.numconnect) + sep
                                                    + inttostr(ADeviceInfo.numdevinfeeder);
    FQuery.Params.ParamByName('pSecID').AsString := ihddevname;
    FQuery.Params.ParamByName('pFeeder').AsInteger := ADeviceInfo.feedernum;
    FQuery.ExecSQL;
  except
    on E: Exception do
      zcUI.TextMessage('Ошибка ExportConnectVOLODQ устройства: ADeviceInfo.fullname = '+ADeviceInfo.fullname + ' ; devPrimID='+devPrimID+ 'Сообщение ошибки' + E.Message, TMWOHistoryOut);
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
