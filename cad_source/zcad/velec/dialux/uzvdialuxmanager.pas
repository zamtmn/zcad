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

{**Модуль управления интеграцией с DIALux EVO}
unit uzvdialuxmanager;

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

  uzclog,              //log system
                       //система логирования
  uzcinterface,        //interface utilities
                       //утилиты интерфейса
  uzcdrawings,         //Drawings manager
                       //Менеджер чертежей
  uzcutils,            //utility functions
                       //утилиты
  uzeentity,           //base entity
                       //базовый примитив
  uzeentpolyline,      //polyline entity
                       //примитив полилиния
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzcenitiesvariablesextender,  //entity variables extender
                                //расширение переменных примитивов
  gzctnrVectorTypes,uzeconsts,uzegeometrytypes,
  varmandef;                     //variable manager definitions
                                 //определения менеджера переменных

type
  {**Класс для управления экспортом/импортом данных DIALux}
  {**Class for managing DIALux data export/import}
  TZVDIALuxManager = class
  private
    FFileName: string;
    FSpacesList: TList;

    {**Проверка находится ли точка внутри полилинии (ray casting алгоритм)}
    {**Check if point is inside polyline (ray casting algorithm)}
    function PointInPolyline(const point: GDBVertex; pPolyline: PGDBObjPolyLine): boolean;

    {**Проверка полностью ли одна полилиния находится внутри другой}
    {**Check if one polyline is completely inside another}
    function PolylineInsidePolyline(pInner: PGDBObjPolyLine; pOuter: PGDBObjPolyLine): boolean;

  public
    constructor Create;
    destructor Destroy; override;

    {**Экспорт в формат STF}
    {**Export to STF format}
    function ExportToSTF(const AFileName: string): boolean;

    {**Импорт из формата EVO}
    {**Import from EVO format}
    function ImportFromEVO(const AFileName: string): boolean;

    {**Сбор информации о пространствах из чертежа}
    {**Collect information about spaces from drawing}
    procedure CollectSpacesFromDrawing;

    {**Построение иерархии пространств математическими методами}
    {**Build space hierarchy using mathematical methods}
    procedure BuildSpaceHierarchy;

    {**Очистка списка пространств}
    {**Clear spaces list}
    procedure ClearSpaces;

    {**Вывод структуры пространств в zcUI}
    {**Display spaces structure in zcUI}
    procedure DisplaySpacesStructure;

    property FileName: string read FFileName write FFileName;
    property SpacesList: TList read FSpacesList;
  end;

  {**Структура для хранения информации о пространстве}
  {**Structure for storing space information}
  TZVSpaceInfo = record
    RoomNumber: string;           // Номер помещения / Room number
    RoomPolyline: PGDBObjPolyLine; // Указатель на полилинию помещения / Pointer to room polyline
    Floor: string;                 // Этаж / Floor
    FloorHeight: double;           // Высота этажа / Floor height
    FloorPolyline: PGDBObjPolyLine; // Указатель на полилинию этажа / Pointer to floor polyline
    Building: string;              // Здание / Building
    BuildingPolyline: PGDBObjPolyLine; // Указатель на полилинию здания / Pointer to building polyline

    // Сохраняем старые поля для совместимости
    // Keep old fields for compatibility
    Name: string;
    Height: double;
    Polyline: PGDBObjPolyLine;
    Variables: TStringList;
  end;
  PZVSpaceInfo = ^TZVSpaceInfo;

implementation

constructor TZVDIALuxManager.Create;
begin
  inherited Create;
  FSpacesList := TList.Create;
  FFileName := '';
end;

destructor TZVDIALuxManager.Destroy;
begin
  ClearSpaces;
  FSpacesList.Free;
  inherited Destroy;
end;

procedure TZVDIALuxManager.ClearSpaces;
var
  i: integer;
  pSpaceInfo: PZVSpaceInfo;
begin
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);
    if pSpaceInfo <> nil then begin
      if pSpaceInfo^.Variables <> nil then
        pSpaceInfo^.Variables.Free;
      Dispose(pSpaceInfo);
    end;
  end;
  FSpacesList.Clear;
