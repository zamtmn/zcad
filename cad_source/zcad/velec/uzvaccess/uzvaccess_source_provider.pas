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
  uzvgetentity, uzvaccess_types, uzclog;

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
  AEntityMode: Integer;
  const AEntityModeParam: String
);
begin
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

  programlog.LogOutFormatStr(
    'uzvaccess: Загружено примитивов: %d',
    [FEntityList.Count],
    LM_Info
  );
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
    programlog.LogOutFormatStr(
      'uzvaccess: Попытка получить свойство из nil-объекта',
      [],
      LM_Info
    );
    Exit;
  end;

  pEntity := PGDBObjEntity(AEntity);

  // Ищем переменную по имени
  pvd := pEntity^.specialize GetVariable<string>(APropName);

  if pvd = nil then
    Exit;

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
  end;
end;

end.
