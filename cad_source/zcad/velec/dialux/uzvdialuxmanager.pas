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
  uzeentdevice,        //device entity (luminaires)
                       //примитив устройство (светильники)
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzcenitiesvariablesextender,  //entity variables extender
                                //расширение переменных примитивов
  gzctnrVectorTypes,uzeconsts,uzegeometrytypes,
  varmandef;                     //variable manager definitions
                                 //определения менеджера переменных

const
  // Константы для значений по умолчанию
  // Default value constants
  UNDEFINED_VALUE = '-1';                // Неопределенное строковое значение
  UNDEFINED_NUMERIC_VALUE = -1.0;        // Неопределенное числовое значение
  DEFAULT_FLOOR_HEIGHT = 3.0;            // Высота этажа по умолчанию (м)
  DEFAULT_ROOM_HEIGHT = 2.8;             // Высота помещения по умолчанию (м)
  DEFAULT_LUMINAIRE_POWER = 35.0;        // Мощность светильника по умолчанию (Вт)
  DEFAULT_LAMPS_COUNT = 1;               // Количество ламп по умолчанию

  // Имена переменных в расширениях полилиний
  // Variable names in polyline extensions
  VAR_SPACE_ROOM = 'Space_Room';         // Переменная для помещения
  VAR_SPACE_FLOOR = 'space_Floor';       // Переменная для этажа
  VAR_SPACE_BUILDING = 'space_Building'; // Переменная для здания
  VAR_FLOOR_HEIGHT = 'space_FloorHeight';// Переменная для высоты этажа

  // Имена переменных в устройствах (светильниках)
  // Variable names in devices (luminaires)
  VAR_LOCATION_FLOORMARK = 'LOCATION_floormark'; // Отметка этажа (высота в мм)

  // Константы конвертации единиц измерения
  // Unit conversion constants
  MM_TO_METERS = 0.001;                  // Конвертация миллиметров в метры

  // Константы формата STF для DIALux EVO
  // STF format constants for DIALux EVO
  STF_VERSION = '1.0.5';                 // Версия формата STF
  STF_PROGRAM_NAME = 'ZCAD';             // Имя программы экспортера
  STF_PROGRAM_VERSION = '1.0';           // Версия программы
  STF_WORKING_PLANE_HEIGHT = 0.8;        // Высота рабочей плоскости (м)
  STF_CEILING_REFLECTANCE = 0.75;        // Коэффициент отражения потолка
  STF_LUMINAIRE_MOUNTING_TYPE = 1;       // Тип монтажа светильника
  STF_LUMINAIRE_SHAPE = 0;               // Форма светильника
  STF_LUMINAIRE_DEFAULT_FLUX = 0;        // Световой поток по умолчанию (лм)

type
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
    Luminaires: TList;            // Список светильников в помещении / List of luminaires in room

    // Сохраняем старые поля для совместимости
    // Keep old fields for compatibility
    Name: string;
    Height: double;
    Polyline: PGDBObjPolyLine;
    Variables: TStringList;
  end;
  PZVSpaceInfo = ^TZVSpaceInfo;

  {**Информация о светильнике}
  {**Luminaire information}
  TZVLuminaireInfo = record
    DeviceName: string;              // Имя устройства / Device name
    DeviceType: string;              // Тип светильника / Luminaire type
    Position: GDBVertex;             // Позиция в мировых координатах / Position in WCS
    Rotation: double;                // Угол поворота / Rotation angle
    Load: double;                    // Мощность (Вт) / Power load (W)
    NrLamps: integer;                // Количество ламп / Number of lamps
    MountingHeight: double;          // Высота размещения (м) / Mounting height (m)
    RoomIndex: integer;              // Индекс помещения / Room index (-1 если не найдено)
    Device: PGDBObjDevice;           // Указатель на устройство / Pointer to device
  end;
  PZVLuminaireInfo = ^TZVLuminaireInfo;

  {**Класс для управления экспортом/импортом данных DIALux}
  {**Class for managing DIALux data export/import}
  TZVDIALuxManager = class
  private
    FFileName: string;
    FSpacesList: TList;
    FLuminairesList: TList;
    FOriginX: double;  // Координата X начала координат / X coordinate of origin
    FOriginY: double;  // Координата Y начала координат / Y coordinate of origin

    {**Проверка находится ли точка внутри полилинии (ray casting алгоритм)}
    {**Check if point is inside polyline (ray casting algorithm)}
    function PointInPolyline(const point: GDBVertex; pPolyline: PGDBObjPolyLine): boolean;

    {**Проверка полностью ли одна полилиния находится внутри другой}
    {**Check if one polyline is completely inside another}
    function PolylineInsidePolyline(pInner: PGDBObjPolyLine; pOuter: PGDBObjPolyLine): boolean;

    {**Получить строковое значение переменной из расширения}
    {**Get string variable value from extension}
    function GetStringVariable(VarExt: TVariablesExtender; const VarName: string): string;

    {**Получить числовое значение переменной из расширения}
    {**Get numeric variable value from extension}
    function GetNumericVariable(VarExt: TVariablesExtender; const VarName: string;
      DefaultValue: double): double;

    function GetDoubleVariable(VarExt: TVariablesExtender;
  const VarName: string; DefaultValue: double): double;

    {**Получить высоту размещения светильника из устройства в метрах}
    {**Get luminaire mounting height from device in meters}
    function GetMountingHeightFromDevice(pDevice: PGDBObjDevice): double;

    {**Проверить является ли полилиния замкнутой}
    {**Check if polyline is closed}
    function IsPolylineClosed(pPolyline: PGDBObjPolyLine): boolean;

    {**Создать структуру информации о помещении}
    {**Create room space info structure}
    function CreateRoomSpaceInfo(pPolyline: PGDBObjPolyLine;
      const RoomNumber: string): PZVSpaceInfo;

    {**Создать структуру информации об этаже}
    {**Create floor space info structure}
    function CreateFloorSpaceInfo(pPolyline: PGDBObjPolyLine;
      const FloorName: string; FloorHeight: double): PZVSpaceInfo;

    {**Создать структуру информации о здании}
    {**Create building space info structure}
    function CreateBuildingSpaceInfo(pPolyline: PGDBObjPolyLine;
      const BuildingName: string): PZVSpaceInfo;

    {**Обработать полилинию как пространство}
    {**Process polyline as space}
    procedure ProcessPolylineAsSpace(pPolyline: PGDBObjPolyLine;
      var spaceCount: integer);

    {**Проверить есть ли выбранные этажи в списке пространств}
    {**Check if there are any selected floors in spaces list}
    function HasSelectedFloors: boolean;

    {**Проверить принадлежит ли помещение к одному из выбранных этажей}
    {**Check if room belongs to one of the selected floors}
    function RoomBelongsToSelectedFloor(pSpaceInfo: PZVSpaceInfo): boolean;

    {**Подсчитать количество помещений в списке пространств}
    {**Count number of rooms in spaces list}
    function CountRooms: integer;

    {**Подсчитать количество помещений принадлежащих выбранным этажам}
    {**Count number of rooms belonging to selected floors}
    function CountRoomsInSelectedFloors: integer;

    {**Собрать список уникальных типов светильников}
    {**Collect list of unique luminaire types}
    procedure CollectUniqueLuminaireTypes(lumTypes: TStringList);

    {**Записать заголовок STF файла (секция VERSION)}
    {**Write STF file header (VERSION section)}
    procedure WriteSTFHeader(var stfFile: TextFile);

    {**Записать секцию PROJECT в STF файл}
    {**Write PROJECT section to STF file}
    procedure WriteSTFProjectSection(var stfFile: TextFile; const projectName: string;
      const currentDate: string; roomCount: integer; floorCount: integer);

    {**Записать координаты точек полилинии помещения}
    {**Write room polyline points coordinates}
    procedure WriteRoomPolylinePoints(var stfFile: TextFile; pPolyline: PGDBObjPolyLine);

    {**Записать информацию о светильниках в помещении}
    {**Write luminaires information in room}
    procedure WriteRoomLuminaires(var stfFile: TextFile; pSpaceInfo: PZVSpaceInfo;
      lumTypes: TStringList);

    {**Записать информацию об одном помещении в STF файл}
    {**Write single room information to STF file}
    procedure WriteSTFRoom(var stfFile: TextFile; pSpaceInfo: PZVSpaceInfo;
      roomIndex: integer; lumTypes: TStringList);

    {**Записать определения типов светильников}
    {**Write luminaire type definitions}
    procedure WriteSTFLuminaireTypes(var stfFile: TextFile; lumTypes: TStringList);

    {**Записать секции этажей в STF файл}
    {**Write floor sections to STF file}
    procedure WriteSTFFloors(var stfFile: TextFile);

    {**Собрать список уникальных этажей}
    {**Collect list of unique floors}
    procedure CollectUniqueFloors(floorsList: TStringList);

    {**Записать одну секцию этажа в STF файл}
    {**Write single floor section to STF file}
    procedure WriteSTFFloorSection(var stfFile: TextFile; const floorData: string;
      floorIndex: integer);

    {**Записать координаты вершин полилинии этажа}
    {**Write floor polyline points coordinates}
    procedure WriteFloorPolylinePoints(var stfFile: TextFile; pPolyline: PGDBObjPolyLine);

    {**Получить список комнат принадлежащих этажу}
    {**Get list of rooms belonging to floor}
    procedure GetFloorRoomsList(pFloorPolyline: PGDBObjPolyLine; roomsList: TList);

    {**Найти структуру этажа по имени}
    {**Find floor structure by name}
    function FindFloorByName(const floorName: string): PZVSpaceInfo;

    {**Записать список комнат этажа в STF файл}
    {**Write floor rooms list to STF file}
    procedure WriteFloorRoomsList(var stfFile: TextFile; pFloorPolyline: PGDBObjPolyLine);

    {**Получить высоту этажа для помещения в метрах}
    {**Get floor elevation for room in meters}
    function GetFloorElevation(pSpaceInfo: PZVSpaceInfo): double;

    {**Сформировать полное имя помещения с информацией об этаже и здании}
    {**Format full room name with floor and building information}
    function FormatRoomName(pSpaceInfo: PZVSpaceInfo): string;

    {**Найти левый нижний угол полилинии этажа для использования как начало координат}
    {**Find left-bottom corner of floor polyline to use as origin}
    procedure CalculateOriginFromFloor;

    {**Преобразовать координату X относительно начала координат}
    {**Transform X coordinate relative to origin}
    function TransformX(x: double): double;

    {**Преобразовать координату Y относительно начала координат}
    {**Transform Y coordinate relative to origin}
    function TransformY(y: double): double;

  public
    constructor Create;
    destructor Destroy; override;

    {**Подсчет количества выделенных объектов в чертеже}
    {**Count number of selected objects in drawing}
    function CountSelectedObjects: integer;

    {**Экспорт в формат STF}
    {**Export to STF format}
    function ExportToSTF(const AFileName: string): boolean;

    {**Импорт из формата EVO}
    {**Import from EVO format}
    function ImportFromEVO(const AFileName: string): boolean;

    {**Сбор информации о пространствах из чертежа}
    {**Collect information about spaces from drawing}
    procedure CollectSpacesFromDrawing;

    {**Сбор информации о пространствах только из выделенных объектов}
    {**Collect information about spaces from selected objects only}
    procedure CollectSpacesFromSelection;

    {**Построение иерархии пространств математическими методами}
    {**Build space hierarchy using mathematical methods}
    procedure BuildSpaceHierarchy;

    {**Очистка списка пространств}
    {**Clear spaces list}
    procedure ClearSpaces;

    {**Сбор информации о светильниках из чертежа}
    {**Collect luminaires information from drawing}
    procedure CollectLuminairesFromDrawing;

    {**Сбор информации о светильниках только из выделенных объектов}
    {**Collect luminaires information from selected objects only}
    procedure CollectLuminairesFromSelection;

    {**Определение принадлежности светильников к помещениям}
    {**Assign luminaires to rooms}
    procedure AssignLuminairesToRooms;

    {**Очистка списка светильников}
    {**Clear luminaires list}
    procedure ClearLuminaires;

    {**Вывод структуры пространств в zcUI}
    {**Display spaces structure in zcUI}
    procedure DisplaySpacesStructure;

    {**Вывод списка светильников в zcUI}
    {**Display luminaires list in zcUI}
    procedure DisplayLuminairesList;

    property FileName: string read FFileName write FFileName;
    property SpacesList: TList read FSpacesList;
    property LuminairesList: TList read FLuminairesList;
  end;

