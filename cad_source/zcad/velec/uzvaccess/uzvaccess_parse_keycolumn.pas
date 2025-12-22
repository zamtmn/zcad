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

unit uzvaccess_parse_keycolumn;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, DB, uzvaccess_types, uzclog;

// Парсинг инструкции keyColumn
// Читает имена ключевых колонок из Col3..Col11
procedure ParseKeyColumnInstruction(
  AInstruction: TExportInstructions;
  ADataset: TDataSet
);

implementation

// Получить значение колонки из датасета
function GetColumnValue(ADataset: TDataSet; AColumnIndex: Integer): String;
var
  fieldName: String;
begin
  Result := '';
  fieldName := Format('Col%d', [AColumnIndex]);

  if ADataset.FindField(fieldName) = nil then
    Exit;

  Result := Trim(ADataset.FieldByName(fieldName).AsString);
end;

procedure ParseKeyColumnInstruction(
  AInstruction: TExportInstructions;
  ADataset: TDataSet
);
var
  i: Integer;
  colValue: String;
  keyCount: Integer;
begin
  keyCount := 0;

  // Читаем все колонки начиная с Col3
  // (Col1 - ID, Col2 - тип инструкции)
  for i := 3 to 11 do
  begin
    colValue := GetColumnValue(ADataset, i);

    if colValue = '' then
      Break;

    AInstruction.AddKeyColumn(colValue);
    Inc(keyCount);
  end;

  programlog.LogOutFormatStr(
    'uzvaccess: keyColumn - найдено ключевых колонок: %d',
    [keyCount],
    LM_Info
  );
end;

end.
