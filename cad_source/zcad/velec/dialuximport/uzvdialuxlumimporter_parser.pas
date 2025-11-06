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

{**Модуль парсинга и фильтрации выделенных элементов}
unit uzvdialuxlumimporter_parser;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcdrawings,
  uzeentity,
  uzeconsts,
  uzclog,
  gzctnrVectorTypes,
  uzvdialuxlumimporter_structs,
  uzvdialuxlumimporter_utils;

{**Проверить наличие выделенных объектов}
function HasSelectedObjects: Boolean;

{**Получить выделенные элементы и отфильтровать по слоям}
procedure ParseSelectedElements(
  out ParsedData: TParsedData
);

{**Освободить память занятую распарсенными данными}
procedure FreeParsedData(var ParsedData: TParsedData);

implementation

{**Проверить наличие выделенных объектов}
function HasSelectedObjects: Boolean;
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
begin
  Result := False;

  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
    Exit;

  repeat
    if EntityPtr^.selected then
    begin
      Result := True;
      Exit;
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;
end;

{**Проверить, является ли объект текстом}
function IsTextEntity(Entity: PGDBObjEntity): Boolean;
var
  ObjType: Integer;
begin
  ObjType := Entity^.GetObjType;
  Result := (ObjType = GDBTextID) or (ObjType = GDBMTextID);
end;

{**Проверить, является ли объект геометрией светильника}
function IsLuminaireGeometry(Entity: PGDBObjEntity): Boolean;
var
  ObjType: Integer;
begin
  ObjType := Entity^.GetObjType;
  // Геометрия может быть полилинией, линией или блоком
  Result := (ObjType = GDBPolyLineID) or
            (ObjType = GDBLineID) or
            (ObjType = GDBBlockInsertID);
end;

{**Получить выделенные элементы и отфильтровать по слоям}
procedure ParseSelectedElements(
  out ParsedData: TParsedData
);
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
begin
  // Инициализация структуры данных
  ParsedData.LuminairesGeometry := TLuminairesGeometryList.Create;
  ParsedData.LuminairesKeys := TLuminairesKeysList.Create;
  ParsedData.GeometryCount := 0;
  ParsedData.KeysCount := 0;

  programlog.LogOutFormatStr(
    'Начат парсинг выделенных элементов',
    [],
    LM_Info
  );

  // Перебираем все объекты на чертеже
  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
  begin
    programlog.LogOutFormatStr(
      'Нет объектов на чертеже',
      [],
      LM_Warning
    );
    Exit;
  end;

  repeat
    // Обрабатываем только выделенные объекты
    if EntityPtr^.selected then
    begin
      // Фильтрация по слою DLX_LUM (геометрия светильников)
      if IsEntityOnLayer(EntityPtr, LAYER_DLX_LUM) then
      begin
        if IsLuminaireGeometry(EntityPtr) then
        begin
          ParsedData.LuminairesGeometry.Add(EntityPtr);
          Inc(ParsedData.GeometryCount);

          programlog.LogOutFormatStr(
            'Найдена геометрия светильника: тип=%s',
            [EntityPtr^.GetObjName],
            LM_Debug
          );
        end;
      end
      // Фильтрация по слою DLX_LUMKEY_IDX (текстовые обозначения)
      else if IsEntityOnLayer(EntityPtr, LAYER_DLX_LUMKEY_IDX) then
      begin
        if IsTextEntity(EntityPtr) then
        begin
          ParsedData.LuminairesKeys.Add(EntityPtr);
          Inc(ParsedData.KeysCount);

          programlog.LogOutFormatStr(
            'Найден текст светильника: тип=%s',
            [EntityPtr^.GetObjName],
            LM_Debug
          );
        end;
      end;
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;

  programlog.LogOutFormatStr(
    'Парсинг завершен: геометрия=%d, тексты=%d',
    [ParsedData.GeometryCount, ParsedData.KeysCount],
    LM_Info
  );
end;

{**Освободить память занятую распарсенными данными}
procedure FreeParsedData(var ParsedData: TParsedData);
begin
  if ParsedData.LuminairesGeometry <> nil then
  begin
    ParsedData.LuminairesGeometry.Free;
    ParsedData.LuminairesGeometry := nil;
  end;

  if ParsedData.LuminairesKeys <> nil then
  begin
    ParsedData.LuminairesKeys.Free;
    ParsedData.LuminairesKeys := nil;
  end;

  ParsedData.GeometryCount := 0;
  ParsedData.KeysCount := 0;
end;

end.