implementation

constructor TZVDIALuxManager.Create;
begin
  inherited Create;
  FSpacesList := TList.Create;
  FLuminairesList := TList.Create;
  FFileName := '';
  FOriginX := 0.0;
  FOriginY := 0.0;
end;

destructor TZVDIALuxManager.Destroy;
begin
  ClearSpaces;
  ClearLuminaires;
  FSpacesList.Free;
  FLuminairesList.Free;
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
      if pSpaceInfo^.Luminaires <> nil then
        pSpaceInfo^.Luminaires.Free;
      Dispose(pSpaceInfo);
    end;
  end;
  FSpacesList.Clear;
end;

{**Очистка списка светильников}
{**Clear luminaires list}
procedure TZVDIALuxManager.ClearLuminaires;
var
  i: integer;
  pLumInfo: PZVLuminaireInfo;
begin
  for i := 0 to FLuminairesList.Count - 1 do begin
    pLumInfo := PZVLuminaireInfo(FLuminairesList[i]);
    if pLumInfo <> nil then
      Dispose(pLumInfo);
  end;
  FLuminairesList.Clear;
end;

{**Получить строковое значение переменной из расширения полилинии.
   Возвращает пустую строку если переменная не найдена}
{**Get string variable value from polyline extension.
   Returns empty string if variable not found}
function TZVDIALuxManager.GetStringVariable(VarExt: TVariablesExtender;
  const VarName: string): string;
var
  pvd: pvardesk;
begin
  Result := '';

  if VarExt = nil then
    Exit;

  pvd := VarExt.entityunit.FindVariable(VarName);
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

{**Получить числовое значение переменной из расширения полилинии.
   Возвращает DefaultValue если переменная не найдена или имеет неверный тип}
{**Get numeric variable value from polyline extension.
   Returns DefaultValue if variable not found or has wrong type}
function TZVDIALuxManager.GetNumericVariable(VarExt: TVariablesExtender;
  const VarName: string; DefaultValue: double): double;
var
  pvd: pvardesk;
begin
  Result := DefaultValue;

  if VarExt = nil then
    Exit;

  pvd := VarExt.entityunit.FindVariable(VarName);
  if pvd = nil then
    Exit;

    Result := PInteger(pvd^.data.Addr.Instance)^;
end;

{**Получить числовое значение переменной из расширения полилинии.
   Возвращает DefaultValue если переменная не найдена или имеет неверный тип}
{**Get numeric variable value from polyline extension.
   Returns DefaultValue if variable not found or has wrong type}
function TZVDIALuxManager.GetDoubleVariable(VarExt: TVariablesExtender;
  const VarName: string; DefaultValue: double): double;
var
  pvd: pvardesk;
begin
  Result := DefaultValue;

  if VarExt = nil then
    Exit;

  pvd := VarExt.entityunit.FindVariable(VarName);
  if pvd = nil then
    Exit;

  Result := PDouble(pvd^.data.Addr.Instance)^

end;

{**Получить высоту размещения светильника из устройства в метрах.
   Читает LOCATION_floormark (в мм) и конвертирует в метры}
{**Get luminaire mounting height from device in meters.
   Reads LOCATION_floormark (in mm) and converts to meters}
function TZVDIALuxManager.GetMountingHeightFromDevice(pDevice: PGDBObjDevice): double;
var
  VarExt: TVariablesExtender;
  heightMM: double;
