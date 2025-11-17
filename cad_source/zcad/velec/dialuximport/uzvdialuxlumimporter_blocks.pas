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

{**Модуль получения и анализа списка загруженных блоков}
unit uzvdialuxlumimporter_blocks;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  uzcdrawings,
  uzbtypes,
  uzclog,
  uzeblockdef,
  gzctnrVectorTypes,
  uzvdialuxlumimporter_structs,
  uzvdialuxlumimporter_utils;

{**Получить список загруженных блоков с фильтром VELEC}
procedure GetLoadedBlocks(out LoadedBlocks: TLoadedBlocksList);

{**Освободить память занятую списком блоков}
procedure FreeLoadedBlocks(var LoadedBlocks: TLoadedBlocksList);

implementation

{**Проверить, содержит ли имя блока префикс VELEC}
function HasVelecPrefix(const BlockName: string): Boolean;
begin
  Result := Pos(
    AnsiUpperCase(BLOCK_FILTER_PREFIX),
    AnsiUpperCase(BlockName)
  ) > 0;
end;

{**Получить список загруженных блоков с фильтром VELEC}
procedure GetLoadedBlocks(out LoadedBlocks: TLoadedBlocksList);
var
  BlockDefPtr: PGDBObjBlockdef;
  IterRec: itrec;
  BlockName: string;
  TotalCount: Integer;
  FilteredCount: Integer;
begin
  LoadedBlocks := TLoadedBlocksList.Create;
  LoadedBlocks.Sorted := True;
  LoadedBlocks.Duplicates := dupIgnore;

  TotalCount := 0;
  FilteredCount := 0;

  programlog.LogOutFormatStr(
    'Начат сбор загруженных блоков',
    [],
    LM_Info
  );

  // Проверяем доступность BlockBaseDWG
  if BlockBaseDWG = nil then
  begin
    programlog.LogOutFormatStr(
      'BlockBaseDWG не инициализирован',
      [],
      LM_Error
    );
    Exit;
  end;

  // Перебираем все определения блоков из базы блоков
  BlockDefPtr := BlockBaseDWG^.BlockDefArray.beginiterate(IterRec);

  if BlockDefPtr = nil then
  begin
    programlog.LogOutFormatStr(
      'Нет определений блоков в BlockBaseDWG',
      [],
      LM_Warning
    );
    Exit;
  end;

  repeat
    Inc(TotalCount);
    BlockName := BlockDefPtr^.Name;

    programlog.LogOutFormatStr(
      'Найден блок: "%s"',
      [BlockName],
      LM_Debug
    );

    // Применяем фильтр VELEC
    if HasVelecPrefix(BlockName) then
    begin
      LoadedBlocks.Add(BlockName);
      Inc(FilteredCount);

      programlog.LogOutFormatStr(
        'Блок "%s" соответствует фильтру VELEC',
        [BlockName],
        LM_Debug
      );
    end;

    BlockDefPtr := BlockBaseDWG^.BlockDefArray.iterate(IterRec);
  until BlockDefPtr = nil;

  programlog.LogOutFormatStr(
    'Сбор блоков завершен: всего=%d, с фильтром VELEC=%d',
    [TotalCount, FilteredCount],
    LM_Info
  );
end;

{**Освободить память занятую списком блоков}
procedure FreeLoadedBlocks(var LoadedBlocks: TLoadedBlocksList);
begin
  if LoadedBlocks <> nil then
  begin
    LoadedBlocks.Free;
    LoadedBlocks := nil;
  end;
end;

end.