end;

procedure TZVDIALuxManager.CollectSpacesFromDrawing;
var
  pEntity: PGDBObjEntity;
  ir: itrec;
  ppolyline: PGDBObjPolyLine;
  VarExt: TVariablesExtender;
  pSpaceInfo: PZVSpaceInfo;
  spaceCount: integer;
  pvd: pvardesk;
  spaceRoom, spaceFloor, spaceBuilding: string;
  floorHeight: double;
begin
  // Очищаем предыдущий список пространств
  // Clear previous spaces list
  ClearSpaces;

  spaceCount := 0;

  zcUI.TextMessage('Сбор всех полилиний с расширениями пространств...', TMWOHistoryOut);
  zcUI.TextMessage('Collecting all polylines with space extensions...', TMWOHistoryOut);

  // Перебираем все примитивы в чертеже
  // Iterate through all entities in the drawing
  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity <> nil then
    repeat
      // Проверяем является ли примитив полилинией
      // Check if entity is a polyline
      if pEntity^.GetObjType = GDBPolyLineID then begin
        ppolyline := PGDBObjPolyLine(pEntity);

        // Проверяем что полилиния замкнута
        // Check if polyline is closed
        if ppolyline^.Closed then begin
          // Получаем расширение переменных
          // Get variables extender
          VarExt := ppolyline^.specialize GetExtension<TVariablesExtender>;

          // Пропускаем полилинии без переменных
          // Skip polylines without variables
          if VarExt = nil then begin
            pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
            continue;
          end;

          // Проверяем наличие переменных пространств
          // Check for space variables
          spaceRoom := '';
          spaceFloor := '';
          spaceBuilding := '';

          pvd := VarExt.entityunit.FindVariable('Space_Room');
          if (pvd <> nil) then
            spaceRoom := pstring(pvd^.data.Addr.Instance)^;

          pvd := VarExt.entityunit.FindVariable('space_Floor');
          if (pvd <> nil) then
            spaceFloor := pstring(pvd^.data.Addr.Instance)^;

          pvd := VarExt.entityunit.FindVariable('space_Building');
          if (pvd <> nil) then
            spaceBuilding := pstring(pvd^.data.Addr.Instance)^;

          // Если полилиния содержит Space_Room (помещение)
          // If polyline contains Space_Room (room)
          if spaceRoom <> '' then begin
            New(pSpaceInfo);
            pSpaceInfo^.RoomNumber := spaceRoom;
            pSpaceInfo^.RoomPolyline := ppolyline;
            pSpaceInfo^.Floor := '-1';           // Временно заполняем -1
            pSpaceInfo^.FloorHeight := -1;       // Временно заполняем -1
            pSpaceInfo^.FloorPolyline := nil;
            pSpaceInfo^.Building := '-1';        // Временно заполняем -1
            pSpaceInfo^.BuildingPolyline := nil;

            // Сохраняем для совместимости
            pSpaceInfo^.Name := spaceRoom;
            pSpaceInfo^.Height := 3.0;
            pSpaceInfo^.Polyline := ppolyline;
            pSpaceInfo^.Variables := TStringList.Create;

            FSpacesList.Add(pSpaceInfo);
            inc(spaceCount);
          end
          // Если полилиния содержит space_Floor (этаж)
          // If polyline contains space_Floor (floor)
          else if spaceFloor <> '' then begin
            New(pSpaceInfo);
            pSpaceInfo^.RoomNumber := '';        // Не заполняем
            pSpaceInfo^.RoomPolyline := nil;
            pSpaceInfo^.Floor := spaceFloor;

            // Пытаемся получить высоту этажа из переменной FloorHeight
            // Try to get floor height from FloorHeight variable
            floorHeight := 3.0; // Значение по умолчанию
            pvd := VarExt.entityunit.FindVariable('FloorHeight');
            if (pvd <> nil) and (pvd^.data.PTD^.TypeName = 'GDBDouble') then
              floorHeight := PDouble(pvd^.data.Addr.Instance)^
            else if (pvd <> nil) and (pvd^.data.PTD^.TypeName = 'GDBInteger') then
              floorHeight := PInteger(pvd^.data.Addr.Instance)^;

            pSpaceInfo^.FloorHeight := floorHeight;
            pSpaceInfo^.FloorPolyline := ppolyline;
            pSpaceInfo^.Building := '-1';        // Временно заполняем -1
            pSpaceInfo^.BuildingPolyline := nil;

            // Сохраняем для совместимости
            pSpaceInfo^.Name := spaceFloor;
            pSpaceInfo^.Height := floorHeight;
            pSpaceInfo^.Polyline := ppolyline;
            pSpaceInfo^.Variables := TStringList.Create;

            FSpacesList.Add(pSpaceInfo);
            inc(spaceCount);
          end
          // Если полилиния содержит space_Building (здание)
          // If polyline contains space_Building (building)
          else if spaceBuilding <> '' then begin
            New(pSpaceInfo);
            pSpaceInfo^.RoomNumber := '';        // Не заполняем
            pSpaceInfo^.RoomPolyline := nil;
            pSpaceInfo^.Floor := '';             // Не заполняем
            pSpaceInfo^.FloorHeight := -1;       // Не заполняем
            pSpaceInfo^.FloorPolyline := nil;
            pSpaceInfo^.Building := spaceBuilding;
            pSpaceInfo^.BuildingPolyline := ppolyline;

            // Сохраняем для совместимости
            pSpaceInfo^.Name := spaceBuilding;
            pSpaceInfo^.Height := 3.0;
            pSpaceInfo^.Polyline := ppolyline;
            pSpaceInfo^.Variables := TStringList.Create;

            FSpacesList.Add(pSpaceInfo);
            inc(spaceCount);
          end;
        end;
      end;

      pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pEntity = nil;

  zcUI.TextMessage('Собрано пространств / Spaces collected: ' + IntToStr(spaceCount), TMWOHistoryOut);