begin
  Result := 0.0;

  if pDevice = nil then
    Exit;

  // Получаем расширение переменных устройства
  // Get device variables extension
  VarExt := pDevice^.specialize GetExtension<TVariablesExtender>;

  if VarExt = nil then
    Exit;

  // Читаем высоту в миллиметрах и конвертируем в метры
  // Read height in millimeters and convert to meters
  heightMM := GetDoubleVariable(VarExt, VAR_LOCATION_FLOORMARK, 0.0);
  Result := heightMM * MM_TO_METERS;
end;

{**Проверка является ли полилиния замкнутой}
{**Check if polyline is closed}
function TZVDIALuxManager.IsPolylineClosed(pPolyline: PGDBObjPolyLine): boolean;
begin
  Result := (pPolyline <> nil) and (pPolyline^.Closed);
end;

{**Создать и инициализировать структуру информации о помещении.
   Помещение — самый нижний уровень иерархии пространств}
{**Create and initialize room space info structure.
   Room is the lowest level of space hierarchy}
function TZVDIALuxManager.CreateRoomSpaceInfo(pPolyline: PGDBObjPolyLine;
  const RoomNumber: string): PZVSpaceInfo;
var
  pSpaceInfo: PZVSpaceInfo;
begin
  New(pSpaceInfo);

  pSpaceInfo^.RoomNumber := RoomNumber;
  pSpaceInfo^.RoomPolyline := pPolyline;
  pSpaceInfo^.Floor := UNDEFINED_VALUE;
  pSpaceInfo^.FloorHeight := UNDEFINED_NUMERIC_VALUE;
  pSpaceInfo^.FloorPolyline := nil;
  pSpaceInfo^.Building := UNDEFINED_VALUE;
  pSpaceInfo^.BuildingPolyline := nil;
  pSpaceInfo^.Luminaires := TList.Create;

  pSpaceInfo^.Name := RoomNumber;
  pSpaceInfo^.Height := DEFAULT_FLOOR_HEIGHT;
  pSpaceInfo^.Polyline := pPolyline;
  pSpaceInfo^.Variables := TStringList.Create;

  Result := pSpaceInfo;
end;

{**Создать и инициализировать структуру информации об этаже.
   Этаж — средний уровень иерархии, содержит помещения}
{**Create and initialize floor space info structure.
   Floor is the middle level, contains rooms}
function TZVDIALuxManager.CreateFloorSpaceInfo(pPolyline: PGDBObjPolyLine;
  const FloorName: string; FloorHeight: double): PZVSpaceInfo;
var
  pSpaceInfo: PZVSpaceInfo;
begin
  New(pSpaceInfo);

  pSpaceInfo^.RoomNumber := '';
  pSpaceInfo^.RoomPolyline := nil;
  pSpaceInfo^.Floor := FloorName;
  pSpaceInfo^.FloorHeight := FloorHeight;
  pSpaceInfo^.FloorPolyline := pPolyline;
  pSpaceInfo^.Building := UNDEFINED_VALUE;
  pSpaceInfo^.BuildingPolyline := nil;
  pSpaceInfo^.Luminaires := TList.Create;

  pSpaceInfo^.Name := FloorName;
  pSpaceInfo^.Height := FloorHeight;
  pSpaceInfo^.Polyline := pPolyline;
  pSpaceInfo^.Variables := TStringList.Create;

  Result := pSpaceInfo;
end;

{**Создать и инициализировать структуру информации о здании.
   Здание — верхний уровень иерархии, содержит этажи}
{**Create and initialize building space info structure.
   Building is the top level, contains floors}
function TZVDIALuxManager.CreateBuildingSpaceInfo(pPolyline: PGDBObjPolyLine;
  const BuildingName: string): PZVSpaceInfo;
var
  pSpaceInfo: PZVSpaceInfo;
begin
  New(pSpaceInfo);

  pSpaceInfo^.RoomNumber := '';
  pSpaceInfo^.RoomPolyline := nil;
  pSpaceInfo^.Floor := '';
  pSpaceInfo^.FloorHeight := UNDEFINED_NUMERIC_VALUE;
  pSpaceInfo^.FloorPolyline := nil;
  pSpaceInfo^.Building := BuildingName;
  pSpaceInfo^.BuildingPolyline := pPolyline;
  pSpaceInfo^.Luminaires := TList.Create;

  pSpaceInfo^.Name := BuildingName;
  pSpaceInfo^.Height := DEFAULT_FLOOR_HEIGHT;
  pSpaceInfo^.Polyline := pPolyline;
  pSpaceInfo^.Variables := TStringList.Create;

  Result := pSpaceInfo;
end;

{**Обработать полилинию как пространство.
   Определяет тип пространства по переменным расширения и создает соответствующую структуру}
{**Process polyline as space.
   Determines space type by extension variables and creates appropriate structure}
procedure TZVDIALuxManager.ProcessPolylineAsSpace(pPolyline: PGDBObjPolyLine;
  var spaceCount: integer);
var
  VarExt: TVariablesExtender;
  spaceRoom, spaceFloor, spaceBuilding: string;
  floorHeight: double;
  pSpaceInfo: PZVSpaceInfo;
begin
  VarExt := pPolyline^.specialize GetExtension<TVariablesExtender>;

  if VarExt = nil then
    Exit;

  spaceRoom := GetStringVariable(VarExt, VAR_SPACE_ROOM);
  spaceFloor := GetStringVariable(VarExt, VAR_SPACE_FLOOR);
  spaceBuilding := GetStringVariable(VarExt, VAR_SPACE_BUILDING);

  if spaceRoom <> '' then begin
    pSpaceInfo := CreateRoomSpaceInfo(pPolyline, spaceRoom);
    FSpacesList.Add(pSpaceInfo);
    inc(spaceCount);
  end
  else if spaceFloor <> '' then begin
    floorHeight := GetDoubleVariable(VarExt, VAR_FLOOR_HEIGHT, DEFAULT_FLOOR_HEIGHT);
    pSpaceInfo := CreateFloorSpaceInfo(pPolyline, spaceFloor, floorHeight);
    FSpacesList.Add(pSpaceInfo);
    inc(spaceCount);
  end
  else if spaceBuilding <> '' then begin
    pSpaceInfo := CreateBuildingSpaceInfo(pPolyline, spaceBuilding);
    FSpacesList.Add(pSpaceInfo);
    inc(spaceCount);
  end;
end;

{**Сбор информации о пространствах из чертежа.
   Основная процедура сбора всех полилиний с расширениями пространств}
{**Collect information about spaces from drawing.
   Main procedure to collect all polylines with space extensions}
procedure TZVDIALuxManager.CollectSpacesFromDrawing;
var
  pEntity: PGDBObjEntity;
  ir: itrec;
  pPolyline: PGDBObjPolyLine;
  spaceCount: integer;
begin
  ClearSpaces;
  spaceCount := 0;

  zcUI.TextMessage('Сбор всех полилиний с расширениями пространств...', TMWOHistoryOut);
  zcUI.TextMessage('Collecting all polylines with space extensions...', TMWOHistoryOut);

  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity = nil then
    Exit;

  repeat
    if pEntity^.GetObjType = GDBPolyLineID then begin
      pPolyline := PGDBObjPolyLine(pEntity);

      if IsPolylineClosed(pPolyline) then
        ProcessPolylineAsSpace(pPolyline, spaceCount);
    end;

    pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pEntity = nil;

  zcUI.TextMessage('Собрано пространств / Spaces collected: ' + IntToStr(spaceCount), TMWOHistoryOut);
end;

{**Подсчитать количество выделенных объектов в чертеже.
   Перебирает все объекты и проверяет свойство selected}
{**Count number of selected objects in drawing.
   Iterates through all objects and checks selected property}
function TZVDIALuxManager.CountSelectedObjects: integer;
var
  pEntity: PGDBObjEntity;
  ir: itrec;
begin
  Result := 0;

  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity = nil then
    Exit;

  repeat
    if pEntity^.selected then
      inc(Result);

    pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pEntity = nil;
end;

{**Сбор информации о пространствах только из выделенных объектов.
   Работает аналогично CollectSpacesFromDrawing, но обрабатывает только выделенные полилинии}
{**Collect information about spaces from selected objects only.
   Works similar to CollectSpacesFromDrawing but processes only selected polylines}
