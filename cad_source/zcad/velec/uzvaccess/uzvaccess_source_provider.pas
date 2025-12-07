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

unit uzvaccess_source_provider;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, Variants,
  uzeentity, varmandef, uzcvariablesutils,
  uzvgetentity, uzvaccess_types, uzvaccess_logger;

type
  {**
    Интерфейс для получения данных из примитивов

    Предоставляет единый интерфейс для доступа к свойствам
    различных источников данных (примитивы, структуры)
  **}
  IDataSourceProvider = interface
    ['{E5B4D8A0-3F4E-4C2F-8B5D-1A2B3C4D5E6F}']

    // Получить список объектов для экспорта
    function GetEntities(ATypeData: TSourceDataType): TList;

    // Получить значение свойства объекта по имени
    function GetPropertyValue(
      AEntity: Pointer;
      const APropName: String
    ): Variant;

    // Проверить наличие свойства у объекта
    function HasProperty(
      AEntity: Pointer;
      const APropName: String
    ): Boolean;
  end;

  {**
    Провайдер данных из примитивов ZCAD

    Извлекает данные из примитивов (device/superline/cable)
    используя механизм переменных
  **}
  TEntitySourceProvider = class(TInterfacedObject, IDataSourceProvider)
  private
    FLogger: TExportLogger;
    FEntityList: TEntityVector;
    FEntityMode: Integer;
    FEntityModeParam: String;

    // Очистить список примитивов
    procedure ClearEntities;

    // Загрузить примитивы из чертежа
    procedure LoadEntities(ATypeData: TSourceDataType);

    // Преобразовать TSourceDataType в строку для поиска
    function GetEntityTypeString(ATypeData: TSourceDataType): String;

  public
    constructor Create(
      ALogger: TExportLogger;
      AEntityMode: Integer;
      const AEntityModeParam: String
    );
    destructor Destroy; override;

    // IDataSourceProvider
    function GetEntities(ATypeData: TSourceDataType): TList;
    function GetPropertyValue(
      AEntity: Pointer;
      const APropName: String
    ): Variant;
    function HasProperty(
      AEntity: Pointer;
      const APropName: String
    ): Boolean;
  end;

implementation

uses
  uzeconsts, uzcenitiesvariablesextender;

{ TEntitySourceProvider }

constructor TEntitySourceProvider.Create(
  ALogger: TExportLogger;
  AEntityMode: Integer;
  const AEntityModeParam: String
);
begin
  FLogger := ALogger;
  FEntityMode := AEntityMode;
  FEntityModeParam := AEntityModeParam;
  FEntityList := nil;
end;

destructor TEntitySourceProvider.Destroy;
begin
  ClearEntities;
  inherited Destroy;
end;

procedure TEntitySourceProvider.ClearEntities;
begin
  if FEntityList <> nil then
  begin
    FEntityList.Free;
    FEntityList := nil;
  end;
end;

function TEntitySourceProvider.GetEntityTypeString(
  ATypeData: TSourceDataType
): String;
begin
  case ATypeData of
    sdtDevice: Result := 'Device';
    sdtSuperLine: Result := 'SuperLine';
    sdtCable: Result := 'Cable';
  else
    Result := '';
  end;
end;

procedure TEntitySourceProvider.LoadEntities(ATypeData: TSourceDataType);
var
  typeStr: String;
begin
  ClearEntities;

  FLogger.LogDebug(Format(
    'Загрузка примитивов: тип=%s, режим=%d',
    [SourceDataTypeToString(ATypeData), FEntityMode]
  ));

  // Для режима 2 (поиск по ENTID_Type) используем параметр
  if FEntityMode = 2 then
  begin
    typeStr := FEntityModeParam;
  end
  else
  begin
    typeStr := GetEntityTypeString(ATypeData);
  end;

  // Получаем примитивы через uzvGetEntity
  FEntityList := uzvGetEntity(FEntityMode, typeStr);

  FLogger.LogInfo(Format(
    'Загружено примитивов: %d',
    [FEntityList.Count]
  ));
end;

function TEntitySourceProvider.GetEntities(
  ATypeData: TSourceDataType
): TList;
var
  i: Integer;
  pEntity: PGDBObjEntity;
  objType: TObjID;
  targetType: TObjID;
begin
  Result := TList.Create;

  // Загружаем примитивы
  LoadEntities(ATypeData);

  if FEntityList = nil then
    Exit;

  // Определяем целевой тип объектов
  case ATypeData of
    sdtDevice: targetType := GDBDeviceID;
    sdtSuperLine: targetType := GDBSuperLineID;
    sdtCable: targetType := GDBCableID;
  else
    targetType := 0;
  end;

  // Фильтруем примитивы по типу
  for i := 0 to FEntityList.Count - 1 do
  begin
    pEntity := FEntityList[i];

    if pEntity = nil then
      Continue;

    objType := pEntity^.GetObjType;

    // Проверяем соответствие типа
    if (targetType = 0) or (objType = targetType) then
      Result.Add(pEntity);
  end;

  FLogger.LogDebug(Format(
    'Отфильтровано примитивов: %d из %d',
    [Result.Count, FEntityList.Count]
  ));
end;

function TEntitySourceProvider.HasProperty(
  AEntity: Pointer;
  const APropName: String
): Boolean;
var
  pEntity: PGDBObjEntity;
  pvd: pvardesk;
begin
  Result := False;

  if AEntity = nil then
    Exit;

  pEntity := PGDBObjEntity(AEntity);

  // Ищем переменную по имени
  pvd := pEntity^.specialize GetVariable<string>(APropName);

  Result := (pvd <> nil);
end;

function TEntitySourceProvider.GetPropertyValue(
  AEntity: Pointer;
  const APropName: String
): Variant;
var
  pEntity: PGDBObjEntity;
  pvd: pvardesk;
  valueStr: String;
  valueInt: Integer;
  valueFloat: Double;
begin
  Result := Null;

  if AEntity = nil then
  begin
    FLogger.LogWarning('Попытка получить свойство из nil-объекта');
    Exit;
  end;

  pEntity := PGDBObjEntity(AEntity);

  // Ищем переменную по имени
  pvd := pEntity^.specialize GetVariable<string>(APropName);

  if pvd = nil then
  begin
    FLogger.LogDebug(Format(
      'Переменная "%s" не найдена в примитиве',
      [APropName]
    ));
    Exit;
  end;

  // Получаем значение переменной в зависимости от её типа
  case pvd^.data.PTD^.TypeName of
    'GDBString',
    'GDBAnsiString':
    begin
      valueStr := pstring(pvd^.data.Instance)^;
      Result := valueStr;
    end;

    'GDBInteger':
    begin
      valueInt := PGDBInteger(pvd^.data.Instance)^;
      Result := valueInt;
    end;

    'GDBDouble',
    'GDBFloat':
    begin
      valueFloat := PGDBDouble(pvd^.data.Instance)^;
      Result := valueFloat;
    end;

  else
    // Для остальных типов пытаемся получить строковое представление
    valueStr := pstring(pvd^.data.Instance)^;
    Result := valueStr;

    FLogger.LogDebug(Format(
      'Неизвестный тип переменной "%s": %s',
      [APropName, pvd^.data.PTD^.TypeName]
    ));
  end;

  FLogger.LogDebug(Format(
    'Получено значение свойства "%s" = "%s"',
    [APropName, VarToStr(Result)]
  ));
end;

end.
