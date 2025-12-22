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

unit uzvaccess_parse_const;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, uzvaccess_types, uzclog;

// Парсинг инструкции const
// Col2 - имя колонки, Col3 - константное значение
procedure ParseConstInstruction(
  AInstruction: TExportInstructions;
  const ACol2, ACol3: String
);

implementation

procedure ParseConstInstruction(
  AInstruction: TExportInstructions;
  const ACol2, ACol3: String
);
var
  mapping: TColumnMapping;
begin
  // Проверка обязательных параметров
  if (ACol2 = '') or (ACol3 = '') then
  begin
    programlog.LogOutFormatStr(
      'uzvaccess: Инструкция const с неполными параметрами - пропускается',
      [],
      LM_Info
    );
    Exit;
  end;

  // Создание константного маппинга
  mapping := TColumnMapping.Create;
  mapping.ColumnName := ACol2;
  mapping.DataType := cdtString;
  mapping.IsConstant := True;
  mapping.DefaultValue := ACol3;

  AInstruction.AddColumnMapping(mapping);

  programlog.LogOutFormatStr(
    'uzvaccess: const - колонка: %s, значение: %s',
    [ACol2, ACol3],
    LM_Info
  );
end;

end.