procedure TZVDIALuxManager.CollectSpacesFromSelection;
var
  pEntity: PGDBObjEntity;
  ir: itrec;
  pPolyline: PGDBObjPolyLine;
  spaceCount: integer;
begin
  ClearSpaces;
  spaceCount := 0;

  zcUI.TextMessage('Сбор пространств из выделенных объектов...', TMWOHistoryOut);
  zcUI.TextMessage('Collecting spaces from selected objects...', TMWOHistoryOut);

  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity = nil then
    Exit;

  repeat
    if pEntity^.selected and (pEntity^.GetObjType = GDBPolyLineID) then begin
      pPolyline := PGDBObjPolyLine(pEntity);

      if IsPolylineClosed(pPolyline) then
        ProcessPolylineAsSpace(pPolyline, spaceCount);
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

{**Сбор информации о светильниках из чертежа}
{**Collect luminaires information from drawing}
procedure TZVDIALuxManager.CollectLuminairesFromDrawing;
var
  pEntity: PGDBObjEntity;
  pDevice: PGDBObjDevice;
  ir: itrec;
  pLumInfo: PZVLuminaireInfo;
  lumCount: integer;
begin
  // Очищаем предыдущий список светильников
  // Clear previous luminaires list
  ClearLuminaires;

  lumCount := 0;

  zcUI.TextMessage('Сбор всех светильников (устройств) из чертежа...', TMWOHistoryOut);
  zcUI.TextMessage('Collecting all luminaires (devices) from drawing...', TMWOHistoryOut);

  // Перебираем все примитивы в чертеже
  // Iterate through all entities in the drawing
  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity <> nil then
    repeat
      // Проверяем является ли примитив устройством (светильником)
      // Check if entity is a device (luminaire)
      if pEntity^.GetObjType = GDBDeviceID then begin
        pDevice := PGDBObjDevice(pEntity);

        // Создаем новую запись о светильнике
        // Create new luminaire record
        New(pLumInfo);
        pLumInfo^.DeviceName := pDevice^.Name;
        pLumInfo^.DeviceType := pDevice^.Name; // Временно используем имя как тип
        pLumInfo^.Position := pDevice^.P_insert_in_WCS;
        pLumInfo^.Rotation := pDevice^.rotate;
        pLumInfo^.Load := DEFAULT_LUMINAIRE_POWER;
        pLumInfo^.NrLamps := DEFAULT_LAMPS_COUNT;
        pLumInfo^.MountingHeight := GetMountingHeightFromDevice(pDevice);
        pLumInfo^.RoomIndex := -1; // Пока не определено / Not determined yet
        pLumInfo^.Device := pDevice;

        FLuminairesList.Add(pLumInfo);
        inc(lumCount);
      end;

      pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pEntity = nil;

  zcUI.TextMessage('Собрано светильников / Luminaires collected: ' + IntToStr(lumCount), TMWOHistoryOut);
end;

{**Сбор информации о светильниках только из выделенных объектов.
   Работает аналогично CollectLuminairesFromDrawing, но обрабатывает только выделенные устройства}
{**Collect luminaires information from selected objects only.
   Works similar to CollectLuminairesFromDrawing but processes only selected devices}
procedure TZVDIALuxManager.CollectLuminairesFromSelection;
var
  pEntity: PGDBObjEntity;
  pDevice: PGDBObjDevice;
  ir: itrec;
  pLumInfo: PZVLuminaireInfo;
  lumCount: integer;
begin
  ClearLuminaires;
  lumCount := 0;

  zcUI.TextMessage('Сбор светильников из выделенных объектов...', TMWOHistoryOut);
  zcUI.TextMessage('Collecting luminaires from selected objects...', TMWOHistoryOut);

  pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pEntity <> nil then
    repeat
      if pEntity^.selected and (pEntity^.GetObjType = GDBDeviceID) then begin
        pDevice := PGDBObjDevice(pEntity);

        New(pLumInfo);
        pLumInfo^.DeviceName := pDevice^.Name;
        pLumInfo^.DeviceType := pDevice^.Name;
        pLumInfo^.Position := pDevice^.P_insert_in_WCS;
        pLumInfo^.Rotation := pDevice^.rotate;
        pLumInfo^.Load := DEFAULT_LUMINAIRE_POWER;
        pLumInfo^.NrLamps := DEFAULT_LAMPS_COUNT;
        pLumInfo^.MountingHeight := GetMountingHeightFromDevice(pDevice);
        pLumInfo^.RoomIndex := -1;
        pLumInfo^.Device := pDevice;

        FLuminairesList.Add(pLumInfo);
        inc(lumCount);
      end;

      pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pEntity = nil;

  zcUI.TextMessage('Собрано светильников / Luminaires collected: ' + IntToStr(lumCount), TMWOHistoryOut);
end;

{**Определение принадлежности светильников к помещениям}
{**Assign luminaires to rooms}
procedure TZVDIALuxManager.AssignLuminairesToRooms;
var
  i, j: integer;
  pLumInfo: PZVLuminaireInfo;
  pSpaceInfo: PZVSpaceInfo;
  assigned: boolean;
  assignedCount: integer;
begin
  zcUI.TextMessage('Определение принадлежности светильников к помещениям...', TMWOHistoryOut);
  zcUI.TextMessage('Assigning luminaires to rooms...', TMWOHistoryOut);

  assignedCount := 0;

  // Для каждого светильника определяем в каком помещении он находится
  // For each luminaire, determine which room it belongs to
  for i := 0 to FLuminairesList.Count - 1 do begin
    pLumInfo := PZVLuminaireInfo(FLuminairesList[i]);
    assigned := false;

    // Проверяем все помещения
    // Check all rooms
    for j := 0 to FSpacesList.Count - 1 do begin
      pSpaceInfo := PZVSpaceInfo(FSpacesList[j]);

      // Проверяем только помещения (Space_Room)
      // Check only rooms (Space_Room)
      if pSpaceInfo^.RoomPolyline <> nil then begin
        // Проверяем находится ли светильник внутри полилинии помещения
        // Check if luminaire is inside room polyline
        if PointInPolyline(pLumInfo^.Position, pSpaceInfo^.RoomPolyline) then begin
          pLumInfo^.RoomIndex := j;
          pSpaceInfo^.Luminaires.Add(pLumInfo);
          assigned := true;
          inc(assignedCount);
          break;
        end;
      end;
    end;

    if not assigned then begin
      zcUI.TextMessage('  Светильник не назначен помещению / Luminaire not assigned: ' +
                      pLumInfo^.DeviceName + ' at (' +
                      FormatFloat('0.##', pLumInfo^.Position.x) + ', ' +
                      FormatFloat('0.##', pLumInfo^.Position.y) + ')', TMWOHistoryOut);
    end;
  end;

  zcUI.TextMessage('Назначено светильников / Luminaires assigned: ' + IntToStr(assignedCount) +
                  ' из / of ' + IntToStr(FLuminairesList.Count), TMWOHistoryOut);
end;

{**Вывод списка светильников в zcUI}
{**Display luminaires list in zcUI}
procedure TZVDIALuxManager.DisplayLuminairesList;
var
  i, j: integer;
  pSpaceInfo: PZVSpaceInfo;
  pLumInfo: PZVLuminaireInfo;
  msg: string;
  roomLumCount: integer;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('=== Список светильников по помещениям / Luminaires by Rooms ===', TMWOHistoryOut);
  zcUI.TextMessage('Всего светильников / Total luminaires: ' + IntToStr(FLuminairesList.Count), TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);

  // Выводим светильники по помещениям
  // Display luminaires by rooms
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Показываем только помещения со светильниками
    // Show only rooms with luminaires
    if (pSpaceInfo^.RoomPolyline <> nil) and (pSpaceInfo^.Luminaires.Count > 0) then begin
      roomLumCount := pSpaceInfo^.Luminaires.Count;

      zcUI.TextMessage('--- Помещение / Room: ' + pSpaceInfo^.RoomNumber +
                      ' (' + IntToStr(roomLumCount) + ' светильников / luminaires) ---', TMWOHistoryOut);

      // Выводим все светильники в помещении
      // Display all luminaires in the room
      for j := 0 to pSpaceInfo^.Luminaires.Count - 1 do begin
        pLumInfo := PZVLuminaireInfo(pSpaceInfo^.Luminaires[j]);

        msg := '  [' + IntToStr(j + 1) + '] ' + pLumInfo^.DeviceName +
               ' Позиция / Position: (' +
               FormatFloat('0.###', pLumInfo^.Position.x) + ', ' +
               FormatFloat('0.###', pLumInfo^.Position.y) + ', ' +
               FormatFloat('0.###', pLumInfo^.Position.z) + ')' +
               ' Высота установки / Mounting height: ' + FormatFloat('0.###', pLumInfo^.MountingHeight) + ' м' +
               ' Поворот / Rotation: ' + FormatFloat('0.#', pLumInfo^.Rotation) + '°';

        zcUI.TextMessage(msg, TMWOHistoryOut);
      end;

      zcUI.TextMessage('', TMWOHistoryOut);
    end;
  end;

  zcUI.TextMessage('=== Конец списка / End of List ===', TMWOHistoryOut);
