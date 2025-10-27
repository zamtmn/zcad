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
  roomNum, floor, building: string;
  spaceRoom, spaceFloor, spaceBuilding: string;
  i, j: integer;
  pFloor, pBuilding: PGDBObjPolyLine;
  VarExtParent: TVariablesExtender;
  pvdParent: pvardesk;
  parentFloorName, parentBuildingName: string;
begin
  // Очищаем предыдущий список пространств
  // Clear previous spaces list
  ClearSpaces;

  spaceCount := 0;

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
            pEntity := drawings.GetCurrentROOT.ObjArray.iterate(ir);
            continue;
          end;

          // Проверяем наличие переменных пространств
          // Check for space variables
          spaceRoom := '';
          spaceFloor := '';
          spaceBuilding := '';

          pvd := VarExt.entityunit.FindVariable('Space_Room');
          if (pvd <> nil) and (pvd^.data.PTD.TypeName = 'GDBString') then
            spaceRoom := pstring(pvd^.data.Addr.Instance)^;

          pvd := VarExt.entityunit.FindVariable('space_Floor');
          if (pvd <> nil) and (pvd^.data.PTD.TypeName = 'GDBString') then
            spaceFloor := pstring(pvd^.data.Addr.Instance)^;

          pvd := VarExt.entityunit.FindVariable('space_Building');
          if (pvd <> nil) and (pvd^.data.PTD.TypeName = 'GDBString') then
            spaceBuilding := pstring(pvd^.data.Addr.Instance)^;

          // Обрабатываем только пространства с переменной Space_Room (помещения)
          // Process only spaces with Space_Room variable (rooms)
          if spaceRoom <> '' then begin
            // Создаем информацию о пространстве
            // Create space information
            New(pSpaceInfo);
            pSpaceInfo^.Polyline := ppolyline;
            pSpaceInfo^.RoomPolyline := ppolyline;
            pSpaceInfo^.FloorPolyline := nil;
            pSpaceInfo^.BuildingPolyline := nil;
            pSpaceInfo^.Variables := TStringList.Create;
            pSpaceInfo^.Height := 3.0; // Default height / Высота по умолчанию

            // Получаем номер помещения
            // Get room number
            pvd := VarExt.entityunit.FindVariable('RoomNumber');
            if pvd = nil then
              pvd := VarExt.entityunit.FindVariable('NMO_Name');
            if pvd = nil then
              pvd := VarExt.entityunit.FindVariable('Name');

            if (pvd <> nil) and (pvd^.data.PTD.TypeName = 'GDBString') then
              roomNum := pstring(pvd^.data.Addr.Instance)^
            else
              roomNum := 'Room_' + IntToStr(spaceCount);

            pSpaceInfo^.RoomNumber := roomNum;
            pSpaceInfo^.Name := roomNum;

            // Устанавливаем значения по умолчанию
            // Set default values
            floor := spaceFloor;
            if floor = '' then
              floor := '1';
            building := spaceBuilding;
            if building = '' then
              building := 'Building_1';

            pSpaceInfo^.Floor := floor;
            pSpaceInfo^.Building := building;

            FSpacesList.Add(pSpaceInfo);
            inc(spaceCount);
          end;
        end;
      end;

      pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pEntity = nil;

  zcUI.TextMessage('Найдено помещений / Rooms found: ' + IntToStr(spaceCount), TMWOHistoryOut);

  // Второй проход: связываем помещения с этажами и зданиями
  // Second pass: link rooms to floors and buildings
  for i := 0 to FSpacesList.Count - 1 do begin
    pSpaceInfo := PZVSpaceInfo(FSpacesList[i]);

    // Ищем этаж для данного помещения
    // Search for floor for this room
    if pSpaceInfo^.Floor <> '' then begin
      pEntity := drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pEntity <> nil then
        repeat
          if pEntity^.GetObjType = GDBPolyLineID then begin
            pFloor := PGDBObjPolyLine(pEntity);
            if pFloor^.Closed then begin
              VarExtParent := pFloor^.GetExtension<TVariablesExtender>;
              if VarExtParent <> nil then begin
                // Проверяем что это этаж
                // Check that this is a floor
                pvdParent := VarExtParent.entityunit.FindVariable('space_Floor');
                if pvdParent <> nil then begin
                  // Получаем имя этажа
                  // Get floor name
                  pvdParent := VarExtParent.entityunit.FindVariable('Name');
                  if pvdParent = nil then
                    pvdParent := VarExtParent.entityunit.FindVariable('NMO_Name');

                  if (pvdParent <> nil) and (pvdParent^.data.PTD.TypeName = 'GDBString') then begin
                    parentFloorName := pstring(pvdParent^.data.Addr.Instance)^;
                    if parentFloorName = pSpaceInfo^.Floor then begin
                      pSpaceInfo^.FloorPolyline := pFloor;
                      break;
                    end;
                  end;
                end;
              end;
            end;
          end;
          pEntity := drawings.GetCurrentROOT.ObjArray.iterate(ir);
        until pEntity = nil;
    end;

    // Ищем здание для данного помещения
    // Search for building for this room
    if pSpaceInfo^.Building <> '' then begin
      pEntity := drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
      if pEntity <> nil then
        repeat
          if pEntity^.GetObjType = GDBPolyLineID then begin
            pBuilding := PGDBObjPolyLine(pEntity);
            if pBuilding^.Closed then begin
              VarExtParent := pBuilding^.GetExtension<TVariablesExtender>;
              if VarExtParent <> nil then begin
                // Проверяем что это здание
                // Check that this is a building
                pvdParent := VarExtParent.entityunit.FindVariable('space_Building');
                if pvdParent <> nil then begin
                  // Получаем имя здания
                  // Get building name
                  pvdParent := VarExtParent.entityunit.FindVariable('Name');
                  if pvdParent = nil then
                    pvdParent := VarExtParent.entityunit.FindVariable('NMO_Name');

                  if (pvdParent <> nil) and (pvdParent^.data.PTD.TypeName = 'GDBString') then begin
                    parentBuildingName := pstring(pvdParent^.data.Addr.Instance)^;
                    if parentBuildingName = pSpaceInfo^.Building then begin
                      pSpaceInfo^.BuildingPolyline := pBuilding;
                      break;
                    end;
                  end;
                end;
              end;
            end;
          end;
          pEntity := drawings.GetCurrentROOT.ObjArray.iterate(ir);
        until pEntity = nil;
    end;
  end;
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
