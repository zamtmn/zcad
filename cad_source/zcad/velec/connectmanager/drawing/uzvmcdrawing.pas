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
  varmandef, gzctnrVectorTypes,Dialogs,
  uzvmcstruct, uzccablemanager, uzcentcable, uzegeometry,
  uzglviewareadata, uzcsysvars, uzeentityfactory, uzcutils,
  uzeroot, uzcenitiesvariablesextender, uzccomelectrical,
  uzgldrawcontext,uzeEntBase, uzcinterface,uzegeometrytypes;

type
  // Тип для хранения списка устройств (указателей на устройства)
  TListDev = specialize TVector<pGDBObjDevice>;

  // Структура для хранения устройства вместе с его номером в массиве
  TDevWithNum = record
    dev: pGDBObjDevice;  // Указатель на устройство
    num: integer;        // Номер устройства в массиве примитивов
  end;

  // Тип для хранения списка устройств с номерами
  TListDevWithNum = specialize TVector<TDevWithNum>;

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

    // Получение списка всех устройств типа GDBDeviceID с чертежа
    // Возвращает список структур, содержащих устройство и его номер в массиве примитивов
    function GetAllGDBDevices: TListDevWithNum;

    // Получение списка выбранных устройств с чертежа
    function GetSelectedDevices: TListDev;

    // Получение списка всех устройств с чертежа в виде TListVElectrDevStruct
    function GetAllDevicesAsStructList: TListVElectrDevStruct;

    // Получение списка выбранных устройств с чертежа в виде TListVElectrDevStruct
    function GetSelectedDevicesAsStructList: TListVElectrDevStruct;

    // Получение устройства по номеру в списке примитивов
    function GetDeviceByPrimitiveIndex(AIndex: Integer): PGDBObjDevice;

    // Выделение устройства по его ZcadId
    // Снимает выделение со всех объектов и выделяет устройство с указанным zcadId
    procedure SelectDeviceByZcadId(AZcadId: integer);

    // Выделение множества устройств по их ZcadId
    // Снимает выделение со всех объектов и выделяет устройства с указанными zcadId
    // AZcadIds - список идентификаторов устройств для выделения
    procedure SelectDevicesByZcadIds(const AZcadIds: array of integer);

    // Зуммирование (приближение) к устройству по его ZcadId
    // Зная номер объекта в массиве объектов, производит зуммирование на этом объекте
    // Снимает выделение со всех объектов, выделяет устройство с указанным zcadId и приближает к нему
    procedure ZoomToDeviceByZcadId(AZcadId: integer);

    // Функции получения значений переменных устройства
    function GetDeviceZcadId(pdev: PGDBObjDevice): integer;
    function GetDeviceFullName(pdev: PGDBObjDevice): string;
    function GetDeviceBaseName(pdev: PGDBObjDevice): string;
    function GetDeviceRealName(pdev: PGDBObjDevice): string;
    function GetDeviceTraceName(pdev: PGDBObjDevice;key:integer): string;
    function GetDeviceHeadDev(pdev: PGDBObjDevice;key:integer): string;
    function GetDeviceFeederNum(pdev: PGDBObjDevice;key:integer): integer;
    function GetDeviceCanBeHead(pdev: PGDBObjDevice): integer;
    function GetDeviceDevType(pdev: PGDBObjDevice): string;
    function GetDeviceOpMode(pdev: PGDBObjDevice): string;
    function GetDevicePower(pdev: PGDBObjDevice): double;
    function GetDeviceVoltage(pdev: PGDBObjDevice): integer;
    function GetDeviceCosFi(pdev: PGDBObjDevice): double;
    function GetDevicePhase(pdev: PGDBObjDevice): string;

    // Установка фазы устройства
    // APhaseValue - значение фазы: 'ABC', 'A', 'B', или 'C'
    // Возвращает true при успешной установке, false при ошибке
    function SetDevicePhase(pdev: PGDBObjDevice; const APhaseValue: string): boolean;
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

// Получение списка всех устройств типа GDBDeviceID с текущего чертежа
// На выходе список TListDevWithNum, содержащий структуры с указателями на устройства
// и их номерами в массиве примитивов
function TDeviceDataCollector.GetAllGDBDevices: TListDevWithNum;
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  devWithNum: TDevWithNum;
  primitiveIndex: integer;