end;

{**Проверить есть ли выбранные этажи в списке пространств.
   Возвращает True если найден хотя бы один этаж}
{**Check if there are any selected floors in spaces list.
   Returns True if at least one floor is found}
function TZVDIALuxManager.HasSelectedFloors: boolean;
var
  i: integer;
  pSpace: PZVSpaceInfo;
begin
  Result := False;

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpace := PZVSpaceInfo(FSpacesList[i]);
    if pSpace^.FloorPolyline <> nil then begin
      Result := True;
      break;
    end;
  end;
end;

{**Проверить принадлежит ли помещение к одному из выбранных этажей.
   Помещение принадлежит этажу если его FloorPolyline совпадает с одним из выбранных}
{**Check if room belongs to one of selected floors.
   Room belongs to floor if its FloorPolyline matches one of selected ones}
function TZVDIALuxManager.RoomBelongsToSelectedFloor(pSpaceInfo: PZVSpaceInfo): boolean;
var
  i: integer;
  pFloorSpace: PZVSpaceInfo;
begin
  Result := False;

  // Если у помещения не установлен этаж, не экспортируем
  // If room has no floor set, don't export
  if pSpaceInfo^.FloorPolyline = nil then
    Exit;

  // Если нет выбранных этажей, принимаем все помещения
  // If no floors selected, accept all rooms
  if not HasSelectedFloors then begin
    Result := True;
    Exit;
  end;

  // Ищем этаж помещения среди выбранных этажей
  // Search for room's floor among selected floors
  for i := 0 to FSpacesList.Count - 1 do begin
    pFloorSpace := PZVSpaceInfo(FSpacesList[i]);
    if (pFloorSpace^.FloorPolyline <> nil) and
       (pSpaceInfo^.FloorPolyline = pFloorSpace^.FloorPolyline) then begin
      Result := True;
      Exit;
    end;
  end;
end;

{**Подсчитать количество помещений в списке пространств.
   Помещения определяются наличием RoomPolyline}
{**Count number of rooms in spaces list.
   Rooms are identified by presence of RoomPolyline}
function TZVDIALuxManager.CountRooms: integer;
var
  i: integer;
  pSpaceInfo: PZVSpaceInfo;
begin
  Result := 0;

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);
    if pSpaceInfo^.RoomPolyline <> nil then
      inc(Result);
  end;
end;

{**Подсчитать количество помещений принадлежащих выбранным этажам.
   Учитываются только помещения из выбранных этажей}
{**Count number of rooms belonging to selected floors.
   Only rooms from selected floors are counted}
function TZVDIALuxManager.CountRoomsInSelectedFloors: integer;
var
  i: integer;
  pSpaceInfo: PZVSpaceInfo;
begin
  Result := 0;

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Подсчитываем только помещения принадлежащие выбранным этажам
    // Count only rooms belonging to selected floors
    if (pSpaceInfo^.RoomPolyline <> nil) and RoomBelongsToSelectedFloor(pSpaceInfo) then
      inc(Result);
  end;
end;

{**Собрать список уникальных типов светильников из помещений выбранных этажей}
{**Collect list of unique luminaire types from rooms in selected floors}
procedure TZVDIALuxManager.CollectUniqueLuminaireTypes(lumTypes: TStringList);
var
  i, j: integer;
  pSpaceInfo: PZVSpaceInfo;
  pLumInfo: PZVLuminaireInfo;
begin
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Собираем светильники только из помещений выбранных этажей
    // Collect luminaires only from rooms in selected floors
    if (pSpaceInfo^.RoomPolyline <> nil) and RoomBelongsToSelectedFloor(pSpaceInfo) and
       (pSpaceInfo^.Luminaires <> nil) then begin
      for j := 0 to pSpaceInfo^.Luminaires.Count - 1 do begin
        pLumInfo := PZVLuminaireInfo(pSpaceInfo^.Luminaires[j]);

        if lumTypes.IndexOf(pLumInfo^.DeviceType) < 0 then
          lumTypes.Add(pLumInfo^.DeviceType);
      end;
    end;
  end;
end;

{**Записать секцию VERSION в STF файл}
{**Write VERSION section to STF file}
procedure TZVDIALuxManager.WriteSTFHeader(var stfFile: TextFile);
begin
  WriteLn(stfFile, '[VERSION]');
  WriteLn(stfFile, 'STFF=' + STF_VERSION);
  WriteLn(stfFile, 'Progname=' + STF_PROGRAM_NAME);
  WriteLn(stfFile, 'Progvers=' + STF_PROGRAM_VERSION);
end;

{**Записать секцию PROJECT в STF файл с информацией о проекте и списком помещений}
{**Write PROJECT section to STF file with project info and room list}
procedure TZVDIALuxManager.WriteSTFProjectSection(var stfFile: TextFile;
  const projectName: string; const currentDate: string; roomCount: integer;
  floorCount: integer);
var
  i, roomIndex: integer;
  pSpaceInfo: PZVSpaceInfo;
begin
  WriteLn(stfFile, '[PROJECT]');
  WriteLn(stfFile, 'Name=' + projectName);
  WriteLn(stfFile, 'Date=' + currentDate);
  WriteLn(stfFile, 'Operator=' + STF_PROGRAM_NAME);

  // Записываем количество и ссылки на помещения
  // Write number of rooms and room references
  WriteLn(stfFile, 'NrRooms=' + IntToStr(roomCount));
  roomIndex := 0;
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    if (pSpaceInfo^.RoomPolyline <> nil) and RoomBelongsToSelectedFloor(pSpaceInfo) then begin
      inc(roomIndex);
      WriteLn(stfFile, 'Room' + IntToStr(roomIndex) + '=ROOM.R' + IntToStr(roomIndex));
    end;
  end;
end;

{**Записать координаты всех точек полилинии помещения с преобразованием координат}
{**Write coordinates of all polyline points of the room with coordinate transformation}
procedure TZVDIALuxManager.WriteRoomPolylinePoints(var stfFile: TextFile;
  pPolyline: PGDBObjPolyLine);
var
  i: integer;
  vertex: GDBVertex;
  transformedX, transformedY: double;
begin
  for i := 0 to pPolyline^.VertexArrayInOCS.Count - 1 do begin
    vertex := pPolyline^.VertexArrayInOCS.getData(i);

    // Преобразуем координаты относительно начала координат
    // Transform coordinates relative to origin
    transformedX := TransformX(vertex.x);
    transformedY := TransformY(vertex.y);

    WriteLn(stfFile, 'Point' + IntToStr(i + 1) + '=' +
            FormatFloat('0.###', transformedX) + ' ' +
            FormatFloat('0.###', transformedY));
  end;
end;

{**Записать координаты всех вершин полилинии этажа с преобразованием координат.
   Аналогично WriteRoomPolylinePoints, но для этажей}
{**Write coordinates of all floor polyline vertices with coordinate transformation.
   Similar to WriteRoomPolylinePoints, but for floors}
procedure TZVDIALuxManager.WriteFloorPolylinePoints(var stfFile: TextFile;
  pPolyline: PGDBObjPolyLine);
