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

unit uzvaccess_sqlbuilder;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, uzvaccess_types;

{**
  Класс для построения SQL-запросов

  Формирует запросы INSERT, UPDATE, SELECT для работы с MS Access
**}
type
  TSqlBuilder = class
  public
    // Построить запрос INSERT
    function BuildInsertSQL(
      const ATableName: String;
      AInstructions: TExportInstructions
    ): String;

    // Построить запрос UPDATE
    function BuildUpdateSQL(
      const ATableName: String;
      AInstructions: TExportInstructions
    ): String;

    // Построить запрос проверки существования записи
    function BuildExistsSQL(
      const ATableName: String;
      AInstructions: TExportInstructions
    ): String;
  end;

implementation

{ TSqlBuilder }

function TSqlBuilder.BuildInsertSQL(
  const ATableName: String;
  AInstructions: TExportInstructions
): String;
var
  i: Integer;
  mapping: TColumnMapping;
  columns, params: String;
begin
  columns := '';
  params := '';

  // Формируем список колонок и параметров
  for i := 0 to AInstructions.ColumnMappings.Size - 1 do
  begin
    mapping := AInstructions.ColumnMappings[i];

    if i > 0 then
    begin
      columns := columns + ', ';
      params := params + ', ';
    end;

    columns := columns + '[' + mapping.ColumnName + ']';
    params := params + ':' + mapping.ColumnName;
  end;

  Result := Format('INSERT INTO [%s] (%s) VALUES (%s)',
    [ATableName, columns, params]);
end;

function TSqlBuilder.BuildUpdateSQL(
  const ATableName: String;
  AInstructions: TExportInstructions
): String;
var
  i: Integer;
  mapping: TColumnMapping;
  setClause, whereClause: String;
  isKey: Boolean;
begin
  setClause := '';
  whereClause := '';

  // Формируем SET и WHERE части
  for i := 0 to AInstructions.ColumnMappings.Size - 1 do
  begin
    mapping := AInstructions.ColumnMappings[i];
    isKey := AInstructions.KeyColumns.IndexOf(mapping.ColumnName) >= 0;

    if not isKey then
    begin
      // Не ключевые колонки идут в SET
      if setClause <> '' then
        setClause := setClause + ', ';

      setClause := setClause + Format('[%s] = :%s',
        [mapping.ColumnName, mapping.ColumnName]);
    end
    else
    begin
      // Ключевые колонки идут в WHERE
      if whereClause <> '' then
        whereClause := whereClause + ' AND ';

      whereClause := whereClause + Format('[%s] = :%s_key',
        [mapping.ColumnName, mapping.ColumnName]);
    end;
  end;

  Result := Format('UPDATE [%s] SET %s WHERE %s',
    [ATableName, setClause, whereClause]);
end;

function TSqlBuilder.BuildExistsSQL(
  const ATableName: String;
  AInstructions: TExportInstructions
): String;
var
  i: Integer;
  keyCol: String;
  whereClause: String;
begin
  whereClause := '';

  // Формируем WHERE по ключевым колонкам
  for i := 0 to AInstructions.KeyColumns.Count - 1 do
  begin
    keyCol := AInstructions.KeyColumns[i];

    if i > 0 then
      whereClause := whereClause + ' AND ';

    whereClause := whereClause + Format('[%s] = :%s',
      [keyCol, keyCol]);
  end;

  Result := Format('SELECT COUNT(*) AS RecCount FROM [%s] WHERE %s',
    [ATableName, whereClause]);
end;

end.
