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

unit uzvaccess_parse_setcolumn;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, uzvaccess_types, uzclog;

// Парсинг инструкции setcolumn
// Col2 - имя колонки, Col3 - тип данных, Col4 - параметр источника
procedure ParseSetColumnInstruction(
  AInstruction: TExportInstructions;
  const ACol2, ACol3, ACol4: String
);

implementation

procedure ParseSetColumnInstruction(
  AInstruction: TExportInstructions;
  const ACol2, ACol3, ACol4: String
);
var
  mapping: TColumnMapping;
begin
  // Проверка обязательных параметров
  if (ACol2 = '') or (ACol3 = '') or (ACol4 = '') then
  begin
    programlog.LogOutFormatStr(
      'uzvaccess: Инструкция setcolumn с неполными параметрами - пропускается',
      [],
      LM_Info
    );
    Exit;
  end;

  // Создание маппинга колонки
  mapping := TColumnMapping.Create;
  mapping.ColumnName := ACol2;
  mapping.DataType := StringToColumnDataType(ACol3);
  mapping.SourceParam := ACol4;

  AInstruction.AddColumnMapping(mapping);

  programlog.LogOutFormatStr(
    'uzvaccess: setcolumn - колонка: %s, тип: %s, источник: %s',
    [ACol2, ACol3, ACol4],
    LM_Info
  );
end;

end.