var
  i: integer;
  vertex: GDBVertex;
  transformedX, transformedY: double;
begin
  for i := 0 to pPolyline^.VertexArrayInOCS.Count - 1 do begin
    vertex := pPolyline^.VertexArrayInOCS.getData(i);

    // Преобразуем координаты относительно начала координат
    // Transform coordinates relative to origin
    transformedX := TransformX(vertex.x);
    transformedY := TransformY(vertex.y);

    WriteLn(stfFile, 'Point' + IntToStr(i + 1) + '=' +
            FormatFloat('0.###', transformedX) + ' ' +
            FormatFloat('0.###', transformedY));
  end;
end;

{**Записать информацию о всех светильниках в помещении с преобразованием координат.
   Также записывает определения типов светильников сразу после списка светильников}
{**Write information about all luminaires in the room with coordinate transformation.
   Also writes luminaire type definitions immediately after luminaire list}
procedure TZVDIALuxManager.WriteRoomLuminaires(var stfFile: TextFile;
  pSpaceInfo: PZVSpaceInfo; lumTypes: TStringList);
var
  i: integer;
  pLumInfo: PZVLuminaireInfo;
  transformedX, transformedY: double;
begin
  if pSpaceInfo^.Luminaires.Count = 0 then begin
    WriteLn(stfFile, 'NrLums=0');
    Exit;
  end;

  // Записываем информацию о каждом светильнике
  // Write information about each luminaire
  for i := 0 to pSpaceInfo^.Luminaires.Count - 1 do begin
    pLumInfo := PZVLuminaireInfo(pSpaceInfo^.Luminaires[i]);

    WriteLn(stfFile, 'Lum' + IntToStr(i + 1) + '=' + pLumInfo^.DeviceType);

    // Преобразуем координаты светильника относительно начала координат
    // Transform luminaire coordinates relative to origin
    transformedX := TransformX(pLumInfo^.Position.x);
    transformedY := TransformY(pLumInfo^.Position.y);

    // Используем MountingHeight как Z координату для правильного размещения в DIALux
    // Use MountingHeight as Z coordinate for correct placement in DIALux
    WriteLn(stfFile, 'Lum' + IntToStr(i + 1) + '.Pos=' +
            FormatFloat('0.###', transformedX) + ' ' +
            FormatFloat('0.###', transformedY) + ' ' +
            FormatFloat('0.###', pLumInfo^.MountingHeight));

    WriteLn(stfFile, 'Lum' + IntToStr(i + 1) + '.Rot=0 0 ' +
            FormatFloat('0.#', pLumInfo^.Rotation));
  end;

  WriteLn(stfFile, 'NrLums=' + IntToStr(pSpaceInfo^.Luminaires.Count));
end;

{**Сформировать полное имя помещения с информацией об этаже и здании}
{**Format full room name with floor and building information}
function TZVDIALuxManager.FormatRoomName(pSpaceInfo: PZVSpaceInfo): string;
begin
  Result := pSpaceInfo^.RoomNumber;

  // Добавляем информацию об этаже если доступна
  // Add floor information if available
  if (pSpaceInfo^.Floor <> '') and (pSpaceInfo^.Floor <> UNDEFINED_VALUE) then
    Result := pSpaceInfo^.Floor + ' - ' + Result;

  // Добавляем информацию о здании если доступна
  // Add building information if available
  if (pSpaceInfo^.Building <> '') and (pSpaceInfo^.Building <> UNDEFINED_VALUE) then
    Result := pSpaceInfo^.Building + ' - ' + Result;
end;

{**Записать информацию об одном помещении в STF файл}
{**Write single room information to STF file}
procedure TZVDIALuxManager.WriteSTFRoom(var stfFile: TextFile;
  pSpaceInfo: PZVSpaceInfo; roomIndex: integer; lumTypes: TStringList);
var
  roomHeight: double;
  roomName: string;
  floorElevation: double;
begin
  // Определяем высоту помещения
  // Determine room height
  if pSpaceInfo^.FloorHeight > 0 then
    roomHeight := pSpaceInfo^.FloorHeight
  else
    roomHeight := DEFAULT_ROOM_HEIGHT;

  // Формируем полное имя помещения с иерархией
  // Format full room name with hierarchy
  roomName := FormatRoomName(pSpaceInfo);

  // Получаем высоту этажа (Z-координату)
  // Get floor elevation (Z-coordinate)
  floorElevation := GetFloorElevation(pSpaceInfo);

  // Записываем заголовок и основные параметры помещения
  // Write room header and basic parameters
  WriteLn(stfFile, '[ROOM.R' + IntToStr(roomIndex) + ']');
  WriteLn(stfFile, 'Name=' + roomName);
  WriteLn(stfFile, 'Height=' + FormatFloat('0.0', roomHeight));
  WriteLn(stfFile, 'WorkingPlane=' + FormatFloat('0.0', STF_WORKING_PLANE_HEIGHT));
  WriteLn(stfFile, 'NrPoints=' + IntToStr(pSpaceInfo^.RoomPolyline^.VertexArrayInOCS.Count));

  // Записываем координаты точек
  // Write point coordinates
  WriteRoomPolylinePoints(stfFile, pSpaceInfo^.RoomPolyline);

  // Записываем параметры отражения
  // Write reflection parameters
  WriteLn(stfFile, 'R_Ceiling=' + FormatFloat('0.00', STF_CEILING_REFLECTANCE));

  // Записываем светильники
  // Write luminaires
  WriteRoomLuminaires(stfFile, pSpaceInfo, lumTypes);

  // Завершаем секцию помещения
  // Finish room section
  WriteLn(stfFile, 'NrStruct=0');
  WriteLn(stfFile, 'NrFurns=0');
end;

{**Записать определения типов светильников в STF файл}
{**Write luminaire type definitions to STF file}
procedure TZVDIALuxManager.WriteSTFLuminaireTypes(var stfFile: TextFile;
  lumTypes: TStringList);
var
  i: integer;
  lumTypeName: string;
begin
  for i := 0 to lumTypes.Count - 1 do begin
    lumTypeName := lumTypes[i];

    WriteLn(stfFile, '[' + lumTypeName + ']');
    WriteLn(stfFile, 'Manufacturer=');
    WriteLn(stfFile, 'Name=');
    WriteLn(stfFile, 'OrderNr=');
    WriteLn(stfFile, 'Box=1 1 0');
    WriteLn(stfFile, 'Shape=' + IntToStr(STF_LUMINAIRE_SHAPE));
    WriteLn(stfFile, 'Load=' + IntToStr(Round(DEFAULT_LUMINAIRE_POWER)));
    WriteLn(stfFile, 'Flux=' + IntToStr(STF_LUMINAIRE_DEFAULT_FLUX));
    WriteLn(stfFile, 'NrLamps=' + IntToStr(DEFAULT_LAMPS_COUNT));
    WriteLn(stfFile, 'MountingType=' + IntToStr(STF_LUMINAIRE_MOUNTING_TYPE));
  end;
end;

{**Собрать список уникальных этажей из списка пространств.
   Формат: "ИмяЭтажа|Высота"}
{**Collect list of unique floors from spaces list.
   Format: "FloorName|Height"}
procedure TZVDIALuxManager.CollectUniqueFloors(floorsList: TStringList);
var
  i: integer;
  pSpaceInfo: PZVSpaceInfo;
  floorData: string;
begin
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    if (pSpaceInfo^.FloorPolyline <> nil) and (pSpaceInfo^.Floor <> '') then begin
      floorData := pSpaceInfo^.Floor + '|' +
                   FormatFloat('0.###', pSpaceInfo^.FloorHeight);
      if floorsList.IndexOf(floorData) < 0 then
        floorsList.Add(floorData);
    end;
  end;
end;

{**Получить список комнат принадлежащих указанному этажу.
   Возвращает TList с PZVSpaceInfo комнат, которые принадлежат этажу}
{**Get list of rooms belonging to specified floor.
   Returns TList with PZVSpaceInfo of rooms that belong to the floor}
procedure TZVDIALuxManager.GetFloorRoomsList(pFloorPolyline: PGDBObjPolyLine;
  roomsList: TList);
