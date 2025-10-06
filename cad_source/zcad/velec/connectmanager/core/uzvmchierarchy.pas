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

unit uzvmchierarchy;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils, Classes, gvector,
  uzeentdevice, gzctnrVectorTypes,
  uzcinterface;

type
  TDeviceLevel = record
    pobj: PGDBObjDevice;
    parentName: string;
    headdev: string;
    wayHD: string;
    fullWayHD: string;
    icanhd: integer;
  end;

  TListDevLevel = specialize TVector<TDeviceLevel>;

  THierarchyBuilder = class
  private
    FDeviceList: TListDevLevel;
    function FindFullHierarchy(const nodeName: string; var hierarchy: string): Boolean;
    function FindOnlyHDHierarchy(const nodeName: string; var hierarchy: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddDevice(const ADeviceName, AParentName: string; ACanBeHead: integer);
    procedure BuildFullHierarchy;
    procedure BuildOnlyHDHierarchy;

    function GetDeviceWay(const ADeviceName: string): string;
    function GetDeviceFullWay(const ADeviceName: string): string;

    property DeviceList: TListDevLevel read FDeviceList;
  end;

implementation

constructor THierarchyBuilder.Create;
begin
  inherited Create;
  FDeviceList := TListDevLevel.Create;
end;

destructor THierarchyBuilder.Destroy;
begin
  FDeviceList.Free;
  inherited Destroy;
end;

procedure THierarchyBuilder.AddDevice(const ADeviceName, AParentName: string; ACanBeHead: integer);
var
  devLevel: TDeviceLevel;
  i: integer;
  exists: boolean;
begin
  exists := False;

  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FDeviceList[i].headdev = ADeviceName then
    begin
      exists := True;
      FDeviceList.Mutable[i]^.parentName := AParentName;
      FDeviceList.Mutable[i]^.icanhd := ACanBeHead;
      Break;
    end;
  end;

  if not exists then
  begin
    devLevel.headdev := ADeviceName;
    devLevel.parentName := AParentName;
    devLevel.icanhd := ACanBeHead;
    devLevel.wayHD := '';
    devLevel.fullWayHD := '';
    devLevel.pobj := nil;

    FDeviceList.PushBack(devLevel);
  end;
end;

function THierarchyBuilder.FindFullHierarchy(const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
begin
  Result := False;

  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FDeviceList[i].headdev = nodeName then
    begin
      parentNode := FDeviceList[i].parentName;

      if parentNode = 'root' then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      if FindFullHierarchy(parentNode, hierarchy) then
      begin
        hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function THierarchyBuilder.FindOnlyHDHierarchy(const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
begin
  Result := False;

  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FDeviceList[i].headdev = nodeName then
    begin
      parentNode := FDeviceList[i].parentName;

      if parentNode = 'root' then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      if FindOnlyHDHierarchy(parentNode, hierarchy) then
      begin
        if FDeviceList[i].icanhd = 1 then
          hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure THierarchyBuilder.BuildFullHierarchy;
var
  i: Integer;
  hierarchy: string;
begin
  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FindFullHierarchy(FDeviceList[i].headdev, hierarchy) then
      FDeviceList.Mutable[i]^.fullWayHD := hierarchy
    else
      zcUI.TextMessage(FDeviceList[i].headdev + '~' + FDeviceList[i].parentName + ' -> Иерархия не найдена', TMWOHistoryOut);
  end;
end;

procedure THierarchyBuilder.BuildOnlyHDHierarchy;
var
  i: Integer;
  hierarchy: string;
begin
  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FindOnlyHDHierarchy(FDeviceList[i].headdev, hierarchy) then
      FDeviceList.Mutable[i]^.wayHD := hierarchy
    else
      zcUI.TextMessage(FDeviceList[i].headdev + '~' + FDeviceList[i].parentName + ' -> Иерархия не найдена', TMWOHistoryOut);
  end;
end;

function THierarchyBuilder.GetDeviceWay(const ADeviceName: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FDeviceList[i].headdev = ADeviceName then
    begin
      Result := FDeviceList[i].wayHD;
      Exit;
    end;
  end;
end;

function THierarchyBuilder.GetDeviceFullWay(const ADeviceName: string): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to FDeviceList.Size - 1 do
  begin
    if FDeviceList[i].headdev = ADeviceName then
    begin
      Result := FDeviceList[i].fullWayHD;
      Exit;
    end;
  end;
end;

end.
