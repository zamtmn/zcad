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

{
  Модуль: ucvrtreader
  Назначение: Чтение примитивов с чертежа ZCAD
  Описание: Модуль отвечает за извлечение выделенных примитивов
            (линий, полилиний, текстов) с текущего чертежа и
            преобразование их в структуры данных TRtPrimitiveItem.
            Не содержит визуальных компонентов.
  Зависимости: ucvrtdata, uzcdrawings, uzeent*
}
unit ucvrtreader;

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
  ucvrtdata;

// Считать все выделенные примитивы с чертежа
// Возвращает True при успешном чтении хотя бы одного примитива
function ReadSelectedPrimitives(out aPrimitives: TRtPrimitiveList): Boolean;

// Проверить, является ли объект поддерживаемым типом примитива
function IsSupportedPrimitive(const aEntity: PGDBObjEntity): Boolean;

// Определить тип примитива по объекту
function GetPrimitiveType(const aEntity: PGDBObjEntity): TRtPrimitiveType;

// Извлечь данные из примитива и создать структуру TRtPrimitiveItem
function ExtractPrimitiveData(const aEntity: PGDBObjEntity): TRtPrimitiveItem;

// Получить количество выделенных объектов на текущем чертеже
function GetSelectedObjectsCount: Integer;

implementation

uses
  uzcinterface;

// Получить количество выделенных объектов на текущем чертеже
function GetSelectedObjectsCount: Integer;
begin
  Result := drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount;
end;

// Считать все выделенные примитивы с чертежа
function ReadSelectedPrimitives(out aPrimitives: TRtPrimitiveList): Boolean;
var
  selectedCount: Integer;
  pobj: PGDBObjEntity;
  ir: itrec;
  primitiveItem: TRtPrimitiveItem;
  supportedCount: Integer;
begin
  Result := False;
  aPrimitives := TRtPrimitiveList.Create;
  supportedCount := 0;

  // Проверяем, есть ли выделенные объекты
  selectedCount := GetSelectedObjectsCount;

  if selectedCount = 0 then
  begin
    zcUI.TextMessage(
      'Ошибка: не выбрано ни одного объекта / Error: no objects selected',
      TMWOHistoryOut
    );
    Exit;
  end;

  zcUI.TextMessage(
    'Начало чтения выделенных примитивов. Выбрано объектов: ' +
    IntToStr(selectedCount),
    TMWOHistoryOut
  );

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

  zcUI.TextMessage(
    'Чтение завершено. Обработано поддерживаемых примитивов: ' +
    IntToStr(supportedCount),
    TMWOHistoryOut
  );

  // Успех, если хотя бы один поддерживаемый примитив найден
  Result := supportedCount > 0;

  if not Result then
    zcUI.TextMessage(
      'Предупреждение: среди выделенных объектов нет поддерживаемых типов',
      TMWOHistoryOut
    );
end;

// Проверить, является ли объект поддерживаемым типом примитива
function IsSupportedPrimitive(const aEntity: PGDBObjEntity): Boolean;
var
  primType: TRtPrimitiveType;
begin
  primType := GetPrimitiveType(aEntity);
  Result := primType <> rtptUnknown;
end;

// Определить тип примитива по объекту
function GetPrimitiveType(const aEntity: PGDBObjEntity): TRtPrimitiveType;
begin
  Result := rtptUnknown;

  if aEntity = nil then
    Exit;

  // Проверяем типы примитивов по имени объекта
  if aEntity^.GetObjTypeName = 'GDBObjLine' then
    Result := rtptLine
  else if aEntity^.GetObjTypeName = 'GDBObjPolyLine' then
    Result := rtptPolyline
  else if aEntity^.GetObjTypeName = 'GDBObjText' then
    Result := rtptText
  else if aEntity^.GetObjTypeName = 'GDBObjMText' then
    Result := rtptMText;
end;

// Извлечь данные из примитива и создать структуру TRtPrimitiveItem
function ExtractPrimitiveData(const aEntity: PGDBObjEntity): TRtPrimitiveItem;
var
  pLine: PGDBObjLine;
  pPolyline: PGDBObjPolyLine;
  pText: PGDBObjText;
  pMText: PGDBObjMText;
  i: Integer;
  minX, minY, maxX, maxY: Double;
  vertex: PzePoint3d;
begin
  // Инициализация результата
  Result.primitiveType := GetPrimitiveType(aEntity);
  Result.objectPointer := aEntity;
  Result.boundingBox := aEntity^.vp.BoundingBox;
  Result.startPoint := CreateVertex(0, 0, 0);
  Result.endPoint := CreateVertex(0, 0, 0);
  Result.textContent := '';
  Result.processed := False;

  // Обрабатываем в зависимости от типа примитива
  case Result.primitiveType of
    rtptLine:
    begin
      pLine := PGDBObjLine(aEntity);
      Result.startPoint := pLine^.CoordInOCS.lBegin;
      Result.endPoint := pLine^.CoordInOCS.lEnd;
    end;

    rtptPolyline:
    begin
      pPolyline := PGDBObjPolyLine(aEntity);

      // Для полилинии берем первую и последнюю точку
      if pPolyline^.VertexArrayInOCS.Count > 0 then
      begin
        Result.startPoint := pPolyline^.VertexArrayInOCS.getDataMutable(0)^;

        if pPolyline^.VertexArrayInOCS.Count > 1 then
          Result.endPoint := pPolyline^.VertexArrayInOCS.getDataMutable(
            pPolyline^.VertexArrayInOCS.Count - 1)^
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

    rtptText:
    begin
      pText := PGDBObjText(aEntity);
      Result.textContent := pText^.Content;
      Result.startPoint := pText^.Local.P_insert;
    end;

    rtptMText:
    begin
      pMText := PGDBObjMText(aEntity);
      Result.textContent := pMText^.Content;
      Result.startPoint := pMText^.P_insert_in_WCS;
    end;
  end;
end;

end.
