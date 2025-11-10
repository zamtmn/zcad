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

{**Модуль общих функций для импорта светильников Dialux}
unit uzvdialuxlumimporter_utils;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Math,
  uzcinterface,
  uzclog,
  uzegeometrytypes,
  uzegeometry,
  uzeentity,
  uzeentpolyline,
  uzeentline,
  uzeentblockinsert,
  uzeentdevice,
  uzeconsts,
  uzestyleslayers,
  uzcdrawings,
  uzcenitiesvariablesextender,
  uzgldrawcontext,
  UUnitManager,
  uzbPaths,
  uzcTranslations,
  uzvconsts;

{**Вывести сообщение в командную строку CAD}
procedure PrintMessage(const Msg: string);

{**Вывести форматированное сообщение в командную строку CAD}
procedure PrintFormatMessage(
  const Format: string;
  const Args: array of const
);

{**Вычислить геометрический центр полилинии}
function CalculatePolylineCenter(
  PolyPtr: PGDBObjPolyLine
): GDBvertex;

{**Вычислить центр линии}
function CalculateLineCenter(
  LinePtr: PGDBObjLine
): GDBvertex;

{**Получить точку вставки блока}
function GetBlockInsertPoint(
  BlockPtr: PGDBObjBlockInsert
): GDBvertex;

{**Вычислить геометрический центр примитива}
function CalculateEntityCenter(
  Entity: PGDBObjEntity
): GDBvertex;

{**Вычислить расстояние между двумя точками}
function CalculateDistance(
  const Point1, Point2: GDBvertex
): Double;

{**Проверить, принадлежит ли объект указанному слою}
function IsEntityOnLayer(
  Entity: PGDBObjEntity;
  const LayerName: string
): Boolean;

{**Вставить устройство или блок на чертеж}
function drawInsertBlock(
  pt: GDBVertex;
  scalex, scaley, iRotate: double;
  InsertionName: string
): PGDBObjBlockInsert;

implementation

{**Вывести сообщение в командную строку CAD}
procedure PrintMessage(const Msg: string);
begin
  zcUI.TextMessage(Msg, TMWOHistoryOut);
end;

{**Вывести форматированное сообщение в командную строку CAD}
procedure PrintFormatMessage(
  const Format: string;
  const Args: array of const
);
begin
  PrintMessage(SysUtils.Format(Format, Args));
end;

{**Вычислить геометрический центр полилинии}
function CalculatePolylineCenter(
  PolyPtr: PGDBObjPolyLine
): GDBvertex;
var
  i: Integer;
  SumX, SumY, SumZ: Double;
  Count: Integer;
  Vertex: PGDBvertex;
begin
  SumX := 0.0;
  SumY := 0.0;
  SumZ := 0.0;
  Count := PolyPtr^.VertexArrayInOCS.Count;

  if Count = 0 then
  begin
    Result := NulVertex;
    Exit;
  end;

  // Суммируем координаты всех вершин
  Vertex := PGDBvertex(PolyPtr^.VertexArrayInOCS.GetParrayAsPointer);
  for i := 0 to Count - 1 do
  begin
    SumX := SumX + Vertex^.x;
    SumY := SumY + Vertex^.y;
    SumZ := SumZ + Vertex^.z;
    Inc(Vertex);
  end;

  // Вычисляем среднее значение
  Result.x := SumX / Count;
  Result.y := SumY / Count;
  Result.z := SumZ / Count;
end;

{**Вычислить центр линии}
function CalculateLineCenter(
  LinePtr: PGDBObjLine
): GDBvertex;
begin
  // Центр линии - это середина между двумя точками
  Result.x := (LinePtr^.CoordInOCS.lBegin.x + LinePtr^.CoordInOCS.lEnd.x) / 2.0;
  Result.y := (LinePtr^.CoordInOCS.lBegin.y + LinePtr^.CoordInOCS.lEnd.y) / 2.0;
  Result.z := (LinePtr^.CoordInOCS.lBegin.z + LinePtr^.CoordInOCS.lEnd.z) / 2.0;
end;

{**Получить точку вставки блока}
function GetBlockInsertPoint(
  BlockPtr: PGDBObjBlockInsert
): GDBvertex;
begin
  // Точка вставки блока - это его координата P_insert
  Result := BlockPtr^.Local.P_insert;
