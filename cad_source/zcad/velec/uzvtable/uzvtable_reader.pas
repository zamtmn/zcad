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

{**Модуль чтения примитивов с чертежа для восстановления таблиц}
unit uzvtable_reader;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcdrawings,
  uzeentline,
  uzeentpolyline,
  uzeenttext,
  uzeentmtext,
  uzegeometry,
  uzegeometrytypes,
  uzeentity,
  gzctnrVectorTypes,
  uzvtable_data;

// Считать все выделенные примитивы с чертежа
function ReadSelectedPrimitives(out aPrimitives: TUzvPrimitiveList): Boolean;

// Проверить, является ли объект поддерживаемым типом примитива
function IsSupportedPrimitive(const aEntity: PGDBObjEntity): Boolean;

// Определить тип примитива по объекту
function GetPrimitiveType(const aEntity: PGDBObjEntity): TPrimitiveType;

// Извлечь данные из примитива и создать структуру TUzvPrimitiveItem
function ExtractPrimitiveData(const aEntity: PGDBObjEntity): TUzvPrimitiveItem;

implementation

uses
  uzclog,
  uzcinterface;

// Считать все выделенные примитивы с чертежа
function ReadSelectedPrimitives(out aPrimitives: TUzvPrimitiveList): Boolean;
var
  selectedCount: Integer;
  pobj: PGDBObjEntity;
  ir: itrec;
  primitiveItem: TUzvPrimitiveItem;
  supportedCount: Integer;
begin
  Result := False;
  aPrimitives:=TUzvPrimitiveList.Create;
  supportedCount := 0;

  // Проверяем, есть ли выделенные объекты
  selectedCount := drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount;

  if selectedCount = 0 then
  begin
    zcUI.TextMessage('Ошибка: не выбрано ни одного объекта / Error: no objects selected', TMWOHistoryOut);
    Exit;
  end;

  //zcUI.TextMessage('Ошибка: не выбрано ни одного объекта / Error: no objects selected', TMWOHistoryOut);
  zcUI.TextMessage('Начало чтения выделенных примитивов. Выбрано объектов: ' + IntToStr(selectedCount), TMWOHistoryOut);

  // Перебираем все объекты на чертеже и проверяем флаг selected
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  begin
    repeat
      // Проверяем, выделен ли объект
      if pobj^.selected then
      begin
        // Проверяем, является ли объект поддерживаемым типом
        if IsSupportedPrimitive(pobj) then
        begin
          // Извлекаем данные из примитива
          primitiveItem := ExtractPrimitiveData(pobj);

          // Добавляем в список
          aPrimitives.PushBack(primitiveItem);
          Inc(supportedCount);
        end;
      end;

      pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pobj = nil;
  end;

  zcUI.TextMessage('Чтение завершено. Обработано поддерживаемых примитивов: ' + IntToStr(supportedCount), TMWOHistoryOut);

  // Успех, если хотя бы один поддерживаемый примитив найден
  Result := supportedCount > 0;

  if not Result then
    zcUI.TextMessage('Предупреждение: среди выделенных объектов нет поддерживаемых типов / Warning: no supported types among selected objects', TMWOHistoryOut);
end;

// Проверить, является ли объект поддерживаемым типом примитива
function IsSupportedPrimitive(const aEntity: PGDBObjEntity): Boolean;
var
  primType: TPrimitiveType;
begin
  primType := GetPrimitiveType(aEntity);
  Result := primType <> ptUnknown;
end;

// Определить тип примитива по объекту
function GetPrimitiveType(const aEntity: PGDBObjEntity): TPrimitiveType;
begin
  Result := ptUnknown;

  if aEntity = nil then
    Exit;

  // Проверяем типы примитивов
  if aEntity^.GetObjTypeName = 'GDBObjLine' then
    Result := ptLine
  else if aEntity^.GetObjTypeName = 'GDBObjPolyLine' then
    Result := ptPolyline
  else if aEntity^.GetObjTypeName = 'GDBObjText' then
    Result := ptText
  else if aEntity^.GetObjTypeName = 'GDBObjMText' then
    Result := ptMText;
end;

// Извлечь данные из примитива и создать структуру TUzvPrimitiveItem
function ExtractPrimitiveData(const aEntity: PGDBObjEntity): TUzvPrimitiveItem;
var
  pLine: PGDBObjLine;
  pPolyline: PGDBObjPolyLine;
  pText: PGDBObjText;
  pMText: PGDBObjMText;
  i: Integer;
  minX, minY, maxX, maxY: Double;
  vertex: PGDBVertex;
begin
  // Инициализация результата
  Result.primitiveType := GetPrimitiveType(aEntity);
  Result.objectPointer := aEntity;
  Result.boundingBox := aEntity^.vp.BoundingBox;
  Result.startPoint := CreateVertex(0, 0, 0);
  Result.endPoint := CreateVertex(0, 0, 0);
  Result.textContent := '';
  Result.processed := False;

  // Обрабатываем в зависимости от типа
  case Result.primitiveType of
    ptLine:
    begin
      pLine := PGDBObjLine(aEntity);
      Result.startPoint := pLine^.CoordInOCS.lBegin;
      Result.endPoint := pLine^.CoordInOCS.lEnd;
    end;

    ptPolyline:
    begin
      pPolyline := PGDBObjPolyLine(aEntity);

      // Для полилинии берем первую и последнюю точку
      if pPolyline^.VertexArrayInOCS.Count > 0 then
      begin
        //PGDBVertex(pline^.VertexArrayInOCS.getDataMutable(vertexCount-1))^
        Result.startPoint := pPolyline^.VertexArrayInOCS.getDataMutable(0)^;

        if pPolyline^.VertexArrayInOCS.Count > 1 then
          Result.endPoint := pPolyline^.VertexArrayInOCS.getDataMutable(pPolyline^.VertexArrayInOCS.Count - 1)^
        else
          Result.endPoint := Result.startPoint;
      end;

      // Вычисляем габаритный прямоугольник для полилинии
      if pPolyline^.VertexArrayInOCS.Count > 0 then
      begin
        vertex := pPolyline^.VertexArrayInOCS.getDataMutable(0);
        minX := vertex^.x;
        maxX := vertex^.x;
        minY := vertex^.y;
        maxY := vertex^.y;

        for i := 1 to pPolyline^.VertexArrayInOCS.Count - 1 do
        begin
          vertex := pPolyline^.VertexArrayInOCS.getDataMutable(i);

          if vertex^.x < minX then minX := vertex^.x;
          if vertex^.x > maxX then maxX := vertex^.x;
          if vertex^.y < minY then minY := vertex^.y;
          if vertex^.y > maxY then maxY := vertex^.y;
        end;

        Result.boundingBox.LBN := CreateVertex(minX, minY, 0);
        Result.boundingBox.RTF := CreateVertex(maxX, maxY, 0);
      end;
    end;

    ptText:
    begin
      pText := PGDBObjText(aEntity);
      Result.textContent := pText^.Content;
      Result.startPoint := pText^.Local.P_insert;
    end;

    ptMText:
    begin
      pMText := PGDBObjMText(aEntity);
      Result.textContent := pMText^.Content;
      Result.startPoint := pMText^.P_insert_in_WCS;
    end;
  end;
end;

end.
