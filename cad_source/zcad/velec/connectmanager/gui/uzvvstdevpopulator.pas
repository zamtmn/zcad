unit uzvvstdevpopulator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, laz.VirtualTrees, uzvmcstruct, gvector;

type
  PGridNodeData = ^TGridNodeData;
  TGridNodeData = record
    DevName: string;
    RealName: string;
    Power: double;
    CosF: double;
    Voltage: integer;
    Phase: string;
    HDName: string;
    HDGroup: integer;
    PathHD: string;
    FullPathHD: string;
  end;
  //PGridNodeData = ^TGridNodeData;
  //TGridNodeData = record
  //  DevName: string;
  //  HDName: string;
  //  HDGroup: integer;
  //  PathHD: string;
  //  FullPathHD: string;
  //end;

  { TVstDevPopulator }
  // Класс для заполнения виртуального дерева устройств (vstDev)
  // Отвечает за формирование записей в TLazVirtualStringTree с группировкой по feedernum
  TVstDevPopulator = class
  private
    FVstDev: TLazVirtualStringTree;          // Ссылка на виртуальное дерево
    FDevicesList: TListVElectrDevStruct;     // Ссылка на список устройств
    deepConnectDev:integer;                  // глубина подключения
    filteredDevices: TListVElectrDevStruct;  // Отфильтрованный список устройств
    // Вспомогательная функция для проверки соответствия путей
    // Возвращает true, если последнее слово из Str1 является последним словом в Str2
    function ProcessStrings(const Str1, Str2: string): integer;

    // Получает отфильтрованный список устройств по условию filterPath
    // filterPath - путь для фильтрации (пустая строка = вернуть все устройства)
    // Возвращает новый список, содержащий только устройства, удовлетворяющие условию
    function GetFilteredDevicesList(const filterPath: string): TListVElectrDevStruct;

    // Проверяет, имеют ли два устройства одинаковые атрибуты для группировки
    // (basename, realname, Power, Voltage, cosF, Phase)
    function DevicesHaveSameAttributes(const dev1, dev2: TVElectrDevStruct): boolean;

    // Создает родительский узел группы для feedernum (уровень 1)
    function CreateGroupNode(const device: TVElectrDevStruct): PVirtualNode;

    // Создает узел подгруппы устройств с одинаковыми атрибутами (уровень 2)
    function CreateDeviceGroupNode(ParentNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;

    // Создает дочерний узел устройства под группой
    function CreateDeviceNode(GroupNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;

    // Заполняет данные узла группы (уровень 1)
    procedure FillGroupNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);

    // Заполняет данные узла подгруппы устройств (уровень 2)
    procedure FillDeviceGroupNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);

    // Заполняет данные узла устройства
    procedure FillDeviceNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);

  public
    // Конструктор класса
    // AVstDev - виртуальное дерево для заполнения
    // ADevicesList - список устройств для отображения
    constructor Create(AVstDev: TLazVirtualStringTree; ADevicesList: TListVElectrDevStruct);

    // Основной метод для заполнения дерева устройств
    // filterPath - путь иерархии для фильтрации (пустая строка = показать все)
    // Группирует устройства по feedernum, создавая родительские узлы для каждой группы
    procedure PopulateTree(const filterPath: string);
  end;

implementation

{ TVstDevPopulator }

constructor TVstDevPopulator.Create(AVstDev: TLazVirtualStringTree; ADevicesList: TListVElectrDevStruct);
begin
  inherited Create;
  FVstDev := AVstDev;
  FDevicesList := ADevicesList;
end;

// Вспомогательная функция для проверки соответствия путей
// Разбивает строки на части по разделителю '~' и проверяет,
// является ли последнее слово из Str1 последним словом в Str2
function TVstDevPopulator.ProcessStrings(const Str1, Str2: string): integer;
var
  Parts1, Parts2: TStringList;
  LastWordFromStr1: string;
  IndexInStr2, i: Integer;
begin
  Result := 0;

  Parts1 := TStringList.Create;
  Parts2 := TStringList.Create;
  try
    // Разбиваем первую строку на части
    ExtractStrings(['~'], [], PChar(Str1), Parts1);
    if Parts1.Count = 0 then Exit;

    // Получаем последнее слово из первой строки
    LastWordFromStr1 := Parts1[Parts1.Count - 1];

    // Разбиваем вторую строку на части
    ExtractStrings(['~'], [], PChar(Str2), Parts2);
    if Parts2.Count = 0 then Exit;

    // Ищем последнее слово из первой строки во второй строке
    IndexInStr2 := -1;
    for i := 0 to Parts2.Count - 1 do
    begin
      if Parts2[i] = LastWordFromStr1 then
      begin
        IndexInStr2 := i;
        Break;
      end;
    end;

    if IndexInStr2 = -1 then Exit;

    // Определяем сколько слов осталось после найденного слова
    result := Parts2.Count - IndexInStr2 - 1;


  finally
    Parts1.Free;
    Parts2.Free;
  end;
end;