var
  i: integer;
  pSpaceInfo: PZVSpaceInfo;
begin
  roomsList.Clear;

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Добавляем только помещения принадлежащие этому этажу
    // Add only rooms belonging to this floor
    if (pSpaceInfo^.RoomPolyline <> nil) and
       (pSpaceInfo^.FloorPolyline = pFloorPolyline) then
      roomsList.Add(pSpaceInfo);
  end;
end;

{**Найти структуру этажа в списке пространств по имени этажа}
{**Find floor structure in spaces list by floor name}
function TZVDIALuxManager.FindFloorByName(const floorName: string): PZVSpaceInfo;
var
  i: integer;
  pSpace: PZVSpaceInfo;
begin
  Result := nil;

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpace := PZVSpaceInfo(FSpacesList[i]);
    if (pSpace^.FloorPolyline <> nil) and (pSpace^.Floor = floorName) then begin
      Result := pSpace;
      break;
    end;
  end;
end;

{**Записать список комнат принадлежащих этажу в STF файл}
{**Write list of rooms belonging to floor to STF file}
procedure TZVDIALuxManager.WriteFloorRoomsList(var stfFile: TextFile;
  pFloorPolyline: PGDBObjPolyLine);
var
  i, roomIndex, globalRoomIndex: integer;
  roomsList: TList;
  pRoomSpace, pSpace: PZVSpaceInfo;
begin
  roomsList := TList.Create;
  try
    GetFloorRoomsList(pFloorPolyline, roomsList);
    WriteLn(stfFile, 'NrRooms=' + IntToStr(roomsList.Count));

    // Записываем ссылки на комнаты
    // Write room references
    roomIndex := 0;
    globalRoomIndex := 0;
    for i := 0 to FSpacesList.Count - 1 do begin
      pSpace := PZVSpaceInfo(FSpacesList[i]);

      // Подсчитываем глобальный индекс всех экспортируемых комнат
      // Count global index of all exported rooms
      if (pSpace^.RoomPolyline <> nil) and RoomBelongsToSelectedFloor(pSpace) then
        inc(globalRoomIndex);

      // Если комната принадлежит текущему этажу, добавляем ссылку
      // If room belongs to current floor, add reference
      if roomsList.IndexOf(pSpace) >= 0 then begin
        inc(roomIndex);
        WriteLn(stfFile, 'Room' + IntToStr(roomIndex) + '=ROOM.R' +
                IntToStr(globalRoomIndex));
      end;
    end;
  finally
    roomsList.Free;
  end;
end;

{**Записать одну секцию этажа в STF файл.
   Включает вершины этажа и список комнат принадлежащих этажу.
   Парсит строку формата "ИмяЭтажа|Высота"}
{**Write single floor section to STF file.
   Includes floor vertices and list of rooms belonging to floor.
   Parses string in format "FloorName|Height"}
procedure TZVDIALuxManager.WriteSTFFloorSection(var stfFile: TextFile;
  const floorData: string; floorIndex: integer);
var
  floorName: string;
  floorHeight, floorElevation: double;
  separatorPos: integer;
  pFloorSpace: PZVSpaceInfo;
begin
  // Парсим данные этажа из строки
  // Parse floor data from string
  separatorPos := Pos('|', floorData);
  floorName := Copy(floorData, 1, separatorPos - 1);
  floorHeight := StrToFloatDef(Copy(floorData, separatorPos + 1,
                 Length(floorData)), DEFAULT_FLOOR_HEIGHT);
  floorElevation := floorIndex * floorHeight;

  // Находим структуру этажа по имени
  // Find floor structure by name
  pFloorSpace := FindFloorByName(floorName);
  if pFloorSpace = nil then
    Exit;

  // Записываем заголовок секции этажа
  // Write floor section header
  WriteLn(stfFile, '[STOREY.S' + IntToStr(floorIndex + 1) + ']');
  WriteLn(stfFile, 'Name=' + floorName);
  WriteLn(stfFile, 'Height=' + FormatFloat('0.0', floorHeight));
  WriteLn(stfFile, 'Elevation=' + FormatFloat('0.0', floorElevation));

  // Записываем вершины этажа
  // Write floor vertices
  WriteLn(stfFile, 'NrPoints=' +
          IntToStr(pFloorSpace^.FloorPolyline^.VertexArrayInOCS.Count));
  WriteFloorPolylinePoints(stfFile, pFloorSpace^.FloorPolyline);

  // Записываем список комнат этажа
  // Write floor rooms list
  WriteFloorRoomsList(stfFile, pFloorSpace^.FloorPolyline);
end;

{**Записать секции этажей в STF файл.
   Создает секцию [FLOOR.Fx] для каждого уникального этажа}
{**Write floor sections to STF file.
   Creates [FLOOR.Fx] section for each unique floor}
procedure TZVDIALuxManager.WriteSTFFloors(var stfFile: TextFile);
var
  floorIndex: integer;
  floorsList: TStringList;
begin
  floorsList := TStringList.Create;
  floorsList.Sorted := True;
  floorsList.Duplicates := dupIgnore;

  try
    CollectUniqueFloors(floorsList);

    for floorIndex := 0 to floorsList.Count - 1 do
      WriteSTFFloorSection(stfFile, floorsList[floorIndex], floorIndex);

  finally
    floorsList.Free;
  end;
end;

{**Получить высоту этажа (elevation) для помещения в метрах.
   Рассчитывает Z-координату на основе индекса этажа}
{**Get floor elevation for room in meters.
   Calculates Z-coordinate based on floor index}
function TZVDIALuxManager.GetFloorElevation(pSpaceInfo: PZVSpaceInfo): double;
var
  i, floorIndex: integer;
  pFloorSpace: PZVSpaceInfo;
begin
  Result := 0.0;
  floorIndex := 0;

  // Если у помещения нет этажа, возвращаем 0
  // If room has no floor, return 0
  if pSpaceInfo^.FloorPolyline = nil then
    Exit;

  // Находим индекс этажа помещения в списке этажей
  // Find index of room's floor in floor list
  for i := 0 to FSpacesList.Count - 1 do begin
    pFloorSpace := PZVSpaceInfo(FSpacesList[i]);

    // Считаем только этажи которые идут до текущего
    // Count only floors that come before current one
    if (pFloorSpace^.FloorPolyline <> nil) then begin
      if pFloorSpace^.FloorPolyline = pSpaceInfo^.FloorPolyline then
        break;
      inc(floorIndex);
    end;
  end;

  // Рассчитываем высоту этажа как сумму высот предыдущих этажей
  // Calculate floor elevation as sum of previous floor heights
  Result := floorIndex * pSpaceInfo^.FloorHeight;
end;

{**Найти левый нижний угол полилинии этажа и установить как начало координат.
   Ищет минимальные значения X и Y среди всех вершин всех этажей}
{**Find left-bottom corner of floor polyline and set as origin.
   Finds minimum X and Y values among all vertices of all floors}
procedure TZVDIALuxManager.CalculateOriginFromFloor;
var
  i, j: integer;
  pSpaceInfo: PZVSpaceInfo;
  vertex: GDBVertex;
  minX, minY: double;
  firstFloor: boolean;
begin
  firstFloor := true;
  minX := 0.0;
  minY := 0.0;

  // Ищем все пространства типа этаж (space_Floor)
  // Search for all floor spaces (space_Floor)
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Обрабатываем только этажи
    // Process only floors
    if pSpaceInfo^.FloorPolyline <> nil then begin
      // Перебираем все вершины полилинии этажа
      // Iterate through all floor polyline vertices
      for j := 0 to pSpaceInfo^.FloorPolyline^.VertexArrayInOCS.Count - 1 do begin
        vertex := pSpaceInfo^.FloorPolyline^.VertexArrayInOCS.getData(j);

        if firstFloor then begin
          minX := vertex.x;
          minY := vertex.y;
          firstFloor := false;
        end
        else begin
          if vertex.x < minX then
            minX := vertex.x;
          if vertex.y < minY then
            minY := vertex.y;
        end;
      end;
    end;
  end;

  // Устанавливаем найденные координаты как начало координат
  // Set found coordinates as origin
  FOriginX := minX;
  FOriginY := minY;

  zcUI.TextMessage('Начало координат установлено / Origin set: (' +
                  FormatFloat('0.###', FOriginX) + ', ' +
                  FormatFloat('0.###', FOriginY) + ')', TMWOHistoryOut);
