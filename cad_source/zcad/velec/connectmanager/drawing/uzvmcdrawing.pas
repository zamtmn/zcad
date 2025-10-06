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

unit uzvmcdrawing;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils, Classes, gvector,
  uzeentdevice, uzeentblockinsert, uzeentity, uzeconsts,
  uzcdrawing, uzcdrawings, uzcvariablesutils,
  varmandef, gzctnrVectorTypes;

type
  TDeviceData = record
    DevName: string;
    HDName: string;
    HDGroup: string;
    CanBeHead: integer;
    Connections: array of record
      HeadDeviceName: string;
      NGHeadDevice: string;
    end;
  end;

  TDeviceDataCollector = class
  private
    function GetDeviceVariableString(ADevice: PGDBObjDevice; const AVarName: string): string;
    function GetDeviceVariableBoolean(ADevice: PGDBObjDevice; const AVarName: string): Boolean;
  public
    function CollectAllDevices: specialize TVector<TDeviceData>;
    function GetDeviceByName(const ADevName: string): PGDBObjDevice;
  end;

implementation

function TDeviceDataCollector.GetDeviceVariableString(ADevice: PGDBObjDevice; const AVarName: string): string;
var
  pvd: pvardesk;
begin
  Result := '';
  pvd := FindVariableInEnt(ADevice, AVarName);
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

function TDeviceDataCollector.GetDeviceVariableBoolean(ADevice: PGDBObjDevice; const AVarName: string): Boolean;
var
  pvd: pvardesk;
begin
  Result := False;
  pvd := FindVariableInEnt(ADevice, AVarName);
  if pvd <> nil then
    Result := pboolean(pvd^.data.Addr.Instance)^;
end;

function TDeviceDataCollector.CollectAllDevices: specialize TVector<TDeviceData>;
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  deviceData: TDeviceData;
  count, i: integer;
  headDevName: string;
begin
  Result := specialize TVector<TDeviceData>.Create;

  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    if pobj^.GetObjType = GDBDeviceID then
    begin
      pdev := PGDBObjDevice(pobj);

      deviceData.DevName := GetDeviceVariableString(pdev, 'NMO_Name');
      if deviceData.DevName = '' then
        deviceData.DevName := 'ERROR';

      if GetDeviceVariableBoolean(pdev, 'ANALYSISEM_icanbeheadunit') then
        deviceData.CanBeHead := 1
      else
        deviceData.CanBeHead := 0;

      SetLength(deviceData.Connections, 0);
      count := 1;
      headDevName := GetDeviceVariableString(pdev, 'SLCABAGEN' + inttostr(count) + '_HeadDeviceName');

      while headDevName <> '' do
      begin
        SetLength(deviceData.Connections, Length(deviceData.Connections) + 1);
        i := Length(deviceData.Connections) - 1;

        deviceData.Connections[i].HeadDeviceName := headDevName;
        deviceData.Connections[i].NGHeadDevice := GetDeviceVariableString(pdev, 'SLCABAGEN' + inttostr(count) + '_NGHeadDevice');

        if i = 0 then
        begin
          deviceData.HDName := headDevName;
          deviceData.HDGroup := deviceData.Connections[i].NGHeadDevice;
        end;

        Inc(count);
        headDevName := GetDeviceVariableString(pdev, 'SLCABAGEN' + inttostr(count) + '_HeadDeviceName');
      end;

      if (deviceData.HDName <> '') and
         (deviceData.HDName <> '???') and
         (deviceData.HDName <> '-') and
         (deviceData.HDName <> 'ERROR') then
        Result.PushBack(deviceData);
    end;

    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

function TDeviceDataCollector.GetDeviceByName(const ADevName: string): PGDBObjDevice;
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  devName: string;
begin
  Result := nil;

  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    if pobj^.GetObjType = GDBDeviceID then
    begin
      pdev := PGDBObjDevice(pobj);
      devName := GetDeviceVariableString(pdev, 'NMO_Name');

      if devName = ADevName then
      begin
        Result := pdev;
        Exit;
      end;
    end;

    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

end.
