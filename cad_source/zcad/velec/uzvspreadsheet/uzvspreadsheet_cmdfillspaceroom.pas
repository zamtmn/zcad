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

{** Модуль для заполнения параметров пространств из данных таблицы
    Содержит процедуры для обработки и обновления расширенных атрибутов }
unit uzvspreadsheet_cmdfillspaceroom;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  uzclog,
  Dialogs,
  uzcinterface,
  uzcdrawings,
  uzeentity,
  uzeentpolyline,
  gzctnrVectorTypes,
  uzeconsts,
  uzcenitiesvariablesextender,
  uzsbVarmanDef;

type
  { Структура данных одного помещения из таблицы }
  TRoomInfo = record
    RoomPos: String;
    RoomName: String;
    RoomArea: String;
    RoomCategory: String;
  end;

  { Список помещений }
  TRoomInfoList = specialize TList<TRoomInfo>;

{ Основная процедура заполнения пространств из таблицы }
procedure FillSpacesFromTable(RoomList: TRoomInfoList);

implementation

{ Проверяет наличие переменных пространства у примитива }
function HasSpaceVariables(pEntity: PGDBObjEntity): Boolean;
var
  VarExt: TVariablesExtender;
  pvd: pvardesk;
begin
  Result := False;

  VarExt := pEntity^.specialize GetExtension<TVariablesExtender>;
  if VarExt = nil then
    Exit;

  pvd := VarExt.entityunit.FindVariable('Space_RoomPos');
  if pvd <> nil then
    Result := True;
end;

{ Получает значение переменной пространства }
function GetSpaceVariable(pEntity: PGDBObjEntity;
  const VarName: String): String;
var
  VarExt: TVariablesExtender;
  pvd: pvardesk;
begin
  Result := '';

  VarExt := pEntity^.specialize GetExtension<TVariablesExtender>;
  if VarExt = nil then
    Exit;

  pvd := VarExt.entityunit.FindVariable(VarName);
  if pvd <> nil then
    Result := pvd^.data.PTD^.GetValueAsString(pvd^.data.Addr.Instance);
end;

{ Устанавливает значение переменной пространства }
procedure SetSpaceVariable(pEntity: PGDBObjEntity;
  const VarName, Value: String);
var
  VarExt: TVariablesExtender;
  pvd: pvardesk;
begin
  VarExt := pEntity^.specialize GetExtension<TVariablesExtender>;
  if VarExt = nil then
    Exit;

  pvd := VarExt.entityunit.FindVariable(VarName);
  if pvd <> nil then
     pstring(pvd^.data.Addr.Instance)^ := Value;
    //pvd^.data.PTD^.SetValueFromString(Value, pvd^.data.Addr.Instance);
end;

//VarDesc := VarExt.entityunit.FindVariable(VarName);
//if VarDesc <> nil then
//begin
//  try
//    pstring(VarDesc^.data.Addr.Instance)^ := Value;


{ Основная процедура заполнения пространств из таблицы }
procedure FillSpacesFromTable(RoomList: TRoomInfoList);
var
  pEntity: PGDBObjEntity;
  ir: itrec;
  Room: TRoomInfo;
  SpacePos: String;
  MatchedCount: Integer;
  ProcessedCount: Integer;
  i: Integer;
begin
  programlog.LogOutFormatStr('Начало заполнения пространств помещений',
    [], LM_Info);

  // Проверка на пустой список
  if (RoomList = nil) or (RoomList.Count = 0) then
  begin
    ShowMessage('Нет данных для заполнения пространств');
    programlog.LogOutFormatStr('Список помещений пуст', [], LM_Info);
    Exit;
  end;

  programlog.LogOutFormatStr('Получено %d записей для обработки',
    [RoomList.Count], LM_Info);

  MatchedCount := 0;
  ProcessedCount := 0;

  // Перебираем все примитивы в чертеже
  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity <> nil then
    repeat
      Inc(ProcessedCount);

      // Проверяем является ли примитив полилинией с переменными пространства
      if pEntity^.GetObjType = GDBPolyLineID then
      begin
        if HasSpaceVariables(pEntity) then
        begin
          SpacePos := GetSpaceVariable(pEntity, 'Space_RoomPos');

          // Ищем совпадение с данными из таблицы
          for i := 0 to RoomList.Count - 1 do
          begin
            Room := RoomList[i];

            if SpacePos = Room.RoomPos then
            begin
              programlog.LogOutFormatStr(
                'Найдено совпадение: RoomPos "%s"',
                [Room.RoomPos], LM_Info);

              // Обновляем переменные пространства
              SetSpaceVariable(pEntity, 'Space_RoomName', Room.RoomName);
              SetSpaceVariable(pEntity, 'Space_RoomArea', Room.RoomArea);
              SetSpaceVariable(pEntity, 'Space_RoomCategory',
                Room.RoomCategory);

              Inc(MatchedCount);
              Break;
            end;
          end;
        end;
      end;

      pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pEntity = nil;

  programlog.LogOutFormatStr('Обработано примитивов: %d',
    [ProcessedCount], LM_Info);
  programlog.LogOutFormatStr('Обновлено пространств: %d',
    [MatchedCount], LM_Info);

  if MatchedCount = 0 then
    ShowMessage('Не найдено совпадений с позициями помещений')
  else
  begin
    ShowMessage(Format('Обновлено %d помещений', [MatchedCount]));

    // Перерисовываем чертеж для отображения изменений
    zcUI.Do_GUIaction(nil, zcMsgUIActionRedraw);
  end;
end;

end.
