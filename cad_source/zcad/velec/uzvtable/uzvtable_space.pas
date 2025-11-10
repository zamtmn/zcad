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

{**Модуль обработки пространств для заполнения данных из таблицы}
unit uzvtable_space;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  uzclog,
  uzcinterface,
  uzcdrawings,
  uzeentity,
  uzeentpolyline,
  uzcenitiesvariablesextender,
  gzctnrVectorTypes,
  uzeconsts,
  varmandef;

const
  // Имена переменных пространств
  VAR_SPACE_ROOM_POS = 'Space_RoomPos';
  VAR_SPACE_ROOM_NAME = 'Space_RoomName';
  VAR_SPACE_ROOM_AREA = 'Space_RoomArea';
  VAR_SPACE_ROOM_CATEGORY = 'Space_RoomCategory';

type
  // Структура данных помещения из таблицы
  TRoomInfo = record
    RoomPos: String;
    RoomName: String;
    RoomArea: String;
    RoomCategory: String;
  end;

  // Список помещений
  TRoomInfoList = specialize TList<TRoomInfo>;

// Заполнить пространства данными из списка
procedure FillSpacesFromTable(RoomList: TRoomInfoList);

implementation

// Получить строковое значение переменной из расширения
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
      Result := '';
    end;
  end;
end;

// Установить строковое значение переменной в расширение
procedure SetStringVariable(
  VarExt: TVariablesExtender;
  const VarName: string;
  const Value: string
);
var
  VarDesc: pvardesk;
begin
  if VarExt = nil then
    Exit;

  VarDesc := VarExt.entityunit.FindVariable(VarName);
  if VarDesc <> nil then
  begin
    try
      pstring(VarDesc^.data.Addr.Instance)^ := Value;
    except
      // Логируем ошибку записи
      programlog.LogOutFormatStr(
        'Ошибка записи переменной %s',
        [VarName],
        LM_Info
      );
    end;
  end;
end;

// Найти помещение в списке по позиции
function FindRoomByPos(
  RoomList: TRoomInfoList;
  const RoomPos: string
): Integer;
var
  i: Integer;
begin
  Result := -1;

  if RoomList = nil then
    Exit;

  for i := 0 to RoomList.Count - 1 do
  begin
    if RoomList[i].RoomPos = RoomPos then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

// Заполнить пространства данными из списка
procedure FillSpacesFromTable(RoomList: TRoomInfoList);
var
  EntityPtr: PGDBObjEntity;
  PolylinePtr: PGDBObjPolyLine;
  IterRec: itrec;
  VarExt: TVariablesExtender;
  CurrentRoomPos: string;
  RoomIndex: Integer;
  RoomInfo: TRoomInfo;
  ProcessedCount: Integer;
  MatchedCount: Integer;
begin
  // Проверка входных данных
  if RoomList = nil then
  begin
    zcUI.TextMessage(
      'Ошибка: список помещений не инициализирован',
      TMWOHistoryOut
    );
    Exit;
  end;

  if RoomList.Count = 0 then
  begin
    zcUI.TextMessage(
      'Нет данных для заполнения пространств',
      TMWOHistoryOut
    );
    Exit;
  end;

  programlog.LogOutFormatStr(
    'Начало заполнения пространств, помещений в списке: %d',
    [RoomList.Count],
    LM_Info
  );

  ProcessedCount := 0;
  MatchedCount := 0;

  // Проходим по всем объектам чертежа
  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
  begin
    programlog.LogOutFormatStr(
      'Нет объектов для обработки',
      [],
      LM_Info
    );
    zcUI.TextMessage(
      'Не найдено объектов в чертеже',
      TMWOHistoryOut
    );
    Exit;
  end;

  repeat
    // Проверяем, является ли объект полилинией
    if EntityPtr^.GetObjType = GDBPolyLineID then
    begin
      PolylinePtr := PGDBObjPolyLine(EntityPtr);
      Inc(ProcessedCount);

      // Получаем расширение переменных
      VarExt := PolylinePtr^.specialize GetExtension<TVariablesExtender>;

      if VarExt <> nil then
      begin
        // Считываем текущее значение Space_RoomPos
        CurrentRoomPos := GetStringVariable(VarExt, VAR_SPACE_ROOM_POS);

        // Если позиция задана, ищем совпадение в списке
        if CurrentRoomPos <> '' then
        begin
          RoomIndex := FindRoomByPos(RoomList, CurrentRoomPos);

          if RoomIndex >= 0 then
          begin
            RoomInfo := RoomList[RoomIndex];
            Inc(MatchedCount);

            // Записываем новые значения в расширения полилинии
            SetStringVariable(VarExt, VAR_SPACE_ROOM_NAME, RoomInfo.RoomName);
            SetStringVariable(VarExt, VAR_SPACE_ROOM_AREA, RoomInfo.RoomArea);
            SetStringVariable(
              VarExt,
              VAR_SPACE_ROOM_CATEGORY,
              RoomInfo.RoomCategory
            );

            programlog.LogOutFormatStr(
              'Обновлено помещение: RoomPos=%s, Name=%s, Area=%s, Category=%s',
              [
                RoomInfo.RoomPos,
                RoomInfo.RoomName,
                RoomInfo.RoomArea,
                RoomInfo.RoomCategory
              ],
              LM_Info
            );
          end;
        end;
      end;
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;

  // Выводим итоговую статистику
  programlog.LogOutFormatStr(
    'Обработано полилиний: %d, совпадений найдено: %d',
    [ProcessedCount, MatchedCount],
    LM_Info
  );

  if MatchedCount = 0 then
  begin
    zcUI.TextMessage(
      'Не найдено совпадений с позициями помещений',
      TMWOHistoryOut
    );
  end
  else
  begin
    zcUI.TextMessage(
      'Заполнение пространств завершено. Обновлено помещений: ' +
      IntToStr(MatchedCount),
      TMWOHistoryOut
    );
  end;
end;

end.
