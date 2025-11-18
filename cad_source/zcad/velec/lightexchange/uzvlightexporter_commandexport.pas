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

{**Модуль реализации и регистрации команды exportLighttoSTF}
unit uzvlightexporter_commandexport;

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
  uzeentity,
  gzctnrVectorTypes,
  uzvlightexporter_controller;

{**Функция команды экспорта освещения в STF}
function exportLighttoSTF_com(
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

{**Получить имя файла для экспорта}
function GetExportFileName(
  const Operands: TCommandOperands
): string;
var
  DrawingPath: string;
  DrawingName: string;
begin
  if Trim(Operands) <> '' then
  begin
    Result := Trim(Operands);

    if (Length(Result) >= 2) and
       (Result[1] = '''') and
       (Result[Length(Result)] = '''') then
      Result := Copy(Result, 2, Length(Result) - 2);
  end
  else
  begin
    DrawingPath := drawings.GetCurrentDWG^.GetFileName;

    if DrawingPath = '' then
    begin
      Result := 'export.stf';
      Exit;
    end;

    DrawingName := ExtractFileName(DrawingPath);
    Result := ChangeFileExt(DrawingName, '.stf');
    DrawingPath := ExtractFileDir(DrawingPath);
    Result := IncludeTrailingPathDelimiter(DrawingPath) + Result;
  end;

  if ExtractFileExt(Result) = '' then
    Result := Result + '.stf';
end;

{**Функция команды экспорта освещения в STF}
function exportLighttoSTF_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  FileName: string;
  SelectedCount: Integer;
  ExportSuccess: Boolean;
begin
  zcUI.TextMessage(
    'Запущена команда exportLighttoSTF',
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
      'Пожалуйста, выделите объекты для экспорта',
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

  FileName := GetExportFileName(operands);

  zcUI.TextMessage(
    'Экспорт в файл: ' + FileName,
    TMWOHistoryOut
  );

  ExportSuccess := ExecuteExport(FileName);

  if ExportSuccess then
  begin
    zcUI.TextMessage(
      'Экспорт успешно завершен',
      TMWOHistoryOut
    );
  end
  else
  begin
    zcUI.TextMessage(
      'Ошибка при экспорте',
      TMWOHistoryOut
    );
  end;

  Result := cmd_ok;
end;

initialization
  CreateZCADCommand(
    @exportLighttoSTF_com,
    'exportLighttoSTF',
    CADWG,
    0
  );

end.