begin
  // Создание результирующего списка устройств с номерами
  Result := TListDevWithNum.Create;

  primitiveIndex := 0;

  // Начало итерации по всем объектам в текущем чертеже
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    // Проверка, что объект является устройством типа GDBDeviceID
    if pobj^.GetObjType = GDBDeviceID then
    begin
      // Приведение типа к PGDBObjDevice
      pdev := PGDBObjDevice(pobj);

      // Заполнение структуры: указатель на устройство и его номер в массиве примитивов
      devWithNum.dev := pdev;
      devWithNum.num := primitiveIndex;

      // Добавление структуры в результирующий список
      Result.PushBack(devWithNum);
    end;

    // Увеличение индекса примитива (для всех объектов, не только устройств)
    Inc(primitiveIndex);

    // Переход к следующему объекту
    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

// Получение списка выбранных пользователем устройств с чертежа
// Функция запускает режим сбора устройств: пользователь по очереди выбирает устройства,
// и эти устройства записываются в той же очереди в список устройств
// На выходе список TListDev, содержащий указатели на выбранные устройства типа GDBDeviceID
function TDeviceDataCollector.GetSelectedDevices: TListDev;
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
begin
  // Создание результирующего списка устройств
  Result := TListDev.Create;

  // Начало итерации по всем объектам в текущем чертеже
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    // Проверка, что объект выбран пользователем и является устройством типа GDBDeviceID
    if pobj^.selected and (pobj^.GetObjType = GDBDeviceID) then
    begin
      // Приведение типа к PGDBObjDevice
      pdev := PGDBObjDevice(pobj);

      // Добавление указателя на устройство в результирующий список
      Result.PushBack(pdev);
    end;

    // Переход к следующему объекту
    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

// Получение списка всех устройств с чертежа в виде структуры TListVElectrDevStruct
// Функция собирает список всех устройств с чертежа и преобразует их в TListVElectrDevStruct
// На выходе список TListVElectrDevStruct, содержащий данные всех устройств типа GDBDeviceID
function TDeviceDataCollector.GetAllDevicesAsStructList: TListVElectrDevStruct;
var
  devicesListWithNum: TListDevWithNum;
  pdev: PGDBObjDevice;
  deviceStruct: TVElectrDevStruct;
  i,count: integer;
begin
  // Создание результирующего списка структур устройств
  Result := TListVElectrDevStruct.Create;

  // Получение списка всех устройств с чертежа (с номерами в массиве примитивов)
  devicesListWithNum := GetAllGDBDevices;

  try
    // Преобразование каждого устройства в структуру TVElectrDevStruct
    for i := 0 to devicesListWithNum.Size - 1 do
    begin
      // Получение указателя на устройство из структуры
      pdev := devicesListWithNum[i].dev;

      // Заполнение структуры данными устройства
      deviceStruct.zcadid := devicesListWithNum[i].num;
      deviceStruct.fullname := GetDeviceFullName(pdev);
      deviceStruct.basename := GetDeviceBaseName(pdev);
      deviceStruct.realname := GetDeviceRealName(pdev);
      deviceStruct.canbehead := GetDeviceCanBeHead(pdev);
      deviceStruct.devtype := GetDeviceDevType(pdev);
      deviceStruct.opmode := GetDeviceOpMode(pdev);
      deviceStruct.power := GetDevicePower(pdev);
      deviceStruct.voltage := GetDeviceVoltage(pdev);
      deviceStruct.cosfi := GetDeviceCosFi(pdev);
      deviceStruct.phase := GetDevicePhase(pdev);

      count:=1;

      // Цикл по всем головным устройствам (подключениям)
      deviceStruct.headdev := GetDeviceHeadDev(pdev,count);
      while (deviceStruct.headdev<>'ERROR') do
        begin
          deviceStruct.tracename := GetDeviceTraceName(pdev,count);
          deviceStruct.feedernum := GetDeviceFeederNum(pdev,count);
          deviceStruct.numconnect := count;

          // Добавление структуры в результирующий список
          Result.PushBack(deviceStruct);

          //zcUI.TextMessage('Количество выбранных примитивов: ' + inttostr(count) + ' шт.',TMWOHistoryOut);
          inc(count);
          deviceStruct.headdev := GetDeviceHeadDev(pdev,count);
        end;
    end;
  finally
    // Освобождение списка устройств с номерами
    devicesListWithNum.Free;
  end;
end;

