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

{**Модуль реализации команды ShowHideSpace для подсветки зон по переменным}
unit uzvcommand_showhidespace;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,
  Classes,             //TStringList and related classes
                       //TStringList и связанные классы

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,     //Commands manager and related objects
                       //менеджер команд и объекты связанные с ним
  uzclog,              //log system
                       //система логирования
  uzcinterface,        //interface utilities
                       //утилиты интерфейса
  uzcdrawings,         //Drawings manager
                       //Менеджер чертежей
  uzcdrawing,          //Drawing type definition
                       //определение типа чертежа
  uzcutils,            //utility functions
                       //утилиты
  uzeentity,           //base entity
                       //базовый примитив
  uzeentpolyline,      //polyline entity
                       //примитив полилиния
  uzeenthatch,         //hatch entity
                       //примитив штриховка
  uzeBoundaryPath,     //boundary path for hatch
                       //граничный путь для штриховки
  UGDBPolyLine2DArray, //2D polyline array
                       //массив 2D полилиний
  uzgldrawcontext,     //drawing context
                       //контекст рисования
  uzegeometrytypes,    //geometry types
                       //геометрические типы
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzcenitiesvariablesextender,  //entity variables extender
                                //расширение переменных примитивов
  uzestyleslayers,     //layer styles and management
                       //стили и управление слоями
  gzctnrVectorTypes,
  uzeconsts,
  zcmultiobjectcreateundocommand, //undo command for multi object operations
                                  //команда отмены для множественных операций над объектами
  varmandef;                     //variable manager definitions
                                 //определения менеджера переменных

function ShowHideSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

// Helper function to create solid hatch from polyline
// Вспомогательная функция для создания сплошной штриховки из полилинии
function CreateSolidHatchFromPolyline(ppolyline: PGDBObjPolyLine; colorIndex: Integer; pLayer: PGDBLayerProp): PGDBObjHatch;
var
  phatch: PGDBObjHatch;
  pathData: GDBPolyline2DArray;
  v2d: GDBVertex2D;
  i: integer;
  vertexCount: integer;
  dc: TDrawContext;
begin
  Result := nil;

  if ppolyline = nil then
    exit;

  vertexCount := ppolyline^.VertexArrayInOCS.Count;

  // Проверяем что у полилинии достаточно вершин для создания штриховки
  // Check that polyline has enough vertices to create hatch
  if vertexCount < 3 then
    exit;

  // Создаем штриховку
  // Create hatch
  phatch := GDBObjHatch.CreateInstance;

  // Устанавливаем свойства штриховки
  // Set hatch properties
  if pLayer <> nil then
    phatch^.vp.Layer := pLayer
  else
    phatch^.vp.Layer := ppolyline^.vp.Layer;

  phatch^.vp.LineWeight := ppolyline^.vp.LineWeight;
  phatch^.vp.Color := colorIndex; // Цвет штриховки из параметров команды
                                  // Hatch color from command parameters
  phatch^.PPattern := nil; // Сплошная штриховка (тип solid)
                           // Solid hatch (solid type)

  // Локальная система координат штриховки инициализирована по умолчанию
  // Hatch local coordinate system is initialized by default

  // Создаем путь из вершин полилинии
  // Create path from polyline vertices
  pathData.init(vertexCount, True);

  for i := 0 to vertexCount - 1 do begin
    v2d.x := ppolyline^.VertexArrayInOCS.getData(i).x;
    v2d.y := ppolyline^.VertexArrayInOCS.getData(i).y;
    pathData.PushBackData(v2d);
  end;

  phatch^.Path.paths.PushBackData(pathData);

  // Форматируем примитив штриховки
  // Format hatch entity
  dc := drawings.GetCurrentDWG^.CreateDrawingRC;
  phatch^.FormatEntity(drawings.GetCurrentDWG^, dc);

  Result := phatch;
end;

// Helper procedure to parse operands: extract color, layer, and variable names
// Вспомогательная процедура для разбора операндов: извлечение цвета, слоя и имен переменных
procedure ParseOperands(
  const operands: TCommandOperands;
  out colorIndex: Integer;
  out layerName: string;
  var varList: TStringList);
var
  i: integer;
  varname: string;
  params: TStringList;