end;

function TZVDIALuxManager.PointInPolyline(const point: GDBVertex; pPolyline: PGDBObjPolyLine): boolean;
var
  i, j: integer;
  vertexCount: integer;
  vi, vj: GDBVertex;
  intersectCount: integer;
begin
  Result := False;

  if pPolyline = nil then
    exit;

  vertexCount := pPolyline^.VertexArrayInOCS.Count;

  if vertexCount < 3 then
    exit;

  // Алгоритм ray casting: подсчет пересечений горизонтального луча с ребрами полигона
  // Ray casting algorithm: count intersections of horizontal ray with polygon edges
  intersectCount := 0;
  j := vertexCount - 1;

  for i := 0 to vertexCount - 1 do begin
    vi := pPolyline^.VertexArrayInOCS.getData(i);
    vj := pPolyline^.VertexArrayInOCS.getData(j);

    // Проверяем пересекает ли горизонтальный луч от точки ребро (vi, vj)
    // Check if horizontal ray from point intersects edge (vi, vj)
    if ((vi.y > point.y) <> (vj.y > point.y)) and
       (point.x < (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x) then
      inc(intersectCount);

    j := i;
  end;

  // Точка внутри если количество пересечений нечетное
  // Point is inside if intersection count is odd
  Result := (intersectCount mod 2) = 1;
end;

function TZVDIALuxManager.PolylineInsidePolyline(pInner: PGDBObjPolyLine; pOuter: PGDBObjPolyLine): boolean;
var
  i: integer;
  vertexCount: integer;
  vertex: GDBVertex;
  allInside: boolean;
begin
  Result := False;

  if (pInner = nil) or (pOuter = nil) then
    exit;

  if pInner = pOuter then
    exit;

  vertexCount := pInner^.VertexArrayInOCS.Count;

  if vertexCount < 3 then
    exit;

  // Проверяем все ли вершины внутренней полилинии находятся внутри внешней
  // Check if all vertices of inner polyline are inside outer polyline
  allInside := True;

  for i := 0 to vertexCount - 1 do begin
    vertex := pInner^.VertexArrayInOCS.getData(i);
    if not PointInPolyline(vertex, pOuter) then begin
      allInside := False;
      break;
    end;
  end;

  Result := allInside;
end;

procedure TZVDIALuxManager.BuildSpaceHierarchy;
var
  i, j: integer;
  pSpaceInfo: PZVSpaceInfo;
  pOtherSpace: PZVSpaceInfo;
begin
  zcUI.TextMessage('Построение иерархии пространств математическими методами...', TMWOHistoryOut);
  zcUI.TextMessage('Building space hierarchy using mathematical methods...', TMWOHistoryOut);

  // Для каждого пространства определяем родительские пространства
  // For each space, determine parent spaces
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Если это помещение (RoomPolyline <> nil), ищем этаж и здание
    // If this is a room (RoomPolyline <> nil), find floor and building
    if pSpaceInfo^.RoomPolyline <> nil then begin
      for j := 0 to FSpacesList.Count - 1 do begin
        if i = j then
          continue;

        pOtherSpace := PZVSpaceInfo(FSpacesList[j]);

        // Проверяем находится ли помещение внутри этажа
        // Check if room is inside floor
        if (pOtherSpace^.FloorPolyline <> nil) and
           PolylineInsidePolyline(pSpaceInfo^.RoomPolyline, pOtherSpace^.FloorPolyline) then begin
          pSpaceInfo^.Floor := pOtherSpace^.Floor;
          pSpaceInfo^.FloorHeight := pOtherSpace^.FloorHeight;
          pSpaceInfo^.FloorPolyline := pOtherSpace^.FloorPolyline;
        end;

        // Проверяем находится ли помещение внутри здания
        // Check if room is inside building
        if (pOtherSpace^.BuildingPolyline <> nil) and
           PolylineInsidePolyline(pSpaceInfo^.RoomPolyline, pOtherSpace^.BuildingPolyline) then begin
          pSpaceInfo^.Building := pOtherSpace^.Building;
          pSpaceInfo^.BuildingPolyline := pOtherSpace^.BuildingPolyline;
        end;
      end;
    end
    // Если это этаж (FloorPolyline <> nil), ищем здание
    // If this is a floor (FloorPolyline <> nil), find building
    else if pSpaceInfo^.FloorPolyline <> nil then begin
      for j := 0 to FSpacesList.Count - 1 do begin
        if i = j then
          continue;

        pOtherSpace := PZVSpaceInfo(FSpacesList[j]);

        // Проверяем находится ли этаж внутри здания
        // Check if floor is inside building
        if (pOtherSpace^.BuildingPolyline <> nil) and
           PolylineInsidePolyline(pSpaceInfo^.FloorPolyline, pOtherSpace^.BuildingPolyline) then begin
          pSpaceInfo^.Building := pOtherSpace^.Building;
          pSpaceInfo^.BuildingPolyline := pOtherSpace^.BuildingPolyline;
        end;
      end;
    end;
    // Для здания (BuildingPolyline <> nil) больше ничего заполнять не нужно
    // For building (BuildingPolyline <> nil) nothing else needs to be filled
  end;

  zcUI.TextMessage('Иерархия построена / Hierarchy built', TMWOHistoryOut);
end;

function TZVDIALuxManager.ExportToSTF(const AFileName: string): boolean;
var
  stfFile: TextFile;
  i, j: integer;
  pSpaceInfo: PZVSpaceInfo;
  ppolyline: PGDBObjPolyLine;
  vertex: GDBVertex;
begin
  Result := False;

  try
    // Проверяем что есть данные для экспорта
    // Check if there is data to export
    if FSpacesList.Count = 0 then begin
      zcUI.TextMessage('Нет пространств для экспорта / No spaces to export', TMWOHistoryOut);
      Exit;
    end;

    // Открываем файл для записи
    // Open file for writing
    AssignFile(stfFile, AFileName);
    Rewrite(stfFile);

    try
      // Заголовок STF файла
      // STF file header
      WriteLn(stfFile, 'STFF V02.00.00');
      WriteLn(stfFile, 'PROJECT "' + ChangeFileExt(ExtractFileName(AFileName), '') + '"');
      WriteLn(stfFile, '');

      // Экспортируем каждое пространство
      // Export each space
      for i := 0 to FSpacesList.Count - 1 do begin
        pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);
        ppolyline := pSpaceInfo^.Polyline;

        WriteLn(stfFile, 'ROOM "' + pSpaceInfo^.Name + '"');
        WriteLn(stfFile, 'HEIGHT ' + FloatToStr(pSpaceInfo^.Height));
        WriteLn(stfFile, 'SPACE');

        // Записываем координаты полилинии
        // Write polyline coordinates
        for j := 0 to ppolyline^.VertexArrayInOCS.Count - 1 do begin
          vertex := ppolyline^.VertexArrayInOCS.getData(j);
          WriteLn(stfFile, Format('VERTEX %.3f %.3f', [vertex.x, vertex.y]));
        end;

        WriteLn(stfFile, 'ENDSPACE');
        WriteLn(stfFile, 'ENDROOM');
        WriteLn(stfFile, '');
      end;

      WriteLn(stfFile, 'ENDPROJECT');

      Result := True;
      zcUI.TextMessage('Экспорт в STF завершен / STF export completed: ' + AFileName, TMWOHistoryOut);

    finally
      CloseFile(stfFile);
    end;

  except
    on E: Exception do begin
      zcUI.TextMessage('Ошибка экспорта / Export error: ' + E.Message, TMWOHistoryOut);
      Result := False;
    end;
  end;