// Получение списка выбранных устройств с чертежа в виде структуры TListVElectrDevStruct
// Функция собирает список выбранных пользователем устройств с чертежа и преобразует их в TListVElectrDevStruct
// На выходе список TListVElectrDevStruct, содержащий данные выбранных устройств типа GDBDeviceID
function TDeviceDataCollector.GetSelectedDevicesAsStructList: TListVElectrDevStruct;
var
  devicesList: TListDev;
  pdev: PGDBObjDevice;
  deviceStruct: TVElectrDevStruct;
  i,count: integer;
begin
  // Создание результирующего списка структур устройств
  Result := TListVElectrDevStruct.Create;

  // Получение списка выбранных устройств с чертежа
  devicesList := GetSelectedDevices;

  try
    // Преобразование каждого устройства в структуру TVElectrDevStruct
    for i := 0 to devicesList.Size - 1 do
    begin
      pdev := devicesList[i];

      // Заполнение структуры данными устройства
      deviceStruct.zcadid := GetDeviceZcadId(pdev);
      deviceStruct.fullname := GetDeviceFullName(pdev);
      deviceStruct.basename := GetDeviceBaseName(pdev);
      deviceStruct.realname := GetDeviceRealName(pdev);
      deviceStruct.canbehead := GetDeviceCanBeHead(pdev);
      deviceStruct.devtype := GetDeviceDevType(pdev);
      deviceStruct.opmode := GetDeviceOpMode(pdev);
      deviceStruct.power := GetDevicePower(pdev);
      deviceStruct.voltage := GetDeviceVoltage(pdev);
      deviceStruct.cosfi := GetDeviceCosFi(pdev);
      deviceStruct.phase := GetDevicePhase(pdev);

      count:=1;
      //while (pvd<>nil) do begin
      //  pvd:=FindVariableInEnt(pdev,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
      //  if (pvd<>nil) then begin
      //     Query.Params.ParamByName('hdname').AsString := pstring(pvd^.data.Addr.Instance)^;
      //  end
      //  else
      //     begin
      //     errorData:=false;
      //     Query.Params.ParamByName('hdname').AsString := 'ERROR';
      //     end;
      //
      //  pvd:=FindVariableInEnt(pdev,'SLCABAGEN'+inttostr(count2)+'_NGHeadDevice');
      //  if (pvd<>nil) then
      //     Query.Params.ParamByName('hdgroup').AsString := pstring(pvd^.data.Addr.Instance)^
      //  else
      //  begin
      //     errorData:=false;
      //     Query.Params.ParamByName('hdgroup').AsString := 'ERROR';
      //  end;
      //  if errorData then
      //    Query.ExecSQL;
      //  inc(count2);
      //  pvd:=FindVariableInEnt(pdev,'SLCABAGEN'+inttostr(count2)+'_HeadDeviceName');
      //end;
      //deviceStruct.tracename := GetDeviceTraceName(pdev);
      //deviceStruct.headdev := GetDeviceHeadDev(pdev);
      //deviceStruct.feedernum := GetDeviceFeederNum(pdev);
      // Добавление структуры в результирующий список
      Result.PushBack(deviceStruct);
    end;
  finally
    // Освобождение списка указателей на устройства
    devicesList.Free;
  end;
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
  pvd := FindVariableInEnt(pdev, 'realnamedev');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение имени трассы к которой принадлежит устройство
function TDeviceDataCollector.GetDeviceTraceName(pdev: PGDBObjDevice;key:integer): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'SLCABAGEN'+inttostr(key)+'_SLTypeagen');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение головного устройства
function TDeviceDataCollector.GetDeviceHeadDev(pdev: PGDBObjDevice;key:integer): string;
var
  pvd: pvardesk;
begin
  Result := 'ERROR';
  pvd := FindVariableInEnt(pdev, 'SLCABAGEN'+inttostr(key)+'_HeadDeviceName');
  if pvd <> nil then
    Result := pstring(pvd^.data.Addr.Instance)^;
end;

// Получение номера фидера
function TDeviceDataCollector.GetDeviceFeederNum(pdev: PGDBObjDevice;key:integer): integer;
var
  pvd: pvardesk;
  IntValue:integer;
begin
  Result := -1;
  pvd := FindVariableInEnt(pdev, 'SLCABAGEN'+inttostr(key)+'_NGHeadDevice');
  try
  if pvd <> nil then
    if TryStrToInt(pstring(pvd^.data.Addr.Instance)^, IntValue) then
       Result := IntValue
    else
       Result := -22;
  except
    Result := -22;
  end;
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
  pvd := FindVariableInEnt(pdev, 'ENTID_Function');
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