// Получает отфильтрованный список устройств по условию filterPath
// Создает новый список, содержащий только те устройства, для которых
// выполняется условие: (filterPath = '') or (device.pathHD = filterPath)
function TVstDevPopulator.GetFilteredDevicesList(const filterPath: string): TListVElectrDevStruct;
var
  i: integer;
  device: TVElectrDevStruct;
begin
  Result := TListVElectrDevStruct.Create;

  // Проходим по всем устройствам в исходном списке
  for i := 0 to FDevicesList.Size - 1 do
  begin
    device := FDevicesList[i];

    // Если фильтр пустой или pathHD совпадает с filterPath, добавляем устройство
    if (filterPath = '') or (device.pathHD = filterPath) then
    begin
      Result.PushBack(device);
    end;
  end;
end;

// Проверяет, имеют ли два устройства одинаковые атрибуты для группировки на уровне 2
// Сравниваются: basename, realname, Power, Voltage, cosF, Phase
function TVstDevPopulator.DevicesHaveSameAttributes(const dev1, dev2: TVElectrDevStruct): boolean;
const
  EPSILON = 0.0001; // Точность сравнения дробных чисел
begin
  Result := (dev1.basename = dev2.basename) and
            (dev1.realname = dev2.realname) and
            (Abs(dev1.power - dev2.power) < EPSILON) and
            (dev1.voltage = dev2.voltage) and
            (Abs(dev1.cosfi - dev2.cosfi) < EPSILON) and
            (dev1.phase = dev2.phase);
end;

// Создает родительский узел группы для feedernum (уровень 1)
function TVstDevPopulator.CreateGroupNode(const device: TVElectrDevStruct): PVirtualNode;
begin
  Result := FVstDev.AddChild(nil);
  FillGroupNodeData(Result, device);
  // Устанавливаем флаг vsHasChildren для отображения индикаторов +/-
  //Include(Result^.States, vsHasChildren);
end;

// Создает узел подгруппы устройств с одинаковыми атрибутами (уровень 2)
function TVstDevPopulator.CreateDeviceGroupNode(ParentNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;
begin
  Result := FVstDev.AddChild(ParentNode);
  FillDeviceGroupNodeData(Result, device);
end;

// Создает дочерний узел устройства под группой
function TVstDevPopulator.CreateDeviceNode(GroupNode: PVirtualNode; const device: TVElectrDevStruct): PVirtualNode;
begin
  Result := FVstDev.AddChild(GroupNode);
  FillDeviceNodeData(Result, device);
end;

// Заполняет данные узла группы (уровень 1 - по feedernum)
procedure TVstDevPopulator.FillGroupNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);
var
  NodeData: PGridNodeData;
begin
  NodeData := FVstDev.GetNodeData(Node);
  NodeData^.DevName := device.headdev+'-Гр.' + IntToStr(device.feedernum);
  NodeData^.RealName := '';
  NodeData^.Power := 0;
  NodeData^.CosF := 0;
  NodeData^.Voltage := 0;
  NodeData^.Phase := '';
  NodeData^.HDName := '';
  NodeData^.HDGroup := 0;
  NodeData^.PathHD := '';
  NodeData^.FullPathHD := '';
end;

// Заполняет данные узла подгруппы устройств (уровень 2 - по атрибутам)
procedure TVstDevPopulator.FillDeviceGroupNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);
var
  NodeData: PGridNodeData;
begin
  NodeData := FVstDev.GetNodeData(Node);
  // Для подгруппы отображаем основные атрибуты, по которым группируются устройства
  NodeData^.DevName := device.basename;
  NodeData^.RealName := device.realname;
  NodeData^.Power := device.power;
  NodeData^.CosF := device.cosfi;
  NodeData^.Voltage := device.voltage;
  NodeData^.Phase := device.phase;
  NodeData^.HDName := '';
  NodeData^.HDGroup := 0;
  NodeData^.PathHD := '';
  NodeData^.FullPathHD := '';
end;

// Заполняет данные узла устройства
procedure TVstDevPopulator.FillDeviceNodeData(Node: PVirtualNode; const device: TVElectrDevStruct);
var
  NodeData: PGridNodeData;
  tempName:string;
  i:integer;
begin

  NodeData := FVstDev.GetNodeData(Node);
  tempName := '';
  for i := 0 to deepConnectDev - 1 do
    tempName := tempName + ' -';
  if deepConnectDev > 0 then
      NodeData^.DevName := tempName + ' ' + device.basename + ' (гр.' + inttostr(device.feedernum) + ')'
    else
      NodeData^.DevName := device.basename;
  //NodeData^.DevName := device.basename;
  NodeData^.RealName := device.realname;
  NodeData^.Power := device.power;
  NodeData^.CosF := device.cosfi;
  NodeData^.Voltage := device.voltage;
  NodeData^.Phase := device.phase;
  NodeData^.HDName := device.headdev;
  NodeData^.HDGroup := device.feedernum;
  NodeData^.PathHD := device.pathHD;
  NodeData^.FullPathHD := device.fullpathHD;
