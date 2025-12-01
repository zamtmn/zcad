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
{$mode delphi}

{**Модуль реализации команды exdRectangle для черчения прямоугольника с расширениями}
unit uzvcommand_exdRectangle;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,               // String utilities / Утилиты для работы со строками
  Classes,                // TStringList / TStringList
  uzcLog,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentity,
  uzcEnitiesVariablesExtender,
  uzcExtdrIncludingVolume,
  uzccommand_rectangle,
  uzcinterface,           // Interface utilities / Утилиты интерфейса
  uzcdrawings,            // Drawings manager / Менеджер чертежей
  uzestyleslayers,        // Layer management / Управление слоями
  varmandef;              // Variable manager definitions / Определения менеджера переменных

implementation

var
  // Module-level variable to store command operands
  // Переменная уровня модуля для хранения операндов команды
  gCommandOperands: TCommandOperands;

// Helper procedure to parse operands and extract color, layer, and variables
// Вспомогательная процедура для разбора операндов и извлечения цвета, слоя и переменных
procedure ParseOperandsAndAddVariables(
  APEnt: PGDBObjEntity;
  const operands: TCommandOperands;
  out colorIndex: Integer;
  out layerName: string);
var
  VarExt: TVariablesExtender;
  params: TStringList;
  i: integer;
  varname, username, typename: string;
  vd: vardesk;