// Получение фазы
function TDeviceDataCollector.GetDevicePhase(pdev: PGDBObjDevice): string;
var
  pvd: pvardesk;
  strTemp: string;
begin
  Result := 'Error';
  pvd := FindVariableInEnt(pdev, 'Phase');
  if pvd <> nil then
  begin
    strTemp := pvd^.data.ptd^.GetValueAsString(pvd^.data.Addr.Instance);
    if strTemp = '_ABC' then
      Result := 'ABC'
    else if strTemp = '_A' then
      Result := 'A'
    else if strTemp = '_B' then
      Result := 'B'
    else if strTemp = '_C' then
      Result := 'C'
    else
      Result := 'Error';
  end;
end;

// Установка фазы устройства
// APhaseValue - значение фазы: 'ABC', 'A', 'B', или 'C'
// Возвращает true при успешной установке, false при ошибке
function TDeviceDataCollector.SetDevicePhase(pdev: PGDBObjDevice; const APhaseValue: string): boolean;
var
  pvd: pvardesk;
  enumValue: string;
begin
  Result := false;

  // Проверка валидности входного значения и преобразование в enum-значение
  if APhaseValue = 'ABC' then
    enumValue := '_ABC'
  else if APhaseValue = 'A' then
    enumValue := '_A'
  else if APhaseValue = 'B' then
    enumValue := '_B'
  else if APhaseValue = 'C' then
    enumValue := '_C'
  else
  begin
    // Неверное значение фазы
    ShowMessage('Ошибка: недопустимое значение фазы "' + APhaseValue + '". Допустимые значения: ABC, A, B, C');
    Exit;
  end;

  // Поиск переменной Phase в устройстве
  pvd := FindVariableInEnt(pdev, 'Phase');
  if pvd = nil then
  begin
    ShowMessage('Ошибка: переменная Phase не найдена в устройстве');
    Exit;
  end;

  // Установка нового значения через SetValueFromString
  try
    pvd^.data.ptd^.SetValueFromString(pvd^.data.Addr.Instance, enumValue);
    Result := true;
  except
    on E: Exception do
    begin
      ShowMessage('Ошибка при установке значения фазы: ' + E.Message);
      Result := false;
    end;
  end;
end;

// Получение устройства по номеру в списке примитивов
// На входе: AIndex - номер устройства в списке примитивов
// На выходе: PGDBObjDevice - указатель на устройство, или nil если устройство не найдено или не является GDBDeviceID
function TDeviceDataCollector.GetDeviceByPrimitiveIndex(AIndex: Integer): PGDBObjDevice;
var
  pobj: pGDBObjBaseEntity;
begin
  Result := nil;

  // Проверка корректности индекса
  if (AIndex < 0) or (AIndex >= drawings.GetCurrentROOT^.ObjArray.Count) then
  begin
    // Вывод сообщения об ошибке - индекс выходит за границы массива
    ShowMessage('Ошибка: индекс ' + inttostr(AIndex) + ' выходит за границы массива примитивов (0..'+  inttostr(drawings.GetCurrentROOT^.ObjArray.Count - 1) + ')');
    Exit;
  end;

  // Получение объекта по индексу
  pobj := drawings.GetCurrentROOT^.ObjArray.getDataMutable(AIndex);

  // Проверка, что объект существует
  if pobj = nil then
  begin
    ShowMessage('Ошибка: объект по индексу ' + IntToStr(AIndex) + ' не найден');
    Exit;
  end;

  // Проверка, что объект является устройством типа GDBDeviceID
  if pobj^.GetObjType <> GDBDeviceID then
  begin
    ShowMessage('Ошибка: объект по индексу ' + IntToStr(AIndex) + ' не является устройством (GDBDeviceID)');
    Exit;
  end;

  // Приведение типа к PGDBObjDevice и возврат результата
  Result := PGDBObjDevice(pobj);
end;

// Выделение устройства по его ZcadId
// Снимает выделение со всех объектов и выделяет устройство с указанным zcadId
// На входе: AZcadId - идентификатор устройства в ZCAD
procedure TDeviceDataCollector.SelectDeviceByZcadId(AZcadId: integer);
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  currentZcadId: integer;
  DC:TDrawContext;
