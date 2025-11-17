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

{**Модуль вспомогательных функций для экспорта освещения}
unit uzvlightexporter_utils;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzeentpolyline,
  uzegeometrytypes,
  uzcenitiesvariablesextender,
  varmandef,
  uzvlightexporter_types;

{**Проверка находится ли точка внутри полилинии (ray casting алгоритм)}
function PointInPolyline(
  const Point: GDBVertex;
  PolylinePtr: PGDBObjPolyLine
): Boolean;

{**Проверка полностью ли одна полилиния находится внутри другой}
function PolylineInsidePolyline(
  InnerPtr: PGDBObjPolyLine;
  OuterPtr: PGDBObjPolyLine
): Boolean;

{**Получить строковое значение переменной из расширения}
function GetStringVariable(
  VarExt: TVariablesExtender;
  const VarName: string
): string;

{**Получить числовое значение переменной типа Integer из расширения}
function GetIntegerVariable(
  VarExt: TVariablesExtender;
  const VarName: string;
  DefaultValue: Integer
): Integer;

{**Получить числовое значение переменной типа Double из расширения}
function GetDoubleVariable(
  VarExt: TVariablesExtender;
  const VarName: string;
  DefaultValue: Double
): Double;

{**Проверить является ли полилиния замкнутой}
function IsPolylineClosed(PolylinePtr: PGDBObjPolyLine): Boolean;

{**Преобразовать координату относительно начала координат}
function TransformCoordinate(Value: Double; Origin: Double): Double;

implementation

{**Проверка находится ли точка внутри полилинии методом ray casting}
function PointInPolyline(
  const Point: GDBVertex;
  PolylinePtr: PGDBObjPolyLine
): Boolean;
var
  i, j: Integer;
  VertexCount: Integer;
  VertexI, VertexJ: GDBVertex;
  IntersectCount: Integer;
begin
  Result := False;

  if PolylinePtr = nil then
    Exit;

  VertexCount := PolylinePtr^.VertexArrayInOCS.Count;

  if VertexCount < 3 then
    Exit;

  IntersectCount := 0;
  j := VertexCount - 1;

  for i := 0 to VertexCount - 1 do
  begin
    VertexI := PolylinePtr^.VertexArrayInOCS.getData(i);
    VertexJ := PolylinePtr^.VertexArrayInOCS.getData(j);

    if ((VertexI.y > Point.y) <> (VertexJ.y > Point.y)) and
       (Point.x < (VertexJ.x - VertexI.x) * (Point.y - VertexI.y) /
       (VertexJ.y - VertexI.y) + VertexI.x) then
      Inc(IntersectCount);

    j := i;
  end;

  Result := (IntersectCount mod 2) = 1;
end;

{**Проверка полностью ли внутренняя полилиния находится внутри внешней}
function PolylineInsidePolyline(
  InnerPtr: PGDBObjPolyLine;
  OuterPtr: PGDBObjPolyLine
): Boolean;
var
  i: Integer;
  VertexCount: Integer;
  Vertex: GDBVertex;
  AllInside: Boolean;
begin
  Result := False;

  if (InnerPtr = nil) or (OuterPtr = nil) then
    Exit;

  if InnerPtr = OuterPtr then
    Exit;

  VertexCount := InnerPtr^.VertexArrayInOCS.Count;

  if VertexCount < 3 then
    Exit;

  AllInside := True;

  for i := 0 to VertexCount - 1 do
  begin
    Vertex := InnerPtr^.VertexArrayInOCS.getData(i);
    if not PointInPolyline(Vertex, OuterPtr) then
    begin
      AllInside := False;
      Break;
    end;
  end;

  Result := AllInside;
end;

{**Получить строковое значение переменной из расширения полилинии}
function GetStringVariable(
  VarExt: TVariablesExtender;
  const VarName: string
): string;
var
  VarDesc: pvardesk;
begin
  Result := '';

  if VarExt = nil then
    Exit;

  VarDesc := VarExt.entityunit.FindVariable(VarName);
  if VarDesc <> nil then
  begin
    try
      Result := pstring(VarDesc^.data.Addr.Instance)^;
    except
      // В случае ошибки чтения возвращаем пустую строку
      Result := '';
    end;
  end;
end;

{**Получить числовое значение переменной типа Integer из расширения}
function GetIntegerVariable(
  VarExt: TVariablesExtender;
  const VarName: string;
  DefaultValue: Integer
): Integer;
var
  VarDesc: pvardesk;
begin
  Result := DefaultValue;

  if VarExt = nil then
    Exit;

  VarDesc := VarExt.entityunit.FindVariable(VarName);
  if VarDesc = nil then
    Exit;

  try
    Result := PInteger(VarDesc^.data.Addr.Instance)^;
  except
    // В случае ошибки возвращаем значение по умолчанию
    Result := DefaultValue;
  end;
end;

{**Получить числовое значение переменной типа Double из расширения}
function GetDoubleVariable(
  VarExt: TVariablesExtender;
  const VarName: string;
  DefaultValue: Double
): Double;
var
  VarDesc: pvardesk;
begin
  Result := DefaultValue;

  if VarExt = nil then
    Exit;

  VarDesc := VarExt.entityunit.FindVariable(VarName);
  if VarDesc = nil then
    Exit;

  try
    Result := PDouble(VarDesc^.data.Addr.Instance)^;
  except
    // В случае ошибки возвращаем значение по умолчанию
    Result := DefaultValue;
  end;
end;

{**Проверить является ли полилиния замкнутой}
function IsPolylineClosed(PolylinePtr: PGDBObjPolyLine): Boolean;
begin
  Result := (PolylinePtr <> nil) and (PolylinePtr^.Closed);
end;

{**Преобразовать координату относительно начала координат}
function TransformCoordinate(Value: Double; Origin: Double): Double;
begin
  Result := Value - Origin;
end;

end.