end;

// Основной метод для заполнения дерева устройств
// Создает 2-уровневую иерархию:
// Уровень 1: группы по feedernum
// Уровень 2: подгруппы по одинаковым basename, realname, Power, Voltage, cosF, Phase
//            (создается ТОЛЬКО если есть 2+ устройства с одинаковыми атрибутами)
// Устройства без совпадений добавляются напрямую в Level 1
procedure TVstDevPopulator.PopulateTree(const filterPath: string);
var
  i: integer;
  Level1Node: PVirtualNode;        // Узел уровня 1 (по feedernum)
  Level2Node: PVirtualNode;        // Узел уровня 2 (по атрибутам)
  device: TVElectrDevStruct;
  nextDevice: TVElectrDevStruct;
  groupDev: TVElectrDevStruct;
  nextGroupDev: TVElectrDevStruct;
  lastFeederNum: integer;
  lastDeviceInLevel2: TVElectrDevStruct;  // Последнее устройство в подгруппе уровня 2
  isFirstDevice: boolean;
  inLevel2Group: boolean;          // Флаг: находимся ли в режиме группировки уровня 2
  hasNextDevice: boolean;
  shouldCreateLevel2: boolean;

begin
  // Получаем отфильтрованный список устройств для избежания обработки ненужных данных
  filteredDevices := GetFilteredDevicesList(filterPath);
  try
    try
      FVstDev.BeginUpdate;
      try
        FVstDev.Clear;

        // Инициализация переменных для отслеживания групп
        lastFeederNum := -1;
        Level1Node := nil;
        Level2Node := nil;
        isFirstDevice := True;
        inLevel2Group := False;

        // Проходим только по отфильтрованным устройствам
        for i := 0 to filteredDevices.Size - 1 do
        begin
          device := filteredDevices[i];

          deepConnectDev := ProcessStrings(filterPath, device.fullpathHD);
          if (deepConnectDev = 0) then
            groupDev := device;

          // Проверяем, нужно ли создать новый узел уровня 1 (по feedernum)
          if isFirstDevice or (groupDev.feedernum <> lastFeederNum) then
          begin
            Level1Node := CreateGroupNode(groupDev);
            lastFeederNum := groupDev.feedernum;
            isFirstDevice := False;
            inLevel2Group := False; // Сброс режима группировки при смене Level 1
          end;

          // Проверяем наличие следующего устройства
          hasNextDevice := (i + 1 < filteredDevices.Size);

          // Определяем, нужно ли создавать группу уровня 2
          shouldCreateLevel2 := False;

          if hasNextDevice then
          begin
            nextDevice := filteredDevices[i + 1];

            // Определяем groupDev для следующего устройства
            if (ProcessStrings(filterPath, nextDevice.fullpathHD) = 0) then
              nextGroupDev := nextDevice
            else
              nextGroupDev := groupDev; // Используем текущий groupDev если deepConnectDev > 0

            // Проверяем, совпадают ли текущее и следующее устройство
            // Они должны быть в одной группе Level 1 и иметь одинаковые атрибуты
            if (groupDev.feedernum = nextGroupDev.feedernum) and
               DevicesHaveSameAttributes(device, nextDevice) then
            begin
              // Есть совпадение со следующим устройством
              // Создаем новую группу Level 2, если не находимся в режиме группировки
              // или если атрибуты изменились с предыдущей группы
              if not inLevel2Group or not DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
              begin
                Level2Node := CreateDeviceGroupNode(Level1Node, device);
                inLevel2Group := True;
              end;

              // Добавляем устройство в группу Level 2
              CreateDeviceNode(Level2Node, device);
              lastDeviceInLevel2 := device;
            end
            else
            begin
              // Нет совпадения со следующим устройством
              // Проверяем, находимся ли в режиме группировки с предыдущими устройствами
              if inLevel2Group and DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
              begin
                // Это последнее устройство в текущей группе Level 2
                CreateDeviceNode(Level2Node, device);
              end
              else
              begin
                // Одиночное устройство - добавляем напрямую в Level 1
                CreateDeviceNode(Level1Node, device);
              end;

              // Выходим из режима группировки
              inLevel2Group := False;
            end;
          end
          else
          begin
            // Это последнее устройство в списке
            // Проверяем, находимся ли в режиме группировки
            if inLevel2Group and DevicesHaveSameAttributes(device, lastDeviceInLevel2) then
            begin
              // Добавляем в текущую группу Level 2
              CreateDeviceNode(Level2Node, device);
            end
            else
            begin
              // Одиночное устройство - добавляем напрямую в Level 1
              CreateDeviceNode(Level1Node, device);
            end;
          end;
        end;

        // Разворачиваем все группы для удобства просмотра
        FVstDev.FullExpand;
      finally
        FVstDev.EndUpdate;
      end;
    except
      on E: Exception do
        raise Exception.Create('Ошибка загрузки данных: ' + E.Message);
    end;
  finally
    // Освобождаем отфильтрованный список
    filteredDevices.Free;
  end;
end;

end.