end;

function TZVDIALuxManager.ImportFromEVO(const AFileName: string): boolean;
begin
  // TODO: Реализовать импорт из формата EVO
  // TODO: Implement import from EVO format
  Result := False;
  zcUI.TextMessage('Импорт из EVO пока не реализован / EVO import not yet implemented', TMWOHistoryOut);
end;

procedure TZVDIALuxManager.DisplaySpacesStructure;
var
  i: integer;
  pSpaceInfo: PZVSpaceInfo;
  msg: string;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('=== Структура пространств / Spaces Structure ===', TMWOHistoryOut);
  zcUI.TextMessage('Всего пространств / Total spaces: ' + IntToStr(FSpacesList.Count), TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    zcUI.TextMessage('--- Пространство / Space #' + IntToStr(i + 1) + ' ---', TMWOHistoryOut);

    // Номер помещения / Room number
    msg := '  Номер помещения / Room number: ' + pSpaceInfo^.RoomNumber;
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Указатель на полилинию помещения / Pointer to room polyline
    if pSpaceInfo^.RoomPolyline <> nil then
      msg := '  Указатель на полилинию помещения / Room polyline: 0x' + IntToHex(PtrUInt(pSpaceInfo^.RoomPolyline), 16)
    else
      msg := '  Указатель на полилинию помещения / Room polyline: nil';
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Этаж / Floor
    msg := '  Этаж / Floor: ' + pSpaceInfo^.Floor;
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Высота этажа / Floor Height
    if pSpaceInfo^.FloorHeight > 0 then begin
      msg := '  Высота этажа / Floor Height: ' + FloatToStr(pSpaceInfo^.FloorHeight);
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

    // Указатель на полилинию этажа / Pointer to floor polyline
    if pSpaceInfo^.FloorPolyline <> nil then
      msg := '  Указатель на полилинию этажа / Floor polyline: 0x' + IntToHex(PtrUInt(pSpaceInfo^.FloorPolyline), 16)
    else
      msg := '  Указатель на полилинию этажа / Floor polyline: nil';
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Здание / Building
    msg := '  Здание / Building: ' + pSpaceInfo^.Building;
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Указатель на полилинию здания / Pointer to building polyline
    if pSpaceInfo^.BuildingPolyline <> nil then
      msg := '  Указатель на полилинию здания / Building polyline: 0x' + IntToHex(PtrUInt(pSpaceInfo^.BuildingPolyline), 16)
    else
      msg := '  Указатель на полилинию здания / Building polyline: nil';
    zcUI.TextMessage(msg, TMWOHistoryOut);

    zcUI.TextMessage('', TMWOHistoryOut);
  end;

  zcUI.TextMessage('=== Конец структуры / End of Structure ===', TMWOHistoryOut);
end;

end.