begin
  // Set default values
  // Устанавливаем значения по умолчанию
  colorIndex := 4;  // Default: light blue (cyan)
                    // По умолчанию: светло-голубой (cyan)
  layerName := '';  // Empty means use polyline's layer
                    // Пустое значит использовать слой полилинии

  // Clear variable list
  // Очищаем список переменных
  varList.Clear;

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

    // Need at least 3 parameters (color, layer, and at least one variable)
    // Нужно минимум 3 параметра (цвет, слой и хотя бы одна переменная)
    if params.Count < 3 then
      exit;

    // Extract color index (first parameter)
    // Извлекаем индекс цвета (первый параметр)
    try
      colorIndex := StrToInt(Trim(params[0]));
      // Ensure color is in valid range (1-255)
      // Проверяем что цвет в допустимом диапазоне (1-255)
      if (colorIndex < 1) or (colorIndex > 255) then
        colorIndex := 4;  // Fallback to default
                          // Возврат к значению по умолчанию
    except
      colorIndex := 4;  // Fallback to default on error
                        // Возврат к значению по умолчанию при ошибке
    end;

    // Extract layer name (second parameter)
    // Извлекаем имя слоя (второй параметр)
    layerName := Trim(params[1]);
    // Remove quotes if present
    // Удаляем кавычки если есть
    if (Length(layerName) >= 2) and (layerName[1] = '''') and (layerName[Length(layerName)] = '''') then
      layerName := Copy(layerName, 2, Length(layerName) - 2);

    // Extract variable names (starting from third parameter)
    // Извлекаем имена переменных (начиная с третьего параметра)
    for i := 2 to params.Count - 1 do begin
      varname := Trim(params[i]);

      // Remove quotes if present
      // Удаляем кавычки если есть
      if (Length(varname) >= 2) and (varname[1] = '''') and (varname[Length(varname)] = '''') then
        varname := Copy(varname, 2, Length(varname) - 2);

      if varname <> '' then
        varList.Add(varname);
    end;
  finally
    params.Free;
  end;
end;

// Check if entity has any of the specified variables
// Проверяет содержит ли примитив любую из указанных переменных
function EntityHasAnyVariable(pEntity: PGDBObjEntity; varList: TStringList): boolean;
var
  VarExt: TVariablesExtender;
  i: integer;
  pvd: pvardesk;
begin
  Result := False;

  // Get variables extender from entity
  // Получаем расширение переменных от примитива
  VarExt := pEntity^.specialize GetExtension<TVariablesExtender>;
  if VarExt = nil then
    exit;

  // Check each variable from the list
  // Проверяем каждую переменную из списка
  for i := 0 to varList.Count - 1 do begin
    pvd := VarExt.entityunit.FindVariable(varList[i]);
    if pvd <> nil then begin
      Result := True;
      exit;
    end;
  end;
end;

// Check if hatches exist on the specified layer and delete them
// Проверяет существуют ли штриховки на указанном слое и удаляет их
// Returns: number of hatches deleted, or -1 if layer doesn't exist
// Возвращает: количество удаленных штриховок или -1 если слой не существует
function DeleteHatchesOnLayer(layerName: string): integer;
var
  pEntity: PGDBObjEntity;
  phatch: PGDBObjHatch;
  ir: itrec;
  deletedCount: integer;
  pLayer: PGDBLayerProp;
  entitiesToDelete: array of PGDBObjEntity;
  i: integer;
  domethod, undomethod: tmethod;
    pproglayer:PGDBLayerProp;
begin
  Result := -1;  // По умолчанию -1 означает что слой не найден
                 // Default -1 means layer not found
  deletedCount := 0;

  if layerName = '' then
    exit;

  // Ищем слой по имени БЕЗ создания нового слоя
  // Find layer by name WITHOUT creating a new one
    pproglayer:=BlockBaseDWG^.LayerTable.getAddres(layerName);//ищем описание слоя в библиотеке
                                                                  //возможно оно найдется, а возможно вернется nil
    // Try to create layer using current layer as template
  // Пытаемся создать слой используя текущий слой как шаблон
  pLayer := drawings.GetCurrentDWG^.LayerTable.createlayerifneedbyname(
    layerName,
    pproglayer
  );


  // Если слой не существует, возвращаем -1
  // If layer doesn't exist, return -1
  if pLayer = nil then
    exit;

  // Collect all hatches on the specified layer
  // Собираем все штриховки на указанном слое
  SetLength(entitiesToDelete, 0);

  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity <> nil then
    repeat
      // Check if entity is a hatch and on the target layer
      // Проверяем является ли примитив штриховкой и на целевом слое
      if pEntity^.GetObjType = GDBHatchID then begin
        phatch := PGDBObjHatch(pEntity);
        if phatch^.vp.Layer = pLayer then begin
          // Add to deletion list
          // Добавляем в список удаления
          SetLength(entitiesToDelete, Length(entitiesToDelete) + 1);
          entitiesToDelete[High(entitiesToDelete)] := pEntity;
        end;
      end;

      pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pEntity = nil;

  // Delete collected hatches with undo support
  // Удаляем собранные штриховки с поддержкой отмены
  if Length(entitiesToDelete) > 0 then begin
    // For deletion, we swap do/undo methods (like in Erase command)
    // Для удаления меняем местами методы do/undo (как в команде Erase)
    SetObjCreateManipulator(undomethod, domethod);

    with PushMultiObjectCreateCommand(
        PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
        tmethod(domethod),
        tmethod(undomethod),
        Length(entitiesToDelete)) do begin

      for i := 0 to High(entitiesToDelete) do begin
        AddObject(entitiesToDelete[i]);
        inc(deletedCount);
      end;

      FreeArray := False;
      comit;
    end;
  end;

  Result := deletedCount;
end;

function ShowHideSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pEntity: PGDBObjEntity;
  pPolyline: PGDBObjPolyLine;
  phatch: PGDBObjHatch;
  ir: itrec;
  varList: TStringList;
  foundCount: integer;
  processedCount: integer;
  hatchCount: integer;
  deletedCount: integer;
  colorIndex: Integer;
  layerName: string;
  pLayer: PGDBLayerProp;
  pproglayer:PGDBLayerProp;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда ShowHideSpace',TMWOHistoryOut);

  // Проверяем наличие операндов
  // Check if we have operands
  if Trim(operands) = '' then begin
    zcUI.TextMessage('Ошибка: не указаны параметры / Error: parameters not specified', TMWOHistoryOut);
    zcUI.TextMessage('Использование / Usage: ShowHideSpace(colorIndex,''LayerName'',variable1,variable2,...)', TMWOHistoryOut);
    zcUI.TextMessage('Пример / Example: ShowHideSpace(3,''Space_Highlight'',space_Floor,Space_Room)', TMWOHistoryOut);
    Result := cmd_ok;
    exit;
  end;

  // Парсим операнды: цвет, слой и имена переменных
  // Parse operands: color, layer and variable names
  varList := TStringList.Create;
  try
    ParseOperands(operands, colorIndex, layerName, varList);

    if varList.Count = 0 then begin
      zcUI.TextMessage('Ошибка: не удалось распознать имена переменных / Error: could not parse variable names', TMWOHistoryOut);
      zcUI.TextMessage('Использование / Usage: ShowHideSpace(colorIndex,''LayerName'',variable1,variable2,...)', TMWOHistoryOut);
      Result := cmd_ok;
      exit;
    end;

    zcUI.TextMessage('Параметры команды / Command parameters:', TMWOHistoryOut);
    zcUI.TextMessage('  Цвет штриховки / Hatch color: ' + IntToStr(colorIndex), TMWOHistoryOut);
    zcUI.TextMessage('  Слой / Layer: ' + layerName, TMWOHistoryOut);
    zcUI.TextMessage('  Переменные / Variables: ' + varList.CommaText, TMWOHistoryOut);

    foundCount := 0;
    processedCount := 0;
    hatchCount := 0;
    deletedCount := 0;

    // ПЕРВЫЙ ШАГ: Проверяем существование слоя и штриховок на нем (toggle mode)
    // FIRST STEP: Check layer existence and hatches on it (toggle mode)
    if layerName <> '' then begin
      deletedCount := DeleteHatchesOnLayer(layerName);

      // deletedCount = -1: слой не существует, переходим к созданию штриховок
      // deletedCount = -1: layer doesn't exist, proceed to hatch creation
      if deletedCount = -1 then begin
        zcUI.TextMessage('Слой не найден, будет создан / Layer not found, will be created', TMWOHistoryOut);
      end
      // deletedCount > 0: нашли и удалили штриховки - режим HIDE
      // deletedCount > 0: found and deleted hatches - HIDE mode
      else if deletedCount > 0 then begin
        zcUI.TextMessage('Режим HIDE: удалено штриховок / HIDE mode: hatches deleted: ' + IntToStr(deletedCount), TMWOHistoryOut);

        // Перерисовываем для отображения изменений
        // Redraw to show changes
        zcUI.Do_GUIaction(nil, zcMsgUIActionRedraw);

        Result := cmd_ok;
        exit;
      end
      // deletedCount = 0: слой существует, но штриховок нет - создаем штриховки
      // deletedCount = 0: layer exists but no hatches - create hatches
      else begin
        zcUI.TextMessage('Слой существует, но штриховок нет, создаем / Layer exists but no hatches, creating', TMWOHistoryOut);
      end;
    end;

    // ВТОРОЙ ШАГ: Создаем или получаем слой если указан (только если не удалили штриховки)
    // SECOND STEP: Create or get layer if specified (only if we didn't delete hatches)
    pLayer := nil;
    if layerName <> '' then begin
      // Try to create layer using current layer as template
      // Пытаемся создать слой используя текущий слой как шаблон

      // Ищем слой по имени БЕЗ создания нового слоя
      // Find layer by name WITHOUT creating a new one
      pproglayer:=BlockBaseDWG^.LayerTable.getAddres(layerName);//ищем описание слоя в библиотеке
                                                                      //возможно оно найдется, а возможно вернется nil
        // Try to create layer using current layer as template
      // Пытаемся создать слой используя текущий слой как шаблон
      pLayer := drawings.GetCurrentDWG^.LayerTable.createlayerifneedbyname(
        layerName,
        pproglayer
      );

      // If layer still doesn't exist, create it with default parameters
      // Если слой все еще не существует, создаем его с параметрами по умолчанию
      if pLayer = nil then begin
        pLayer := drawings.GetCurrentDWG^.LayerTable.addlayer(
          layerName,           // name / имя
          colorIndex,            // color / цвет
          -1,                 // line weight / толщина линии
          True,               // on / включен
          False,              // lock / заблокирован
          True,               // print / печатать
          'Space highlight layer',  // description / описание
          TLOLoad             // load mode / режим загрузки
        );
        if pLayer <> nil then
          zcUI.TextMessage('Создан слой / Layer created: ' + layerName, TMWOHistoryOut);
      end;
    end;

    // Режим SHOW (показать/создать): создаем штриховки
    // SHOW mode (show/create): create hatches
    zcUI.TextMessage('Режим SHOW: создание штриховок / SHOW mode: creating hatches', TMWOHistoryOut);

    // Снимаем выделение со всех объектов перед началом
    // Deselect all objects before starting
    drawings.GetCurrentDWG^.DeSelectAll;

    // Перебираем все примитивы в чертеже
    // Iterate through all entities in the drawing
    pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pEntity <> nil then
      repeat
        inc(processedCount);

        // Проверяем является ли примитив полилинией
        // Check if entity is a polyline
        if pEntity^.GetObjType = GDBPolyLineID then begin
          // Проверяем содержит ли полилиния указанные переменные
          // Check if polyline contains specified variables
          if EntityHasAnyVariable(pEntity, varList) then begin
            // Выделяем полилинию
            // Select the polyline
            //pEntity^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,
            //               @drawings.GetCurrentDWG^.Selector);
            inc(foundCount);

            // Создаем сплошную штриховку внутри полилинии
            // Create solid hatch inside polyline
            pPolyline := PGDBObjPolyLine(pEntity);
            phatch := CreateSolidHatchFromPolyline(pPolyline, colorIndex, pLayer);

            if phatch <> nil then begin
              // Добавляем штриховку в чертеж
              // Add hatch to drawing
              zcAddEntToCurrentDrawingWithUndo(phatch);
              inc(hatchCount);
            end;
          end;
        end;

        pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pEntity = nil;

    // Выводим результаты
    // Output results
    zcUI.TextMessage('Обработано примитивов / Entities processed: ' + IntToStr(processedCount), TMWOHistoryOut);
    zcUI.TextMessage('Найдено и выделено полилиний / Polylines found and selected: ' + IntToStr(foundCount), TMWOHistoryOut);
    zcUI.TextMessage('Создано штриховок / Hatches created: ' + IntToStr(hatchCount), TMWOHistoryOut);

    // Перерисовываем для отображения выделения и штриховок
    // Redraw to show selection and hatches
    if foundCount > 0 then
      zcUI.Do_GUIaction(nil, zcMsgUIActionRedraw);

  finally
    varList.Free;
  end;

  Result := cmd_ok;
end;

initialization
  // Регистрация команды ShowHideSpace
  // Register the ShowHideSpace command
  CreateZCADCommand(@ShowHideSpace_com,'ShowHideSpace',CADWG,0);
end.
