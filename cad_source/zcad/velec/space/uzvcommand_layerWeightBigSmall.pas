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

{**Команда layerWeightBigSmall(<LayerName>)
   Переключает вес указанного слоя между "большой" и "маленький".}
unit uzvcommand_layerWeightBigSmall;

{$INCLUDE zengineconfig.inc}

interface

uses
  sysutils,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,     // менеджер команд и связанные объекты
  uzcinterface,        // утилиты интерфейса
  uzcdrawings,         // менеджер чертежей
  uzestyleslayers,     // стили и таблица слоёв
  uzeconsts;           // константы (в т.ч. для LineWeight)

// Основная команда
function layerWeightBigSmall_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

const
  // Константы веса слоя (внутренние единицы: сотые доли мм)
  // 2.00 мм = 200, 0.00 мм = 0
  CONST_LAYER_WEIGHT_BIG   = LnWt200;
  CONST_LAYER_WEIGHT_SMALL = LnWt000;

// Нормализация имени слоя из операндов:
// - обрезаем пробелы
// - убираем скобки и одинарные/двойные кавычки, если присутствуют
function NormalizeLayerName(const s: string): string;
var
  name: string;
begin
  name := Trim(s);

  // Удалим внешние скобки вида (LayerName)
  if (Length(name) >= 2) and (name[1] = '(') and (name[Length(name)] = ')') then
    name := Copy(name, 2, Length(name) - 2);

  name := Trim(name);

  // Удалим одинарные кавычки
  if (Length(name) >= 2) and (name[1] = '''') and (name[Length(name)] = '''') then
    name := Copy(name, 2, Length(name) - 2);

  // Удалим двойные кавычки
  if (Length(name) >= 2) and (name[1] = '"') and (name[Length(name)] = '"') then
    name := Copy(name, 2, Length(name) - 2);

  Result := Trim(name);
end;

function layerWeightBigSmall_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  layerName: string;
  pLayer: PGDBLayerProp;
  newLW: SmallInt;
begin
  // Получаем имя слоя из операндов
  layerName := NormalizeLayerName(operands);

  if layerName = '' then
  begin
    zcUI.TextMessage('Укажите имя слоя: layerWeightBigSmall(<LayerName>)', TMWOHistoryOut);
    exit(cmd_error);
  end;

  // Ищем слой в текущем чертеже
  pLayer := drawings.GetCurrentDWG^.LayerTable.getAddres(layerName);
  if pLayer = nil then
  begin
    zcUI.TextMessage('Слой ' + layerName + ' не существует', TMWOHistoryOut);
    exit(cmd_ok);
  end;

  // Переключаем вес: если текущий НЕ big -> ставим big, иначе -> small
  if pLayer^.lineweight <> CONST_LAYER_WEIGHT_BIG then
    newLW := CONST_LAYER_WEIGHT_BIG
  else
    newLW := CONST_LAYER_WEIGHT_SMALL;

  pLayer^.lineweight := newLW;

  // Информируем пользователя
  if newLW = CONST_LAYER_WEIGHT_BIG then
    zcUI.TextMessage('Вес слоя ' + layerName + ' установлен: 2.00 мм', TMWOHistoryOut)
  else
    zcUI.TextMessage('Вес слоя ' + layerName + ' установлен: 0.00 мм', TMWOHistoryOut);

  Result := cmd_ok;
end;

initialization
  // Регистрация команды
  CreateZCADCommand(@layerWeightBigSmall_com,'layerWeightBigSmall',CADWG,0);

end.