begin
  currentZcadId:=0;
  // Начало итерации по всем объектам в текущем чертеже
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    // Снимаем выделение со всех объектов
    //pobj^.selected := false;

    // Проверяем, является ли объект устройством типа GDBDeviceID
    if pobj^.GetObjType = GDBDeviceID then
    begin
      pdev := PGDBObjDevice(pobj);
      //currentZcadId := GetDeviceZcadId(pdev);

      // Если zcadId совпадает с искомым, выделяем устройство
      if currentZcadId = AZcadId then
      begin
        //zcUI.TextMessage('currentZcadId: ' + inttostr(currentZcadId),TMWOHistoryOut);
              pobj^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,
                        @drawings.GetCurrentDWG^.Selector);

              zcUI.Do_GUIaction(drawings.GetCurrentDWG^.wa, zcMsgUIActionSelectionChanged);
        //pobj^.selected := true;
      end;
    end;
    inc(currentZcadId);
    // Переход к следующему объекту
    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

// Выделение множества устройств по их ZcadId
// Снимает выделение со всех объектов и выделяет устройства с указанными zcadId
// На входе: AZcadIds - массив идентификаторов устройств в ZCAD
procedure TDeviceDataCollector.SelectDevicesByZcadIds(const AZcadIds: array of integer);
var
  pobj: pGDBObjEntity;
  pdev: PGDBObjDevice;
  ir: itrec;
  currentZcadId: integer;
  i: integer;
  shouldSelect: boolean;
begin
  currentZcadId:=0;
  // Начало итерации по всем объектам в текущем чертеже
  pobj := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if pobj <> nil then
  repeat
    // Снимаем выделение со всех объектов
    //pobj^.selected := false;

    // Проверяем, является ли объект устройством типа GDBDeviceID
    if pobj^.GetObjType = GDBDeviceID then
    begin
      pdev := PGDBObjDevice(pobj);
      //currentZcadId := GetDeviceZcadId(pdev);

      // Проверяем, есть ли текущий zcadId в списке для выделения
      shouldSelect := false;
      for i := Low(AZcadIds) to High(AZcadIds) do
      begin
        if currentZcadId = AZcadIds[i] then
        begin
          shouldSelect := true;
          Break;
        end;
      end;

      // Если zcadId найден в списке, выделяем устройство
      if shouldSelect then
      begin
        pobj^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,
          @drawings.GetCurrentDWG^.Selector);
        zcUI.Do_GUIaction(drawings.GetCurrentDWG^.wa, zcMsgUIActionSelectionChanged);
        //pobj^.selected := true;
      end;
    end;
    inc(currentZcadId);
    // Переход к следующему объекту
    pobj := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until pobj = nil;
end;

// Зуммирование (приближение) к устройству по его ZcadId
// Зная номер объекта в массиве объектов, производит зуммирование на этом объекте
// Снимает выделение со всех объектов, выделяет устройство с указанным zcadId и приближает к нему
// На входе: AZcadId - идентификатор устройства в ZCAD
procedure TDeviceDataCollector.ZoomToDeviceByZcadId(AZcadId: integer);
begin
  // Выделяем устройство по его zcadId
  SelectDeviceByZcadId(AZcadId);

  // Приближаем камеру к выделенному устройству
  drawings.GetCurrentDWG^.wa.ZoomSel;
end;

// Процедура для сбора длин и типов кабелей
// Копия функции OPS_SPBuild из uzccomops.pas
procedure CollectCablesLengthsAndTypes;
var count: Integer;
    pcabledesk:PTCableDesctiptor;
    PCableSS:PGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
    cman:TCableManager;
    pv:pGDBObjDevice;

    coord,currentcoord:TzePoint3d;
    pvmc:pvardesk;

    nodeend,nodestart:PGDBObjDevice;
    isfirst:boolean;
    startmat,endmat,startname,endname,prevname:String;

    uy,dy:Double;
    lsave:PPointer;
    DC:TDrawContext;
    pCableSSvarext,ppvvarext,pnodeendvarext:TVariablesExtender;