end;

{**Преобразовать координату X относительно начала координат}
{**Transform X coordinate relative to origin}
function TZVDIALuxManager.TransformX(x: double): double;
begin
  Result := x - FOriginX;
end;

{**Преобразовать координату Y относительно начала координат}
{**Transform Y coordinate relative to origin}
function TZVDIALuxManager.TransformY(y: double): double;
begin
  Result := y - FOriginY;
end;

{**Экспорт данных в формат STF для DIALux EVO.
   Основная функция координирует процесс экспорта}
{**Export data to STF format for DIALux EVO.
   Main function coordinates the export process}
function TZVDIALuxManager.ExportToSTF(const AFileName: string): boolean;
var
  stfFile: TextFile;
  i, roomIndex, floorCount: integer;
  pSpaceInfo: PZVSpaceInfo;
  roomCount: integer;
  currentDate: string;
  projectName: string;
  lumTypes: TStringList;
  tempFloorsList: TStringList;
begin
  Result := False;

  try
    // Проверка наличия данных для экспорта
    // Check if there is data to export
    if FSpacesList.Count = 0 then begin
      zcUI.TextMessage('Нет пространств для экспорта / No spaces to export', TMWOHistoryOut);
      Exit;
    end;

    // Подсчитываем количество уникальных этажей
    // Count number of unique floors
    tempFloorsList := TStringList.Create;
    tempFloorsList.Sorted := True;
    tempFloorsList.Duplicates := dupIgnore;
    try
      CollectUniqueFloors(tempFloorsList);
      floorCount := tempFloorsList.Count;
    finally
      tempFloorsList.Free;
    end;

    // Выводим информацию о выбранных этажах
    // Display information about selected floors
    if floorCount > 0 then begin
      tempFloorsList := TStringList.Create;
      tempFloorsList.Sorted := True;
      tempFloorsList.Duplicates := dupIgnore;
      try
        CollectUniqueFloors(tempFloorsList);
        zcUI.TextMessage('Выбрано этажей / Selected floors: ' + IntToStr(tempFloorsList.Count), TMWOHistoryOut);
        for i := 0 to tempFloorsList.Count - 1 do begin
          zcUI.TextMessage('  - Этаж / Floor: ' +
                          Copy(tempFloorsList[i], 1, Pos('|', tempFloorsList[i]) - 1), TMWOHistoryOut);
        end;
      finally
        tempFloorsList.Free;
      end;
    end else begin
      zcUI.TextMessage('Этажи не выбраны, будут экспортированы все помещения', TMWOHistoryOut);
      zcUI.TextMessage('No floors selected, all rooms will be exported', TMWOHistoryOut);
    end;

    // Подсчет количества помещений принадлежащих выбранным этажам
    // Count number of rooms belonging to selected floors
    roomCount := CountRoomsInSelectedFloors;

    if roomCount = 0 then begin
      zcUI.TextMessage('Нет помещений для экспорта на выбранных этажах', TMWOHistoryOut);
      zcUI.TextMessage('No rooms to export on selected floors', TMWOHistoryOut);
      Exit;
    end;

    // Рассчитываем начало координат из левого нижнего угла этажа
    // Calculate origin from left-bottom corner of floor
    CalculateOriginFromFloor;

    // Подготовка метаданных для экспорта
    // Prepare metadata for export
    currentDate := FormatDateTime('yyyy-mm-dd', Now);
    projectName := ChangeFileExt(ExtractFileName(AFileName), '');

    // Создание списка уникальных типов светильников
    // Create list of unique luminaire types
    lumTypes := TStringList.Create;
    lumTypes.Sorted := True;
    lumTypes.Duplicates := dupIgnore;

    try
      CollectUniqueLuminaireTypes(lumTypes);

      // Открытие файла для записи в кодировке Windows-1251
      // Open file for writing with Windows-1251 encoding
      AssignFile(stfFile, AFileName);
      SetTextCodePage(stfFile, 1251); // Windows-1251 кодировка / Windows-1251 encoding
      Rewrite(stfFile);

      try
        // Запись заголовка и секций файла
        // Write header and file sections
        WriteSTFHeader(stfFile);
        WriteSTFProjectSection(stfFile, projectName, currentDate, roomCount, floorCount);

        // Экспорт помещений принадлежащих выбранным этажам
        // Export rooms belonging to selected floors
        roomIndex := 0;
        for i := 0 to FSpacesList.Count - 1 do begin
          pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

          // Экспортируем только помещения принадлежащие выбранным этажам
          // Export only rooms belonging to selected floors
          if (pSpaceInfo^.RoomPolyline <> nil) and RoomBelongsToSelectedFloor(pSpaceInfo) then begin
            inc(roomIndex);
            WriteSTFRoom(stfFile, pSpaceInfo, roomIndex, lumTypes);
          end;
        end;

        // Записываем определения типов светильников после всех помещений
        // Write luminaire type definitions after all rooms
        WriteSTFLuminaireTypes(stfFile, lumTypes);

        Result := True;
        zcUI.TextMessage('Экспорт в STF завершен / STF export completed: ' + AFileName, TMWOHistoryOut);
        zcUI.TextMessage('Экспортировано этажей / Floors exported: ' + IntToStr(floorCount), TMWOHistoryOut);
        zcUI.TextMessage('Экспортировано помещений / Rooms exported: ' + IntToStr(roomCount), TMWOHistoryOut);
        zcUI.TextMessage('Экспортировано типов светильников / Luminaire types exported: ' +
                        IntToStr(lumTypes.Count), TMWOHistoryOut);

      finally
        CloseFile(stfFile);
      end;

    finally
      lumTypes.Free;
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
  msg, fullName: string;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('=== Структура пространств / Spaces Structure ===', TMWOHistoryOut);
  zcUI.TextMessage('Всего пространств / Total spaces: ' + IntToStr(FSpacesList.Count), TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);

  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    zcUI.TextMessage('--- Пространство / Space #' + IntToStr(i + 1) + ' ---', TMWOHistoryOut);

    // Полное имя с иерархией / Full name with hierarchy
    if pSpaceInfo^.RoomPolyline <> nil then begin
      fullName := FormatRoomName(pSpaceInfo);
      msg := '  Полное имя / Full name: ' + fullName;
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

    // Номер помещения / Room number
    if pSpaceInfo^.RoomNumber <> '' then begin
      msg := '  Номер помещения / Room number: ' + pSpaceInfo^.RoomNumber;
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

    // Указатель на полилинию помещения / Pointer to room polyline
    if pSpaceInfo^.RoomPolyline <> nil then
      msg := '  Указатель на полилинию помещения / Room polyline: 0x' + IntToHex(PtrUInt(pSpaceInfo^.RoomPolyline), 16)
    else
      msg := '  Указатель на полилинию помещения / Room polyline: nil';
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Этаж / Floor
    if pSpaceInfo^.Floor <> '' then begin
      msg := '  Этаж / Floor: ' + pSpaceInfo^.Floor;
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

    // Высота этажа / Floor Height
    if pSpaceInfo^.FloorHeight > 0 then begin
      msg := '  Высота этажа / Floor Height: ' + FormatFloat('0.###', pSpaceInfo^.FloorHeight) + ' м';
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

    // Указатель на полилинию этажа / Pointer to floor polyline
    if pSpaceInfo^.FloorPolyline <> nil then
      msg := '  Указатель на полилинию этажа / Floor polyline: 0x' + IntToHex(PtrUInt(pSpaceInfo^.FloorPolyline), 16)
    else
      msg := '  Указатель на полилинию этажа / Floor polyline: nil';
    zcUI.TextMessage(msg, TMWOHistoryOut);

    // Здание / Building
    if pSpaceInfo^.Building <> '' then begin
      msg := '  Здание / Building: ' + pSpaceInfo^.Building;
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

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
