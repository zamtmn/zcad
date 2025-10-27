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

    property FileName: string read FFileName write FFileName;
    property SpacesList: TList read FSpacesList;
  end;

  {**Структура для хранения информации о пространстве}
  {**Structure for storing space information}
  TZVSpaceInfo = record
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
begin
  // Очищаем предыдущий список пространств
  // Clear previous spaces list
  ClearSpaces;

  spaceCount := 0;

  // Перебираем все примитивы в чертеже
  // Iterate through all entities in the drawing
  pEntity := drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
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
          VarExt := ppolyline^.GetExtension<TVariablesExtender>;

          // Создаем информацию о пространстве
          // Create space information
          New(pSpaceInfo);
          pSpaceInfo^.Polyline := ppolyline;
          pSpaceInfo^.Variables := TStringList.Create;
          pSpaceInfo^.Height := 3.0; // Default height / Высота по умолчанию

          // Пытаемся получить имя из переменных
          // Try to get name from variables
          if VarExt <> nil then begin
            // TODO: извлечь переменные из примитива
            // TODO: extract variables from entity
            pSpaceInfo^.Name := 'Space_' + IntToStr(spaceCount);
          end else begin
            pSpaceInfo^.Name := 'Space_' + IntToStr(spaceCount);
          end;

          FSpacesList.Add(pSpaceInfo);
          inc(spaceCount);
        end;
      end;

      pEntity := drawings.GetCurrentROOT.ObjArray.iterate(ir);
    until pEntity = nil;

  zcUI.TextMessage('Найдено пространств / Spaces found: ' + IntToStr(spaceCount), TMWOHistoryOut);
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
    // Собираем информацию о пространствах
    // Collect information about spaces
    CollectSpacesFromDrawing;

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

end.
