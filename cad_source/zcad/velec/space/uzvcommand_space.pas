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

{**Модуль реализации команды addZona для работы с зонами}
unit uzvcommand_space;

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
  uzcutils,            //utility functions
                       //утилиты
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
  uzegeometry,         //geometry functions
                       //геометрические функции
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzcenitiesvariablesextender,  //entity variables extender
                                //расширение переменных примитивов
  uzcextdrincludingvolume,      //including volume extender
                                //расширение включающего объема
  uzccominteractivemanipulators, //interactive manipulators
                                  //интерактивные манипуляторы
  varmandef,                     //variable manager definitions
                                 //определения менеджера переменных
  uzestyleslayers,
  uzeconsts,
  UBaseTypeDescriptor;           //base type descriptors
                                 //базовые дескрипторы типов

type
  // Structure to hold polyline and hatch for interactive manipulation
  // Структура для хранения полилинии и штриховки для интерактивного манипулирования
  TSpaceDrawData = record
    ppolyline: PGDBObjPolyLine;
    phatch: PGDBObjHatch;
    hatchColor: Integer;  // Color index for hatch visualization
                          // Индекс цвета для визуализации штриховки
  end;
  PSpaceDrawData = ^TSpaceDrawData;

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

// Helper procedure to parse operands and extract color, layer, and variables
// Вспомогательная процедура для разбора операндов и извлечения цвета, слоя и переменных
procedure ParseOperandsAndAddVariables(
  ppolyline: PGDBObjPolyLine;
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
  colorIndex := 4;  // Default: light blue (cyan)
                    // По умолчанию: светло-голубой (cyan)
  layerName := '';  // Empty means use current layer
                    // Пустое значит использовать текущий слой

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

    // Now process variables starting from index 2
    // Теперь обрабатываем переменные начиная с индекса 2
    VarExt := ppolyline^.specialize GetExtension<TVariablesExtender>;
    if VarExt = nil then
      exit;

    // Process variables in triplets: varname, username, typename
    // Обрабатываем переменные в триплетах: имя_переменной, имя_пользователя, тип
    i := 2;  // Start after color and layer parameters
             // Начинаем после параметров цвета и слоя
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

// Interactive manipulator for space drawing with hatch visualization
// Интерактивный манипулятор для черчения пространства с визуализацией штриховки
procedure InteractiveSpaceManipulator(
  const PInteractiveData: Pointer;
  Point: GDBVertex;
  Click: boolean);
var
  spaceData: PSpaceDrawData absolute PInteractiveData;
  pline: PGDBObjPolyline;
  phatch: PGDBObjHatch;
  dc: TDrawContext;
  vertexCount: integer;
  i: integer;
  pathData: GDBPolyline2DArray;
  v2d: GDBVertex2D;
begin
  if spaceData = nil then
    exit;

  pline := spaceData^.ppolyline;
  phatch := spaceData^.phatch;

  if pline = nil then
    exit;

  // Update polyline as before
  // Обновляем полилинию как раньше
  zcSetEntPropFromCurrentDrawingProp(pline);

  vertexCount := pline^.VertexArrayInOCS.Count;

  if vertexCount > 0 then begin
    if not Click then begin
      // During mouse movement, update preview vertex
      // При движении мыши обновляем вершину предпросмотра
      if vertexCount > 1 then begin
        PGDBVertex(pline^.VertexArrayInOCS.getDataMutable(vertexCount-1))^ := Point;
      end else begin
        pline^.VertexArrayInOCS.PushBackData(Point);
      end;
    end;

    // Update hatch to match polyline if we have at least 3 vertices
    // Обновляем штриховку чтобы соответствовать полилинии если есть минимум 3 вершины
    if (phatch <> nil) and (vertexCount >= 2) then begin
      // Clear existing path
      // Очищаем существующий путь
      phatch^.Path.Clear;

      // Create new path from polyline vertices
      // Создаем новый путь из вершин полилинии
      pathData.init(vertexCount, True);

      for i := 0 to vertexCount - 1 do begin
        v2d.x := pline^.VertexArrayInOCS.getData(i).x;
        v2d.y := pline^.VertexArrayInOCS.getData(i).y;
        pathData.PushBackData(v2d);
      end;

      phatch^.Path.paths.PushBackData(pathData);

      // Set hatch properties: solid fill with specified color
      // Устанавливаем свойства штриховки: сплошная заливка с указанным цветом
      zcSetEntPropFromCurrentDrawingProp(phatch);
      phatch^.vp.Color := spaceData^.hatchColor; // Use color from data structure
                                                  // Используем цвет из структуры данных
      phatch^.PPattern := nil; // Solid hatch (no pattern)
                               // Сплошная штриховка (без паттерна)

      // Format hatch entity
      // Форматируем примитив штриховки
      dc := drawings.GetCurrentDWG^.CreateDrawingRC;
      phatch^.FormatEntity(drawings.GetCurrentDWG^, dc);
    end;

    // Format polyline entity
    // Форматируем примитив полилинии
    dc := drawings.GetCurrentDWG^.CreateDrawingRC;
    pline^.FormatEntity(drawings.GetCurrentDWG^, dc);
  end;
end;

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  ppolyline: PGDBObjPolyLine;
  phatch: PGDBObjHatch;
  spaceData: TSpaceDrawData;
  point: GDBVertex;
  firstPoint: GDBVertex;
  getResult: TGetResult;
  pointCount: integer;
  colorIndex: Integer;
  layerName: string;
  pLayer: PGDBLayerProp;
  params: TStringList;
  pproglayer:PGDBLayerProp;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда addSpace',TMWOHistoryOut);

  // Early parse of color and layer from operands (before drawing starts)
  // Ранний разбор цвета и слоя из операндов (до начала черчения)
  colorIndex := 4;  // Default: light blue (cyan) / По умолчанию: светло-голубой (cyan)
  layerName := '';  // Empty means use current layer / Пустое значит использовать текущий слой

  if Trim(operands) <> '' then begin
    params := TStringList.Create;
    try
      params.Delimiter := ',';
      params.StrictDelimiter := True;
      params.DelimitedText := operands;

      // Extract color if available
      // Извлекаем цвет если доступен
      if params.Count >= 1 then begin
        try
          colorIndex := StrToInt(Trim(params[0]));
          if (colorIndex < 1) or (colorIndex > 255) then
            colorIndex := 4;
        except
          colorIndex := 4;
        end;
      end;

      // Extract layer name if available
      // Извлекаем имя слоя если доступно
      if params.Count >= 2 then begin
        layerName := Trim(params[1]);
        if (Length(layerName) >= 2) and (layerName[1] = '''') and (layerName[Length(layerName)] = '''') then
          layerName := Copy(layerName, 2, Length(layerName) - 2);
      end;
    finally
      params.Free;
    end;
  end;

  // Получаем первую точку
  // Get first point
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint, firstPoint) = GRNormal then begin
    // Создаем полилинию
    // Create polyline
    ppolyline := GDBObjPolyline.CreateInstance;
    zcSetEntPropFromCurrentDrawingProp(ppolyline);

    // Устанавливаем свойства полилинии
    // Set polyline properties
    ppolyline^.Closed := True;  // Полилиния замкнута / Polyline is closed

    // Создаем штриховку для визуализации процесса построения
    // Create hatch for visualization of construction process
    phatch := GDBObjHatch.CreateInstance;
    zcSetEntPropFromCurrentDrawingProp(phatch);

    // Use color from operands parsing
    // Используем цвет из разбора операндов
    phatch^.vp.Color := colorIndex;
    phatch^.PPattern := nil; // Solid hatch
                             // Сплошная штриховка

    // Добавляем первую точку
    // Add first point
    ppolyline^.VertexArrayInOCS.PushBackData(firstPoint);
    pointCount := 1;

    // Добавляем полилинию и штриховку в конструкторскую область для визуализации
    // Add polyline and hatch to construct root for visualization
    zcAddEntToCurrentDrawingConstructRoot(ppolyline);
    zcAddEntToCurrentDrawingConstructRoot(phatch);

    // Prepare data for interactive manipulator
    // Подготавливаем данные для интерактивного манипулятора
    spaceData.ppolyline := ppolyline;
    spaceData.phatch := phatch;
    spaceData.hatchColor := colorIndex;

    // Интерактивный ввод остальных точек
    // Interactive input of remaining points
    point := firstPoint;
    repeat
      // Используем интерактивный манипулятор для следующей точки
      // Use interactive manipulator for next point
      InteractiveSpaceManipulator(@spaceData, point, False);

      getResult := commandmanager.Get3DPointInteractive(
        rscmSpecifyNextPoint + ' (Enter to finish):',
        point,
        @InteractiveSpaceManipulator,
        @spaceData
      );

      if getResult = GRNormal then begin
        // Добавляем следующую точку
        // Add next point
        ppolyline^.VertexArrayInOCS.PushBackData(point);
        inc(pointCount);
      end;
    until getResult <> GRNormal;

    // Проверяем что введено минимум 3 точки для создания пространства
    // Check that at least 3 points were entered to create a space
    if pointCount >= 3 then begin
      // Добавляем расширения к полилинии перед сохранением
      // Add extensions to polyline before saving

      // Добавляем расширение extdrVariables для хранения переменных
      // Add extdrVariables extension for storing variables
      if ppolyline^.specialize GetExtension<TVariablesExtender> = nil then
        AddVariablesToEntity(ppolyline);

      // Добавляем расширение extdrIncludingVolume для работы с объемом
      // Add extdrIncludingVolume extension for volume operations
      if ppolyline^.specialize GetExtension<TIncludingVolumeExtender> = nil then
        AddVolumeExtenderToEntity(ppolyline);

      // Парсим операнды и добавляем переменные к полилинии
      // Parse operands and add variables to polyline
      // Also extracts color and layer from operands
      // Также извлекает цвет и слой из операндов
      ParseOperandsAndAddVariables(ppolyline, operands, colorIndex, layerName);

      // Set layer if specified
      // Устанавливаем слой если указан
      if layerName <> '' then begin
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
            'Space layer',      // description / описание
            TLOLoad             // load mode / режим загрузки
          );
          zcUI.TextMessage('Создан слой / Layer created: ' + layerName, TMWOHistoryOut);
        end;

        // Set the layer for the polyline
        // Устанавливаем слой для полилинии
        if pLayer <> nil then
          ppolyline^.vp.Layer := pLayer;
      end;

      // Удаляем штриховку из конструкторской области (она была только для визуализации)
      // Remove hatch from construct root (it was only for visualization)
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.RemoveData(phatch);

      // Копируем только полилинию из конструкторской области в чертеж с Undo
      // Copy only polyline from construct root to drawing with Undo
      zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('addSpace');

      // Выделяем созданную полилинию для последующего редактирования в инспекторе
      // Select created polyline for subsequent editing in inspector
      ppolyline^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,
                        @drawings.GetCurrentDWG^.Selector);

      zcUI.TextMessage('Пространство создано / Space created', TMWOHistoryOut);
    end else begin
      // Если точек меньше 3, очищаем конструкторскую область
      // If less than 3 points, clear construct root
      drawings.GetCurrentDWG^.FreeConstructionObjects;
      zcUI.TextMessage('Отменено: необходимо минимум 3 точки / Cancelled: minimum 3 points required', TMWOHistoryOut);
    end;
  end;

  result := cmd_ok;
end;

initialization
  // Регистрация команды addSpace
  // Register the addSpace command
  CreateZCADCommand(@addSpace_com,'addSpace',CADWG,0);
end.
