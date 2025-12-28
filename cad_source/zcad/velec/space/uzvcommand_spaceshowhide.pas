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

{**Команда spaceshowhide(<LayerName>)
   Переключает вес указанного слоя между "большой" и "маленький".}
unit uzvcommand_spaceshowhide;

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
  uzeconsts,           // константы (в т.ч. для LineWeight)
  uzbtypes,uzeTypes,
  uzvcommand_spaceutils; // общие утилиты для команд space

// Основная команда
function SpaceShowHide_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

const
  // Константы веса слоя (внутренние единицы: сотые доли мм)
  // Weight constants for layers (internal units: hundredths of mm)
  // 2.00 мм = 200, 0.00 мм = 0
  // Храним как числа, чтобы их было проще редактировать по ТЗ
  // Store as numbers to make them easier to edit per requirements
  CONST_LAYER_WEIGHT_BIG   = 200;
  CONST_LAYER_WEIGHT_SMALL = 0;

{** Основная функция команды spaceshowhide
    Переключает вес указанного слоя между большим и малым значениями.
    @param(Context - контекст выполнения команды)
    @param(operands - операнды команды, содержащие имя слоя)
    @return(результат выполнения команды)}
function SpaceShowHide_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  layerName: string;
  pLayer: PGDBLayerProp;
  newLW: TGDBLineWeight;
begin
  // Получаем и нормализуем имя слоя из операндов
  // Get and normalize layer name from operands
  layerName := NormalizeLayerName(operands);

  // Проверяем что имя слоя указано
  // Check that layer name is specified
  if layerName = '' then
  begin
    zcUI.TextMessage('Укажите имя слоя: spaceshowhide(<LayerName>)', TMWOHistoryOut);
    exit(cmd_error);
  end;

  // Ищем слой в текущем чертеже используя утилиту
  // Find layer in current drawing using utility function
  pLayer := FindLayerByName(layerName);
  if pLayer = nil then
  begin
    zcUI.TextMessage('Слой ' + layerName + ' не существует', TMWOHistoryOut);
    exit(cmd_ok);
  end;

  // Переключаем вес: если текущий НЕ big -> ставим big, иначе -> small
  // Toggle weight: if current is NOT big -> set big, else -> set small
  if pLayer^.lineweight <> CONST_LAYER_WEIGHT_BIG then
    newLW := CONST_LAYER_WEIGHT_BIG
  else
    newLW := CONST_LAYER_WEIGHT_SMALL;

  // Применяем новый вес к слою
  // Apply new weight to layer
  pLayer^.lineweight := newLW;

  // Информируем пользователя об изменении
  // Inform user about the change
  if newLW = CONST_LAYER_WEIGHT_BIG then
    zcUI.TextMessage('Вес слоя ' + layerName + ' установлен: 2.00 мм', TMWOHistoryOut)
  else
    zcUI.TextMessage('Вес слоя ' + layerName + ' установлен: 0.00 мм', TMWOHistoryOut);

  Result := cmd_ok;
end;

initialization
  // Регистрация команды в системе
  // Register command in system
  CreateZCADCommand(@SpaceShowHide_com,'spaceshowhide',CADWG,0);

end.
