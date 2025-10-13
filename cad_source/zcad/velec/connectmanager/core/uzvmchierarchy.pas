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
  uzcinterface, uzvmcstruct;

type
  THierarchyBuilder = class
  private
    function FindFullHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
    function FindOnlyHDHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BuildHierarchyPaths(var deviceList: TListVElectrDevStruct);
  end;

implementation

constructor THierarchyBuilder.Create;
begin
  inherited Create;
end;

destructor THierarchyBuilder.Destroy;
begin
  inherited Destroy;
end;

function THierarchyBuilder.FindFullHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
  device: TVElectrDevStruct;
begin
  Result := False;

  // Ищем устройство с заданным полным именем
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList[i];
    if device.fullname = nodeName then
    begin
      parentNode := device.headdev;

      // Если головное устройство пустое или является корневым, начинаем иерархию
      if (parentNode = '') or (parentNode = 'root') or (parentNode = '???') or (parentNode = '-') then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      // Рекурсивно ищем иерархию для родительского узла
      if FindFullHierarchy(deviceList, parentNode, hierarchy) then
      begin
        hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function THierarchyBuilder.FindOnlyHDHierarchy(const deviceList: TListVElectrDevStruct; const nodeName: string; var hierarchy: string): Boolean;
var
  i: Integer;
  parentNode: string;
  device: TVElectrDevStruct;
begin
  Result := False;

  // Ищем устройство с заданным полным именем
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList[i];
    if device.fullname = nodeName then
    begin
      parentNode := device.headdev;

      // Если головное устройство пустое или является корневым, начинаем иерархию
      if (parentNode = '') or (parentNode = 'root') or (parentNode = '???') or (parentNode = '-') then
      begin
        hierarchy := nodeName;
        Result := True;
        Exit;
      end;

      // Рекурсивно ищем иерархию для родительского узла
      if FindOnlyHDHierarchy(deviceList, parentNode, hierarchy) then
      begin
        // Добавляем текущий узел только если он может быть головным устройством
        if device.canbehead = 1 then
          hierarchy := hierarchy + '~' + nodeName;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

procedure THierarchyBuilder.BuildHierarchyPaths(var deviceList: TListVElectrDevStruct);
var
  i: Integer;
  hierarchy: string;
  device: PTVElectrDevStruct;
begin
  // Построение полного пути и пути только для головных устройств
  for i := 0 to deviceList.Size - 1 do
  begin
    device := deviceList.Mutable[i];

    // Построение полного пути иерархии
    hierarchy := '';
    if FindFullHierarchy(deviceList, device^.fullname, hierarchy) then
      device^.fullpathHD := hierarchy
    else
      device^.fullpathHD := '';

    // Построение пути только для головных устройств
    hierarchy := '';
    if FindOnlyHDHierarchy(deviceList, device^.fullname, hierarchy) then
      device^.pathHD := hierarchy
    else
      device^.pathHD := '';
  end;
end;

end.
