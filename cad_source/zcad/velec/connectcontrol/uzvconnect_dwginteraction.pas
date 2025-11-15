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

{**Модуль взаимодействия с чертежом для сбора информации о подключениях устройств}
unit uzvconnect_dwginteraction;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzeentity,
  uzeentdevice,
  uzcdrawings,
  uzcvariablesutils,
  varmandef,
  uzeentsubordinated,
  gzctnrVectorTypes,
  uzeconsts,
  UGDBSelectedObjArray,
  uzvconnect_struct;

{**Собрать устройства с чертежа и извлечь их параметры подключений}
procedure CollectDevicesFromDWG;

{**Получить строковое значение параметра устройства}
function GetDeviceParameterAsString(
  ADevice: PGDBObjDevice;
  const AParamName: String
): String;

implementation

{**Получить строковое значение параметра устройства}
function GetDeviceParameterAsString(
  ADevice: PGDBObjDevice;
  const AParamName: String
): String;
var
  pvd: pvardesk;
begin
  Result := '';

  if ADevice = nil then
    Exit;

  // Поиск параметра в объекте устройства
  pvd := FindVariableInEnt(ADevice, AParamName);

  if pvd <> nil then
    Result := pString(pvd^.data.Addr.Instance)^;
end;

{**Проверить существование параметра с заданным индексом}
function HasParameterWithIndex(
  ADevice: PGDBObjDevice;
  const ABaseName: String;
  AIndex: Integer
): Boolean;
var
  paramName: String;
begin
  // Формируем имя параметра с индексом
  paramName := ABaseName + IntToStr(AIndex) + '_SLTypeagen';
  Result := FindVariableInEnt(ADevice, paramName) <> nil;
end;

{**Извлечь один набор параметров подключения по индексу}
procedure ExtractConnectionByIndex(
  ADevice: PGDBObjDevice;
  const ADeviceName: String;
  AIndex: Integer
);
var
  connectItem: TConnectItem;
  baseName: String;
begin
  // Формируем базовое имя параметров для данного индекса
  baseName := 'SLCABAGEN' + IntToStr(AIndex);

  // Заполняем структуру данных подключения
  connectItem.Device := ADevice;
  connectItem.NMO_Name := ADeviceName;
  connectItem.SLTypeagen := GetDeviceParameterAsString(
    ADevice,
    baseName + '_SLTypeagen'
  );
  connectItem.HeadDeviceName := GetDeviceParameterAsString(
    ADevice,
    baseName + '_HeadDeviceName'
  );
  connectItem.NGHeadDevice := GetDeviceParameterAsString(
    ADevice,
    baseName + '_NGHeadDevice'
  );

  // Добавляем запись в глобальный список
  ConnectList.PushBack(connectItem);
end;

{**Обработать одно устройство и извлечь все его подключения}
procedure ProcessDevice(ADevice: PGDBObjDevice);
var
  deviceName: String;
  connectionIndex: Integer;
begin
  if ADevice = nil then
    Exit;

  // Получаем имя устройства
  deviceName := GetDeviceParameterAsString(ADevice, 'NMO_Name');

  // Если имя пустое, пропускаем устройство
  if deviceName = '' then
    Exit;

  // Перебираем подключения последовательно (1, 2, 3, ...)
  // пока существуют параметры с текущим индексом
  connectionIndex := 1;
  while HasParameterWithIndex(ADevice, 'SLCABAGEN', connectionIndex) do
  begin
    ExtractConnectionByIndex(ADevice, deviceName, connectionIndex);
    Inc(connectionIndex);
  end;
end;

{**Собрать устройства с чертежа и извлечь их параметры подключений}
procedure CollectDevicesFromDWG;
var
  psd:PSelectedObjDesc;
  pEntity: PGDBObjEntity;
  pDevice: PGDBObjDevice;
  ir: itrec;
begin
  // Очищаем список перед новым сбором данных
  ConnectList.Clear;

  // Получаем первый выбранный объект с чертежа
  psd := drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);

  if psd = nil then
    Exit;

  repeat
    pEntity := psd^.objaddr;

    // Проверяем, является ли объект устройством
    if pEntity^.GetObjType = GDBDeviceID then
    begin
      pDevice := PGDBObjDevice(pEntity);
      ProcessDevice(pDevice);
    end;

    psd := drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
  until psd = nil;
end;

end.
