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

{**Модуль команд для вывода информации о структуре освещения}
unit uzvlightexporter_commandprint;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzclog,
  uzcinterface,
  uzcdrawings,
  uzcutils,
  uzbtypes,
  uzcstrconsts,
  uzvlightexporter_types,
  uzvlightexporter_spacecollector,
  uzvlightexporter_spacehierarchy,
  uzvlightexporter_printer;

{**Команда вывода структуры пространств и светильников}
function PrintLightStructure_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

{**Подсчитать количество выделенных объектов}
function CountSelectedObjects: Integer;
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
begin
  Result := 0;

  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
    Exit;

  repeat
    if EntityPtr^.selected then
      Inc(Result);

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;
end;

{**Собрать данные и построить иерархию}
function BuildHierarchyFromSelection(
  var HierarchyRoot: TLightHierarchyRoot
): Boolean;
var
  CollectedData: TCollectedData;
begin
  Result := False;

  CollectedData.SpacesList := nil;
  CollectedData.LuminairesList := nil;

  try
    CollectSelectedSpacesAndDevices(CollectedData);

    if CollectedData.SpacesList = nil then
    begin
      zcUI.TextMessage(
        'Список пространств не инициализирован',
        TMWOHistoryOut
      );
      Exit;
    end;

    if CollectedData.SpacesList.Count = 0 then
    begin
      zcUI.TextMessage(
        'Нет выделенных пространств для отображения',
        TMWOHistoryOut
      );
      Exit;
    end;

    BuildHierarchy(CollectedData, HierarchyRoot);

    if CollectedData.LuminairesList <> nil then
    begin
      if CollectedData.LuminairesList.Count > 0 then
        AssignDevicesToRooms(HierarchyRoot);
    end;

    Result := True;

  finally
    ClearCollectedData(CollectedData);
  end;
end;

{**Команда вывода структуры пространств и светильников}
function PrintLightStructure_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  SelectedCount: Integer;
  HierarchyRoot: TLightHierarchyRoot;
  ShowMode: string;
begin
  zcUI.TextMessage(
    'Запущена команда PrintLightStructure',
    TMWOHistoryOut
  );

  SelectedCount := CountSelectedObjects;

  if SelectedCount = 0 then
  begin
    zcUI.TextMessage(
      'Выделенных объектов не обнаружено',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      'Пожалуйста, выделите объекты для анализа',
      TMWOHistoryOut
    );

    commandmanager.executecommand(
      'SelectFrame',
      drawings.GetCurrentDWG,
      drawings.GetCurrentOGLWParam
    );

    Result := cmd_ok;
    Exit;
  end;

  zcUI.TextMessage(
    'Обнаружено выделенных объектов: ' + IntToStr(SelectedCount),
    TMWOHistoryOut
  );

  HierarchyRoot.Tree := nil;

  try
    if not BuildHierarchyFromSelection(HierarchyRoot) then
    begin
      zcUI.TextMessage(
        'Не удалось построить иерархию',
        TMWOHistoryOut
      );
      Result := cmd_ok;
      Exit;
    end;

    ShowMode := Trim(LowerCase(operands));

    if ShowMode = '' then
      ShowMode := 'full';

    case ShowMode of
      'spaces':
        begin
          zcUI.TextMessage(
            'Режим: только структура пространств',
            TMWOHistoryOut
          );
          PrintSpaceStructure(HierarchyRoot);
        end;

      'luminaires':
        begin
          zcUI.TextMessage(
            'Режим: только список светильников',
            TMWOHistoryOut
          );
          PrintLuminaireNames(HierarchyRoot);
        end;

      'full':
        begin
          zcUI.TextMessage(
            'Режим: полная информация',
            TMWOHistoryOut
          );
          PrintFullHierarchyInfo(HierarchyRoot);
        end;

    else
      zcUI.TextMessage(
        'Неизвестный режим: ' + ShowMode,
        TMWOHistoryOut
      );
      zcUI.TextMessage(
        'Доступные режимы: spaces, luminaires, full (по умолчанию)',
        TMWOHistoryOut
      );
    end;

  finally
    ClearHierarchy(HierarchyRoot);
  end;

  Result := cmd_ok;
end;

initialization
  CreateZCADCommand(
    @PrintLightStructure_com,
    'PrintLightStructure',
    CADWG,
    0
  );

end.
