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
  UBaseTypeDescriptor;           //base type descriptors
                                 //базовые дескрипторы типов

type
  // Structure to hold polyline and hatch for interactive manipulation
  // Структура для хранения полилинии и штриховки для интерактивного манипулирования
  TSpaceDrawData = record
    ppolyline: PGDBObjPolyLine;
    phatch: PGDBObjHatch;
  end;
  PSpaceDrawData = ^TSpaceDrawData;

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

// Helper procedure to parse and add variables from operands string
// Вспомогательная процедура для разбора и добавления переменных из строки операндов
procedure ParseAndAddVariables(ppolyline: PGDBObjPolyLine; const operands: TCommandOperands);
var
  VarExt: TVariablesExtender;
  params: TStringList;
  i: integer;
  varname, username, typename: string;
  vd: vardesk;
begin
  // Check if we have operands
  // Проверяем наличие операндов
  if Trim(operands) = '' then
    exit;

  VarExt := ppolyline^.GetExtension<TVariablesExtender>;
  if VarExt = nil then
    exit;

  // Split operands by comma
  // Разделяем операнды по запятой
  params := TStringList.Create;
  try
    params.Delimiter := ',';
    params.StrictDelimiter := True;
    params.DelimitedText := operands;

    // Process variables in triplets: varname, username, typename
    // Обрабатываем переменные в триплетах: имя_переменной, имя_пользователя, тип
    i := 0;
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

      // Set hatch properties: solid fill, light blue color with transparency
      // Устанавливаем свойства штриховки: сплошная заливка, светло-голубой цвет с прозрачностью
      zcSetEntPropFromCurrentDrawingProp(phatch);
      phatch^.vp.Color := 4; // Light blue color index (cyan)
                             // Индекс светло-голубого цвета (cyan)
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
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда addSpace',TMWOHistoryOut);

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
    phatch^.vp.Color := 4; // Light blue color (cyan)
                           // Светло-голубой цвет (cyan)
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
      ParseAndAddVariables(ppolyline, operands);

      // Удаляем штриховку из конструкторской области (она была только для визуализации)
      // Remove hatch from construct root (it was only for visualization)
      drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.RemoveData(phatch);

      // Копируем только полилинию из конструкторской области в чертеж с Undo
      // Copy only polyline from construct root to drawing with Undo
      zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('addSpace');

      // Выделяем созданную полилинию для последующего редактирования в инспекторе
      // Select created polyline for subsequent editing in inspector
      ppolyline^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,
                        drawings.CurrentDWG^.Selector);

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