end;

{**Вычислить геометрический центр примитива}
function CalculateEntityCenter(
  Entity: PGDBObjEntity
): GDBvertex;
var
  ObjType: Integer;
begin
  Result := NulVertex;

  if Entity = nil then
    Exit;

  ObjType := Entity^.GetObjType;

  if ObjType = GDBPolyLineID then
    Result := CalculatePolylineCenter(PGDBObjPolyLine(Entity))
  else if ObjType = GDBLineID then
    Result := CalculateLineCenter(PGDBObjLine(Entity))
  else if ObjType = GDBBlockInsertID then
    Result := GetBlockInsertPoint(PGDBObjBlockInsert(Entity))
  else
  begin
    // Для других типов используем центр ограничивающего прямоугольника
    Result.x := (Entity^.vp.BoundingBox.LBN.x + Entity^.vp.BoundingBox.RTF.x) / 2.0;
    Result.y := (Entity^.vp.BoundingBox.LBN.y + Entity^.vp.BoundingBox.RTF.y) / 2.0;
    Result.z := (Entity^.vp.BoundingBox.LBN.z + Entity^.vp.BoundingBox.RTF.z) / 2.0;
  end;
end;

{**Вычислить расстояние между двумя точками}
function CalculateDistance(
  const Point1, Point2: GDBvertex
): Double;
var
  dx, dy, dz: Double;
begin
  dx := Point2.x - Point1.x;
  dy := Point2.y - Point1.y;
  dz := Point2.z - Point1.z;

  Result := Sqrt(dx * dx + dy * dy + dz * dz);
end;

{**Проверить, принадлежит ли объект указанному слою}
function IsEntityOnLayer(
  Entity: PGDBObjEntity;
  const LayerName: string
): Boolean;
var
  EntityLayerName: string;
begin
  Result := False;

  if Entity = nil then
    Exit;

  // Получаем полное имя слоя объекта
  EntityLayerName := Entity^.vp.Layer^.GetFullName;

  // Сравниваем с искомым именем (без учета регистра)
  Result := AnsiCompareText(EntityLayerName, LayerName) = 0;
end;

{**Вставить устройство или блок на чертеж}
function drawInsertBlock(
  pt: GDBVertex;
  scalex, scaley, iRotate: double;
  InsertionName: string
): PGDBObjBlockInsert;
var
  rc: TDrawContext;
  entvarext: TVariablesExtender;
  psu: ptunit;
  itDevice: boolean;
  blockName: string;
begin
  // Проверяем на входе устройство или блок
  itDevice := AnsiPos(velec_beforeNameGlobalSchemaBlock, InsertionName) = 1;

  // Добавляем в чертеж то что на входе
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG, InsertionName);

  if itDevice then
  begin
    // Если устройство добавляем т блок
    blockName := Copy(
      InsertionName,
      length(velec_beforeNameGlobalSchemaBlock) + 1,
      length(InsertionName) - length(velec_beforeNameGlobalSchemaBlock)
    );
    drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG, blockName);

    // Создаем примитив
    result := GDBObjDevice.CreateInstance;
  end
  else
  begin
    blockName := InsertionName;
    result := GDBObjBlockInsert.CreateInstance;
  end;

  // Настраивает
  result^.Name := blockName;
  result^.Local.P_insert := pt;
  result^.scale := uzegeometry.CreateVertex(scalex, scaley, 1);
  result^.rotate := iRotate;

  // Строим переменную часть примитива (та что может редактироваться)
  result^.BuildVarGeometry(drawings.GetCurrentDWG^);

  // Строим постоянную часть примитива
  result^.BuildGeometry(drawings.GetCurrentDWG^);

  // "Форматируем"
  rc := drawings.GetCurrentDWG^.CreateDrawingRC;
  result^.FormatEntity(drawings.GetCurrentDWG^, rc);

  // Добавляем свойства
  if itDevice then
  begin
    entvarext := result^.GetExtension<TVariablesExtender>;
    if entvarext <> nil then
    begin
      psu := units.findunit(GetSupportPaths, @InterfaceTranslate, InsertionName);
      if psu <> nil then
        entvarext.entityunit.copyfrom(psu);
    end;
  end;

  // Дальше как обычно
  zcAddEntToCurrentDrawingConstructRoot(result);
end;

end.