begin
  // Set default values
  // Устанавливаем значения по умолчанию
  colorIndex := 3;  // Default: green / По умолчанию: зеленый
  layerName := '';  // Empty means use current layer / Пустое значит использовать текущий слой

  // Check if we have operands
  // Проверяем наличие операндов
  if Trim(operands) = '' then
    exit;

  // Split operands by comma
  // Разделяем операнды по запятой
  params := TStringList.Create;
  try
    params.Delimiter := ',';
    params.StrictDelimiter := True;
    params.DelimitedText := operands;

    // Need at least 2 parameters (color and layer)
    // Нужно минимум 2 параметра (цвет и слой)
    if params.Count < 2 then
      exit;

    // Extract color index (first parameter)
    // Извлекаем индекс цвета (первый параметр)
    try
      colorIndex := StrToInt(Trim(params[0]));
      // Ensure color is in valid range (1-255)
      // Проверяем что цвет в допустимом диапазоне (1-255)
      if (colorIndex < 1) or (colorIndex > 255) then
        colorIndex := 3;  // Fallback to default / Возврат к значению по умолчанию
    except
      colorIndex := 3;  // Fallback to default on error / Возврат к значению по умолчанию при ошибке
    end;

    // Extract layer name (second parameter)
    // Извлекаем имя слоя (второй параметр)
    layerName := Trim(params[1]);
    // Remove quotes if present
    // Удаляем кавычки если есть
    if (Length(layerName) >= 2) and (layerName[1] = '''') and (layerName[Length(layerName)] = '''') then
      layerName := Copy(layerName, 2, Length(layerName) - 2);

    // Now process variables starting from index 2
    // Теперь обрабатываем переменные начиная с индекса 2
    VarExt := APEnt^.specialize GetExtension<TVariablesExtender>;
    if VarExt = nil then
      exit;

    // Process variables in triplets: varname, username, typename
    // Обрабатываем переменные в триплетах: имя_переменной, имя_пользователя, тип
    i := 2;  // Start after color and layer parameters / Начинаем после параметров цвета и слоя
    while i + 2 < params.Count do begin
      varname := Trim(params[i]);
      username := Trim(params[i + 1]);
      typename := Trim(params[i + 2]);

      // Remove quotes if present
      // Удаляем кавычки если есть
      if (Length(username) >= 2) and (username[1] = '''') and (username[Length(username)] = '''') then
        username := Copy(username, 2, Length(username) - 2);

      // Check if variable already exists
      // Проверяем существует ли уже переменная
      if VarExt.entityunit.FindVariable(varname) = nil then begin
        // Create and add the variable
        // Создаем и добавляем переменную
        VarExt.entityunit.setvardesc(vd, varname, username, typename);
        VarExt.entityunit.InterfaceVariables.createvariable(vd.Name, vd);

        zcUI.TextMessage('Добавлена переменная / Variable added: ' + varname +
                        ' (' + username + ') : ' + typename, TMWOHistoryOut);
      end;

      // Move to next triplet
      // Переходим к следующему триплету
      Inc(i, 3);
    end;
  finally
    params.Free;
  end;
end;

{**Функция добавления расширений к прямоугольнику на разных стадиях настройки
   @param(AStage - стадия настройки примитива)
   @param(APEnt - указатель на примитив)
   @return(true если обработка успешна)}
function AddExtdrToRectangle(const AStage:TEntitySetupStage;
  const APEnt:PGDBObjEntity):boolean;
var
  colorIndex: Integer;
  layerName: string;
  pLayer: PGDBLayerProp;
  pproglayer: PGDBLayerProp;
begin
  case AStage of
    ESSSuppressCommandParams:
      result:=false;
    ESSSetEntity:begin
      if APEnt<>nil then begin
        // Добавляем расширение extdrVariables первым
        // Add extdrVariables extension first
        AddVariablesToEntity(APEnt);

        // Затем добавляем расширение extdrIncludingVolume
        // Then add extdrIncludingVolume extension
        AddVolumeExtenderToEntity(APEnt);

        // Парсим операнды и добавляем переменные к примитиву
        // Parse operands and add variables to entity
        // Also extracts color and layer from operands
        // Также извлекает цвет и слой из операндов
        ParseOperandsAndAddVariables(APEnt, gCommandOperands, colorIndex, layerName);

        // Set layer if specified
        // Устанавливаем слой если указан
        if layerName <> '' then begin
          pproglayer:=BlockBaseDWG^.LayerTable.getAddres(layerName);
          // Try to create layer using library layer as template
          // Пытаемся создать слой используя слой из библиотеки как шаблон
          pLayer := drawings.GetCurrentDWG^.LayerTable.createlayerifneedbyname(
            layerName,
            pproglayer
          );

          // If layer still doesn't exist, create it with default parameters
          // Если слой все еще не существует, создаем его с параметрами по умолчанию
          if pLayer = nil then begin
            pLayer := drawings.GetCurrentDWG^.LayerTable.addlayer(
              layerName,           // name / имя
              colorIndex,          // color / цвет
              -1,                  // line weight / толщина линии
              True,                // on / включен
              False,               // lock / заблокирован
              True,                // print / печатать
              'Rectangle layer',   // description / описание
              TLOLoad              // load mode / режим загрузки
            );
            zcUI.TextMessage('Создан слой / Layer created: ' + layerName, TMWOHistoryOut);
          end;

          // Set the layer for the entity
          // Устанавливаем слой для примитива
          if pLayer <> nil then
            APEnt^.vp.Layer := pLayer;
        end;

        result:=true;
      end else
        result:=False;
      end;
    ESSCommandEnd:begin
      // Clear operands after command ends
      // Очищаем операнды после завершения команды
      gCommandOperands := '';
      result:=False;
    end;
  end;
end;

{**Команда черчения прямоугольника с расширениями
   @param(Context - контекст команды ZCAD)
   @param(operands - операнды команды)
   @return(результат выполнения команды)}
function ExdRectangle_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  // Store operands in module-level variable for access by AddExtdrToRectangle
  // Сохраняем операнды в переменной уровня модуля для доступа из AddExtdrToRectangle
  gCommandOperands := operands;

  // Output message about command launch
  // Вывод сообщения о запуске команды
  zcUI.TextMessage('запущена команда exdRectangle', TMWOHistoryOut);

  Result:=InteractiveDrawRectangle(
    Context,
    rscmSpecifyFirstPoint,
    rscmSpecifySecondPoint,
    AddExtdrToRectangle
  );
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ExdRectangle_com,'exdRectangle',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
