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

{**Модуль управления процессом экспорта и взаимодействия между модулями}
unit uzvlightexporter_controller;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzclog,
  uzvlightexporter_types,
  uzvlightexporter_spacecollector,
  uzvlightexporter_spacehierarchy,
  uzvlightexporter_exporter;

{**Выполнить полный процесс экспорта в STF}
function ExecuteExport(const FileName: string): Boolean;

implementation

{**Проверить валидность имени файла}
function ValidateFileName(var FileName: string): Boolean;
begin
  Result := False;

  if Trim(FileName) = '' then
  begin
    programlog.LogOutFormatStr(
      'Не указано имя файла для экспорта',
      [],
      LM_Error
    );
    Exit;
  end;

  if ExtractFileExt(FileName) = '' then
    FileName := FileName + '.stf';

  Result := True;
end;

{**Проверить собранные данные на валидность}
function ValidateCollectedData(
  const CollectedData: TCollectedData
): Boolean;
begin
  Result := False;

  if CollectedData.SpacesList = nil then
  begin
    programlog.LogOutFormatStr(
      'Список пространств не инициализирован',
      [],
      LM_Error
    );
    Exit;
  end;

  if CollectedData.SpacesList.Count = 0 then
  begin
    programlog.LogOutFormatStr(
      'Нет пространств для экспорта',
      [],
      LM_Warning
    );
    Exit;
  end;

  Result := True;
end;

{**Выполнить полный процесс экспорта в STF}
function ExecuteExport(const FileName: string): Boolean;
var
  CollectedData: TCollectedData;
  HierarchyRoot: TLightHierarchyRoot;
  ValidatedFileName: string;
begin
  Result := False;

  programlog.LogOutFormatStr(
    'Запуск процесса экспорта освещения',
    [],
    LM_Info
  );

  ValidatedFileName := FileName;
  if not ValidateFileName(ValidatedFileName) then
    Exit;

  CollectedData.SpacesList := nil;
  CollectedData.LuminairesList := nil;
  HierarchyRoot.Tree := nil;

  try
    CollectSelectedSpacesAndDevices(CollectedData);

    if not ValidateCollectedData(CollectedData) then
      Exit;

    BuildHierarchy(CollectedData, HierarchyRoot);

    if CollectedData.LuminairesList <> nil then
    begin
      if CollectedData.LuminairesList.Count > 0 then
        AssignDevicesToRooms(CollectedData, HierarchyRoot);
    end;

    Result := ExportToSTF(HierarchyRoot, ValidatedFileName);

    if Result then
    begin
      programlog.LogOutFormatStr(
        'Экспорт успешно завершен: %s',
        [ValidatedFileName],
        LM_Info
      );
    end
    else
    begin
      programlog.LogOutFormatStr(
        'Экспорт завершился с ошибками',
        [],
        LM_Error
      );
    end;

  finally
    ClearCollectedData(CollectedData);
    ClearHierarchy(HierarchyRoot);
  end;
end;

end.