begin
  ////if drawings.GetCurrentROOT.ObjArray.Count = 0 then exit;
  //dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  //cman.init;
  //cman.build;
  //
  //       //drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  //
  //coord:=uzegeometry.NulVertex;
  //coord.y:=0;
  //coord.x:=0;
  //prevname:='';
  //pcabledesk:=cman.beginiterate(ir);
  //if pcabledesk<>nil then
  //repeat
  //      PCableSS:=pcabledesk^.StartSegment;
  //      pCableSSvarext:=PCableSS^.GetExtension<TVariablesExtender>;
  //      pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_Type');
  //
  //      if pvd<>nil then
  //      begin
  //           if (pcabledesk.StartDevice<>nil) then
  //           begin
  //                zcUI.TextMessage(pcabledesk.Name,TMWOHistoryOut);
  //                currentcoord:=coord;
  //                PTCableType(pvd^.data.Addr.Instance)^:=TCT_ShleifOPS;
  //                lsave:=SysVar.dwg.DWG_CLayer^;
  //                SysVar.dwg.DWG_CLayer^:=drawings.GetCurrentDWG.LayerTable.GetSystemLayer;
  //
  //                drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'DEVICE_CABLE_MARK');
  //                pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,
  //                                                    drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
  //                                                    currentcoord, 1, 0,'DEVICE_CABLE_MARK');
  //                zcSetEntPropFromCurrentDrawingProp(pv);
  //
  //                SysVar.dwg.DWG_CLayer^:=lsave;
  //                ppvvarext:=pv^.GetExtension<TVariablesExtender>;
  //                pvmc:=ppvvarext.entityunit.FindVariable('CableName');
  //                if pvmc<>nil then
  //                begin
  //                    pstring(pvmc^.data.Addr.Instance)^:=pcabledesk.Name;
  //                end;
  //                Cable2CableMark(pcabledesk,pv);
  //                pv^.formatentity(drawings.GetCurrentDWG^,dc);
  //                pv^.getoutbound(dc);
  //
  //                dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
  //                uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;
  //
  //                pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
  //                pv^.Formatentity(drawings.GetCurrentDWG^,dc);
  //                currentcoord.y:=currentcoord.y+dy+uy;
  //
  //
  //                isfirst:=true;
  //                pcabledesk^.Devices.beginiterate(ir_inNodeArray);
  //                nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
  //                nodestart:=nil;
  //                count:=0;
  //                if nodeend<>nil then
  //                repeat
  //                      if nodeend^.bp.ListPos.Owner<>pointer(drawings.GetCurrentROOT) then
  //                                                                        nodeend:=pointer(nodeend^.bp.ListPos.Owner);
  //                      pnodeendvarext:=nodeend^.GetExtension<TVariablesExtender>;
  //                      pvd:=pnodeendvarext.entityunit.FindVariable('NMO_Name');
  //                      if pvd<>nil then
  //                      begin
  //                           endname:=pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance);
  //                      end
  //                         else endname:='';
  //                      pvd:=pnodeendvarext.entityunit.FindVariable('DB_link');
  //                      if pvd<>nil then
  //                      begin
  //                          endmat:=nodeend^.Name+pvd^.data.PTD.GetValueAsString(pvd^.data.Addr.Instance);
  //                          if isfirst then
  //                                         begin
  //                                              isfirst:=false;
  //                                              nodestart:=nodeend;
  //                                              startmat:=endmat;
  //                                              startname:=endname;
  //                                         end;
  //                          if startmat<>endmat then
  //                          begin
  //                               InsertDat(nodestart^.name,startname,prevname,count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot);
  //                               count:=0;
  //                               nodestart:=nodeend;
  //                               startmat:=endmat;
  //                               startname:=endname;
  //                          end;
  //                          inc(count);
  //                      end;
  //                      prevname:=endname;
  //                      nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
  //                until nodeend=nil;
  //                if nodestart<>nil then
  //                                      InsertDat(nodestart^.name,startname,endname,count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(drawings.GetCurrentDWG^)
  //                                  else
  //                                      InsertDat('_error_here',startname,endname,count,currentcoord,drawings.GetCurrentDWG.ConstructObjRoot).YouDeleted(drawings.GetCurrentDWG^);
  //
  //                pvd:=pCableSSvarext.entityunit.FindVariable('CABLE_WireCount');
  //                if pvd=nil then
  //                               coord.x:=coord.x+12
  //                           else
  //                               begin
  //                                    if PInteger(pvd^.data.Addr.Instance)^<>0 then
  //                                                                                coord.x:=coord.x+6*PInteger(pvd^.data.Addr.Instance)^
  //                                                                            else
  //                                                                                coord.x:=coord.x+12;
  //                               end;
  //           end
  //
  //      end;
  //
  //
  //pcabledesk:=cman.iterate(ir);
  //until pcabledesk=nil;
  //
  //cman.done;
  //
  //zcRedrawCurrentDrawing;
end;

end.
