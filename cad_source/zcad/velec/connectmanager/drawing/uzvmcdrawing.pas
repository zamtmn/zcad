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

unit uzvmcdrawing;
{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils, Classes, gvector,
  uzeentdevice, uzeentblockinsert, uzeentity, uzeconsts,
  uzcdrawing, uzcdrawings, uzcvariablesutils,
  varmandef, gzctnrVectorTypes;

type
  TDeviceData = record
    DevName: string;
    HDName: string;
    HDGroup: string;
    CanBeHead: integer;
    Connections: array of record
      HeadDeviceName: string;
      NGHeadDevice: string;
    end;
  end;

  TDeviceDataCollector = class
  public
    function getAllCollectDevices: specialize TVector<TDeviceData>;
    function GetDeviceByName(const ADevName: string): PGDBObjDevice;

    // Функции получения значений переменных устройства
    function GetDeviceZcadId(pdev: PGDBObjDevice): integer;
    function GetDeviceFullName(pdev: PGDBObjDevice): string;
    function GetDeviceBaseName(pdev: PGDBObjDevice): string;
    function GetDeviceRealName(pdev: PGDBObjDevice): string;
    function GetDeviceTraceName(pdev: PGDBObjDevice): string;
    function GetDeviceHeadDev(pdev: PGDBObjDevice): string;
    function GetDeviceFeederNum(pdev: PGDBObjDevice): integer;
    function GetDeviceCanBeHead(pdev: PGDBObjDevice): integer;
    function GetDeviceDevType(pdev: PGDBObjDevice): string;
    function GetDeviceOpMode(pdev: PGDBObjDevice): string;
    function GetDevicePower(pdev: PGDBObjDevice): double;
    function GetDeviceVoltage(pdev: PGDBObjDevice): integer;
    function GetDeviceCosFi(pdev: PGDBObjDevice): double;
  end;

implementation

// Получение коллекции всех устройств с заполнением их данных
// На вход подается список устройств для заполнения
// На выходе коллекция TVector<TDeviceData>
function TDeviceDataCollector.getAllCollectDevices: specialize TVector<TDeviceData>;
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  deviceData: TDeviceData;
  count, i: integer;
  headDevName: string;
  pvd: pvardesk;
begin
  // Создание результирующей коллекции
  Result := specialize TVector<TDeviceData>.Create;

  // Начало итерации по всем объектам в текущем чертеже
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    // Проверка, что объект является устройством
    if pobj^.GetObjType = GDBDeviceID then
    begin
      pdev := PGDBObjDevice(pobj);

      // Получение имени устройства с использованием внутренней функции класса
      deviceData.DevName := GetDeviceFullName(pdev);
      if deviceData.DevName = '' then
        deviceData.DevName := 'ERROR';

      // Получение признака "может быть головным устройством" с использованием внутренней функции класса
      deviceData.CanBeHead := GetDeviceCanBeHead(pdev);

      // Инициализация массива подключений
      SetLength(deviceData.Connections, 0);
      count := 1;

      // Получение имени головного устройства для первого подключения
      pvd := FindVariableInEnt(pdev, 'SLCABAGEN' + inttostr(count) + '_HeadDeviceName');
      if pvd <> nil then
        headDevName := pstring(pvd^.data.Addr.Instance)^
      else
        headDevName := '';

      // Цикл обработки всех подключений устройства
      while headDevName <> '' do
      begin
        // Добавление нового элемента в массив подключений
        SetLength(deviceData.Connections, Length(deviceData.Connections) + 1);
        i := Length(deviceData.Connections) - 1;

        // Заполнение данных о подключении
        deviceData.Connections[i].HeadDeviceName := headDevName;
        pvd := FindVariableInEnt(pdev, 'SLCABAGEN' + inttostr(count) + '_NGHeadDevice');
        if pvd <> nil then
          deviceData.Connections[i].NGHeadDevice := pstring(pvd^.data.Addr.Instance)^
        else
          deviceData.Connections[i].NGHeadDevice := '';

        // Сохранение первого головного устройства и группы
        if i = 0 then
        begin
          deviceData.HDName := headDevName;
          deviceData.HDGroup := deviceData.Connections[i].NGHeadDevice;
        end;

        // Переход к следующему подключению
        Inc(count);
        pvd := FindVariableInEnt(pdev, 'SLCABAGEN' + inttostr(count) + '_HeadDeviceName');
        if pvd <> nil then
          headDevName := pstring(pvd^.data.Addr.Instance)^
        else
          headDevName := '';
      end;

      // Добавление устройства в результирующую коллекцию, если оно имеет корректное головное устройство
      if (deviceData.HDName <> '') and
         (deviceData.HDName <> '???') and
         (deviceData.HDName <> '-') and
         (deviceData.HDName <> 'ERROR') then
        Result.PushBack(deviceData);
    end;

    // Переход к следующему объекту
    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

function TDeviceDataCollector.GetDeviceByName(const ADevName: string): PGDBObjDevice;
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  devName: string;
  pvd: pvardesk;
begin
  Result := nil;

  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    if pobj^.GetObjType = GDBDeviceID then
    begin
      pdev := PGDBObjDevice(pobj);
      pvd := FindVariableInEnt(pdev, 'NMO_Name');
      if pvd <> nil then
        devName := pstring(pvd^.data.Addr.Instance)^
      else
        devName := '';

      if devName = ADevName then
      begin
        Result := pdev;
        Exit;
      end;
    end;

    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

// Получение ид устройства внутри zcad
function TDeviceDataCollector.GetDeviceZcadId(pdev: PGDBObjDevice): integer;
var
  pvd: pvardesk;
begin
  Result := -1;
  pvd := FindVariableInEnt(pdev, 'ZcadId');
  if pvd <> nil then
    Result := pinteger(pvd^.data.Addr.Instance)^;
end;

// Получение полного имени устройства
function TDeviceDataCollector.GetDeviceFullName(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'NMO_Name');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение базового имени устройства
function TDeviceDataCollector.GetDeviceBaseName(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'NMO_BaseName');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение реального имени устройства
function TDeviceDataCollector.GetDeviceRealName(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'NMO_RealName');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение имени трассы к которой принадлежит устройство
function TDeviceDataCollector.GetDeviceTraceName(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'SLCABAGEN1_HeadDeviceName');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение головного устройства
function TDeviceDataCollector.GetDeviceHeadDev(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'SLCABAGEN1_HeadDeviceName');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение номера фидера
function TDeviceDataCollector.GetDeviceFeederNum(pdev: PGDBObjDevice): integer;
var
  pvd: pvardesk;
begin
  Result := -1;
  pvd := FindVariableInEnt(pdev, 'FeederNum');
  if pvd <> nil then
    Result := pinteger(pvd^.data.Addr.Instance)^;
end;

// Получение признака "Я могу быть головным устройством"
function TDeviceDataCollector.GetDeviceCanBeHead(pdev: PGDBObjDevice): integer;
var
  pvd: pvardesk;
begin
  Result := 0;
  pvd := FindVariableInEnt(pdev, 'ANALYSISEM_icanbeheadunit');
  if (pvd <> nil) and (pboolean(pvd^.data.Addr.Instance)^) then
    Result := 1;
end;

// Получение типа устройства
function TDeviceDataCollector.GetDeviceDevType(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'DevType');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение режима работы
function TDeviceDataCollector.GetDeviceOpMode(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'OpMode');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение мощности устройства
function TDeviceDataCollector.GetDevicePower(pdev: PGDBObjDevice): double;
var
  pvd: pvardesk;
begin
  Result := -1;
  pvd := FindVariableInEnt(pdev, 'Power');
  if pvd <> nil then
    Result := pdouble(pvd^.data.Addr.Instance)^;
end;

// Получение напряжения устройства
function TDeviceDataCollector.GetDeviceVoltage(pdev: PGDBObjDevice): integer;
var
  pvd: pvardesk;
  strTemp: string;
begin
  Result := -110;
  pvd := FindVariableInEnt(pdev, 'Voltage');
  if pvd <> nil then
  begin
    strTemp := pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
    if strTemp = '_AC_380V_50Hz' then
      Result := 380
    else if strTemp = '_AC_220V_50Hz' then
      Result := 220
    else
      Result := -110;
  end;
end;

// Получение коэффициента мощности (cosfi)
function TDeviceDataCollector.GetDeviceCosFi(pdev: PGDBObjDevice): double;
var
  pvd: pvardesk;
begin
  Result := -1;
  pvd := FindVariableInEnt(pdev, 'CosPHI');
  if pvd <> nil then
    Result := pdouble(pvd^.data.Addr.Instance)^;
end;

end.
